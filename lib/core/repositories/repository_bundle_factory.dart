import 'demo_repositories.dart';
import 'repository_bundle_factory_stub.dart'
    if (dart.library.io) 'repository_bundle_factory_io.dart'
    if (dart.library.html) 'repository_bundle_factory_web.dart' as platform;

DemoRepositoryBundle createDemoRepositoryBundle() {
  return platform.createDemoRepositoryBundle();
}
