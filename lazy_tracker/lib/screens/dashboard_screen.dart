import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/study_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/weekly_chart.dart';
import '../widgets/log_modal.dart';
import '../widgets/live_timer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showLogModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors
          .transparent, // Ensure modal background is transparent for glass
      builder: (context) => const LogModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor, // Base solid fallback
      body: Stack(
        children: [
          // Simulated Liquid Mesh Gradient Background using soft blurred blobs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withAlpha(50),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondaryColor.withAlpha(40),
              ),
            ),
          ),
          // Blur everything behind it to make meshes look like liquid
          Positioned.fill(
            child: BackdropFilter(
              filter: ColorFilter.mode(
                Colors.black.withAlpha(20),
                BlendMode.darken,
              ),
              child: Container(color: Colors.transparent),
            ),
          ),

          // Main Foreground Content
          Consumer<StudyProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                );
              }

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Header
                      const SizedBox(height: 20),
                      Text(
                        'LazyTracker.',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              foreground: Paint()
                                ..shader =
                                    const LinearGradient(
                                      colors: [
                                        Color(0xFFA29BFE),
                                        AppTheme.secondaryColor,
                                      ],
                                    ).createShader(
                                      const Rect.fromLTWH(
                                        0.0,
                                        0.0,
                                        200.0,
                                        70.0,
                                      ),
                                    ),
                            ),
                      ),
                      Text(
                        'Minimum effort, maximum consistency.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 32),

                      // Stats Row
                      Row(
                        children: [
                          StatCard(
                            title: 'Current Streak',
                            value: '${provider.currentStreak} Days',
                            icon: Icons.local_fire_department_rounded,
                            iconColor: AppTheme.streakColor,
                            iconBgColor: AppTheme.streakColor.withAlpha(38),
                          ),
                          const SizedBox(width: 16),
                          StatCard(
                            title: "Today's Hours",
                            value:
                                '${provider.todayHours.toStringAsFixed(1)} Hrs',
                            icon: Icons.access_time_rounded,
                            iconColor: const Color(0xFFA29BFE),
                            iconBgColor: AppTheme.primaryColor.withAlpha(51),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Smart Watch Timer
                      const Center(child: SmartWatchTimer()),

                      const SizedBox(height: 40),

                      // Chart Section
                      Text(
                        'Weekly Progress',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        height: 250,
                        child: WeeklyChart(weeklyData: provider.weeklyData),
                      ),
                      const SizedBox(height: 80), // Padding for FAT button
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogModal(context),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.bolt, color: Colors.white),
        label: const Text(
          'Log Manually',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
