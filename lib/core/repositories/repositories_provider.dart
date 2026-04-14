import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'demo_repositories.dart';
import 'repository_bundle_factory.dart';

final Provider<DemoRepositoryBundle> demoRepositoryBundleProvider =
    Provider<DemoRepositoryBundle>((Ref ref) {
      return createDemoRepositoryBundle();
    });

final Provider<BinsRepository> binsRepositoryProvider = Provider<BinsRepository>(
  (Ref ref) => ref.read(demoRepositoryBundleProvider).binsRepository,
);

final Provider<VisitsRepository> visitsRepositoryProvider =
    Provider<VisitsRepository>(
      (Ref ref) => ref.read(demoRepositoryBundleProvider).visitsRepository,
    );

final Provider<DieselStatsRepository> dieselStatsRepositoryProvider =
    Provider<DieselStatsRepository>(
      (Ref ref) => ref.read(demoRepositoryBundleProvider).dieselStatsRepository,
    );

final Provider<RoutePlanningRepository> routePlanningRepositoryProvider =
    Provider<RoutePlanningRepository>(
      (Ref ref) => ref.read(demoRepositoryBundleProvider).routePlanningRepository,
    );

final Provider<DriverEventsRepository> driverEventsRepositoryProvider =
    Provider<DriverEventsRepository>(
      (Ref ref) => ref.read(demoRepositoryBundleProvider).driverEventsRepository,
    );

final Provider<DriverLocationRepository> driverLocationRepositoryProvider =
    Provider<DriverLocationRepository>(
      (Ref ref) => ref.read(demoRepositoryBundleProvider).driverLocationRepository,
    );

final Provider<PredictionRepository> predictionRepositoryProvider =
    Provider<PredictionRepository>(
      (Ref ref) => ref.read(demoRepositoryBundleProvider).predictionRepository,
    );

final Provider<TrucksRepository> trucksRepositoryProvider =
    Provider<TrucksRepository>(
      (Ref ref) => ref.read(demoRepositoryBundleProvider).trucksRepository,
    );

final Provider<DemoSeedRepository> demoSeedRepositoryProvider =
    Provider<DemoSeedRepository>(
      (Ref ref) => ref.read(demoRepositoryBundleProvider).demoSeedRepository,
    );
