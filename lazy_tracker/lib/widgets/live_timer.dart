import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/study_provider.dart';
import '../utils/app_theme.dart';

class SmartWatchTimer extends StatelessWidget {
  const SmartWatchTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timer, child) {
        // Calculate progress logic for the outer ring (e.g 60 seconds loop)
        double progress = (timer.secondsElapsed % 60) / 60.0;

        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Inner Blur background
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: timer.currentState == TimerState.running
                            ? AppTheme.secondaryColor.withAlpha(50)
                            : Colors.transparent,
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                // Circular Progress Ring
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CustomPaint(
                    painter: TimerRingPainter(
                      progress: progress,
                      color: AppTheme.secondaryColor,
                      backgroundColor: Colors.white.withAlpha(25),
                    ),
                  ),
                ),
                // Timer Text and Play Button
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timer.formattedTime,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 48,
                        letterSpacing: 2,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => timer.toggle(),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: timer.currentState == TimerState.running
                              ? AppTheme.surfaceColor
                              : AppTheme.primaryColor,
                          border: Border.all(
                            color: timer.currentState == TimerState.running
                                ? AppTheme.secondaryColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          timer.currentState == TimerState.running
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Finish & Log Button (Only visible if paused and time > 0)
            if (timer.currentState == TimerState.paused &&
                timer.secondsElapsed > 0) ...[
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () async {
                  double totalHours = timer.finishAndGetHours();
                  await context.read<StudyProvider>().logHours(totalHours);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Awesome! Saved ${totalHours.toStringAsFixed(2)} hours.',
                        ),
                        backgroundColor: AppTheme.secondaryColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(
                  Icons.check_circle_outline,
                  color: AppTheme.secondaryColor,
                ),
                label: const Text(
                  'Finish Track Session',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor.withAlpha(25),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: AppTheme.secondaryColor.withAlpha(128),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class TimerRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  TimerRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        min(size.width / 2, size.height / 2) - 8; // Stroke width / 2 padding

    // Draw background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Start from top (-pi / 2)
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
