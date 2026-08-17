import 'package:make_a_habbit/domain/repositories/habit_repository.dart';
import 'package:make_a_habbit/domain/repositories/notification_config_repository.dart';
import 'package:make_a_habbit/domain/services/clock.dart';
import 'package:make_a_habbit/domain/services/notification_scheduler.dart';

final class NotificationReconciliationResult {
  const NotificationReconciliationResult({required this.failedHabitIds});

  final Set<String> failedHabitIds;
  bool get hasFailures => failedHabitIds.isNotEmpty;
}

final class ReconcileHabitNotifications {
  const ReconcileHabitNotifications({
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

  Future<NotificationReconciliationResult> call() async {
    final failedHabitIds = <String>{};
    final now = _clock.now();

    for (final habit in _habits.getAll()) {
      try {
        final config = _notificationConfigs.get(habit.id);
        if (config == null) {
          await _notificationScheduler.cancelForHabit(habit.id);
          continue;
        }
        await _notificationScheduler.replaceSchedules(
          habit: habit,
          reminderEnabled: config.isReminderEnabled,
          streakEnabled: config.isStreakEnabled,
          now: now,
        );
      } catch (_) {
        failedHabitIds.add(habit.id);
      }
    }

    return NotificationReconciliationResult(
      failedHabitIds: Set.unmodifiable(failedHabitIds),
    );
  }
}
