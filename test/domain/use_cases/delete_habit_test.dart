import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/domain/repositories/conclusion_repository.dart';
import 'package:make_a_habbit/domain/repositories/habit_repository.dart';
import 'package:make_a_habbit/domain/repositories/notification_config_repository.dart';
import 'package:make_a_habbit/domain/services/notification_scheduler.dart';
import 'package:make_a_habbit/domain/use_cases/delete_habit.dart';
import 'package:make_a_habbit/domain/use_cases/habit_operation_result.dart';
import 'package:mocktail/mocktail.dart';

class _MockHabitRepository extends Mock implements HabitRepository {}

class _MockConclusionRepository extends Mock implements ConclusionRepository {}

class _MockNotificationConfigRepository extends Mock
    implements NotificationConfigRepository {}

class _MockNotificationScheduler extends Mock
    implements NotificationScheduler {}

void main() {
  late _MockHabitRepository habits;
  late _MockConclusionRepository conclusions;
  late _MockNotificationConfigRepository configs;
  late _MockNotificationScheduler scheduler;
  late DeleteHabit deleteHabit;
  const habitId = 'habito';

  setUp(() {
    habits = _MockHabitRepository();
    conclusions = _MockConclusionRepository();
    configs = _MockNotificationConfigRepository();
    scheduler = _MockNotificationScheduler();
    deleteHabit = DeleteHabit(
      habits: habits,
      conclusions: conclusions,
      notificationConfigs: configs,
      notificationScheduler: scheduler,
    );
  });

  group('CASOS DE USO PARA EXCLUIR HÁBITO', () {
    test(
      'Cancela a agenda antes de excluir o hábito e os dados relacionados.',
      () async {
        when(() => scheduler.cancelForHabit(habitId)).thenAnswer((_) async {});
        when(() => conclusions.deleteByHabit(habitId)).thenAnswer((_) async {});
        when(() => configs.delete(habitId)).thenAnswer((_) async {});
        when(() => habits.delete(habitId)).thenAnswer((_) async {});

        final result = await deleteHabit(habitId);

        expect(result.hasPartialFailures, isFalse);
        verifyInOrder([
          () => scheduler.cancelForHabit(habitId),
          () => habits.delete(habitId),
          () => conclusions.deleteByHabit(habitId),
          () => configs.delete(habitId),
        ]);
      },
    );

    test('Continua a limpeza e informa as falhas auxiliares.', () async {
      when(() => scheduler.cancelForHabit(habitId)).thenAnswer((_) async {});
      when(() => conclusions.deleteByHabit(habitId)).thenThrow(Exception());
      when(() => configs.delete(habitId)).thenThrow(Exception());
      when(() => habits.delete(habitId)).thenAnswer((_) async {});

      final result = await deleteHabit(habitId);

      expect(
        result.failures,
        containsAll([
          HabitOperationFailure.conclusions,
          HabitOperationFailure.notificationConfig,
        ]),
      );
      expect(
        result.failures,
        isNot(contains(HabitOperationFailure.notificationSchedule)),
      );
      verify(() => habits.delete(habitId)).called(1);
    });

    test(
      'Não exclui o hábito quando a agenda não pode ser cancelada.',
      () async {
        when(
          () => scheduler.cancelForHabit(habitId),
        ).thenThrow(Exception('agendamento'));

        await expectLater(deleteHabit(habitId), throwsException);

        verifyNever(() => habits.delete(habitId));
        verifyNever(() => conclusions.deleteByHabit(habitId));
        verifyNever(() => configs.delete(habitId));
      },
    );

    test(
      'Permite repetir a exclusão sem alterar a sequência de limpeza.',
      () async {
        when(() => scheduler.cancelForHabit(habitId)).thenAnswer((_) async {});
        when(() => conclusions.deleteByHabit(habitId)).thenAnswer((_) async {});
        when(() => configs.delete(habitId)).thenAnswer((_) async {});
        when(() => habits.delete(habitId)).thenAnswer((_) async {});

        await deleteHabit(habitId);
        await deleteHabit(habitId);

        verify(() => scheduler.cancelForHabit(habitId)).called(2);
        verify(() => conclusions.deleteByHabit(habitId)).called(2);
        verify(() => configs.delete(habitId)).called(2);
        verify(() => habits.delete(habitId)).called(2);
      },
    );

    test('Propaga a falha quando o hábito não pode ser excluído.', () async {
      when(() => scheduler.cancelForHabit(habitId)).thenAnswer((_) async {});
      when(() => conclusions.deleteByHabit(habitId)).thenAnswer((_) async {});
      when(() => configs.delete(habitId)).thenAnswer((_) async {});
      when(() => habits.delete(habitId)).thenThrow(Exception('armazenamento'));

      await expectLater(deleteHabit(habitId), throwsException);
      verify(() => scheduler.cancelForHabit(habitId)).called(1);
      verifyNever(() => conclusions.deleteByHabit(habitId));
      verifyNever(() => configs.delete(habitId));
    });
  });
}
