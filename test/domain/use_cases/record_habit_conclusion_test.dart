import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/domain/entities/conclusions/completion_value.dart';
import 'package:make_a_habbit/domain/entities/conclusions/concluded_habits_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/domain/repositories/conclusion_repository.dart';
import 'package:make_a_habbit/domain/repositories/habit_repository.dart';
import 'package:make_a_habbit/domain/services/clock.dart';
import 'package:make_a_habbit/domain/use_cases/record_habit_conclusion.dart';
import 'package:mocktail/mocktail.dart';

final class _MockHabitRepository extends Mock implements HabitRepository {}

final class _MockConclusionRepository extends Mock
    implements ConclusionRepository {}

final class _FakeConclusion extends Fake implements ConcludedHabitsModel {}

final class _FixedClock implements Clock {
  @override
  DateTime now() => DateTime(2026, 8, 16, 12);
}

void main() {
  late _MockHabitRepository habits;
  late _MockConclusionRepository conclusions;
  late RecordHabitConclusion recordConclusion;

  setUpAll(() => registerFallbackValue(_FakeConclusion()));

  setUp(() {
    habits = _MockHabitRepository();
    conclusions = _MockConclusionRepository();
    recordConclusion = RecordHabitConclusion(
      habits: habits,
      conclusions: conclusions,
      clock: _FixedClock(),
    );
  });

  group('VALIDAÇÃO DO REGISTRO DE CONCLUSÕES', () {
    test('Registra uma conclusão válida para o hábito.', () async {
      when(() => habits.getById('habito')).thenReturn(_habit());
      when(() => conclusions.save(any())).thenAnswer((_) async {});

      final result = await recordConclusion(
        habitId: 'habito',
        date: DateTime(2026, 8, 10, 18),
        value: const YesNoCompletionValue(true),
      );

      expect(result.conclusionDate, DateTime(2026, 8, 10));
      verify(() => conclusions.save(any())).called(1);
    });

    test('Rejeita a conclusão quando o hábito não existe.', () async {
      when(() => habits.getById('inexistente')).thenReturn(null);

      await expectLater(
        recordConclusion(
          habitId: 'inexistente',
          date: DateTime(2026, 8, 10),
          value: const YesNoCompletionValue(true),
        ),
        throwsArgumentError,
      );
      verifyNever(() => conclusions.save(any()));
    });

    test('Rejeita a conclusão em uma data não agendada.', () async {
      when(
        () => habits.getById('habito'),
      ).thenReturn(_habit(frequency: WeeklyHabitFrequency(const [1])));

      await expectLater(
        recordConclusion(
          habitId: 'habito',
          date: DateTime(2026, 8, 11),
          value: const YesNoCompletionValue(true),
        ),
        throwsArgumentError,
      );
      verifyNever(() => conclusions.save(any()));
    });

    test('Rejeita a conclusão antes do início ou depois do término.', () async {
      when(() => habits.getById('habito')).thenReturn(
        _habit(
          startDate: DateTime(2026, 8, 10),
          endDate: DateTime(2026, 8, 12),
        ),
      );

      await expectLater(
        recordConclusion(
          habitId: 'habito',
          date: DateTime(2026, 8, 9),
          value: const YesNoCompletionValue(true),
        ),
        throwsArgumentError,
      );
      await expectLater(
        recordConclusion(
          habitId: 'habito',
          date: DateTime(2026, 8, 13),
          value: const YesNoCompletionValue(true),
        ),
        throwsArgumentError,
      );
      verifyNever(() => conclusions.save(any()));
    });

    test('Rejeita um tipo de conclusão incompatível com o hábito.', () async {
      when(() => habits.getById('habito')).thenReturn(_habit());

      await expectLater(
        recordConclusion(
          habitId: 'habito',
          date: DateTime(2026, 8, 10),
          value: QuantityCompletionValue(2),
        ),
        throwsArgumentError,
      );
      verifyNever(() => conclusions.save(any()));
    });
  });
}

HabitModel _habit({
  HabitFrequency frequency = const DailyHabitFrequency(),
  DateTime? startDate,
  DateTime? endDate,
}) => HabitModel(
  id: 'habito',
  iconCode: 1,
  name: 'Hábito válido',
  conclusionType: HabitConclusionType.yesNo,
  frequency: frequency,
  startDate: startDate ?? DateTime(2026, 1, 1),
  endDate: endDate,
);
