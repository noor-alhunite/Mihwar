import '../../../core/models/bin.dart';

class KaramaBins {
  const KaramaBins._();

  /// 10 deterministic "studied" bins around Zarqa - Al-Karama:
  /// - 4 commercial bins along the main street (roughly 300m spacing)
  /// - 6 residential bins in surrounding neighborhoods (roughly 500m spacing)
  static const List<BinModel> bins = [
    BinModel(
      id: 1,
      label: 'BIN-01',
      lat: 32.07090,
      lng: 36.08555,
      zoneType: BinZoneType.commercial,
    ),
    BinModel(
      id: 2,
      label: 'BIN-02',
      lat: 32.07170,
      lng: 36.08705,
      zoneType: BinZoneType.commercial,
    ),
    BinModel(
      id: 3,
      label: 'BIN-03',
      lat: 32.07245,
      lng: 36.08865,
      zoneType: BinZoneType.commercial,
    ),
    BinModel(
      id: 4,
      label: 'BIN-04',
      lat: 32.07335,
      lng: 36.09035,
      zoneType: BinZoneType.commercial,
    ),
    BinModel(
      id: 5,
      label: 'BIN-05',
      lat: 32.07515,
      lng: 36.08690,
      zoneType: BinZoneType.residential,
    ),
    BinModel(
      id: 6,
      label: 'BIN-06',
      lat: 32.07460,
      lng: 36.09160,
      zoneType: BinZoneType.residential,
    ),
    BinModel(
      id: 7,
      label: 'BIN-07',
      lat: 32.07220,
      lng: 36.09335,
      zoneType: BinZoneType.residential,
    ),
    BinModel(
      id: 8,
      label: 'BIN-08',
      lat: 32.06995,
      lng: 36.09195,
      zoneType: BinZoneType.residential,
    ),
    BinModel(
      id: 9,
      label: 'BIN-09',
      lat: 32.06925,
      lng: 36.08725,
      zoneType: BinZoneType.residential,
    ),
    BinModel(
      id: 10,
      label: 'BIN-10',
      lat: 32.07135,
      lng: 36.08385,
      zoneType: BinZoneType.residential,
    ),
  ];
}
