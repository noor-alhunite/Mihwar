import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:msar_flutter/core/role.dart';
import 'package:msar_flutter/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/providers/auth_controller.dart';
import '../features/driver/driver_home_screen.dart';
import '../features/governorate/governorate_home_screen.dart';
import '../features/governorate/settings/governorate_settings_screen.dart';
import '../features/supervisor/supervisor_home_screen.dart';
import '../shared/providers/language_provider.dart';
import '../shared/theme/app_theme.dart';

class AppRoutes {
  static const String roleSelection = '/';
  static const String beforeStudy = '/before-study';
  static const String login = '/login';
  static const String driver = '/driver';
  static const String driverMapStart = '/driver/map-start';
  static const String driverRouteMap = '/driver/route-map';
  static const String driverProfile = '/driver/profile';
  static const String driverAchievement = '/driver/achievements';
  static const String supervisor = '/supervisor';
  static const String governorate = '/governorate';
  static const String governorateSettings = '/governorate/settings';
}

class WasteApp extends ConsumerWidget {
  const WasteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale locale = ref.watch(languageProvider);
    final AuthState authState = ref.watch(authControllerProvider);
    final GoRouter router = GoRouter(
      initialLocation: AppRoutes.login,
      redirect: (context, state) {
        final bool loggedIn = authState.isAuthenticated;
        final String currentPath = state.matchedLocation;
        final bool onLogin = currentPath == AppRoutes.login;

        if (!loggedIn) {
          return onLogin ? null : AppRoutes.login;
        }

        final String homeRoute = _routeForRole(authState.currentUser!.role);

        if (onLogin) {
          return homeRoute;
        }

        if (!_isAllowedPathForRole(authState.currentUser!.role, currentPath)) {
          return homeRoute;
        }

        return null;
      },
      errorBuilder: (context, state) {
        final AppLocalizations l10n = AppLocalizations.of(context)!;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.routing_error)),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.route_error(state.error.toString()),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.driver,
          builder: (context, state) => const DriverHomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.supervisor,
          builder: (context, state) => const SupervisorHomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.governorate,
          builder: (context, state) => const GovernorateHomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.governorateSettings,
          builder: (context, state) => const GovernorateSettingsScreen(),
        ),
      ],
    );

    final TextDirection textDirection =
        locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;

    return MaterialApp.router(
      key: ValueKey(locale.toString()),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Directionality(
        textDirection: textDirection,
        child: child!,
      ),
      routerConfig: router,
    );
  }
}

String _routeForRole(UserRole role) {
  switch (role) {
    case UserRole.driver:
      return AppRoutes.driver;
    case UserRole.supervisor:
      return AppRoutes.supervisor;
    case UserRole.governorateManager:
      return AppRoutes.governorate;
  }
}

bool _isAllowedPathForRole(UserRole role, String path) {
  return switch (role) {
    UserRole.driver => path == AppRoutes.driver,
    UserRole.supervisor => path == AppRoutes.supervisor,
    UserRole.governorateManager =>
      path == AppRoutes.governorate || path == AppRoutes.governorateSettings,
  };
}