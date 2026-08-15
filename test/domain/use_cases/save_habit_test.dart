import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/domain/entities/notifications/notification_config_model.dart';
import 'package:make_a_habbit/domain/repositories/habit_repository.dart';
import 'package:make_a_habbit/domain/repositories/notification_config_repository.dart';
import 'package:make_a_habbit/domain/services/clock.dart';
import 'package:make_a_habbit/domain/services/notification_scheduler.dart';
import 'package:make_a_habbit/domain/use_cases/habit_operation_result.dart';
import 'package:make_a_habbit/domain/use_cases/save_habit.dart';
import 'package:mocktail/mocktail.dart';

class _MockHabitRepository extends Mock implements HabitRepository {}
class _MockNotificationConfigRepository extends Mock
    implements NotificationConfigRepository {}
class _MockNotificationScheduler extends Mock implements NotificationScheduler {}
class _MockClock extends Mock implements Clock {}

void main() {
  late _MockHabitRepository habits;
  late _MockNotificationConfigRepository configs;
  late _MockNotificationScheduler scheduler;
  late _MockClock clock;
  late SaveHabit saveHabit;
  late HabitModel habit;
  late NotificationConfigModel notification;
  final now = DateTime(2026, 8, 11, 10);

  setUp(() {
    habits = _MockHabitRepository();
    configs = _MockNotificationConfigRepository();
    scheduler = _MockNotificationScheduler();
    clock = _MockClock();
    habit = HabitModel(
      id: 'habito-1',
      iconCode: 0,
      name: 'Beber água',
      conclusionType: HabitConclusionType.yesNo,
      frequency: HabitFrequency.fromType(type: HabitFrequencyType.daily),
      startDate: DateTime(2026, 8, 11),
    );
    notification = NotificationConfigModel(
      isReminderEnabled: true,
      isStreakEnabled: false,
      customTimeNotification: const [],
    );
    when(() => clock.now()).thenReturn(now);
    saveHabit = SaveHabit(
      habits: habits,
      notificationConfigs: configs,
      notificationScheduler: scheduler,
      clock: clock,
    );
  });

  group('CASO DE USO PARA SALVAR HÁBITO', () {
    test('Salva o hábito antes da configuração e do agendamento', () async {
      when(() => habits.getById(habit.id)).thenReturn(null);
      when(() => habits.add(habit)).thenAnswer((_) async {});
      when(() => configs.save(habit.id, notification)).thenAnswer((_) async {});
      when(
        () => scheduler.replaceSchedules(
          habit: habit,
          reminderEnabled: true,
          streakEnabled: false,
          now: now,
        ),
      ).thenAnswer((_) async {});

      final result = await saveHabit(habit: habit, notification: notification);

      expect(result.hasPartialFailures, isFalse);
      verifyInOrder([
        () => habits.getById(habit.id),
        () => habits.add(habit),
        () => configs.save(habit.id, notification),
        () => scheduler.replaceSchedules(
          habit: habit,
          reminderEnabled: true,
          streakEnabled: false,
          now: now,
        ),
      ]);
    });

    test('Repete a operação como atualização quando o hábito já existe', () async {
      var lookupCount = 0;
      when(() => habits.getById(habit.id)).thenAnswer((_) {
        lookupCount++;
        return lookupCount == 1 ? null : habit;
      });
      when(() => habits.add(habit)).thenAnswer((_) async {});
      when(() => habits.update(habit)).thenAnswer((_) async {});
      when(() => configs.save(habit.id, notification)).thenAnswer((_) async {});
      when(
        () => scheduler.replaceSchedules(
          habit: habit,
          reminderEnabled: true,
          streakEnabled: false,
          now: now,
        ),
      ).thenAnswer((_) async {});

      await saveHabit(habit: habit, notification: notification);
      await saveHabit(habit: habit, notification: notification);

      verify(() => habits.add(habit)).called(1);
      verify(() => habits.update(habit)).called(1);
    });

    test('Informa falhas parciais sem desfazer o hábito persistido', () async {
      when(() => habits.getById(habit.id)).thenReturn(null);
      when(() => habits.add(habit)).thenAnswer((_) async {});
      when(() => configs.save(habit.id, notification)).thenThrow(Exception());
      when(
        () => scheduler.replaceSchedules(
          habit: habit,
          reminderEnabled: true,
          streakEnabled: false,
          now: now,
        ),
      ).thenThrow(Exception());

      final result = await saveHabit(habit: habit, notification: notification);

      expect(
        result.failures,
        containsAll({
          HabitOperationFailure.notificationConfig,
          HabitOperationFailure.notificationSchedule,
        }),
      );
      verify(() => habits.add(habit)).called(1);
    });

    test('Interrompe a operação quando o hábito não pode ser persistido', () async {
      when(() => habits.getById(habit.id)).thenReturn(null);
      when(() => habits.add(habit)).thenThrow(Exception('armazenamento'));

      await expectLater(
        saveHabit(habit: habit, notification: notification),
        throwsException,
      );

      verifyNever(() => configs.save(habit.id, notification));
      verifyNever(
        () => scheduler.replaceSchedules(
          habit: habit,
          reminderEnabled: true,
          streakEnabled: false,
          now: now,
        ),
      );
    });
  });
}
