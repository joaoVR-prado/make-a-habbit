import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';

void main() {
  HabitModel criarHabito({
    String id = 'habito',
    String name = 'Beber água',
    HabitConclusionType conclusionType = HabitConclusionType.yesNo,
    int? goalQuantity,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return HabitModel(
      id: id,
      iconCode: 0,
      name: name,
      conclusionType: conclusionType,
      goalQuantity: goalQuantity,
      frequency: HabitFrequency.fromType(type: HabitFrequencyType.daily),
      startDate: startDate ?? DateTime(2026, 8, 9),
      endDate: endDate,
    );
  }

  group('Id e nome do hábito', () {
    test('Remove espaços externos do nome.', () {
      final habit = criarHabito(name: '  Beber água  ');

      expect(habit.name, 'Beber água');
    });

    test('Rejeita id vazio.', () {
      expect(() => criarHabito(id: '  '), throwsA(isA<ArgumentError>()));
    });

    test('Rejeita nome com menos de 3 caracteres.', () {
      expect(() => criarHabito(name: 'ab'), throwsA(isA<ArgumentError>()));
    });
  });

  group('Tipo de conclusão e meta', () {
    test('Exige meta positiva para hábito quantitativo.', () {
      expect(
        () => criarHabito(conclusionType: HabitConclusionType.goalQuantity),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => criarHabito(
          conclusionType: HabitConclusionType.goalQuantity,
          goalQuantity: 0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Aceita uma meta quantitativa positiva.', () {
      final habit = criarHabito(
        conclusionType: HabitConclusionType.goalQuantity,
        goalQuantity: 2,
      );

      expect(habit.goalQuantity, 2);
    });

    test('Rejeita meta em hábito do tipo sim ou não.', () {
      expect(() => criarHabito(goalQuantity: 1), throwsA(isA<ArgumentError>()));
    });
  });

  group('Intervalo de atividade', () {
    test('Rejeita data final anterior à data inicial.', () {
      expect(
        () => criarHabito(
          startDate: DateTime(2026, 8, 9),
          endDate: DateTime(2026, 8, 8),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Considera as datas inicial e final como inclusivas.', () {
      final habit = criarHabito(
        startDate: DateTime(2026, 8, 9, 20),
        endDate: DateTime(2026, 8, 10, 8),
      );

      expect(habit.isHabitActiveOn(DateTime(2026, 8, 9)), isTrue);
      expect(habit.isHabitActiveOn(DateTime(2026, 8, 10)), isTrue);
      expect(habit.isHabitActiveOn(DateTime(2026, 8, 11)), isFalse);
    });

    test('Cceita horários invertidos quando as datas são do mesmo dia.', () {
      final habit = criarHabito(
        startDate: DateTime(2026, 8, 9, 20),
        endDate: DateTime(2026, 8, 9, 8),
      );

      expect(habit.isHabitActiveOn(DateTime(2026, 8, 9)), isTrue);
    });
  });
}
