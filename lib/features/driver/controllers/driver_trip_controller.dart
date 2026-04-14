import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/models/bin.dart';

class TruckPose {
  const TruckPose({
    required this.position,
    required this.bearingRadians,
  });

  final LatLng position;
  final double bearingRadians;
}

class RouteRenderState {
  const RouteRenderState({
    required this.currentPolyline,
    required this.completedPolylines,
    required this.currentTarget,
    required this.showFallbackDebug,
    required this.isAwaitingStatus,
  });

  factory RouteRenderState.initial() => const RouteRenderState(
        currentPolyline: <LatLng>[],
        completedPolylines: <List<LatLng>>[],
        currentTarget: null,
        showFallbackDebug: false,
        isAwaitingStatus: false,
      );

  final List<LatLng> currentPolyline;
  final List<List<LatLng>> completedPolylines;
  final BinModel? currentTarget;
  final bool showFallbackDebug;
  final bool isAwaitingStatus;

  RouteRenderState copyWith({
    List<LatLng>? currentPolyline,
    List<List<LatLng>>? completedPolylines,
    BinModel? currentTarget,
    bool? showFallbackDebug,
    bool? isAwaitingStatus,
  }) {
    return RouteRenderState(
      currentPolyline: currentPolyline ?? this.currentPolyline,
      completedPolylines: completedPolylines ?? this.completedPolylines,
      currentTarget: currentTarget ?? this.currentTarget,
      showFallbackDebug: showFallbackDebug ?? this.showFallbackDebug,
      isAwaitingStatus: isAwaitingStatus ?? this.isAwaitingStatus,
    );
  }
}

class DriverTripController extends ChangeNotifier {
  DriverTripController({required LatLng startPoint})
      : _truckPose = ValueNotifier<TruckPose>(
          TruckPose(position: startPoint, bearingRadians: 0),
        ),
        _routeState = ValueNotifier<RouteRenderState>(RouteRenderState.initial());

  final ValueNotifier<TruckPose> _truckPose;
  final ValueNotifier<RouteRenderState> _routeState;

  int currentTargetIndex = -1;
  List<BinModel> visitOrder = <BinModel>[];

  ValueListenable<TruckPose> get truckPoseListenable => _truckPose;
  ValueListenable<RouteRenderState> get routeStateListenable => _routeState;
  TruckPose get truckPose => _truckPose.value;
  RouteRenderState get routeState => _routeState.value;

  void reset(LatLng startPoint) {
    currentTargetIndex = -1;
    visitOrder = <BinModel>[];
    _truckPose.value = TruckPose(position: startPoint, bearingRadians: 0);
    _routeState.value = RouteRenderState.initial();
    notifyListeners();
  }

  void setVisitOrder(List<BinModel> order) {
    visitOrder = order;
    notifyListeners();
  }

  void setCurrentSegment({
    required int targetIndex,
    required BinModel target,
    required List<LatLng> polyline,
    required bool usedFallback,
  }) {
    currentTargetIndex = targetIndex;
    _routeState.value = _routeState.value.copyWith(
      currentTarget: target,
      currentPolyline: polyline,
      showFallbackDebug: usedFallback,
      isAwaitingStatus: false,
    );
    notifyListeners();
  }

  void completeCurrentSegment() {
    final List<List<LatLng>> completed = [
      ..._routeState.value.completedPolylines,
      _routeState.value.currentPolyline,
    ];
    _routeState.value = _routeState.value.copyWith(
      completedPolylines: completed,
      currentPolyline: const <LatLng>[],
      isAwaitingStatus: false,
    );
    notifyListeners();
  }

  void setAwaitingStatus(bool value) {
    _routeState.value = _routeState.value.copyWith(isAwaitingStatus: value);
    notifyListeners();
  }

  void clearTarget() {
    _routeState.value = _routeState.value.copyWith(
      currentTarget: null,
      currentPolyline: const <LatLng>[],
      isAwaitingStatus: false,
    );
    notifyListeners();
  }

  void updateTruckPose({
    required LatLng position,
    required double bearingRadians,
  }) {
    _truckPose.value = TruckPose(
      position: position,
      bearingRadians: bearingRadians,
    );
  }

  @override
  void dispose() {
    _truckPose.dispose();
    _routeState.dispose();
    super.dispose();
  }
}
