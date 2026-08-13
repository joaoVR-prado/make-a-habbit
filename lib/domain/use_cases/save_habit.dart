import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/models/notifications/notification_config_model.dart';
import 'package:make_a_habbit/domain/repositories/habit_repository.dart';
import 'package:make_a_habbit/domain/repositories/notification_config_repository.dart';
import 'package:make_a_habbit/domain/services/clock.dart';
import 'package:make_a_habbit/domain/services/notification_scheduler.dart';
import 'package:make_a_habbit/domain/use_cases/habit_operation_result.dart';

final class SaveHabit {
  const SaveHabit({
    required HabitRepository habits,
    required NotificationConfigRepository notificationConfigs,
    required NotificationScheduler notificationScheduler,
    required Clock clock,
  }) : _habits = habits,
       _notificationConfigs = notificationConfigs,
       _notificationScheduler = notificationScheduler,
       _clock = clock;

  final HabitRepository _habits;
  final NotificationConfigRepository _notificationConfigs;
  final NotificationScheduler _notificationScheduler;
  final Clock _clock;

  Future<HabitOperationResult> call({
    required HabitModel habit,
    required NotificationConfigModel notification,
  }) async {
    final alreadyExists = _habits.getById(habit.id) != null;
    if (alreadyExists) {
      await _habits.update(habit);
    } else {
      await _habits.add(habit);
    }

    final failures = <HabitOperationFailure>{};
    try {
      await _notificationConfigs.save(habit.id, notification);
    } catch (_) {
      failures.add(HabitOperationFailure.notificationConfig);
    }

    try {
      await _notificationScheduler.replaceSchedules(
        habit: habit,
        reminderEnabled: notification.isReminderEnabled,
        streakEnabled: notification.isStreakEnabled,
        now: _clock.now(),
      );
    } catch (_) {
      failures.add(HabitOperationFailure.notificationSchedule);
    }

    return HabitOperationResult(failures: Set.unmodifiable(failures));
  }
}
