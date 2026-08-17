import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/domain/repositories/conclusion_repository.dart';
import 'package:make_a_habbit/domain/repositories/habit_repository.dart';
import 'package:make_a_habbit/domain/repositories/notification_config_repository.dart';
import 'package:make_a_habbit/domain/services/notification_scheduler.dart';
import 'package:make_a_habbit/domain/use_cases/clear_habit_data.dart';
import 'package:make_a_habbit/domain/use_cases/habit_operation_result.dart';
import 'package:mocktail/mocktail.dart';

final class _MockHabitRepository extends Mock implements HabitRepository {}

final class _MockConclusionRepository extends Mock
    implements ConclusionRepository {}

final class _MockNotificationConfigRepository extends Mock
    implements NotificationConfigRepository {}

final class _MockNotificationScheduler extends Mock
    implements NotificationScheduler {}

void main() {
  late _MockHabitRepository habits;
  late _MockConclusionRepository conclusions;
  late _MockNotificationConfigRepository notifications;
  late _MockNotificationScheduler scheduler;
  late ClearHabitData clearHabitData;
  late List<HabitModel> savedHabits;

  setUp(() {
    habits = _MockHabitRepository();
    conclusions = _MockConclusionRepository();
    notifications = _MockNotificationConfigRepository();
    scheduler = _MockNotificationScheduler();
    savedHabits = [_habit('primeiro'), _habit('segundo')];
    clearHabitData = ClearHabitData(
      habits: habits,
      conclusions: conclusions,
      notificationConfigs: notifications,
      notificationScheduler: scheduler,
    );
  });

  group('CASO DE USO PARA LIMPAR OS DADOS DOS HÁBITOS', () {
    test('Cancela os agendamentos e limpa todos os repositórios.', () async {
      when(habits.getAll).thenReturn(savedHabits);
      for (final habit in savedHabits) {
        when(() => scheduler.cancelForHabit(habit.id)).thenAnswer((_) async {});
      }
      when(conclusions.clear).thenAnswer((_) async {});
      when(notifications.clear).thenAnswer((_) async {});
      when(habits.clear).thenAnswer((_) async {});

      final result = await clearHabitData();

      expect(result.hasPartialFailures, isFalse);
      verifyInOrder([
        () => scheduler.cancelForHabit('primeiro'),
        () => scheduler.cancelForHabit('segundo'),
        habits.clear,
        conclusions.clear,
        notifications.clear,
      ]);
    });

    test('Continua a limpeza quando serviços auxiliares falham.', () async {
      when(habits.getAll).thenReturn(savedHabits);
      when(() => scheduler.cancelForHabit('primeiro')).thenAnswer((_) async {});
      when(() => scheduler.cancelForHabit('segundo')).thenAnswer((_) async {});
      when(conclusions.clear).thenThrow(Exception('conclusões'));
      when(notifications.clear).thenThrow(Exception('configurações'));
      when(habits.clear).thenAnswer((_) async {});

      final result = await clearHabitData();

      expect(
        result.failures,
        containsAll([
          HabitOperationFailure.conclusions,
          HabitOperationFailure.notificationConfig,
        ]),
      );
      verify(habits.clear).called(1);
    });

    test(
      'Propaga a falha quando os hábitos não podem ser removidos.',
      () async {
        when(habits.getAll).thenReturn(const []);
        when(conclusions.clear).thenAnswer((_) async {});
        when(notifications.clear).thenAnswer((_) async {});
        when(habits.clear).thenThrow(Exception('armazenamento'));

        await expectLater(clearHabitData(), throwsException);
        verifyNever(() => scheduler.cancelForHabit(any()));
        verifyNever(conclusions.clear);
        verifyNever(notifications.clear);
      },
    );

    test(
      'Não apaga os hábitos quando uma agenda não pode ser cancelada',
      () async {
        when(habits.getAll).thenReturn(savedHabits);
        when(
          () => scheduler.cancelForHabit('primeiro'),
        ).thenThrow(Exception('agendamento'));

        await expectLater(clearHabitData(), throwsException);

        verifyNever(habits.clear);
        verifyNever(conclusions.clear);
        verifyNever(notifications.clear);
      },
    );
  });
}

HabitModel _habit(String id) => HabitModel(
  id: id,
  iconCode: 10,
  name: 'Hábito $id',
  conclusionType: HabitConclusionType.yesNo,
  frequency: const DailyHabitFrequency(),
  startDate: DateTime(2026, 8, 16),
);
