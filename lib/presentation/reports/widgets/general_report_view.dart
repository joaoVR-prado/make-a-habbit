import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/data/providers/concluded_habits_repository_provider.dart';
import 'package:make_a_habbit/data/providers/habit_stats_provider.dart';
import 'package:make_a_habbit/presentation/reports/widgets/weekly_graphic_card.dart';

class GeneralReportView extends ConsumerWidget {
  const GeneralReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(habitStatsProvider);
    return stats.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: FilledButton(
          onPressed: () async {
            try {
              await Future.wait([
                ref.read(habitControllerProvider.notifier).retry(),
                ref.read(concludedHabitsControllerProvider.notifier).retry(),
              ]);
            } catch (_) {
              // Os providers mantêm o estado de erro para outra tentativa.
            }
          },
          child: const Text('Tentar novamente'),
        ),
      ),
      data: (value) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          children: [
            WeeklyGraphicCard(weeklyData: value.weeklyCompletionHistory),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1,
              children: [
                _StatCard(
                  title: 'Taxa de sucesso',
                  value: '${value.generalSuccessRate.toStringAsFixed(1)}%',
                  icon: Icons.bolt,
                ),
                _StatCard(
                  title: 'Recorde de ofensiva',
                  value: '${value.bestStreakGeral} dias',
                  icon: Icons.local_fire_department,
                ),
                _StatCard(
                  title: 'Total de hábitos',
                  value: '${value.totalHabits}',
                  icon: Icons.assignment,
                ),
                _StatCard(
                  title: 'Concluídos hoje',
                  value: '${value.completedToday}',
                  icon: Icons.check_circle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.cardBackgrounColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: AppColors.positiveActionDialogTextColor),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
