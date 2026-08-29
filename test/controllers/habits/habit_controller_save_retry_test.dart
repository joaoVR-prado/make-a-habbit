import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/app/providers/controller_providers.dart';
import 'package:make_a_habbit/app/providers/dependency_providers.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/domain/entities/notifications/notification_config_model.dart';
import 'package:make_a_habbit/domain/repositories/habit_repository.dart';
import 'package:make_a_habbit/domain/repositories/notification_config_repository.dart';
import 'package:make_a_habbit/domain/services/notification_scheduler.dart';
import 'package:mocktail/mocktail.dart';

final class _MockHabitRepository extends Mock implements HabitRepository {}

final class _MockNotificationConfigRepository extends Mock
    implements NotificationConfigRepository {}

final class _MockNotificationScheduler extends Mock
    implements NotificationScheduler {}

void main() {
  group('RECUPERAÇÃO DO SALVAMENTO DE HÁBITOS', () {
    test(
      'Permite salvar novamente depois de uma falha de persistência.',
      () async {
        final habits = _MockHabitRepository();
        final notifications = _MockNotificationConfigRepository();
        final scheduler = _MockNotificationScheduler();
        final habit = HabitModel(
          id: 'habito',
          iconCode: 10,
          name: 'Beber água',
          conclusionType: HabitConclusionType.yesNo,
          frequency: const DailyHabitFrequency(),
          startDate: DateTime(2026, 8, 16),
        );
        final notification = NotificationConfigModel(
          isReminderEnabled: false,
          isStreakEnabled: false,
          customTimeNotification: const [],
        );
        when(habits.getAll).thenReturn([]);
        when(() => habits.getById(habit.id)).thenReturn(null);
        when(() => habits.add(habit)).thenThrow(Exception('armazenamento'));
        final container = ProviderContainer(
          overrides: [
            habitRepositoryProvider.overrideWithValue(habits),
            notificationConfigRepositoryProvider.overrideWithValue(
              notifications,
            ),
            notificationSchedulerProvider.overrideWithValue(scheduler),
          ],
        );
        addTearDown(container.dispose);
        await container.read(habitControllerProvider.future);
        final controller = container.read(habitControllerProvider.notifier);

        await expectLater(
          controller.addHabit(habit, notification),
          throwsException,
        );
        expect(container.read(habitControllerProvider), isA<AsyncError>());

        when(() => habits.add(habit)).thenAnswer((_) async {});
        when(
          () => notifications.save(habit.id, notification),
        ).thenAnswer((_) async {});
        when(
          () => scheduler.replaceSchedules(
            habit: habit,
            reminderEnabled: false,
            streakEnabled: false,
            now: any(named: 'now'),
          ),
        ).thenAnswer((_) async {});

        await controller.addHabit(habit, notification);

        expect(container.read(habitControllerProvider).requireValue, [habit]);
        verify(() => habits.add(habit)).called(2);
      },
    );
  });
}
