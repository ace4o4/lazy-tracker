import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/app_theme.dart';
import 'glass_container.dart';

class WeeklyChart extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyData;

  const WeeklyChart({super.key, required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    if (weeklyData.isEmpty) return const SizedBox();

    // Data consists of last 7 days.
    double maxHours = 0;
    for (var d in weeklyData) {
      if (d['hours'] > maxHours) maxHours = d['hours'];
    }
    if (maxHours == 0) maxHours = 5; // Default max Y if no data

    return GlassContainer(
      padding: const EdgeInsets.only(top: 32, bottom: 20, left: 16, right: 32),
      child: BarChart(
        BarChartData(
          maxY: maxHours + (maxHours * 0.2), // Add 20% headroom
          minY: 0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white10,
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: maxHours > 10 ? 5 : 2,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value >= 0 && value < weeklyData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        weeklyData[value.toInt()]['day'],
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          barGroups: weeklyData.asMap().entries.map((entry) {
            int index = entry.key;
            double hours = entry.value['hours'] as double;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: hours,
                  color: AppTheme.secondaryColor,
                  width: 14,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxHours + (maxHours * 0.2),
                    color: Colors.white.withAlpha(12), // roughly 5% opacity
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
