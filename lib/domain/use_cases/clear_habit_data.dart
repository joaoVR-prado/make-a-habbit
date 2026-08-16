import 'package:make_a_habbit/domain/repositories/conclusion_repository.dart';
import 'package:make_a_habbit/domain/repositories/habit_repository.dart';
import 'package:make_a_habbit/domain/repositories/notification_config_repository.dart';
import 'package:make_a_habbit/domain/services/notification_scheduler.dart';
import 'package:make_a_habbit/domain/use_cases/habit_operation_result.dart';

final class ClearHabitData {
  const ClearHabitData({
    required HabitRepository habits,
    required ConclusionRepository conclusions,
    required NotificationConfigRepository notificationConfigs,
    required NotificationScheduler notificationScheduler,
  }) : _habits = habits,
       _conclusions = conclusions,
       _notificationConfigs = notificationConfigs,
       _notificationScheduler = notificationScheduler;

  final HabitRepository _habits;
  final ConclusionRepository _conclusions;
  final NotificationConfigRepository _notificationConfigs;
  final NotificationScheduler _notificationScheduler;

  Future<HabitOperationResult> call() async {
    final failures = <HabitOperationFailure>{};
    final habitIds = _habits.getAll().map((habit) => habit.id).toSet();

    for (final habitId in habitIds) {
      try {
        await _notificationScheduler.cancelForHabit(habitId);
      } catch (_) {
        failures.add(HabitOperationFailure.notificationSchedule);
      }
    }

    try {
      await _conclusions.clear();
    } catch (_) {
      failures.add(HabitOperationFailure.conclusions);
    }
    try {
      await _notificationConfigs.clear();
    } catch (_) {
      failures.add(HabitOperationFailure.notificationConfig);
    }

    await _habits.clear();
    return HabitOperationResult(failures: Set.unmodifiable(failures));
  }
}
