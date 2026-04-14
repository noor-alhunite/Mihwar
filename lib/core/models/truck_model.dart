import 'operations_enums.dart';

class TruckModel {
  const TruckModel({
    required this.driverId,
    required this.label,
    required this.truckType,
    required this.areaName,
    this.trainingOnly = false,
  });

  final String driverId;
  final String label;
  final TruckType truckType;
  final String areaName;
  final bool trainingOnly;
}
