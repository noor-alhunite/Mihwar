import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/bootstrap/demo_bootstrap.dart';
import '../../../core/models/bin.dart';
import '../../../core/models/operations_enums.dart';
import '../../../core/repositories/demo_seed_spec.dart';
import '../../../core/repositories/repositories_provider.dart';

class PredictedBinPriority {
  const PredictedBinPriority({
    required this.bin,
    required this.score,
    required this.reasons,
  });

  final BinModel bin;
  final double score;
  final List<String> reasons;
}

final FutureProvider<List<PredictedBinPriority>> predictiveEngineProvider =
    FutureProvider<List<PredictedBinPriority>>((ref) async {
      await DemoBootstrap.ensureInitialized();
      final List<BinModel> bins = await ref.read(binsRepositoryProvider).getAllBins();
      final visits = await ref
          .read(visitsRepositoryProvider)
          .getVisitsByDriverAndDate(
            driverId: DemoSeedSpec.defaultDriverId,
            routeDate: DemoSeedSpec.demoDate,
          );

      final int weekday = DateTime.parse('${DemoSeedSpec.demoDate}T08:00:00.000').weekday;
      final bool weekendLike = weekday == DateTime.friday || weekday == DateTime.saturday;

      final List<PredictedBinPriority> ranked = bins.map((bin) {
        final int fullCount = visits
            .where((v) => v.binId == bin.id && v.status == BinStatus.full)
            .length;
        final bool isCommercial = bin.zoneType == BinZoneType.commercial;

        double score = 0;
        final List<String> reasons = <String>[];

        if (isCommercial) {
          score += 0.45;
          reasons.add('predict_reason_commercial_fast');
        } else {
          score += 0.18;
          reasons.add('predict_reason_residential_slow');
        }

        score += (fullCount * 0.08).clamp(0, 0.4);
        reasons.add('predict_reason_history_full');

        if (weekendLike && isCommercial) {
          score += 0.18;
          reasons.add('predict_reason_weekend_commercial');
        } else if (!weekendLike && !isCommercial) {
          score += 0.08;
          reasons.add('predict_reason_weekday_residential');
        }

        if (score > 0.70) {
          reasons.add('predict_reason_priority_today');
        }

        return PredictedBinPriority(
          bin: bin,
          score: score,
          reasons: reasons,
        );
      }).toList(growable: false);

      ranked.sort((a, b) => b.score.compareTo(a.score));
      return ranked.take(8).toList(growable: false);
    });
