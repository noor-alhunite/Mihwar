import 'package:latlong2/latlong.dart';

import '../config/zarqa_karama_area.dart';

class StreetNode {
  const StreetNode({
    required this.id,
    required this.p,
  });

  final int id;
  final LatLng p;
}

class StreetEdge {
  const StreetEdge({
    required this.fromId,
    required this.toId,
    required this.distanceMeters,
    required this.shapePoints,
  });

  final int fromId;
  final int toId;
  final double distanceMeters;
  final List<LatLng> shapePoints;
}

class StreetGraph {
  const StreetGraph({
    required this.nodes,
    required this.adjacency,
  });

  final Map<int, StreetNode> nodes;
  final Map<int, List<StreetEdge>> adjacency;
}

class StreetGraphRouter {
  const StreetGraphRouter._();

  static const Distance _distance = Distance();
  static final StreetGraph _graph = _buildDemoStreetGraph();

  /// Max distance (meters) from a point to its nearest graph node. If either end of a leg
  /// is farther than this, the route is rejected to avoid long fake L-shaped connectors.
  /// Demo graph has ~160 m grid spacing; 180 m allows bins inside a cell to snap to the nearest node.
  static const double maxSnapDistanceMeters = 180;

  /// When true, last call's snap distances and rejection reason are available for debugging.
  static bool debugLastSnapRejected = false;
  static double debugLastSnapFromMeters = 0;
  static double debugLastSnapToMeters = 0;

  static StreetGraph _buildDemoStreetGraph() {
    const int cols = 10;
    const int rows = 8;
    final Map<int, StreetNode> nodes = <int, StreetNode>{};
    final Map<int, List<StreetEdge>> adjacency = <int, List<StreetEdge>>{};
    final double latStep = (ZarqaKaramaArea.maxLat - ZarqaKaramaArea.minLat) / (rows - 1);
    final double lngStep = (ZarqaKaramaArea.maxLng - ZarqaKaramaArea.minLng) / (cols - 1);

    int nodeId(int r, int c) => (r * cols) + c + 1;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final int id = nodeId(r, c);
        final LatLng p = LatLng(
          ZarqaKaramaArea.minLat + (latStep * r),
          ZarqaKaramaArea.minLng + (lngStep * c),
        );
        nodes[id] = StreetNode(id: id, p: p);
        adjacency[id] = <StreetEdge>[];
      }
    }

    void addUndirectedEdge(int fromId, int toId) {
      final LatLng a = nodes[fromId]!.p;
      final LatLng b = nodes[toId]!.p;
      final double meters = _distance(a, b);
      final List<LatLng> shape = <LatLng>[a, b];
      adjacency[fromId]!.add(
        StreetEdge(fromId: fromId, toId: toId, distanceMeters: meters, shapePoints: shape),
      );
      adjacency[toId]!.add(
        StreetEdge(fromId: toId, toId: fromId, distanceMeters: meters, shapePoints: shape.reversed.toList(growable: false)),
      );
    }

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final int id = nodeId(r, c);
        if (c + 1 < cols) {
          addUndirectedEdge(id, nodeId(r, c + 1));
        }
        if (r + 1 < rows) {
          addUndirectedEdge(id, nodeId(r + 1, c));
        }
      }
    }

    return StreetGraph(nodes: nodes, adjacency: adjacency);
  }

  static LatLng snapToNearestNode(LatLng p) {
    final result = nearestNodeIdAndDistance(p);
    return _graph.nodes[result.id]!.p;
  }

  /// Returns the nearest graph node id and distance in meters. Used for explicit snap validation.
  static ({int id, double meters}) nearestNodeIdAndDistance(LatLng p) {
    int nearestId = _graph.nodes.values.first.id;
    double best = double.infinity;
    for (final StreetNode node in _graph.nodes.values) {
      final double d = _distance(p, node.p);
      if (d < best) {
        best = d;
        nearestId = node.id;
      }
    }
    return (id: nearestId, meters: best);
  }

  /// Short axis-aligned connector from [from] to [to] only if distance <= [maxMeters].
  /// Returns empty list if too long, so we do not accept long invalid connectors.
  static List<LatLng> _shortConnector(LatLng from, LatLng to, double maxMeters) {
    if (_distance(from, to) > maxMeters) return <LatLng>[];
    return _orthogonalConnector(from, to);
  }

  static List<LatLng> shortestPathPolyline({
    required LatLng from,
    required LatLng to,
  }) {
    debugLastSnapRejected = false;
    debugLastSnapFromMeters = 0;
    debugLastSnapToMeters = 0;

    final fromSnap = nearestNodeIdAndDistance(from);
    final toSnap = nearestNodeIdAndDistance(to);
    final int fromId = fromSnap.id;
    final int toId = toSnap.id;
    final double fromDist = fromSnap.meters;
    final double toDist = toSnap.meters;

    debugLastSnapFromMeters = fromDist;
    debugLastSnapToMeters = toDist;

    if (fromDist > maxSnapDistanceMeters || toDist > maxSnapDistanceMeters) {
      debugLastSnapRejected = true;
      return <LatLng>[];
    }

    final List<int> ids = _dijkstraNodePath(fromId: fromId, toId: toId);
    if (ids.isEmpty || ids.length < 2) {
      debugLastSnapRejected = true;
      return <LatLng>[];
    }

    final LatLng fromNode = _graph.nodes[fromId]!.p;
    final LatLng toNode = _graph.nodes[toId]!.p;
    final List<LatLng> edgePath = _edgePolylineForNodePath(ids);

    final List<LatLng> startConnector =
        _shortConnector(from, fromNode, maxSnapDistanceMeters);
    final List<LatLng> endConnector =
        _shortConnector(toNode, to, maxSnapDistanceMeters);

    final List<LatLng> polyline = <LatLng>[
      ...startConnector.isEmpty ? <LatLng>[fromNode] : startConnector,
      ...edgePath.skip(1),
      ...endConnector.length > 1 ? endConnector.skip(1) : <LatLng>[],
    ];
    return densify(_dedupe(polyline), stepMeters: 18);
  }

  /// Street-graph path only between snapped nodes (no connectors from/to original points).
  /// Use this when the truck and green route must stay on the street with no off-street movement.
  /// Same snap validation as [shortestPathPolyline]; returns [] if snap is invalid or no path.
  static List<LatLng> shortestPathPolylineStreetOnly({
    required LatLng from,
    required LatLng to,
  }) {
    debugLastSnapRejected = false;
    debugLastSnapFromMeters = 0;
    debugLastSnapToMeters = 0;

    final fromSnap = nearestNodeIdAndDistance(from);
    final toSnap = nearestNodeIdAndDistance(to);
    final int fromId = fromSnap.id;
    final int toId = toSnap.id;
    final double fromDist = fromSnap.meters;
    final double toDist = toSnap.meters;

    debugLastSnapFromMeters = fromDist;
    debugLastSnapToMeters = toDist;

    if (fromDist > maxSnapDistanceMeters || toDist > maxSnapDistanceMeters) {
      debugLastSnapRejected = true;
      return <LatLng>[];
    }

    final List<int> ids = _dijkstraNodePath(fromId: fromId, toId: toId);
    if (ids.isEmpty || ids.length < 2) {
      debugLastSnapRejected = true;
      return <LatLng>[];
    }

    final List<LatLng> edgePath = _edgePolylineForNodePath(ids);
    return densify(_dedupe(edgePath), stepMeters: 18);
  }

  static List<LatLng> densify(List<LatLng> points, {double stepMeters = 20}) {
    if (points.length < 2) {
      return points;
    }
    final List<LatLng> out = <LatLng>[points.first];
    for (int i = 0; i < points.length - 1; i++) {
      final LatLng a = points[i];
      final LatLng b = points[i + 1];
      final double segMeters = _distance(a, b);
      final int steps = (segMeters / stepMeters).clamp(2, 20).round();
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

  static List<int> _dijkstraNodePath({
    required int fromId,
    required int toId,
  }) {
    final Set<int> unvisited = <int>{..._graph.nodes.keys};
    final Map<int, double> dist = <int, double>{
      for (final int id in _graph.nodes.keys) id: double.infinity,
    };
    final Map<int, int?> prev = <int, int?>{};
    dist[fromId] = 0;

    while (unvisited.isNotEmpty) {
      int? current;
      double best = double.infinity;
      for (final int id in unvisited) {
        final double value = dist[id]!;
        if (value < best) {
          best = value;
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
      for (final StreetEdge edge in _graph.adjacency[current] ?? const <StreetEdge>[]) {
        if (!unvisited.contains(edge.toId)) {
          continue;
        }
        final double alt = dist[current]! + edge.distanceMeters;
        if (alt < dist[edge.toId]!) {
          dist[edge.toId] = alt;
          prev[edge.toId] = current;
        }
      }
    }

    if (dist[toId] == null || dist[toId] == double.infinity) {
      return const <int>[];
    }
    final List<int> revPath = <int>[toId];
    int? cursor = prev[toId];
    while (cursor != null) {
      revPath.add(cursor);
      cursor = prev[cursor];
    }
    return revPath.reversed.toList(growable: false);
  }

  static List<LatLng> _edgePolylineForNodePath(List<int> ids) {
    if (ids.length < 2) {
      return ids
          .map((id) => _graph.nodes[id]!.p)
          .toList(growable: false);
    }
    final List<LatLng> path = <LatLng>[_graph.nodes[ids.first]!.p];
    for (int i = 0; i < ids.length - 1; i++) {
      final int a = ids[i];
      final int b = ids[i + 1];
      final StreetEdge? edge = _graph.adjacency[a]
          ?.where((e) => e.toId == b)
          .cast<StreetEdge?>()
          .firstWhere((e) => e != null, orElse: () => null);
      if (edge == null) {
        path.add(_graph.nodes[b]!.p);
        continue;
      }
      path.addAll(edge.shapePoints.skip(1));
    }
    return _dedupe(path);
  }

  static List<LatLng> _orthogonalConnector(LatLng start, LatLng end) {
    if ((start.latitude - end.latitude).abs() < 0.0000001 &&
        (start.longitude - end.longitude).abs() < 0.0000001) {
      return <LatLng>[start];
    }
    final double latDelta = (start.latitude - end.latitude).abs();
    final double lngDelta = (start.longitude - end.longitude).abs();

    // Keep connectors street-like by moving axis-aligned into the graph node.
    if (lngDelta >= latDelta) {
      final double midLng = (start.longitude + end.longitude) / 2;
      return <LatLng>[
        start,
        LatLng(start.latitude, midLng),
        LatLng(end.latitude, midLng),
        end,
      ];
    }
    final double midLat = (start.latitude + end.latitude) / 2;
    return <LatLng>[
      start,
      LatLng(midLat, start.longitude),
      LatLng(midLat, end.longitude),
      end,
    ];
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
