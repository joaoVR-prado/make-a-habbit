import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/data/providers/habit_stats_provider.dart';
import 'package:make_a_habbit/presentation/reports/widgets/weekly_graphic_card.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref){
    final stats = ref.watch(habitStatsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text('Seu Progresso Geral: ', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              
              WeeklyGraphicCard(weeklyData: stats.weeklyCompletionHistory), 
              const SizedBox(height: 10),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                // crossAxisSpacing: 8,
                // mainAxisSpacing: 8,
                childAspectRatio: 1,
                children: [
                  _buildStatCard(context, 'Taxa de Sucesso', '${stats.generalSuccessRate.toStringAsFixed(1)}%', Icons.bolt),
                  _buildStatCard(context, 'Recorde de Ofensiva', '${stats.bestStreakGeral} dias', Icons.local_fire_department),
                  _buildStatCard(context, 'Total de Hábitos', '${stats.totalHabits}', Icons.assignment),
                  _buildStatCard(context, 'Concluídos Hoje', '${stats.completedToday}', Icons.check_circle),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      color: AppColors.cardBackgrounColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColors.positiveActionDialogTextColor),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: Theme.of(context).textTheme.headlineMedium)
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(title, style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center)
            ),
          ],
        ),
      ),
    );
  }

}
