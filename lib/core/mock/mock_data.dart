import 'package:flutter/material.dart';

class MockBinStop {
  const MockBinStop({
    required this.id,
    required this.label,
    required this.lat,
    required this.lng,
    required this.fillLevel,
  });

  final int id;
  final String label;
  final double lat;
  final double lng;
  final double fillLevel;
}

class MockData {
  const MockData._();

  static const String governorateName = 'Baghdad Governorate';
  static const String areaName = 'Al Mansour Area';
  static const String driverName = 'Ahmed Kareem';
  static const String truckName = 'Truck-07 (Modern)';

  static const List<MockBinStop> todayRouteStops = [
    MockBinStop(id: 1001, label: 'BIN-1001', lat: 33.303, lng: 44.374, fillLevel: 0.92),
    MockBinStop(id: 1010, label: 'BIN-1010', lat: 33.307, lng: 44.368, fillLevel: 0.81),
    MockBinStop(id: 1022, label: 'BIN-1022', lat: 33.311, lng: 44.371, fillLevel: 0.74),
    MockBinStop(id: 1034, label: 'BIN-1034', lat: 33.315, lng: 44.366, fillLevel: 0.88),
    MockBinStop(id: 1041, label: 'BIN-1041', lat: 33.319, lng: 44.362, fillLevel: 0.69),
  ];

  static const Map<String, int> statusCounts = {
    'full': 26,
    'half': 42,
    'empty': 31,
    'broken': 4,
  };

  static const List<String> achievementHighlightKeys = [
    'route_distance_reduced',
    'estimated_fuel_saved',
    'priority_bins_ontime',
  ];

  static const List<Map<String, String>> supervisorKpis = [
    {'titleKey': 'active_drivers', 'value': '8'},
    {'titleKey': 'completed_stops', 'value': '124'},
    {'titleKey': 'open_issues', 'value': '5'},
    {'titleKey': 'on_time_service', 'value': '93%'},
  ];

  static const List<Map<String, String>> governorateKpis = [
    {'titleKey': 'areas_covered', 'value': '3'},
    {'titleKey': 'total_trucks', 'value': '21'},
    {'titleKey': 'daily_km_smart', 'value': '412'},
    {'titleKey': 'fuel_saved', 'value': '11.8%'},
  ];

  static const List<Color> chartColors = [
    Color(0xFF1F6F43),
    Color(0xFF4F8A67),
    Color(0xFF8FB39A),
    Color(0xFFD66B5E),
  ];
}
