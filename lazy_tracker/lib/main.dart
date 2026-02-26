import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/study_provider.dart';
import 'providers/timer_provider.dart';
import 'utils/app_theme.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudyProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
      ],
      child: const LazyTrackerApp(),
    ),
  );
}

class LazyTrackerApp extends StatelessWidget {
  const LazyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LazyTracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const DashboardScreen(),
    );
  }
}
