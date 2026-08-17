import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/core/providers/clock_provider.dart';
import 'package:make_a_habbit/data/providers/concluded_habits_repository_provider.dart';
import 'package:make_a_habbit/data/providers/habit_repository_provider.dart';
import 'package:make_a_habbit/data/providers/notification_config_repository_provider.dart';
import 'package:make_a_habbit/data/providers/notification_scheduler_provider.dart';
import 'package:make_a_habbit/domain/use_cases/clear_habit_data.dart';
import 'package:make_a_habbit/domain/use_cases/delete_habit.dart';
import 'package:make_a_habbit/domain/use_cases/ensure_notification_permission.dart';
import 'package:make_a_habbit/domain/use_cases/save_habit.dart';
import 'package:make_a_habbit/domain/use_cases/record_habit_conclusion.dart';
import 'package:make_a_habbit/domain/use_cases/reconcile_habit_notifications.dart';

final saveHabitProvider = Provider<SaveHabit>((ref) {
  return SaveHabit(
    habits: ref.watch(habitRepositoryProvider),
    notificationConfigs: ref.watch(notificationConfigRepositoryProvider),
    notificationScheduler: ref.watch(notificationSchedulerProvider),
    clock: ref.watch(clockProvider),
  );
});

final deleteHabitProvider = Provider<DeleteHabit>((ref) {
  return DeleteHabit(
    habits: ref.watch(habitRepositoryProvider),
    conclusions: ref.watch(concludedHabitsRepositoryProvider),
    notificationConfigs: ref.watch(notificationConfigRepositoryProvider),
    notificationScheduler: ref.watch(notificationSchedulerProvider),
  );
});

final clearHabitDataProvider = Provider<ClearHabitData>((ref) {
  return ClearHabitData(
    habits: ref.watch(habitRepositoryProvider),
    conclusions: ref.watch(concludedHabitsRepositoryProvider),
    notificationConfigs: ref.watch(notificationConfigRepositoryProvider),
    notificationScheduler: ref.watch(notificationSchedulerProvider),
  );
});

final recordHabitConclusionProvider = Provider<RecordHabitConclusion>((ref) {
  return RecordHabitConclusion(
    habits: ref.watch(habitRepositoryProvider),
    conclusions: ref.watch(concludedHabitsRepositoryProvider),
    clock: ref.watch(clockProvider),
  );
});

final ensureNotificationPermissionProvider =
    Provider<EnsureNotificationPermission>((ref) {
      return EnsureNotificationPermission(
        notificationScheduler: ref.watch(notificationSchedulerProvider),
      );
    });

final reconcileHabitNotificationsProvider =
    Provider<ReconcileHabitNotifications>((ref) {
      return ReconcileHabitNotifications(
        habits: ref.watch(habitRepositoryProvider),
        notificationConfigs: ref.watch(notificationConfigRepositoryProvider),
        notificationScheduler: ref.watch(notificationSchedulerProvider),
        clock: ref.watch(clockProvider),
      );
    });
