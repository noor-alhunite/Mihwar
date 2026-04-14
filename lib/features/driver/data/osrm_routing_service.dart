import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class OsrmRouteResult {
  const OsrmRouteResult({
    required this.points,
    required this.distanceMeters,
    required this.usedFallback,
  });

  final List<LatLng> points;
  final double distanceMeters;
  final bool usedFallback;
}

class OsrmRoutingService {
  OsrmRoutingService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
            ));

  final Dio _dio;
  final Map<String, double> _distanceCache = <String, double>{};
  final Map<String, OsrmRouteResult> _routeCache = <String, OsrmRouteResult>{};

  String _cacheKey(LatLng from, LatLng to) =>
      '${from.latitude.toStringAsFixed(5)},${from.longitude.toStringAsFixed(5)}->${to.latitude.toStringAsFixed(5)},${to.longitude.toStringAsFixed(5)}';

  /// Fetches full (n x n) road distance matrix in one request via OSRM Table API.
  /// Returns matrix in meters; matrix[i][j] = distance from points[i] to points[j].
  /// Returns null if Table API is unavailable or fails (caller should fall back to per-cell or batched calls).
  Future<List<List<double>>?> roadDistanceMatrix(List<LatLng> points) async {
    if (points.length < 2) return null;
    try {
      final String coordinates = points
          .map((p) => '${p.longitude},${p.latitude}')
          .join(';');
      final Response<dynamic> response = await _dio.get(
        'https://router.project-osrm.org/table/v1/driving/$coordinates',
        queryParameters: const {'annotations': 'distance'},
      );
      final dynamic data = response.data;
      if (data is! Map<String, dynamic>) return null;
      if (data['code'] != 'Ok') return null;
      final dynamic dist = data['distances'];
      if (dist is! List<dynamic> || dist.length != points.length) return null;
      final List<List<double>> matrix = <List<double>>[];
      for (int i = 0; i < dist.length; i++) {
        final dynamic row = dist[i];
        if (row is! List<dynamic> || row.length != points.length) return null;
        matrix.add(
          row.map((e) => (e is num) ? e.toDouble() : 0.0).toList(),
        );
      }
      return matrix;
    } catch (_) {
      return null;
    }
  }

  Future<double> roadDistanceMeters(LatLng from, LatLng to) async {
    final String key = _cacheKey(from, to);
    final double? cached = _distanceCache[key];
    if (cached != null) {
      return cached;
    }

    try {
      final Response<dynamic> response = await _dio.get(
        'https://router.project-osrm.org/route/v1/driving/${from.longitude},${from.latitude};${to.longitude},${to.latitude}',
        queryParameters: const {
          'overview': 'false',
          'steps': 'false',
        },
      );

      final routes = response.data['routes'] as List<dynamic>;
      if (routes.isEmpty) {
        throw Exception('No routes');
      }
      final double distance = (routes.first['distance'] as num).toDouble();
      _distanceCache[key] = distance;
      return distance;
    } catch (_) {
      if (kDebugMode) {
        const Distance distance = Distance();
        return distance(from, to);
      }
      rethrow;
    }
  }

  Future<OsrmRouteResult> routePolyline(LatLng from, LatLng to) async {
    final String key = _cacheKey(from, to);
    final OsrmRouteResult? cached = _routeCache[key];
    if (cached != null) {
      return cached;
    }

    try {
      final Response<dynamic> response = await _dio.get(
        'https://router.project-osrm.org/route/v1/driving/${from.longitude},${from.latitude};${to.longitude},${to.latitude}',
        queryParameters: const {
          'overview': 'full',
          'geometries': 'geojson',
          'steps': 'true',
        },
      );

      if (response.statusCode != 200) {
        if (kDebugMode) {
          debugPrint('OSRM routePolyline: HTTP ${response.statusCode}');
        }
        throw Exception('OSRM HTTP ${response.statusCode}');
      }

      final dynamic data = response.data;
      if (data is! Map<String, dynamic>) {
        if (kDebugMode) debugPrint('OSRM routePolyline: invalid response body (not map)');
        throw Exception('OSRM invalid response body');
      }
      final routes = data['routes'];
      if (routes is! List<dynamic> || routes.isEmpty) {
        if (kDebugMode) debugPrint('OSRM routePolyline: no routes (code=${data['code']}, message=${data['message']})');
        throw Exception('OSRM no routes');
      }
      final Map<String, dynamic> route = routes.first as Map<String, dynamic>;
      final dynamic geometry = route['geometry'];
      if (geometry is! Map<String, dynamic>) {
        if (kDebugMode) debugPrint('OSRM routePolyline: missing or invalid geometry');
        throw Exception('OSRM missing geometry');
      }
      final dynamic coordinates = geometry['coordinates'];
      if (coordinates is! List<dynamic> || coordinates.length < 2) {
        if (kDebugMode) {
          debugPrint('OSRM routePolyline: missing or insufficient coordinates');
        }
        throw Exception('OSRM insufficient geometry points');
      }

      final List<LatLng> points = <LatLng>[];
      for (int i = 0; i < coordinates.length; i++) {
        final dynamic point = coordinates[i];
        if (point is! List || point.length < 2) {
          if (kDebugMode) debugPrint('OSRM routePolyline: invalid coordinate at index $i');
          throw Exception('OSRM invalid coordinate at $i');
        }
        final num lat = point[1] as num;
        final num lng = point[0] as num;
        points.add(LatLng(lat.toDouble(), lng.toDouble()));
      }

      final double distanceMeters = (route['distance'] as num).toDouble();
      final OsrmRouteResult result = OsrmRouteResult(
        points: points,
        distanceMeters: distanceMeters,
        usedFallback: false,
      );
      _routeCache[key] = result;
      if (kDebugMode) {
        debugPrint('OSRM routePolyline: success, points=${points.length}, distance=${distanceMeters.toStringAsFixed(0)}m');
      }
      return result;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        final int? status = error is DioException && error.response != null
            ? error.response!.statusCode
            : null;
        debugPrint('OSRM routePolyline failed: ${status != null ? "HTTP $status " : ""}$error');
        debugPrint('$stackTrace');
      }
      rethrow;
    }
  }
}
