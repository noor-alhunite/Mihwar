import 'package:latlong2/latlong.dart';

import '../models/bin.dart';
import '../models/route_planning_models.dart';

class RoadLegRouter {
  const RoadLegRouter._();

  static const Distance _distance = Distance();

  static List<LatLng> buildLegPolyline({
    required LatLng from,
    required LatLng to,
    required List<RoadSegmentRecord> roadSegments,
    required List<BinModel> bins,
    int? fromBinId,
    int? toBinId,
  }) {
    final Map<int, BinModel> binsById = <int, BinModel>{
      for (final BinModel bin in bins) bin.id: bin,
    };
    final Map<int, List<_Edge>> graph = _buildGraph(roadSegments, binsById);

    final int? startId = _resolveNearestNodeId(
      preferredId: fromBinId,
      point: from,
      binsById: binsById,
      graph: graph,
    );
    final int? endId = _resolveNearestNodeId(
      preferredId: toBinId,
      point: to,
      binsById: binsById,
      graph: graph,
    );
    if (startId == null || endId == null) {
      return densify(_streetFallback(from: from, to: to, seed: ((fromBinId ?? 0) * 1000) + (toBinId ?? 0)));
    }

    final List<_Edge> edges = _shortestPathEdges(graph: graph, fromId: startId, toId: endId);
    if (edges.isEmpty) {
      return densify(_streetFallback(from: from, to: to, seed: ((fromBinId ?? 0) * 1000) + (toBinId ?? 0)));
    }

    final List<LatLng> nodes = <LatLng>[from];
    for (final _Edge edge in edges) {
      final List<LatLng> edgePoints = edge.forward ? edge.points : edge.points.reversed.toList(growable: false);
      if (edgePoints.isEmpty) {
        continue;
      }
      if (_distance(nodes.last, edgePoints.first) > 1.0) {
        nodes.add(edgePoints.first);
      }
      for (int i = 1; i < edgePoints.length; i++) {
        nodes.add(edgePoints[i]);
      }
    }
    if (_distance(nodes.last, to) > 1.0) {
      nodes.add(to);
    }
    return densify(_dedupe(nodes));
  }

  static List<LatLng> densify(List<LatLng> points, {double stepMeters = 10}) {
    if (points.length < 2) {
      return points;
    }
    final List<LatLng> out = <LatLng>[points.first];
    for (int i = 0; i < points.length - 1; i++) {
      final LatLng a = points[i];
      final LatLng b = points[i + 1];
      final double segMeters = _distance(a, b);
      final int steps = (segMeters / stepMeters).clamp(3, 30).round();
      for (int s = 1; s <= steps; s++) {
        final double t = s / steps;
        out.add(
          LatLng(
            a.latitude + ((b.latitude - a.latitude) * t),
            a.longitude + ((b.longitude - a.longitude) * t),
          ),
        );
      }
    }
    return _dedupe(out);
  }

  static Map<int, List<_Edge>> _buildGraph(
    List<RoadSegmentRecord> roadSegments,
    Map<int, BinModel> binsById,
  ) {
    final Map<int, List<_Edge>> graph = <int, List<_Edge>>{};
    for (final RoadSegmentRecord segment in roadSegments) {
      final BinModel? from = binsById[segment.fromBinId];
      final BinModel? to = binsById[segment.toBinId];
      if (from == null || to == null) {
        continue;
      }
      final List<LatLng> polyline = segment.polylinePoints == null || segment.polylinePoints!.isEmpty
          ? _streetFallback(
              from: LatLng(from.lat, from.lng),
              to: LatLng(to.lat, to.lng),
              seed: (segment.fromBinId * 97) + segment.toBinId,
            )
          : segment.polylinePoints!;
      graph
          .putIfAbsent(segment.fromBinId, () => <_Edge>[])
          .add(
            _Edge(
              from: segment.fromBinId,
              to: segment.toBinId,
              distanceKm: segment.distanceKm,
              points: _dedupe(polyline),
              forward: true,
            ),
          );
      graph
          .putIfAbsent(segment.toBinId, () => <_Edge>[])
          .add(
            _Edge(
              from: segment.toBinId,
              to: segment.fromBinId,
              distanceKm: segment.distanceKm,
              points: _dedupe(polyline),
              forward: false,
            ),
          );
    }
    return graph;
  }

  static List<_Edge> _shortestPathEdges({
    required Map<int, List<_Edge>> graph,
    required int fromId,
    required int toId,
  }) {
    if (!graph.containsKey(fromId) || !graph.containsKey(toId)) {
      return const <_Edge>[];
    }
    final Set<int> unvisited = <int>{...graph.keys};
    final Map<int, double> dist = <int, double>{for (final int id in graph.keys) id: double.infinity};
    final Map<int, _Edge?> prev = <int, _Edge?>{};
    dist[fromId] = 0;

    while (unvisited.isNotEmpty) {
      int? node;
      double best = double.infinity;
      for (final int id in unvisited) {
        final double value = dist[id]!;
        if (value < best) {
          best = value;
          node = id;
        }
      }
      if (node == null || best == double.infinity) {
        break;
      }
      if (node == toId) {
        break;
      }
      unvisited.remove(node);
      for (final _Edge edge in graph[node]!) {
        if (!unvisited.contains(edge.to)) {
          continue;
        }
        final double next = dist[node]! + edge.distanceKm;
        if (next < dist[edge.to]!) {
          dist[edge.to] = next;
          prev[edge.to] = edge;
        }
      }
    }
    if (dist[toId] == null || dist[toId] == double.infinity) {
      return const <_Edge>[];
    }
    final List<_Edge> rev = <_Edge>[];
    int cursor = toId;
    while (cursor != fromId) {
      final _Edge? edge = prev[cursor];
      if (edge == null) {
        return const <_Edge>[];
      }
      rev.add(edge);
      cursor = edge.from;
    }
    return rev.reversed.toList(growable: false);
  }

  static int? _resolveNearestNodeId({
    required int? preferredId,
    required LatLng point,
    required Map<int, BinModel> binsById,
    required Map<int, List<_Edge>> graph,
  }) {
    if (preferredId != null && binsById.containsKey(preferredId) && graph.containsKey(preferredId)) {
      return preferredId;
    }
    int? nearestId;
    double nearest = double.infinity;
    for (final MapEntry<int, BinModel> entry in binsById.entries) {
      if (!graph.containsKey(entry.key)) {
        continue;
      }
      final double d = _distance(point, LatLng(entry.value.lat, entry.value.lng));
      if (d < nearest) {
        nearest = d;
        nearestId = entry.key;
      }
    }
    return nearestId;
  }

  static List<LatLng> _streetFallback({
    required LatLng from,
    required LatLng to,
    required int seed,
  }) {
    final double latDelta = to.latitude - from.latitude;
    final double lngDelta = to.longitude - from.longitude;
    final double turnA = ((seed % 9) - 4) * 0.00003;
    final double turnB = (((seed ~/ 9) % 9) - 4) * 0.00003;
    final LatLng p1 = LatLng(from.latitude + (latDelta * 0.25), from.longitude + (lngDelta * 0.10) + turnA);
    final LatLng p2 = LatLng(from.latitude + (latDelta * 0.48) + turnB, from.longitude + (lngDelta * 0.45));
    final LatLng p3 = LatLng(from.latitude + (latDelta * 0.72), from.longitude + (lngDelta * 0.78) - turnA);
    return _dedupe(<LatLng>[from, p1, p2, p3, to]);
  }

  static List<LatLng> _dedupe(List<LatLng> points) {
    if (points.length < 2) {
      return points;
    }
    final List<LatLng> out = <LatLng>[points.first];
    for (int i = 1; i < points.length; i++) {
      final LatLng a = out.last;
      final LatLng b = points[i];
      if ((a.latitude - b.latitude).abs() < 0.0000001 &&
          (a.longitude - b.longitude).abs() < 0.0000001) {
        continue;
      }
      out.add(b);
    }
    return out;
  }
}

class _Edge {
  const _Edge({
    required this.from,
    required this.to,
    required this.distanceKm,
    required this.points,
    required this.forward,
  });

  final int from;
  final int to;
  final double distanceKm;
  final List<LatLng> points;
  final bool forward;
}
