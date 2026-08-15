import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/controllers/reports/habit_stats_calculator.dart';
import 'package:make_a_habbit/domain/entities/conclusions/concluded_habits_model.dart';
import 'package:make_a_habbit/domain/entities/conclusions/completion_value.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';

void main() {
  const calculator = HabitStatsCalculator();
  final today = DateTime(2026, 8, 6);

  HabitModel habit({
    required String id,
    HabitConclusionType type = HabitConclusionType.yesNo,
    int? goal,
    HabitFrequencyType frequencyType = HabitFrequencyType.daily,
    List<int>? selectedDays,
    DateTime? startDate,
  }) {
    return HabitModel(
      id: id,
      iconCode: 0,
      name: 'Hábito com metas a serem batidas!',
      conclusionType: type,
      goalQuantity: goal,
      frequency: HabitFrequency.fromType(
        type: frequencyType,
        selectedDays: selectedDays,
      ),
      startDate: startDate ?? today.subtract(const Duration(days: 60)),
    );
  }

  ConcludedHabitsModel conclusion(String id, DateTime date, Object value) {
    return ConcludedHabitsModel(
      habitId: id,
      conclusionDate: date,
      conclusionValue: switch (value) {
        bool value => YesNoCompletionValue(value),
        int value => QuantityCompletionValue(value),
        _ => throw ArgumentError.value(value),
      },
    );
  }

  group('TESTES BÁSICOS SOBRE OS RELATÓRIOS DE HÁBITOS', (){
    test('Retorna com as conquistas zeradas quando não tenho um hábito', () {
      final stats = calculator.calculate(habits: [], conclusions: [], now: today);

      expect(stats.totalHabits, 0);
      expect(stats.completedToday, 0);
      expect(stats.generalSuccessRate, 0);
      expect(stats.bestStreakGeral, 0);
      expect(stats.weeklyCompletionHistory.length, 7);

    });

    test('Conta as conclusões de hábitos do tipo booleano (sim/não) e de quantidade ', () {
      final habits = [
        habit(id: 'boolean'),
        habit(
          id: 'quantity',
          type: HabitConclusionType.goalQuantity,
          goal: 3,
        ),
      ];
      final conclusions = [
        conclusion('boolean', today, true),
        conclusion('quantity', today, 3),
      ];

      final stats = calculator.calculate(
        habits: habits,
        conclusions: conclusions,
        now: today,
      );

      expect(stats.completedToday, 2);
      expect(stats.weeklyCompletionHistory[today], 2);
    });

    test('Calcula a taxa de sucesso de habitos diarios', () {
      final start = today.subtract(const Duration(days: 1));
      final dailyHabit = habit(id: 'daily', startDate: start);
      final stats = calculator.calculate(
        habits: [dailyHabit],
        conclusions: [conclusion('daily', today, true)],
        now: today,
      );

      expect(stats.generalSuccessRate, 50);
    });

    test('Testa se segue a regra de não calcular conclusões em datas que o hábito não ocorre está correta', () {
      final futureHabit = habit(
        id: 'future',
        startDate: today.add(const Duration(days: 1)),
      );
      final stats = calculator.calculate(
        habits: [futureHabit],
        conclusions: [conclusion('future', today, true)],
        now: today,
      );

      expect(stats.totalHabits, 0);
      expect(stats.completedToday, 0);
      expect(stats.generalSuccessRate, 0);
    });

    test('Mantem a sequência em dias que o hábito não está agendado', () {
      final monday = DateTime(2026, 8, 3);
      final wednesday = DateTime(2026, 8, 5);
      final weeklyHabit = habit(
        id: 'weekly',
        frequencyType: HabitFrequencyType.weekly,
        selectedDays: [DateTime.monday, DateTime.wednesday],
      );
      final stats = calculator.calculate(
        habits: [weeklyHabit],
        conclusions: [
          conclusion('weekly', monday, true),
          conclusion('weekly', wednesday, true),
        ],
        now: today,
      );

      expect(stats.bestStreakGeral, 2);
    });

    test('Quebra a sequência quando um hábito não é concluído no dia ', () {
      final monday = DateTime(2026, 8, 3);
      final wednesday = DateTime(2026, 8, 5);
      final dailyHabit = habit(id: 'daily');
      final stats = calculator.calculate(
        habits: [dailyHabit],
        conclusions: [
          conclusion('daily', monday, true),
          conclusion('daily', wednesday, true),
        ],
        now: today,
      );

      expect(stats.bestStreakGeral, 1);

    });

  });

  
}
