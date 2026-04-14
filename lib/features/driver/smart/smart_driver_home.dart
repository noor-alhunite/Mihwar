import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:msar_flutter/l10n/app_localizations.dart';

import '../../../app/app.dart';
import '../../../core/bootstrap/demo_bootstrap.dart';
import '../../../core/config/zarqa_karama_area.dart';
import '../../../core/models/bin.dart';
import '../../../core/models/bin_visit_record.dart';
import '../../../core/models/operations_enums.dart';
import '../../../core/models/route_planning_models.dart';
import '../../../core/models/truck_model.dart';
import '../../../core/repositories/repositories_provider.dart';
import '../../../core/routing/street_graph_router.dart';
import '../../../core/services/simulated_telemetry_service.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/language_switch_button.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../auth/providers/auth_controller.dart';
import '../controllers/driver_trip_controller.dart';
import '../data/osrm_routing_service.dart';

enum _TripPhase { idle, optimizing, routing, moving, awaitingService, completed }

class SmartDriverHome extends ConsumerStatefulWidget {
  const SmartDriverHome({super.key, required this.driverId});

  final String driverId;

  @override
  ConsumerState<SmartDriverHome> createState() => _SmartDriverHomeState();
}

class _SmartDriverHomeState extends ConsumerState<SmartDriverHome>
    with TickerProviderStateMixin {
  static const Distance _distance = Distance();
  static final LatLng _startPoint = const LatLng(
    ZarqaKaramaArea.startLat,
    ZarqaKaramaArea.startLng,
  );

  final MapController _mapController = MapController();
  final DriverTripController _tripController = DriverTripController(startPoint: _startPoint);

  late final SimulatedTelemetryService _telemetry = SimulatedTelemetryService(
    locationRepository: ref.read(driverLocationRepositoryProvider),
  );

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 860),
  )..repeat(reverse: true);

  AnimationController? _movementController;

  _TripPhase _phase = _TripPhase.idle;
  bool _loading = false;
  bool _tripRunning = false;
  final bool _simulateDeviation = false;
  Set<int> _servedBinIds = <int>{};
  List<BinModel> _assignedBins = <BinModel>[];
  List<BinModel> _predictedBins = <BinModel>[];
  // ignore: unused_field - kept for possible future use (e.g. road type in ordering)
  List<RoadSegmentRecord> _roadSegments = <RoadSegmentRecord>[];
  final Map<String, OsrmRouteResult> _legCache = <String, OsrmRouteResult>{};
  // ignore: unused_field - kept for possible future use (e.g. truck type in UI)
  TruckModel? _truck;
  int _visitCursor = 0;
  // ignore: unused_field - accumulated during animation; completion dialog uses _routePolylineDistanceMeters()
  double _totalMeters = 0;
  DateTime _lastTelemetryTick = DateTime.fromMillisecondsSinceEpoch(0);
  List<double> _tripDeviationMeters = <double>[];
  int? _finalCompliancePercent;

  /// Map is hidden until route/bin data is loaded so the first frame has correct local zoom.
  bool _startupCameraReady = false;
  LatLng _startupCenter = _startPoint;
  double _startupZoom = ZarqaKaramaArea.defaultZoom;

  /// Selected daily round for driver 1001 only (1..4). null = no round selected yet (user must choose).
  int? _selectedRound;

  /// Incremented when starting a round apply; used to ignore stale async results if user switches round.
  int _roundApplyToken = 0;

  /// Round for which bins and legs have been applied (1..4). null = none applied. Start Trip enabled only when _appliedRound == _selectedRound.
  int? _appliedRound;

  /// Route polylines for current round (driver 1001 only). From OSRM real-road routing (router.project-osrm.org).
  List<List<LatLng>> _fixedLegPolylines = <List<LatLng>>[];

  /// Cache for street-path distance (from->to key) for permutation search. For 1001 filled with OSRM distances.
  final Map<String, double> _streetDistanceCache = <String, double>{};

  /// OSRM routing for smart driver (1001) only. Real road polylines and distances.
  final OsrmRoutingService _osrmRouting = OsrmRoutingService();
  static const Duration _osrmTimeout = Duration(seconds: 12);

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    if (mounted) setState(() => _loading = widget.driverId != '1001');
    unawaited(
      _loadRouteData().then((bool applied) {
        if (!mounted) return;
        if (applied) {
          setState(() => _loading = false);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _fitToInitialView();
            });
          });
        } else if (widget.driverId == '1001') {
          setState(() => _loading = false);
        }
      }).catchError((Object e, StackTrace st) {
        if (mounted) setState(() => _loading = false);
      }),
    );
  }

  @override
  void dispose() {
    _movementController?.dispose();
    _pulseController.dispose();
    _tripController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const SizedBox.shrink(),
        actions: [
          const LanguageSwitchButton(),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: Theme.of(context).colorScheme.surfaceContainerLow,
              ),
              child: Text('${l10n.compliance_label}: ${_displayCompliancePercent()}%'),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
              context.go(AppRoutes.login);
            },
            icon: const Icon(Icons.logout, size: 18),
            label: Text(l10n.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: _startupCameraReady
                ? FlutterMap(
                    key: ValueKey('smart_driver_map'),
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _startupCenter,
                      initialZoom: _startupZoom,
                      minZoom: 12,
                      maxZoom: 17,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                    ),
                    children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'msar_flutter',
                    ),
                    ValueListenableBuilder<RouteRenderState>(
                      valueListenable: _tripController.routeStateListenable,
                      builder: (context, route, _) {
                        final List<Polyline> completed = route.completedPolylines
                            .where((line) => line.length >= 2)
                            .map(
                              (line) => Polyline(
                                points: line,
                                color: AppColors.primary.withValues(alpha: 0.45),
                                strokeWidth: 5,
                              ),
                            )
                            .toList();
                        final List<Polyline> current = route.currentPolyline.length >= 2
                            ? [
                                Polyline(
                                  points: route.currentPolyline,
                                  color: AppColors.primary,
                                  strokeWidth: 6,
                                ),
                              ]
                            : [];
                        return PolylineLayer(polylines: [...completed, ...current]);
                      },
                    ),
                    MarkerLayer(markers: _buildBinMarkers()),
                    ValueListenableBuilder<TruckPose>(
                      valueListenable: _tripController.truckPoseListenable,
                      builder: (context, truck, _) => MarkerLayer(
                        markers: [
                          Marker(
                            point: truck.position,
                            width: 48,
                            height: 48,
                            child: const _TruckMarker(),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                : Container(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: AppCard(
                  child: AnimatedBuilder(
                    animation: _tripController,
                    builder: (context, _) => _buildBottomCard(l10n),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const List<String> _roundLabels = <String>['جولة 1', 'جولة 2', 'جولة 3', 'جولة 4'];

  /// Start Trip is enabled only when the current round is fully ready: not loading, bins and legs applied for selected round, every leg valid.
  bool get _canStartSmartTrip {
    if (_loading || _predictedBins.isEmpty) return false;
    if (widget.driverId != '1001') return true;
    if (_selectedRound == null) return false;
    if (_fixedLegPolylines.isEmpty || _appliedRound != _selectedRound) return false;
    if (_fixedLegPolylines.any((List<LatLng> leg) => leg.length < 2)) return false;
    return true;
  }

  /// Round chips: enabled when no round selected or round failed (choose again); disabled only while loading or after a successful load.
  Widget _buildRoundSelector() {
    final bool locked = _loading || (_selectedRound != null && _appliedRound == _selectedRound);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: IgnorePointer(
        ignoring: locked,
        child: Opacity(
          opacity: locked ? 0.7 : 1.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List<Widget>.generate(4, (int i) {
              final int round = i + 1;
              final bool selected = _selectedRound != null && _selectedRound == round;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: FilterChip(
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _roundLabels[i],
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                    selected: selected,
                    onSelected: (bool value) {
                      if (locked) return;
                      if (!value) return;
                      setState(() {
                        _selectedRound = round;
                        _predictedBins = <BinModel>[];
                        _fixedLegPolylines = <List<LatLng>>[];
                        _loading = true;
                        _appliedRound = null;
                      });
                      _tripController.reset(_startPoint);
                      _legCache.clear();
                      _streetDistanceCache.clear();
                      _servedBinIds = <int>{};
                      _visitCursor = 0;
                      unawaited(_applyRoundSelection(round));
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  /// Single round-load entry point. Only this method may apply bins/legs/loading/appliedRound.
  /// Returns true iff it applied state (requestId still current). Stale requests do nothing and return false.
  Future<bool> _loadRoundData(int round, int requestId) async {
    if (round < 1 || round > 4) return false;
    _legCache.clear();
    _streetDistanceCache.clear();

    List<BinModel> binsForRound = _getStaticBinsForRound(round);
    binsForRound = _deduplicateBinsById(binsForRound);
    if (binsForRound.isEmpty) {
      if (mounted && _selectedRound == round && _roundApplyToken == requestId) {
        setState(() {
          _selectedRound = null;
          _predictedBins = <BinModel>[];
          _fixedLegPolylines = <List<LatLng>>[];
          _loading = false;
          _appliedRound = null;
        });
        _tripController.reset(_startPoint);
        return true;
      }
      return false;
    }

    await _fetchOsrmDistancesForRound(binsForRound);
    if (!mounted || _selectedRound != round || _roundApplyToken != requestId) return false;
    final List<BinModel> bestOrder = _computeBestVisitOrderStreet(binsForRound);
    final List<List<LatLng>> streetLegs = (round == 3 || round == 4)
        ? await _buildOsrmLegPolylinesForOrderedBinsSequential(bestOrder)
        : await _buildOsrmLegPolylinesForOrderedBins(bestOrder);
    if (!mounted || _selectedRound != round || _roundApplyToken != requestId) return false;
    final bool legsValid = streetLegs.isNotEmpty && streetLegs.every((List<LatLng> leg) => leg.length >= 2);
    if (!legsValid) {
      if (mounted && _selectedRound == round && _roundApplyToken == requestId) {
        setState(() {
          _selectedRound = null;
          _predictedBins = <BinModel>[];
          _fixedLegPolylines = <List<LatLng>>[];
          _loading = false;
          _appliedRound = null;
        });
        _tripController.reset(_startPoint);
        return true;
      }
      return false;
    }
    if (!mounted || _selectedRound != round || _roundApplyToken != requestId) return false;
    setState(() {
      _predictedBins = List<BinModel>.from(bestOrder);
      _fixedLegPolylines = streetLegs;
      _tripController.setVisitOrder(_predictedBins);
      _loading = false;
      _appliedRound = round;
    });
    _fitToInitialView();
    return true;
  }

  /// Round selection: load the tapped round only. On failure or exception, reset to recoverable state so user can select another round.
  Future<void> _applyRoundSelection(int round) async {
    if (widget.driverId != '1001') return;
    if (round < 1 || round > 4) return;
    final int requestId = ++_roundApplyToken;
    unawaited(
      _loadRoundData(round, requestId).catchError((Object e, StackTrace st) {
        if (mounted) {
          setState(() {
            _selectedRound = null;
            _predictedBins = <BinModel>[];
            _fixedLegPolylines = <List<LatLng>>[];
            _loading = false;
            _appliedRound = null;
          });
          _tripController.reset(_startPoint);
          _legCache.clear();
          _streetDistanceCache.clear();
        }
        return false;
      }),
    );
  }

  List<Marker> _buildBinMarkers() {
    final Set<int> priorityIds = _predictedBins.map((b) => b.id).toSet();
    return _assignedBins.map((bin) {
      final bool priority = priorityIds.contains(bin.id);
      final bool served = _servedBinIds.contains(bin.id);
      final bool current = _tripController.routeState.currentTarget?.id == bin.id;
      final Color color = served
          ? const Color(0xFF1F6F43)
          : priority
              ? const Color(0xFF0A4D8C)
              : const Color(0xFF6CBF84);
      final double opacity = priority ? 0.96 : 0.35;
      final double scale = current ? (0.9 + (_pulseController.value * 0.2)) : 1.0;
      return Marker(
        point: LatLng(bin.lat, bin.lng),
        width: 44,
        height: 44,
        child: Opacity(
          opacity: opacity,
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 180),
            child: Icon(
              served ? Icons.check_circle_rounded : Icons.delete_outline_rounded,
              color: color,
              size: 34,
            ),
          ),
        ),
      );
    }).toList(growable: false);
  }

  static const String _pleaseChooseRoundMessage = 'يرجى اختيار جولة';

  Widget _buildBottomCard(AppLocalizations l10n) {
    if (_phase == _TripPhase.idle) {
      final bool is1001 = widget.driverId == '1001';
      final bool beforeChoice = is1001 && _selectedRound == null;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (beforeChoice) ...[
            Text(_pleaseChooseRoundMessage, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
          ] else ...[
            Text(l10n.smart_hint_start_trip, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.smart_hint_priority_bins, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 2),
            Text(l10n.smart_hint_diesel_shortest_visual, style: Theme.of(context).textTheme.bodySmall),
          ],
          if (is1001) ...[
            const SizedBox(height: 6),
            _buildRoundSelector(),
            const SizedBox(height: 4),
          ],
          if (_loading) ...[
            const SizedBox(height: 6),
            const LinearProgressIndicator(minHeight: 2),
          ],
          const SizedBox(height: 6),
          PrimaryButton(
            label: l10n.start_trip,
            onPressed: _canStartSmartTrip ? _startTrip : null,
          ),
        ],
      );
    }

    if (_phase == _TripPhase.awaitingService) {
      final BinModel? target = _tripController.routeState.currentTarget;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            target == null ? l10n.bin_status_update : '${l10n.today_route}: ${target.label}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(l10n.bin_status_modal, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          PrimaryButton(
            label: l10n.serviced,
            onPressed: target == null ? null : () => _confirmServiced(target),
          ),
        ],
      );
    }

    final int total = _predictedBins.length;
    final int completed = _servedBinIds.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _phase == _TripPhase.completed ? l10n.trip_completed_title : l10n.today_route,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(value: total == 0 ? 0 : completed / total),
        const SizedBox(height: 4),
        Text('${l10n.completed_stops}: $completed/$total', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  /// Loads repo data (_assignedBins, etc.). For driver 1001, runs the single round loader for initial round 1. No other apply path.
  Future<bool> _loadRouteData() async {
    await DemoBootstrap.ensureInitialized();
    final binsRepo = ref.read(binsRepositoryProvider);
    final routeRepo = ref.read(routePlanningRepositoryProvider);
    final trucksRepo = ref.read(trucksRepositoryProvider);

    final List<Object?> results = await Future.wait(<Future<Object?>>[
      binsRepo.getBinsByDriver(widget.driverId),
      routeRepo.getRoadSegments(),
      trucksRepo.getAllTrucks(),
    ]);
    _assignedBins = results[0]! as List<BinModel>;
    _roadSegments = results[1]! as List<RoadSegmentRecord>;
    final List<TruckModel> trucks = results[2]! as List<TruckModel>;
    _truck = trucks.where((t) => t.driverId == widget.driverId).cast<TruckModel?>().firstWhere(
      (t) => t != null,
      orElse: () => null,
    );

    if (widget.driverId == '1001') {
      _computeStartupCamera();
      return false;
    }
    if (mounted) {
      setState(() {
        _predictedBins = <BinModel>[];
        _fixedLegPolylines = <List<LatLng>>[];
        _appliedRound = null;
      });
    }
    _computeStartupCamera();
    return true;
  }

  /// Fixed bin labels per round (جولة 1, جولة 2). Defines which bins are in each round; visit order is computed by shortest street path.
  static const List<String> _demoRound1OrderedLabels = <String>['BIN-015', 'BIN-004', 'BIN-006'];
  static const List<String> _demoRound2OrderedLabels = <String>['BIN-011', 'BIN-012', 'BIN-007', 'BIN-020'];
  /// Round 3: 2 commercial (BIN-011, BIN-015), 3 residential_dense (BIN-004, BIN-006, BIN-009), 1 residential_quiet (BIN-017).
  static const List<String> _demoRound3OrderedLabels = <String>['BIN-011', 'BIN-015', 'BIN-004', 'BIN-006', 'BIN-009', 'BIN-017'];
  /// Round 4: 3 commercial (BIN-011, BIN-012, BIN-015), 2 residential_dense (BIN-007, BIN-009) — farthest pair.
  static const List<String> _demoRound4OrderedLabels = <String>['BIN-011', 'BIN-012', 'BIN-015', 'BIN-007', 'BIN-009'];

  /// Removes duplicate bins by id; keeps first occurrence.
  static List<BinModel> _deduplicateBinsById(List<BinModel> bins) {
    if (bins.length <= 1) return bins;
    final List<BinModel> out = <BinModel>[];
    final Set<int> seen = <int>{};
    for (final BinModel b in bins) {
      if (seen.add(b.id)) out.add(b);
    }
    return out;
  }

  static String _streetCacheKey(LatLng from, LatLng to) =>
      '${from.latitude},${from.longitude}->${to.latitude},${to.longitude}';

  /// Street-path distance in meters. For driver 1001 uses OSRM distances (cache pre-filled by _fetchOsrmDistancesForRound).
  /// For other drivers uses local StreetGraphRouter. Returns double.infinity if unavailable.
  double _streetPathDistance(LatLng from, LatLng to) {
    final String key = _streetCacheKey(from, to);
    final double? cached = _streetDistanceCache[key];
    if (cached != null) return cached;
    if (widget.driverId == '1001') return double.infinity;
    final List<LatLng> poly =
        StreetGraphRouter.shortestPathPolylineStreetOnly(from: from, to: to);
    final double d = poly.isEmpty ? double.infinity : _polylineLength(poly);
    _streetDistanceCache[key] = d;
    return d;
  }

  /// Total street-path distance for tour: start -> order[0] -> order[1] -> ... -> order[n-1].
  double _tourStreetDistance(List<BinModel> order) {
    if (order.isEmpty) return 0;
    double total = _streetPathDistance(_startPoint, LatLng(order[0].lat, order[0].lng));
    for (int i = 0; i < order.length - 1; i++) {
      final double leg = _streetPathDistance(
        LatLng(order[i].lat, order[i].lng),
        LatLng(order[i + 1].lat, order[i + 1].lng),
      );
      if (leg == double.infinity) return double.infinity;
      total += leg;
    }
    return total;
  }

  /// Best visit order by brute-force over permutations; cost = total street-path distance (not Haversine).
  /// Returns the permutation with minimum _tourStreetDistance; same order is used for route and truck.
  List<BinModel> _computeBestVisitOrderStreet(List<BinModel> bins) {
    bins = _deduplicateBinsById(bins);
    if (bins.isEmpty || bins.length == 1) return bins;
    final int n = bins.length;
    List<BinModel> bestOrder = List<BinModel>.from(bins);
    double bestDist = _tourStreetDistance(bestOrder);
    void permute(List<BinModel> a, int l, int r) {
      if (l == r) {
        final double d = _tourStreetDistance(a);
        if (d < bestDist && d < double.infinity) {
          bestDist = d;
          bestOrder = List<BinModel>.from(a);
        }
        return;
      }
      for (int i = l; i <= r; i++) {
        final BinModel t = a[l];
        a[l] = a[i];
        a[i] = t;
        permute(a, l + 1, r);
        a[i] = a[l];
        a[l] = t;
      }
    }
    permute(List<BinModel>.from(bins), 0, n - 1);
    return bestOrder;
  }

  /// Fetches OSRM road distances for all pairs needed for permutation (start->each bin, bin_i->bin_j). Fills _streetDistanceCache.
  /// For 5+ bins (Round 4, Round 3) uses sequential fetch so all distances are filled reliably and shortest-order quality matches other rounds.
  Future<void> _fetchOsrmDistancesForRound(List<BinModel> bins) async {
    _streetDistanceCache.clear();
    if (bins.length >= 5) {
      await _fetchOsrmDistancesForRoundSequential(bins);
      return;
    }
    final LatLng start = _startPoint;
    final List<Future<void>> tasks = <Future<void>>[];
    for (final BinModel b in bins) {
      final LatLng to = LatLng(b.lat, b.lng);
      tasks.add(
        _osrmRouting.roadDistanceMeters(start, to).timeout(_osrmTimeout).then(
          (double d) => _streetDistanceCache[_streetCacheKey(start, to)] = d,
          onError: (_) => _streetDistanceCache[_streetCacheKey(start, to)] = double.infinity,
        ),
      );
    }
    for (int i = 0; i < bins.length; i++) {
      for (int j = 0; j < bins.length; j++) {
        if (i == j) continue;
        final LatLng from = LatLng(bins[i].lat, bins[i].lng);
        final LatLng to = LatLng(bins[j].lat, bins[j].lng);
        tasks.add(
          _osrmRouting.roadDistanceMeters(from, to).timeout(_osrmTimeout).then(
            (double d) => _streetDistanceCache[_streetCacheKey(from, to)] = d,
            onError: (_) => _streetDistanceCache[_streetCacheKey(from, to)] = double.infinity,
          ),
        );
      }
    }
    await Future.wait(tasks);
  }

  /// Round 3 (6 bins), Round 4 (5 bins): fetch OSRM distances sequentially so no request is dropped; cache is complete for true shortest order.
  Future<void> _fetchOsrmDistancesForRoundSequential(List<BinModel> bins) async {
    final LatLng start = _startPoint;
    for (final BinModel b in bins) {
      final LatLng to = LatLng(b.lat, b.lng);
      double d = double.infinity;
      try {
        d = await _osrmRouting.roadDistanceMeters(start, to).timeout(_osrmTimeout);
      } catch (_) {
        try {
          d = await _osrmRouting.roadDistanceMeters(start, to).timeout(_osrmTimeout);
        } catch (_) {}
      }
      _streetDistanceCache[_streetCacheKey(start, to)] = d;
    }
    for (int i = 0; i < bins.length; i++) {
      for (int j = 0; j < bins.length; j++) {
        if (i == j) continue;
        final LatLng from = LatLng(bins[i].lat, bins[i].lng);
        final LatLng to = LatLng(bins[j].lat, bins[j].lng);
        double d = double.infinity;
        try {
          d = await _osrmRouting.roadDistanceMeters(from, to).timeout(_osrmTimeout);
        } catch (_) {
          try {
            d = await _osrmRouting.roadDistanceMeters(from, to).timeout(_osrmTimeout);
          } catch (_) {}
        }
        _streetDistanceCache[_streetCacheKey(from, to)] = d;
      }
    }
  }

  /// Builds route legs using OSRM (real roads). One leg per bin: start->bin1, bin1->bin2, ...
  /// Fetches all legs in parallel to reduce loading time. Returns [] if any leg fails. No fake fallback.
  Future<List<List<LatLng>>> _buildOsrmLegPolylinesForOrderedBins(List<BinModel> orderedBins) async {
    if (orderedBins.isEmpty) return <List<LatLng>>[];
    LatLng from = _startPoint;
    final List<Future<OsrmRouteResult>> legFutures = <Future<OsrmRouteResult>>[];
    for (int i = 0; i < orderedBins.length; i++) {
      final LatLng to = LatLng(orderedBins[i].lat, orderedBins[i].lng);
      legFutures.add(_osrmRouting.routePolyline(from, to).timeout(_osrmTimeout));
      from = to;
    }
    try {
      final List<OsrmRouteResult> results = await Future.wait(legFutures);
      final List<List<LatLng>> legs = <List<LatLng>>[];
      for (final OsrmRouteResult result in results) {
        if (result.points.length < 2) return <List<LatLng>>[];
        legs.add(result.points);
      }
      return legs;
    } catch (_) {
      return <List<LatLng>>[];
    }
  }

  /// Round 3 (6 legs), Round 4 (5 legs): build OSRM legs sequentially to avoid timeout/rate limit with many parallel requests. Same OSRM API, so route follows real streets.
  /// Retries each failed leg once so one transient OSRM failure does not leave the round permanently unready.
  Future<List<List<LatLng>>> _buildOsrmLegPolylinesForOrderedBinsSequential(List<BinModel> orderedBins) async {
    if (orderedBins.isEmpty) return <List<LatLng>>[];
    LatLng from = _startPoint;
    final List<List<LatLng>> legs = <List<LatLng>>[];
    for (int i = 0; i < orderedBins.length; i++) {
      final LatLng to = LatLng(orderedBins[i].lat, orderedBins[i].lng);
      OsrmRouteResult? result;
      try {
        result = await _osrmRouting.routePolyline(from, to).timeout(_osrmTimeout);
      } catch (_) {
        try {
          result = await _osrmRouting.routePolyline(from, to).timeout(_osrmTimeout);
        } catch (_) {
          return <List<LatLng>>[];
        }
      }
      if (result.points.length < 2) return <List<LatLng>>[];
      legs.add(result.points);
      from = to;
    }
    return legs;
  }

  /// Resolves the set of bins for the round from assigned bins (by label). Visit order is computed by _computeBestVisitOrderStreet.
  List<BinModel> _getStaticBinsForRound(int round) {
    final List<String> labels = switch (round) {
      2 => _demoRound2OrderedLabels,
      3 => _demoRound3OrderedLabels,
      4 => _demoRound4OrderedLabels,
      _ => _demoRound1OrderedLabels,
    };
    final Map<String, BinModel> byLabel = <String, BinModel>{
      for (final BinModel b in _assignedBins) b.label: b,
    };
    final List<BinModel> result = <BinModel>[];
    for (final String label in labels) {
      final BinModel? bin = byLabel[label];
      if (bin != null) result.add(bin);
    }
    return result;
  }

  Future<void> _startTrip() async {
    setState(() {
      _tripRunning = true;
      _servedBinIds = <int>{};
      _visitCursor = 0;
      _totalMeters = 0;
      _tripDeviationMeters = <double>[];
      _finalCompliancePercent = null;
      _phase = _TripPhase.optimizing;
    });
    _telemetry.reset();
    _telemetry.setSimulateDeviation(_simulateDeviation);
    _tripController.reset(_startPoint);
    _tripController.setVisitOrder(_predictedBins);
    if (widget.driverId == '1001' &&
        _fixedLegPolylines.isNotEmpty &&
        _fixedLegPolylines[0].isNotEmpty) {
      _tripController.updateTruckPose(
        position: _fixedLegPolylines[0].first,
        bearingRadians: _tripController.truckPose.bearingRadians,
      );
    }
    if (_predictedBins.isNotEmpty) {
      _fitToPoints(<LatLng>[
        _startPoint,
        LatLng(_predictedBins.first.lat, _predictedBins.first.lng),
      ]);
    }
    await _goToNextBin();
  }

  Future<void> _goToNextBin() async {
    if (!mounted || !_tripRunning) {
      return;
    }
    if (_visitCursor >= _predictedBins.length) {
      await _onTripComplete();
      return;
    }
    setState(() => _phase = _TripPhase.routing);
    final BinModel nextBin = _predictedBins[_visitCursor];
    final LatLng from = _tripController.truckPose.position;
    final LatLng target = LatLng(nextBin.lat, nextBin.lng);

    // Driver 1001: use only pre-built legs from OSRM (real road routing).
    // No straight-line segments; truck follows the street graph only.
    List<LatLng> legPoints;
    bool usedFallback = true;
    if (widget.driverId == '1001' &&
        _fixedLegPolylines.isNotEmpty &&
        _visitCursor < _fixedLegPolylines.length) {
      legPoints = _fixedLegPolylines[_visitCursor];
    } else {
      final int? fromBinId = _visitCursor > 0 ? _predictedBins[_visitCursor - 1].id : null;
      final OsrmRouteResult leg = await _buildLegAsync(
        from,
        target,
        fromBinId: fromBinId,
        toBinId: nextBin.id,
      );
      legPoints = leg.points;
      usedFallback = leg.usedFallback;
    }

    if (!mounted || !_tripRunning) return;

    _tripController.setCurrentSegment(
      targetIndex: _visitCursor,
      target: nextBin,
      polyline: legPoints,
      usedFallback: usedFallback,
    );
    _fitToPoints(legPoints, focusPoint: from);
    setState(() => _phase = _TripPhase.moving);
    final LatLng animationEnd = (widget.driverId == '1001' && legPoints.isNotEmpty)
        ? legPoints.last
        : target;
    await _animateTruckAlongRoute(legPoints, animationEnd);
    if (!mounted || !_tripRunning) {
      return;
    }
    _tripController.setAwaitingStatus(true);
    setState(() => _phase = _TripPhase.awaitingService);
  }

  Future<void> _confirmServiced(BinModel bin) async {
    await ref.read(visitsRepositoryProvider).addVisit(
      BinVisitRecord(
        binId: bin.id,
        status: BinStatus.full,
        visitedAt: DateTime.now(),
        driverId: widget.driverId,
        latitude: bin.lat,
        longitude: bin.lng,
      ),
    );
    _servedBinIds.add(bin.id);
    _visitCursor += 1;
    _tripController.completeCurrentSegment();
    if (mounted) {
      setState(() {});
    }
    await _goToNextBin();
  }

  Future<void> _animateTruckAlongRoute(List<LatLng> route, LatLng target) async {
    final List<LatLng> sampled = _resamplePolyline(route, stepMeters: 8);
    if (sampled.length < 2) {
      _tripController.updateTruckPose(
        position: target,
        bearingRadians: _tripController.truckPose.bearingRadians,
      );
      return;
    }

    final double totalMeters = _polylineLength(sampled);
    final int durationMs = (totalMeters / 18 * 1000).clamp(1000, 8000).round();
    _movementController?.dispose();
    final AnimationController controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    );
    _movementController = controller;
    final Animation<double> curve = CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    void listener() {
      final double progress = curve.value * (sampled.length - 1);
      final int i = progress.floor().clamp(0, sampled.length - 2);
      final double t = progress - i;
      final LatLng a = sampled[i];
      final LatLng b = sampled[i + 1];
      LatLng current = LatLng(
        a.latitude + ((b.latitude - a.latitude) * t),
        a.longitude + ((b.longitude - a.longitude) * t),
      );
      if (_simulateDeviation) {
        current = LatLng(current.latitude + 0.0001, current.longitude - 0.00008);
      }
      _totalMeters += _distance(_tripController.truckPose.position, current);
      _tripController.updateTruckPose(
        position: current,
        bearingRadians: _tripController.truckPose.bearingRadians,
      );
      _captureTelemetry(current);
    }

    controller.addListener(listener);
    await controller.forward();
    controller.removeListener(listener);
    controller.dispose();
    _movementController = null;

    _tripController.updateTruckPose(
      position: target,
      bearingRadians: _tripController.truckPose.bearingRadians,
    );
    _captureTelemetry(target, force: true);
  }

  void _captureTelemetry(LatLng point, {bool force = false}) {
    final DateTime now = DateTime.now();
    if (!force && now.difference(_lastTelemetryTick).inMilliseconds < 1100) {
      return;
    }
    _lastTelemetryTick = now;
    final List<LatLng> plannedPath = <LatLng>[
      ..._tripController.routeState.currentPolyline,
      ..._tripController.routeState.completedPolylines.expand((x) => x),
    ];
    final double deviation = _distanceFromPathMeters(
      point: point,
      path: plannedPath,
    );
    _tripDeviationMeters.add(deviation);
    unawaited(
      _telemetry.capturePoint(
        routeDate: _formatDate(now),
        driverId: widget.driverId,
        truckPosition: point,
        plannedPathPoints: plannedPath,
        now: now,
      ).then((_) {
        if (mounted) {
          setState(() {});
        }
      }).catchError((_) {
        // Keep trip progression resilient if telemetry persistence fails.
      }),
    );
  }

  /// Min zoom when fitting so the map never zooms out too far during the trip.
  static const double _fitMinZoom = 14.5;
  static const double _fitMaxZoom = 17.0;
  /// Min zoom for initial startup fit only; slightly lower for balanced local view.
  static const double _initialFitMinZoom = 13.4;
  /// Max points used for bounds when fitting; keeps focus on current segment.
  static const int _fitMaxPointsForBounds = 18;
  /// Max bins to include in initial fit so we do not fit to whole city.
  static const int _initialFitMaxBins = 14;
  /// Extra bottom padding when fitting so route/bins stay visible above the bottom card.
  static const double _fitBottomPadding = 140;

  /// Computes startup center and zoom from local points; call when route data is loaded.
  /// Map is not shown until this runs so the first frame has correct local zoom.
  void _computeStartupCamera() {
    final List<LatLng> points = <LatLng>[_startPoint];
    if (_predictedBins.isNotEmpty) {
      for (final BinModel b in _predictedBins) {
        points.add(LatLng(b.lat, b.lng));
      }
    } else if (_assignedBins.isNotEmpty) {
      final int take = math.min(_initialFitMaxBins, _assignedBins.length);
      for (int i = 0; i < take; i++) {
        points.add(LatLng(_assignedBins[i].lat, _assignedBins[i].lng));
      }
    }
    if (points.length >= 2) {
      final LatLngBounds bounds = LatLngBounds.fromPoints(points);
      _startupCenter = bounds.center;
      _startupZoom = _initialFitMinZoom;
    } else {
      _startupCenter = _startPoint;
      _startupZoom = _initialFitMinZoom;
    }
    _startupCameraReady = true;
  }

  /// Fits camera to working area (start + predicted/assigned bins). Call after map is ready.
  void _fitToInitialView() {
    final List<LatLng> points = <LatLng>[_startPoint];
    if (_predictedBins.isNotEmpty) {
      for (final BinModel b in _predictedBins) {
        points.add(LatLng(b.lat, b.lng));
      }
    } else if (_assignedBins.isNotEmpty) {
      final int take = math.min(_initialFitMaxBins, _assignedBins.length);
      for (int i = 0; i < take; i++) {
        points.add(LatLng(_assignedBins[i].lat, _assignedBins[i].lng));
      }
    }
    if (points.length >= 2) {
      _fitToPoints(
        points,
        focusPoint: _startPoint,
        padding: const EdgeInsets.only(left: 24, right: 24, top: 28, bottom: _fitBottomPadding),
        minZoom: _initialFitMinZoom,
      );
    } else {
      try {
        _mapController.move(_startPoint, _initialFitMinZoom);
      } catch (_) {}
    }
  }

  void _fitToPoints(List<LatLng> points, {LatLng? focusPoint, EdgeInsets? padding, double? minZoom}) {
    if (points.isEmpty && focusPoint == null) {
      return;
    }
    if (points.length < 2 && focusPoint == null) {
      return;
    }
    try {
      final List<LatLng> forBounds = <LatLng>[];
      if (focusPoint != null) {
        forBounds.add(focusPoint);
      }
      if (points.length <= _fitMaxPointsForBounds) {
        forBounds.addAll(points);
      } else {
        forBounds.add(points.first);
        forBounds.addAll(points.sublist(1, _fitMaxPointsForBounds - 1));
        forBounds.add(points.last);
      }
      final LatLngBounds bounds = LatLngBounds.fromPoints(forBounds);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        ),
      );
      final double minZ = minZoom ?? _fitMinZoom;
      final double zoom = _mapController.camera.zoom.clamp(minZ, _fitMaxZoom);
      _mapController.move(_mapController.camera.center, zoom);
    } catch (_) {
      // Ignore first-frame map timing issues on web.
    }
  }

  /// Demo: local routing only (StreetGraphRouter). No OSRM network calls.
  Future<OsrmRouteResult> _buildLegAsync(
    LatLng from,
    LatLng to, {
    int? fromBinId,
    required int toBinId,
  }) async {
    final String cacheKey =
        '${fromBinId ?? -1}->$toBinId|${from.latitude.toStringAsFixed(5)},${from.longitude.toStringAsFixed(5)}';
    final OsrmRouteResult? cached = _legCache[cacheKey];
    if (cached != null) return cached;

    final List<LatLng> path = StreetGraphRouter.shortestPathPolyline(from: from, to: to);
    final List<LatLng> safePoints = path.isEmpty
        ? <LatLng>[]
        : (path.length >= 3
            ? path
            : StreetGraphRouter.densify(path, stepMeters: 18));
    final OsrmRouteResult result = OsrmRouteResult(
      points: safePoints,
      distanceMeters: _polylineLength(safePoints),
      usedFallback: true,
    );
    _legCache[cacheKey] = result;
    return result;
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  int _displayCompliancePercent() {
    if (_phase == _TripPhase.completed) {
      return _finalCompliancePercent ?? 0;
    }
    return 0;
  }

  double _computeFinalCompliance({
    required int predictedStops,
    required int servicedStops,
    required double avgDeviationMeters,
  }) {
    if (predictedStops <= 0) {
      return 0;
    }
    const double perfectDeviationGraceMeters = 35;
    if (servicedStops == predictedStops && avgDeviationMeters <= perfectDeviationGraceMeters) {
      return 100;
    }
    const double thresholdMeters = 50;
    final double deviationPenalty = (avgDeviationMeters / thresholdMeters).clamp(0, 1) * 100;
    final double stopScore = (servicedStops / predictedStops) * 100;
    return (stopScore - deviationPenalty).clamp(0, 100).toDouble();
  }

  double _distanceFromPathMeters({
    required LatLng point,
    required List<LatLng> path,
  }) {
    if (path.isEmpty) {
      return 0;
    }
    double minMeters = double.infinity;
    for (final LatLng routePoint in path) {
      final double d = _distance(point, routePoint);
      if (d < minMeters) {
        minMeters = d;
      }
    }
    return minMeters.isFinite ? minMeters : 0;
  }

  /// Total distance in meters along the route polyline (same polylines used to animate the truck).
  /// For driver 1001 uses _fixedLegPolylines; otherwise uses tripController completed + current polylines.
  double _routePolylineDistanceMeters() {
    if (widget.driverId == '1001' && _fixedLegPolylines.isNotEmpty) {
      double total = 0;
      for (final List<LatLng> leg in _fixedLegPolylines) {
        total += _polylineLength(leg);
      }
      return total;
    }
    final RouteRenderState state = _tripController.routeState;
    double total = 0;
    for (final List<LatLng> line in state.completedPolylines) {
      total += _polylineLength(line);
    }
    total += _polylineLength(state.currentPolyline);
    return total;
  }

  Future<void> _onTripComplete() async {
    final int predictedStops = _predictedBins.length;
    final int servicedStops = _servedBinIds.length;
    final double avgDeviation = _tripDeviationMeters.isEmpty
        ? 0
        : (_tripDeviationMeters.reduce((a, b) => a + b) / _tripDeviationMeters.length);
    _finalCompliancePercent = _computeFinalCompliance(
      predictedStops: predictedStops,
      servicedStops: servicedStops,
      avgDeviationMeters: avgDeviation,
    ).round();
    setState(() {
      _phase = _TripPhase.completed;
      _tripRunning = false;
    });
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.trip_completed_title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.trip_completed_message),
              const SizedBox(height: 8),
              Text('${l10n.compliance_label}: ${_finalCompliancePercent ?? 0}%'),
              const SizedBox(height: 8),
              Text('${l10n.distance_traveled}: ${(_routePolylineDistanceMeters() / 1000).toStringAsFixed(2)} km'),
            ],
          ),
          actions: [
            PrimaryButton(
              label: l10n.exit_label,
              onPressed: () {
                _tripController.reset(_startPoint);
                _servedBinIds = <int>{};
                _visitCursor = 0;
                ref.read(authControllerProvider.notifier).logout();
                Navigator.of(context).pop();
                if (mounted) {
                  context.go(AppRoutes.login);
                }
              },
            ),
          ],
        );
      },
    );
  }

  List<LatLng> _resamplePolyline(List<LatLng> points, {double stepMeters = 8}) {
    if (points.length < 2) {
      return points;
    }
    final double total = _polylineLength(points);
    final int count = math.max(2, (total / stepMeters).round() + 1);
    final List<LatLng> out = <LatLng>[];
    for (int i = 0; i < count; i++) {
      final double target = total * (i / (count - 1));
      out.add(_pointAtDistance(points, target));
    }
    return out;
  }

  double _polylineLength(List<LatLng> points) {
    double total = 0;
    for (int i = 0; i < points.length - 1; i++) {
      total += _distance(points[i], points[i + 1]);
    }
    return total;
  }

  LatLng _pointAtDistance(List<LatLng> points, double targetMeters) {
    double walked = 0;
    for (int i = 0; i < points.length - 1; i++) {
      final LatLng a = points[i];
      final LatLng b = points[i + 1];
      final double seg = _distance(a, b);
      if (walked + seg >= targetMeters) {
        final double t = (targetMeters - walked) / seg;
        return LatLng(
          a.latitude + ((b.latitude - a.latitude) * t),
          a.longitude + ((b.longitude - a.longitude) * t),
        );
      }
      walked += seg;
    }
    return points.last;
  }

}

class _TruckMarker extends StatelessWidget {
  const _TruckMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99),
        boxShadow: const [
          BoxShadow(
            color: Color(0x331F6F43),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(
        Icons.local_shipping_rounded,
        color: Color(0xFF1F6F43),
        size: 32,
      ),
    );
  }
}
