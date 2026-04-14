import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/providers/auth_controller.dart';
import 'smart/smart_driver_home.dart';
import 'training/training_driver_home.dart';

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final String driverId = user.id.toString();
    if (driverId == '1006') {
      return TrainingDriverHome(driverId: driverId);
    }
    return SmartDriverHome(driverId: driverId);
  }
}
