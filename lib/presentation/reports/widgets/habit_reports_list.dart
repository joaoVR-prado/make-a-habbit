import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/app/providers/controller_providers.dart';
import 'package:make_a_habbit/core/providers/clock_provider.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/core/utils/enums/habit_icon.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_icon_container.dart';
import 'package:make_a_habbit/presentation/reports/views/habit_detail_report_page.dart';

class HabitReportsList extends ConsumerWidget {
  const HabitReportsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitControllerProvider);
    final today = _dateOnly(ref.watch(clockProvider).now());
    return habits.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: FilledButton(
          onPressed: () async {
            try {
              await ref.read(habitControllerProvider.notifier).retry();
            } catch (_) {
              // O provider mantém o estado de erro para outra tentativa.
            }
          },
          child: const Text('Tentar novamente'),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            key: Key('empty-habit-reports'),
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Crie seu primeiro hábito para acompanhar o progresso.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        }
        final sorted = [...items]
          ..sort((left, right) {
            final status = _statusWeight(
              left,
              today,
            ).compareTo(_statusWeight(right, today));
            return status != 0
                ? status
                : left.name.toLowerCase().compareTo(right.name.toLowerCase());
          });
        return ListView.builder(
          key: const Key('habit-reports-list'),
          itemCount: sorted.length,
          itemBuilder: (context, index) {
            final habit = sorted[index];
            return Column(
              children: [
                Card(
                  key: ValueKey('habit-report-${habit.id}'),
                  color: Colors.transparent,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(16),
                  ),
                  child: InkWell(
                    onTap: () => openHabitDetailReport(context, habit),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CommonIconContainer(
                        habitIcon: HabitIcon.fromCode(habit.iconCode),
                        alpha: 0.4,
                      ),
                      title: Text(
                        habit.name,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        [
                          if (habit.description?.trim().isNotEmpty == true)
                            habit.description!,
                          _statusLabel(habit, today),
                        ].join(' • '),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColors.homePageIconColor,
                      ),
                    ),
                  ),
                ),
                if (index != sorted.length - 1)
                  const Padding(
                    padding: EdgeInsetsGeometry.only(left: 10, right: 10),
                    child: Divider(thickness: 0.3, height: 2),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

Future<void> openHabitDetailReport(BuildContext context, HabitModel habit) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HabitDetailReportPage(habit: habit),
      ),
    );

int _statusWeight(HabitModel habit, DateTime today) {
  if (_dateOnly(habit.startDate).isAfter(today)) return 1;
  if (habit.endDate != null && _dateOnly(habit.endDate!).isBefore(today)) {
    return 2;
  }
  return 0;
}

String _statusLabel(HabitModel habit, DateTime today) {
  final start = _dateOnly(habit.startDate);
  if (start.isAfter(today)) return 'Começa em ${_formatDate(start)}';
  if (habit.endDate != null && _dateOnly(habit.endDate!).isBefore(today)) {
    return 'Encerrado';
  }
  return 'Ativo';
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
