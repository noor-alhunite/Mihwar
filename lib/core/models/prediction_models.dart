import 'bin.dart';
import 'operations_enums.dart';

class PredictedBinStop {
  const PredictedBinStop({
    required this.binId,
    required this.driverId,
    required this.predictedFillPercent,
    required this.reasons,
    required this.shift,
  });

  final int binId;
  final String driverId;
  final double predictedFillPercent;
  final List<String> reasons;
  final ShiftPeriod shift;
}

class BinPredictionInput {
  const BinPredictionInput({
    required this.bin,
    required this.driverId,
    required this.lastServicedAt,
    required this.avgDailyFillPercent,
    required this.dayOfWeek,
    required this.season,
  });

  final BinModel bin;
  final String driverId;
  final DateTime lastServicedAt;
  final double avgDailyFillPercent;
  final int dayOfWeek;
  final SeasonType season;
}
