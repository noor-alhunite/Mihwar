import 'package:latlong2/latlong.dart';

import '../models/bin.dart';
import '../models/route_planning_models.dart';

class ShortestPathBuilder {
  const ShortestPathBuilder._();

  static const Distance _distance = Distance();

  static List<LatLng> buildPathPolyline({
    required LatLng from,
    required LatLng to,
    required List<BinModel> bins,
    required List<RoadSegmentRecord> segments,
    int? fromBinId,
    required int toBinId,
  }) {
    final Map<int, List<({int to, double distance})>> graph = _buildGraph(segments);
    final Map<int, BinModel> binsById = <int, BinModel>{
      for (final BinModel bin in bins) bin.id: bin,
    };
    final int? resolvedFromId = _resolveFromNodeId(
      fromBinId: fromBinId,
      from: from,
      binsById: binsById,
      graph: graph,
    );
    if (resolvedFromId == null || !binsById.containsKey(toBinId) || !graph.containsKey(toBinId)) {
      return _streetLikeFallback(from: from, to: to, seed: (fromBinId ?? 0) * 1000 + toBinId);
    }
    final List<int> nodePath = _shortestPathIds(
      fromId: resolvedFromId,
      toId: toBinId,
      graph: graph,
    );
    if (nodePath.isEmpty) {
      return _streetLikeFallback(from: from, to: to, seed: (fromBinId ?? 0) * 1000 + toBinId);
    }
    final List<LatLng> nodesPolyline = <LatLng>[from];
    for (final int nodeId in nodePath) {
      final BinModel? bin = binsById[nodeId];
      if (bin != null) {
        nodesPolyline.add(LatLng(bin.lat, bin.lng));
      }
    }
    if (_distance(nodesPolyline.last, to) > 1.0) {
      nodesPolyline.add(to);
    }
    return _interpolatePath(_dedupeConsecutive(nodesPolyline));
  }

  static Map<int, List<({int to, double distance})>> _buildGraph(
    List<RoadSegmentRecord> segments,
  ) {
    final Map<int, List<({int to, double distance})>> graph =
        <int, List<({int to, double distance})>>{};
    for (final RoadSegmentRecord edge in segments) {
      graph.putIfAbsent(edge.fromBinId, () => <({int to, double distance})>[]).add(
        (to: edge.toBinId, distance: edge.distanceKm),
      );
      graph.putIfAbsent(edge.toBinId, () => <({int to, double distance})>[]).add(
        (to: edge.fromBinId, distance: edge.distanceKm),
      );
    }
    return graph;
  }

  static int? _resolveFromNodeId({
    required int? fromBinId,
    required LatLng from,
    required Map<int, BinModel> binsById,
    required Map<int, List<({int to, double distance})>> graph,
  }) {
    if (fromBinId != null && binsById.containsKey(fromBinId) && graph.containsKey(fromBinId)) {
      return fromBinId;
    }
    int? nearestId;
    double nearestMeters = double.infinity;
    for (final MapEntry<int, BinModel> entry in binsById.entries) {
      if (!graph.containsKey(entry.key)) {
        continue;
      }
      final double meters = _distance(from, LatLng(entry.value.lat, entry.value.lng));
      if (meters < nearestMeters) {
        nearestMeters = meters;
        nearestId = entry.key;
      }
    }
    return nearestId;
  }

  static List<int> _shortestPathIds({
    required int fromId,
    required int toId,
    required Map<int, List<({int to, double distance})>> graph,
  }) {
    if (!graph.containsKey(fromId) || !graph.containsKey(toId)) {
      return const <int>[];
    }

    final Set<int> unvisited = <int>{...graph.keys};
    final Map<int, double> dist = <int, double>{for (final int id in graph.keys) id: double.infinity};
    final Map<int, int?> prev = <int, int?>{};
    dist[fromId] = 0;

    while (unvisited.isNotEmpty) {
      int? current;
      double best = double.infinity;
      for (final int id in unvisited) {
        final double score = dist[id]!;
        if (score < best) {
          best = score;
          current = id;
        }
      }
      if (current == null || best == double.infinity) {
        break;
      }
      if (current == toId) {
        break;
      }
      unvisited.remove(current);
      final List<({int to, double distance})> neighbors = graph[current]!;
      for (final ({int to, double distance}) edge in neighbors) {
        if (!unvisited.contains(edge.to)) {
          continue;
        }
        final double next = dist[current]! + edge.distance;
        if (next < dist[edge.to]!) {
          dist[edge.to] = next;
          prev[edge.to] = current;
        }
      }
    }

    if (dist[toId] == null || dist[toId] == double.infinity) {
      return const <int>[];
    }
    final List<int> path = <int>[toId];
    int? node = prev[toId];
    while (node != null) {
      path.add(node);
      node = prev[node];
    }
    return path.reversed.toList(growable: false);
  }

  static List<LatLng> _interpolatePath(List<LatLng> points) {
    if (points.length < 2) {
      return points;
    }
    final List<LatLng> out = <LatLng>[points.first];
    for (int i = 0; i < points.length - 1; i++) {
      final LatLng a = points[i];
      final LatLng b = points[i + 1];
      final double meters = _distance(a, b);
      final int steps = (meters / 14).clamp(6, 28).round();
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
    return _dedupeConsecutive(out);
  }

  static List<LatLng> _streetLikeFallback({
    required LatLng from,
    required LatLng to,
    required int seed,
  }) {
    final double latDelta = to.latitude - from.latitude;
    final double lngDelta = to.longitude - from.longitude;
    final double direction = (seed & 1) == 0 ? 1 : -1;
    final double jitter = 0.00012 + ((seed.abs() % 5) * 0.00003);
    final LatLng midA = LatLng(
      from.latitude + (latDelta * 0.35) + (jitter * direction),
      from.longitude + (lngDelta * 0.28),
    );
    final LatLng midB = LatLng(
      from.latitude + (latDelta * 0.68),
      from.longitude + (lngDelta * 0.70) - (jitter * direction),
    );
    return _dedupeConsecutive(<LatLng>[from, midA, midB, to]);
  }

  static List<LatLng> _dedupeConsecutive(List<LatLng> points) {
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
