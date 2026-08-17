import 'package:make_a_habbit/domain/repositories/conclusion_repository.dart';
import 'package:make_a_habbit/domain/repositories/habit_repository.dart';
import 'package:make_a_habbit/domain/repositories/notification_config_repository.dart';
import 'package:make_a_habbit/domain/services/notification_scheduler.dart';
import 'package:make_a_habbit/domain/use_cases/habit_operation_result.dart';

final class DeleteHabit {
  const DeleteHabit({
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

  Future<HabitOperationResult> call(String habitId) async {
    final failures = <HabitOperationFailure>{};

    await _habits.delete(habitId);

    try {
      await _notificationScheduler.cancelForHabit(habitId);
    } catch (_) {
      failures.add(HabitOperationFailure.notificationSchedule);
    }
    try {
      await _conclusions.deleteByHabit(habitId);
    } catch (_) {
      failures.add(HabitOperationFailure.conclusions);
    }
    try {
      await _notificationConfigs.delete(habitId);
    } catch (_) {
      failures.add(HabitOperationFailure.notificationConfig);
    }
    return HabitOperationResult(failures: Set.unmodifiable(failures));
  }
}
