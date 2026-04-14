import 'package:latlong2/latlong.dart';

class DriverArea {
  const DriverArea({
    required this.id,
    required this.name,
    required this.truckName,
    required this.type,
    required this.center,
    required this.routePoints,
    required this.bins,
  });

  final int id;
  final String name;
  final String truckName;
  final String type;
  final LatLng center;
  final List<LatLng> routePoints;
  final List<DriverBin> bins;
}

class DriverBin {
  const DriverBin({
    required this.id,
    required this.label,
    required this.location,
    required this.zoneType,
    required this.typicalFillHours,
  });

  final int id;
  final String label;
  final LatLng location;
  final String zoneType;
  final int typicalFillHours;
}

class DriverMapMockData {
  const DriverMapMockData._();

  static const DriverArea residentialArea = DriverArea(
    id: 1,
    name: 'Zarqa - Al Karama',
    truckName: 'Modern Truck A',
    type: 'Residential',
    center: LatLng(32.0725, 36.0886),
    routePoints: [
      LatLng(32.07190, 36.08690),
      LatLng(32.07215, 36.08745),
      LatLng(32.07242, 36.08805),
      LatLng(32.07268, 36.08870),
      LatLng(32.07294, 36.08930),
      LatLng(32.07318, 36.08995),
    ],
    bins: [
      DriverBin(
        id: 1101,
        label: 'AK-1101',
        location: LatLng(32.07190, 36.08690),
        zoneType: 'Residential',
        typicalFillHours: 38,
      ),
      DriverBin(
        id: 1102,
        label: 'AK-1102',
        location: LatLng(32.07215, 36.08745),
        zoneType: 'Residential',
        typicalFillHours: 40,
      ),
      DriverBin(
        id: 1103,
        label: 'AK-1103',
        location: LatLng(32.07242, 36.08805),
        zoneType: 'Residential',
        typicalFillHours: 42,
      ),
      DriverBin(
        id: 1104,
        label: 'AK-1104',
        location: LatLng(32.07268, 36.08870),
        zoneType: 'Residential',
        typicalFillHours: 39,
      ),
      DriverBin(
        id: 1105,
        label: 'AK-1105',
        location: LatLng(32.07294, 36.08930),
        zoneType: 'Residential',
        typicalFillHours: 41,
      ),
      DriverBin(
        id: 1106,
        label: 'AK-1106',
        location: LatLng(32.07318, 36.08995),
        zoneType: 'Residential',
        typicalFillHours: 37,
      ),
    ],
  );

  static const DriverArea commercialArea = DriverArea(
    id: 2,
    name: 'Karrada Commercial Strip',
    truckName: 'TR-12 Legacy',
    type: 'Commercial',
    center: LatLng(33.3035, 44.4065),
    routePoints: [
      LatLng(33.3019, 44.4101),
      LatLng(33.3028, 44.4084),
      LatLng(33.3036, 44.4066),
      LatLng(33.3046, 44.4048),
      LatLng(33.3057, 44.4031),
      LatLng(33.3068, 44.4016),
    ],
    bins: [
      DriverBin(
        id: 2201,
        label: 'C-2201',
        location: LatLng(33.3020, 44.4096),
        zoneType: 'Commercial',
        typicalFillHours: 18,
      ),
      DriverBin(
        id: 2202,
        label: 'C-2202',
        location: LatLng(33.3029, 44.4080),
        zoneType: 'Commercial',
        typicalFillHours: 16,
      ),
      DriverBin(
        id: 2203,
        label: 'C-2203',
        location: LatLng(33.3038, 44.4063),
        zoneType: 'Commercial',
        typicalFillHours: 19,
      ),
      DriverBin(
        id: 2204,
        label: 'C-2204',
        location: LatLng(33.3047, 44.4046),
        zoneType: 'Commercial',
        typicalFillHours: 17,
      ),
      DriverBin(
        id: 2205,
        label: 'C-2205',
        location: LatLng(33.3057, 44.4030),
        zoneType: 'Commercial',
        typicalFillHours: 15,
      ),
      DriverBin(
        id: 2206,
        label: 'C-2206',
        location: LatLng(33.3068, 44.4015),
        zoneType: 'Commercial',
        typicalFillHours: 18,
      ),
      DriverBin(
        id: 2207,
        label: 'C-2207',
        location: LatLng(33.3073, 44.4004),
        zoneType: 'Commercial',
        typicalFillHours: 20,
      ),
    ],
  );

  static DriverArea areaById(int areaId) {
    if (areaId == commercialArea.id) {
      return commercialArea;
    }
    return residentialArea;
  }
}
