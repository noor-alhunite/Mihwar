import '../models/bin.dart';
import '../models/bin_visit_record.dart';
import '../models/driver_location_point.dart';
import '../models/diesel_stat_record.dart';
import '../models/prediction_models.dart';
import '../models/route_planning_models.dart';
import '../models/truck_model.dart';

abstract class BinsRepository {
  Future<List<BinModel>> getAllBins();
  Future<void> replaceAllBins(List<BinModel> bins);
  Future<List<BinModel>> getBinsByDriver(String driverId);
  Future<void> assignBinsToDrivers(Map<int, String> binAssignments);
}

abstract class VisitsRepository {
  Future<void> addVisit(BinVisitRecord visit);
  Future<void> addVisits(List<BinVisitRecord> visits);
  Future<List<BinVisitRecord>> getVisitsByDriverAndDate({
    required String driverId,
    required String routeDate,
  });
  Future<List<BinVisitRecord>> getVisitsByBin(int binId);
}

abstract class DieselStatsRepository {
  Future<void> replaceAllStats(List<DieselStatRecord> stats);
  Future<List<DieselStatRecord>> getAllStats();
}

abstract class RoutePlanningRepository {
  Future<void> replacePlannedStops(List<PlannedStopRecord> stops);
  Future<List<PlannedStopRecord>> getPlannedStops({
    required String driverId,
    required String routeDate,
  });

  Future<void> replaceRoadSegments(List<RoadSegmentRecord> segments);
  Future<List<RoadSegmentRecord>> getRoadSegments();
}

abstract class DriverEventsRepository {
  Future<void> addEvent(DriverEventRecord event);
  Future<List<DriverEventRecord>> getEventsByDriverAndDate({
    required String driverId,
    required String routeDate,
  });
}

abstract class DriverLocationRepository {
  Future<void> addLocationPoint(DriverLocationPoint point);
  Future<void> addLocationPoints(List<DriverLocationPoint> points);
  Future<List<DriverLocationPoint>> getLocationPoints({
    required String driverId,
    required String routeDate,
  });
}

abstract class PredictionRepository {
  Future<List<PredictedBinStop>> getPriorityStops({
    required String driverId,
    required String routeDate,
    required DateTime now,
    required String shift,
    bool includeTrainingDriver = false,
  });
}

abstract class TrucksRepository {
  Future<void> replaceAllTrucks(List<TruckModel> trucks);
  Future<List<TruckModel>> getAllTrucks();
}

abstract class DemoSeedRepository {
  Future<void> ensureSeeded();
  Future<void> resetDemo();
}

class DemoRepositoryBundle {
  const DemoRepositoryBundle({
    required this.binsRepository,
    required this.visitsRepository,
    required this.dieselStatsRepository,
    required this.routePlanningRepository,
    required this.driverEventsRepository,
    required this.driverLocationRepository,
    required this.predictionRepository,
    required this.trucksRepository,
    required this.demoSeedRepository,
  });

  final BinsRepository binsRepository;
  final VisitsRepository visitsRepository;
  final DieselStatsRepository dieselStatsRepository;
  final RoutePlanningRepository routePlanningRepository;
  final DriverEventsRepository driverEventsRepository;
  final DriverLocationRepository driverLocationRepository;
  final PredictionRepository predictionRepository;
  final TrucksRepository trucksRepository;
  final DemoSeedRepository demoSeedRepository;
}
