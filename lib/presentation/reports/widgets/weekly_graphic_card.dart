import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/core/providers/clock_provider.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';

class WeeklyGraphicCard extends ConsumerWidget {
  final Map<DateTime, int> weeklyData;

  const WeeklyGraphicCard({super.key, required this.weeklyData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(clockProvider).now();
    final highestValue = weeklyData.values.fold<int>(
      0,
      (a, b) => a > b ? a : b,
    );
    final maxY = (highestValue < 10 ? 10 : highestValue).toDouble();
    return Card(
      color: AppColors.cardBackgrounColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Hábitos Concluídos (Últimos 7 dias)',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) =>
                            _bottomTitles(value, meta, today),
                        reservedSize: 28,
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: _generateBars(today),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Geras as barras do gráfico
  List<BarChartGroupData> _generateBars(DateTime today) {
    return List.generate(7, (index) {
      final date = today.subtract(Duration(days: 6 - index));
      final dateKey = DateTime(date.year, date.month, date.day);

      final completedAmount = weeklyData[dateKey] ?? 0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: completedAmount.toDouble(),
            color: AppColors.positiveActionDialogTextColor,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  // Desenha os dias da semana
  Widget _bottomTitles(double value, TitleMeta meta, DateTime today) {
    final date = today.subtract(Duration(days: 6 - value.toInt()));

    const days = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    final dayString = days[date.weekday % 7];

    return SideTitleWidget(
      meta: meta,
      child: Text(
        dayString,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
