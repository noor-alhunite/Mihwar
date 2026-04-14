import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/bin.dart';
import '../../../core/models/prediction_models.dart';
import '../../../core/repositories/demo_seed_spec.dart';
import '../../../core/repositories/repositories_provider.dart';

class SmartDriverRouteData {
  const SmartDriverRouteData({
    required this.allAssignedBins,
    required this.priorityStops,
  });

  final List<BinModel> allAssignedBins;
  final List<PredictedBinStop> priorityStops;
}

final smartDriverRouteProvider = FutureProvider.family<SmartDriverRouteData, String>((
  ref,
  driverId,
) async {
  final binsRepo = ref.read(binsRepositoryProvider);
  final predictionRepo = ref.read(predictionRepositoryProvider);
  final List<BinModel> assignedBins = await binsRepo.getBinsByDriver(driverId);
  final List<PredictedBinStop> priorityStops = await predictionRepo.getPriorityStops(
    driverId: driverId,
    routeDate: DemoSeedSpec.demoDate,
    now: DateTime.parse('${DemoSeedSpec.demoDate}T08:30:00.000'),
    shift: 'morning',
  );

  return SmartDriverRouteData(
    allAssignedBins: assignedBins,
    priorityStops: priorityStops,
  );
});
