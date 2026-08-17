import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/domain/entities/notifications/notification_config_model.dart';
import 'package:make_a_habbit/domain/repositories/habit_repository.dart';
import 'package:make_a_habbit/domain/repositories/notification_config_repository.dart';
import 'package:make_a_habbit/domain/services/clock.dart';
import 'package:make_a_habbit/domain/services/notification_scheduler.dart';
import 'package:make_a_habbit/domain/use_cases/reconcile_habit_notifications.dart';
import 'package:mocktail/mocktail.dart';

final class _MockHabitRepository extends Mock implements HabitRepository {}

final class _MockNotificationConfigRepository extends Mock
    implements NotificationConfigRepository {}

final class _MockNotificationScheduler extends Mock
    implements NotificationScheduler {}

final class _FixedClock implements Clock {
  @override
  DateTime now() => DateTime(2026, 8, 17, 12);
}

void main() {
  late _MockHabitRepository habits;
  late _MockNotificationConfigRepository configs;
  late _MockNotificationScheduler scheduler;
  late ReconcileHabitNotifications reconcile;

  setUpAll(() => registerFallbackValue(_habit('fallback')));

  setUp(() {
    habits = _MockHabitRepository();
    configs = _MockNotificationConfigRepository();
    scheduler = _MockNotificationScheduler();
    reconcile = ReconcileHabitNotifications(
      habits: habits,
      notificationConfigs: configs,
      notificationScheduler: scheduler,
      clock: _FixedClock(),
    );
  });

  group('RECONCILIAÇÃO DAS NOTIFICAÇÕES', () {
    test('Substitui as agendas usando a configuração persistida.', () async {
      final habit = _habit('ativo');
      when(habits.getAll).thenReturn([habit]);
      when(() => configs.get(habit.id)).thenReturn(_config);
      when(
        () => scheduler.replaceSchedules(
          habit: habit,
          reminderEnabled: true,
          streakEnabled: true,
          now: any(named: 'now'),
        ),
      ).thenAnswer((_) async {});

      final result = await reconcile();

      expect(result.hasFailures, isFalse);
      verify(
        () => scheduler.replaceSchedules(
          habit: habit,
          reminderEnabled: true,
          streakEnabled: true,
          now: DateTime(2026, 8, 17, 12),
        ),
      ).called(1);
    });

    test('Cancela as agendas quando a configuração não existe.', () async {
      final habit = _habit('sem-configuracao');
      when(habits.getAll).thenReturn([habit]);
      when(() => configs.get(habit.id)).thenReturn(null);
      when(() => scheduler.cancelForHabit(habit.id)).thenAnswer((_) async {});

      await reconcile();

      verify(() => scheduler.cancelForHabit(habit.id)).called(1);
      verifyNever(
        () => scheduler.replaceSchedules(
          habit: any(named: 'habit'),
          reminderEnabled: any(named: 'reminderEnabled'),
          streakEnabled: any(named: 'streakEnabled'),
          now: any(named: 'now'),
        ),
      );
    });

    test('Continua os demais hábitos quando uma agenda falha.', () async {
      final first = _habit('primeiro');
      final second = _habit('segundo');
      when(habits.getAll).thenReturn([first, second]);
      when(() => configs.get(any())).thenReturn(_config);
      when(
        () => scheduler.replaceSchedules(
          habit: first,
          reminderEnabled: true,
          streakEnabled: true,
          now: any(named: 'now'),
        ),
      ).thenThrow(Exception('agenda'));
      when(
        () => scheduler.replaceSchedules(
          habit: second,
          reminderEnabled: true,
          streakEnabled: true,
          now: any(named: 'now'),
        ),
      ).thenAnswer((_) async {});

      final result = await reconcile();

      expect(result.failedHabitIds, {'primeiro'});
      verify(
        () => scheduler.replaceSchedules(
          habit: second,
          reminderEnabled: true,
          streakEnabled: true,
          now: any(named: 'now'),
        ),
      ).called(1);
    });
  });
}

const _config = NotificationConfigModel(
  isReminderEnabled: true,
  isStreakEnabled: true,
  customTimeNotification: [],
);

HabitModel _habit(String id) => HabitModel(
  id: id,
  iconCode: 1,
  name: 'Hábito $id',
  conclusionType: HabitConclusionType.yesNo,
  frequency: const DailyHabitFrequency(),
  startDate: DateTime(2026, 1, 1),
  notificationTime: DateTime(2026, 1, 1, 9),
);
