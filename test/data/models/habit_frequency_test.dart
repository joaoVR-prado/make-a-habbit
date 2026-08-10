import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency_type.dart';

void main() {
  group('Frequência diária', () {
    test('Ocorre em qualquer dia.', () {
      final frequency = HabitFrequency.fromType(type: HabitFrequencyType.daily);

      expect(frequency, isA<DailyHabitFrequency>());
      expect(frequency.occursOn(DateTime(2026, 8, 9)), isTrue);
      expect(frequency.selectedDays, isEmpty);
    });
  });

  group('Frequência semanal', () {
    test('Ocorre somente nos dias selecionados.', () {
      final frequency = HabitFrequency.fromType(
        type: HabitFrequencyType.weekly,
        selectedDays: [DateTime.monday, DateTime.friday],
      );

      expect(frequency, isA<WeeklyHabitFrequency>());
      expect(frequency.occursOn(DateTime(2026, 8, 10)), isTrue);
      expect(frequency.occursOn(DateTime(2026, 8, 11)), isFalse);
    });

    test('Rejeita uma seleção vazia.', () {
      expect(
        () => HabitFrequency.fromType(
          type: HabitFrequencyType.weekly,
          selectedDays: const [],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Rejeita dias fora do intervalo de 1 - 7.', () {
      expect(
        () => HabitFrequency.fromType(
          type: HabitFrequencyType.weekly,
          selectedDays: const [0, 8],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Remove duplicidades e impede alteração externa.', () {
      final source = [DateTime.friday, DateTime.monday, DateTime.monday];
      final frequency = HabitFrequency.fromType(
        type: HabitFrequencyType.weekly,
        selectedDays: source,
      );
      source.add(DateTime.sunday);

      expect(frequency.selectedDays, [DateTime.monday, DateTime.friday]);
      expect(() => frequency.selectedDays.add(DateTime.sunday), throwsUnsupportedError);
    });
  });

  group('Frequência mensal', () {
    test('Rejeita dias fora do intervalo de 1 - 32.', () {
      expect(
        () => HabitFrequency.fromType(
          type: HabitFrequencyType.monthly,
          selectedDays: const [0, 33],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Interpreta 32 como o último dia do mê.s', () {
      final frequency = HabitFrequency.fromType(
        type: HabitFrequencyType.monthly,
        selectedDays: const [MonthlyHabitFrequency.lastDayOfMonth],
      );

      expect(frequency.occursOn(DateTime(2026, 2, 28)), isTrue);
      expect(frequency.occursOn(DateTime(2026, 2, 27)), isFalse);
      expect(frequency.occursOn(DateTime(2028, 2, 29)), isTrue);
      expect(frequency.occursOn(DateTime(2028, 2, 28)), isFalse);
    });
  });
}
