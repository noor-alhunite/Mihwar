import '../models/prediction_models.dart';
import '../models/operations_enums.dart';

class PredictionEngine {
  const PredictionEngine();

  static const double priorityThresholdPercent = 85;

  PredictedBinStop predictForShift({
    required BinPredictionInput input,
    required DateTime now,
    required ShiftPeriod shift,
  }) {
    final double seasonMultiplier = switch (input.season) {
      SeasonType.ramadan => 1.28,
      SeasonType.summerHoliday => 1.14,
      SeasonType.normal => 1.0,
    };

    final double dayMultiplier = _dayOfWeekMultiplier(input.dayOfWeek);
    final double shiftMultiplier = _shiftMultiplier(shift, input.bin.zoneType.name);
    final double hoursSinceLast = now.difference(input.lastServicedAt).inMinutes / 60.0;
    final double hourlyFill = (input.avgDailyFillPercent / 24.0) *
        seasonMultiplier *
        dayMultiplier *
        shiftMultiplier;
    final double predictedFill = (hoursSinceLast * hourlyFill).clamp(0, 100);

    final String intensityLabel = _intensityLabel(
      zoneTypeName: input.bin.zoneType.name,
      avgDailyFillPercent: input.avgDailyFillPercent,
    );
    final String dailyFillBand = _dailyFillBand(input.avgDailyFillPercent);
    final List<String> reasons = <String>[
      'predict_reason_${input.bin.zoneType.name}_$intensityLabel',
      if (input.season == SeasonType.ramadan) 'predict_reason_ramadan_multiplier',
      if (input.season == SeasonType.summerHoliday) 'predict_reason_summer_multiplier',
      if (input.dayOfWeek == DateTime.friday || input.dayOfWeek == DateTime.saturday) 'predict_reason_weekend_increase',
      if (input.dayOfWeek == DateTime.monday || input.dayOfWeek == DateTime.tuesday) 'predict_reason_early_week_reduction',
      'predict_reason_last_service_stale',
      'predict_reason_avg_daily_fill_$dailyFillBand',
    ];

    return PredictedBinStop(
      binId: input.bin.id,
      driverId: input.driverId,
      predictedFillPercent: predictedFill,
      reasons: reasons,
      shift: shift,
    );
  }

  double _dayOfWeekMultiplier(int dayOfWeek) {
    if (dayOfWeek == DateTime.friday || dayOfWeek == DateTime.saturday) {
      return 1.15;
    }
    if (dayOfWeek == DateTime.monday) {
      return 1.08;
    }
    return 1.0;
  }

  double _shiftMultiplier(ShiftPeriod shift, String zoneTypeName) {
    final bool commercial = zoneTypeName == 'commercial';
    if (commercial) {
      return switch (shift) {
        ShiftPeriod.morning => 0.95,
        ShiftPeriod.noon => 1.10,
        ShiftPeriod.afternoon => 1.05,
        ShiftPeriod.evening => 1.00,
      };
    }
    return switch (shift) {
      ShiftPeriod.morning => 0.90,
      ShiftPeriod.noon => 1.00,
      ShiftPeriod.afternoon => 0.98,
      ShiftPeriod.evening => 1.18,
    };
  }

  String _intensityLabel({
    required String zoneTypeName,
    required double avgDailyFillPercent,
  }) {
    if (zoneTypeName == 'commercial') {
      if (avgDailyFillPercent >= 170) {
        return 'high';
      }
      if (avgDailyFillPercent >= 130) {
        return 'medium';
      }
      return 'low';
    }
    if (avgDailyFillPercent >= 122) {
      return 'high';
    }
    if (avgDailyFillPercent >= 96) {
      return 'medium';
    }
    return 'low';
  }

  String _dailyFillBand(double avgDailyFillPercent) {
    if (avgDailyFillPercent >= 150) {
      return 'high';
    }
    if (avgDailyFillPercent >= 100) {
      return 'medium';
    }
    return 'low';
  }
}
