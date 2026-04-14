import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
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
import '../../../core/repositories/repositories_provider.dart';
import '../../../core/routing/street_graph_router.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/language_switch_button.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../auth/providers/auth_controller.dart';
import '../controllers/driver_trip_controller.dart';
import '../data/osrm_routing_service.dart';

class TrainingDriverHome extends ConsumerStatefulWidget {
  const TrainingDriverHome({super.key, required this.driverId});

  final String driverId;

  @override
  ConsumerState<TrainingDriverHome> createState() => _TrainingDriverHomeState();
}

enum _TrainingPhase { idle, moving, awaitingStatus, completed }

class _TrainingDriverHomeState extends ConsumerState<TrainingDriverHome>
    with TickerProviderStateMixin {
  static const Distance _distance = Distance();
  static final LatLng _startPoint = const LatLng(
    ZarqaKaramaArea.startLat,
    ZarqaKaramaArea.startLng,
  );

  final Map<int, BinStatus> _latestStatus = <int, BinStatus>{};
  final MapController _mapController = MapController();
  final DriverTripController _tripController = DriverTripController(startPoint: _startPoint);
  final OsrmRoutingService _routingService = OsrmRoutingService();

  AnimationController? _movementController;
  List<BinModel> _bins = <BinModel>[];
  final Map<String, OsrmRouteResult> _legCache = <String, OsrmRouteResult>{};
  Set<int> _servedBinIds = <int>{};
  bool _loading = true;
  bool _tripRunning = false;
  int _cursor = 0;
  _TrainingPhase _phase = _TrainingPhase.idle;

  @override
  void initState() {
    super.initState();
    _loading = false;
    unawaited(_loadBins());
  }

  @override
  void dispose() {
    _movementController?.dispose();
    _tripController.dispose();
    super.dispose();
  }

  Future<void> _loadBins() async {
    await DemoBootstrap.ensureInitialized();
    final binsRepo = ref.read(binsRepositoryProvider);
    final List<BinModel> bins = (await binsRepo.getBinsByDriver(widget.driverId))
        .take(5)
        .toList(growable: false);
    if (!mounted) {
      return;
    }
    setState(() {
      _bins = bins;
      _legCache.clear();
    });
    _fitToPoints(<LatLng>[_startPoint, ..._bins.map((b) => LatLng(b.lat, b.lng))]);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.training_title),
        actions: [
          const LanguageSwitchButton(),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _startPoint,
                    initialZoom: ZarqaKaramaArea.defaultZoom,
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
                                color: AppColors.primary.withValues(alpha: 0.4),
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
                            child: const _TrainingTruckMarker(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: AppCard(child: _buildBottomCard(l10n)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  List<Marker> _buildBinMarkers() {
    return _bins.map((bin) {
      final bool served = _servedBinIds.contains(bin.id);
      return Marker(
        point: LatLng(bin.lat, bin.lng),
        width: 44,
        height: 44,
        child: Icon(
          served ? Icons.check_circle_rounded : Icons.delete_outline_rounded,
          color: const Color(0xFF1F6F43),
          size: 34,
        ),
      );
    }).toList(growable: false);
  }

  Widget _buildBottomCard(AppLocalizations l10n) {
    if (_phase == _TrainingPhase.idle) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.training_title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          PrimaryButton(
            label: l10n.training_start_trip,
            onPressed: _bins.isEmpty ? null : _startTrip,
          ),
        ],
      );
    }
    if (_phase == _TrainingPhase.awaitingStatus) {
      final BinModel? target = _tripController.routeState.currentTarget;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            target == null ? l10n.training_pick_status : '${l10n.bin_status}: ${target.label}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: target == null ? null : _pickStatusForCurrent,
            icon: const Icon(Icons.tune_rounded),
            label: Text(l10n.training_pick_status),
          ),
        ],
      );
    }
    final int done = _servedBinIds.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _phase == _TrainingPhase.completed ? l10n.training_completed : l10n.training_moving_next,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: _bins.isEmpty ? 0 : done / _bins.length),
        const SizedBox(height: 6),
        Text('${l10n.completed_stops}: $done/${_bins.length}'),
      ],
    );
  }

  Future<void> _pickStatusForCurrent() async {
    final BinModel? target = _tripController.routeState.currentTarget;
    if (target == null) {
      return;
    }
    final BinStatus? selected = await _showTrainingStatusPicker();
    if (selected == null || !mounted) {
      return;
    }
    await _recordTrainingStatus(target, selected);
  }

  Future<void> _startTrip() async {
    setState(() {
      _tripRunning = true;
      _cursor = 0;
      _servedBinIds = <int>{};
      _phase = _TrainingPhase.moving;
    });
    _tripController.reset(_startPoint);
    _tripController.setVisitOrder(_bins);
    if (_bins.isNotEmpty) {
      _fitToPoints(<LatLng>[_startPoint, LatLng(_bins.first.lat, _bins.first.lng)]);
    }
    await _goToNextBin();
  }

  Future<void> _goToNextBin() async {
    if (!mounted || !_tripRunning) {
      return;
    }
    if (_cursor >= _bins.length) {
      await _onTrainingComplete();
      return;
    }
    final BinModel target = _bins[_cursor];
    final LatLng from = _tripController.truckPose.position;
    final LatLng to = LatLng(target.lat, target.lng);
    final int? fromBinId = _cursor > 0 ? _bins[_cursor - 1].id : null;
    final OsrmRouteResult leg = await _buildLegAsync(
      from,
      to,
      fromBinId: fromBinId,
      toBinId: target.id,
    );
    if (!mounted || !_tripRunning) {
      return;
    }
    _tripController.setCurrentSegment(
      targetIndex: _cursor,
      target: target,
      polyline: leg.points,
      usedFallback: leg.usedFallback,
    );
    _fitToPoints(leg.points);
    setState(() => _phase = _TrainingPhase.moving);
    await _animateTruckAlongRoute(leg.points, to);
    if (!mounted || !_tripRunning) {
      return;
    }
    _tripController.setAwaitingStatus(true);
    setState(() => _phase = _TrainingPhase.awaitingStatus);
    await _pickStatusForCurrent();
  }

  Future<void> _onTrainingComplete() async {
    setState(() {
      _phase = _TrainingPhase.completed;
      _tripRunning = false;
    });
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.training_trip_ended),
        content: Text(l10n.training_trip_ended),
        actions: [
          PrimaryButton(
            label: l10n.exit_label,
            onPressed: () {
              _tripController.reset(_startPoint);
              _servedBinIds = <int>{};
              _cursor = 0;
              ref.read(authControllerProvider.notifier).logout();
              Navigator.of(context).pop();
              if (mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _recordTrainingStatus(BinModel bin, BinStatus status) async {
    await ref.read(visitsRepositoryProvider).addVisit(
      BinVisitRecord(
        binId: bin.id,
        status: status,
        visitedAt: DateTime.now(),
        driverId: widget.driverId,
        latitude: bin.lat,
        longitude: bin.lng,
      ),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _latestStatus[bin.id] = status;
      _servedBinIds.add(bin.id);
      _cursor += 1;
    });
    _tripController.completeCurrentSegment();
    await _goToNextBin();
  }

  Future<BinStatus?> _showTrainingStatusPicker() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<BinStatus>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        Widget tile(BinStatus status, String label, Color color, IconData icon) {
          return ListTile(
            leading: Icon(icon, color: color),
            title: Text(label),
            onTap: () => Navigator.of(context).pop(status),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.training_pick_status,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                tile(BinStatus.empty, l10n.empty, const Color(0xFF1F6F43), Icons.inbox_rounded),
                tile(BinStatus.half, l10n.half, const Color(0xFFE6A700), Icons.opacity_rounded),
                tile(BinStatus.full, l10n.full, const Color(0xFFD66B5E), Icons.warning_amber_rounded),
                tile(BinStatus.broken, l10n.broken, Colors.grey, Icons.build_circle_outlined),
              ],
            ),
          ),
        );
      },
    );
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
    final int durationMs = (totalMeters / 14 * 1000).clamp(900, 6200).round();
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
      final LatLng current = LatLng(
        a.latitude + ((b.latitude - a.latitude) * t),
        a.longitude + ((b.longitude - a.longitude) * t),
      );
      _tripController.updateTruckPose(
        position: current,
        bearingRadians: _tripController.truckPose.bearingRadians,
      );
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

  void _fitToPoints(List<LatLng> points) {
    if (points.length < 2) {
      return;
    }
    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(48),
        ),
      );
      final double clampedZoom = _mapController.camera.zoom.clamp(12.0, 17.0);
      _mapController.move(_mapController.camera.center, clampedZoom);
    } catch (_) {
      // Ignore first-frame map timing issues on web.
    }
  }

  /// OSRM is primary; StreetGraphRouter is last resort only when OSRM fails.
  static const Duration _osrmTimeout = Duration(seconds: 10);

  Future<OsrmRouteResult> _buildLegAsync(
    LatLng from,
    LatLng to, {
    int? fromBinId,
    required int toBinId,
  }) async {
    final String cacheKey =
        '${fromBinId ?? -1}->$toBinId|${from.latitude.toStringAsFixed(5)},${from.longitude.toStringAsFixed(5)}';
    final OsrmRouteResult? cached = _legCache[cacheKey];
    if (cached != null) {
      return cached;
    }

    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final OsrmRouteResult osrm = await _routingService
            .routePolyline(from, to)
            .timeout(_osrmTimeout);
        if (osrm.points.length >= 2 && osrm.distanceMeters > 0) {
          _legCache[cacheKey] = osrm;
          if (kDebugMode) {
            debugPrint('routing(training): OSRM used, points=${osrm.points.length}');
          }
          return osrm;
        }
        if (kDebugMode) {
          debugPrint(
            'routing(training): OSRM invalid, retry/fallback — points=${osrm.points.length}, distance=${osrm.distanceMeters}',
          );
        }
      } on Exception catch (e) {
        if (kDebugMode) {
          debugPrint('routing(training): OSRM attempt ${attempt + 1} failed: $e');
        }
      }
    }

    if (kDebugMode) {
      debugPrint('routing(training): using StreetGraphRouter as last fallback');
    }
    final List<LatLng> fallback = StreetGraphRouter.shortestPathPolyline(
      from: from,
      to: to,
    );
    final List<LatLng> safePoints = fallback.length >= 3
        ? fallback
        : StreetGraphRouter.densify(fallback, stepMeters: 18);
    final OsrmRouteResult result = OsrmRouteResult(
      points: safePoints,
      distanceMeters: _polylineLength(safePoints),
      usedFallback: true,
    );
    _legCache[cacheKey] = result;
    if (kDebugMode) {
      debugPrint('routing(training): StreetGraphRouter fallback, points=${safePoints.length}');
    }
    return result;
  }

}

class _TrainingTruckMarker extends StatelessWidget {
  const _TrainingTruckMarker();

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
