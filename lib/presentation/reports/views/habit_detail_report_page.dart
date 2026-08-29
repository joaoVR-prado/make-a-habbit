import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/app/providers/controller_providers.dart';
import 'package:make_a_habbit/app/providers/report_providers.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/presentation/reports/widgets/habit_month_calendar.dart';

class HabitDetailReportPage extends ConsumerWidget {
  const HabitDetailReportPage({super.key, required this.habit});

  final HabitModel habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(habitDetailStatsProvider(habit));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('habit-detail-back-button'),
          tooltip: 'Voltar',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            size: 32,
            color: AppColors.homePageIconColor,
          ),
        ),
        title: Text(
          habit.name,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppColors.whiteText),
        ),
      ),
      body: report.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: FilledButton(
            onPressed: () async {
              try {
                await ref
                    .read(concludedHabitsControllerProvider.notifier)
                    .retry();
              } catch (_) {
                // O provider mantém o estado de erro para outra tentativa.
              }
            },
            child: const Text('Tentar novamente'),
          ),
        ),
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1,
                children: [
                  _MetricCard(
                    label: 'Taxa de sucesso',
                    value: '${stats.successRate.toStringAsFixed(1)}%',
                    icon: Icons.bolt,
                    key: const Key('habit-success-rate'),
                  ),
                  _MetricCard(
                    label: 'Sequência atual',
                    value: '${stats.currentStreak} dias',
                    icon: Icons.local_fire_department,
                    key: const Key('habit-current-streak'),
                  ),
                  _MetricCard(
                    label: 'Melhor sequência',
                    value: '${stats.bestStreak} dias',
                    icon: Icons.emoji_events,
                    key: const Key('habit-best-streak'),
                  ),
                  _MetricCard(
                    label: 'Total concluído',
                    value: '${stats.totalCompletions}',
                    icon: Icons.check_circle,
                    key: const Key('habit-total-completions'),
                  ),
                ],
              ),
              //const SizedBox(height: 12),
              HabitMonthCalendar(habit: habit, stats: stats),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: AppColors.cardBackgrounColor,
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
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
