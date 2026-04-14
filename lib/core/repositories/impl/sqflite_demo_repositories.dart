import '../demo_repositories.dart';
import 'in_memory_demo_repositories.dart';

class SqfliteDemoRepositoryBundle {
  const SqfliteDemoRepositoryBundle._();

  static DemoRepositoryBundle create() {
    // Lightweight fallback for environments where sqflite demo storage
    // is unavailable or reset; keeps repository contract intact.
    return InMemoryDemoRepositoryBundle.create();
  }
}
