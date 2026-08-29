import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/data/dtos/conclusion_dto.dart';
import 'package:make_a_habbit/data/dtos/habit_dto.dart';
import 'package:make_a_habbit/data/dtos/notification_config_dto.dart';
import 'package:make_a_habbit/data/repositories/concluded_habits_repository.dart';
import 'package:make_a_habbit/data/repositories/habit_repository.dart';
import 'package:make_a_habbit/data/repositories/notification_config_repository.dart';
import 'package:make_a_habbit/data/services/awesome_notification_scheduler.dart';
import 'package:make_a_habbit/domain/repositories/notification_config_repository.dart';
import 'package:make_a_habbit/domain/services/notification_scheduler.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HiveHabitRepository(Hive.box<HabitDto>('habits'));
});

final concludedHabitsRepositoryProvider = Provider<ConclusionRepository>((ref) {
  return HiveConclusionRepository(Hive.box<ConclusionDto>('conclusions'));
});

final notificationConfigRepositoryProvider =
    Provider<NotificationConfigRepository>((ref) {
      return HiveNotificationConfigRepository(
        Hive.box<NotificationConfigDto>('notifications'),
      );
    });

final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  return AwesomeNotificationScheduler();
});
