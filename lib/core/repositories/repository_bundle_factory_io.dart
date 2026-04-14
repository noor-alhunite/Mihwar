import 'demo_repositories.dart';
import 'impl/sqflite_demo_repositories.dart';

final DemoRepositoryBundle _bundle = SqfliteDemoRepositoryBundle.create();

DemoRepositoryBundle createDemoRepositoryBundle() {
  return _bundle;
}
