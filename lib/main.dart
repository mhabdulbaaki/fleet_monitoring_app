import 'package:fleet_monitoring_app/ui/home_screen.dart' show HomeScreen;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/car_provider.dart';

void main() {
  runApp(const FleetMonitoringApp());
}

class FleetMonitoringApp extends StatelessWidget {
  const FleetMonitoringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CarProvider(),
      child: MaterialApp(
        title: 'Fleet Monitoring',
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}