import '../repositories/repository_bundle_factory.dart';

class DemoBootstrap {
  const DemoBootstrap._();

  static bool _initialized = false;
  static Future<void>? _initializing;

  static Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }
    if (_initializing != null) {
      return _initializing!;
    }
    _initializing = _runInitialization();
    return _initializing!;
  }

  static Future<void> _runInitialization() async {
    try {
      final bundle = createDemoRepositoryBundle();
      await bundle.demoSeedRepository.ensureSeeded();
      _initialized = true;
    } finally {
      _initializing = null;
    }
  }
}
