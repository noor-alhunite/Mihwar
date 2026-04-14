enum BinZoneType { residential, commercial }

class BinModel {
  const BinModel({
    required this.id,
    required this.label,
    required this.lat,
    required this.lng,
    required this.zoneType,
  });

  final int id;
  final String label;
  final double lat;
  final double lng;
  final BinZoneType zoneType;
}
