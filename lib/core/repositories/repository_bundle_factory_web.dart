import 'demo_repositories.dart';
import 'impl/in_memory_demo_repositories.dart';

final DemoRepositoryBundle _bundle = InMemoryDemoRepositoryBundle.create();

DemoRepositoryBundle createDemoRepositoryBundle() {
  return _bundle;
}
