import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/controllers/reports/habit_stats_calculator.dart';
import 'package:make_a_habbit/data/models/reports/habit_detail_stats_model.dart';
import 'package:make_a_habbit/domain/entities/conclusions/concluded_habits_model.dart';
import 'package:make_a_habbit/domain/entities/conclusions/completion_value.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';

void main() {
  const calculator = HabitStatsCalculator();
  final today = DateTime(2026, 8, 16);

  group('ESTATÍSTICAS DETALHADAS DO HÁBITO', () {
    test('Calcula taxa, sequências e total para hábito sim ou não.', () {
      final habit = _dailyHabit(startDate: DateTime(2026, 8, 14));
      final stats = calculator.calculateForHabit(
        habit: habit,
        conclusions: [
          _conclusion(habit.id, DateTime(2026, 8, 14), true),
          _conclusion(habit.id, DateTime(2026, 8, 15), true),
        ],
        now: today,
      );

      expect(stats.successRate, closeTo(66.67, 0.01));
      expect(stats.currentStreak, 2);
      expect(stats.bestStreak, 2);
      expect(stats.totalCompletions, 2);
    });

    test('Conta hábito quantitativo apenas quando a meta é alcançada.', () {
      final habit = _dailyHabit(
        startDate: DateTime(2026, 8, 14),
        type: HabitConclusionType.goalQuantity,
        goal: 5,
      );
      final stats = calculator.calculateForHabit(
        habit: habit,
        conclusions: [
          _conclusion(habit.id, DateTime(2026, 8, 14), 4),
          _conclusion(habit.id, DateTime(2026, 8, 15), 5),
          _conclusion(habit.id, today, 8),
        ],
        now: today,
      );

      expect(stats.totalCompletions, 2);
      expect(stats.successRate, closeTo(66.67, 0.01));
    });

    test('Considera somente dias agendados na taxa e na sequência.', () {
      final habit = HabitModel(
        id: 'semanal',
        iconCode: 0,
        name: 'Hábito semanal',
        conclusionType: HabitConclusionType.yesNo,
        frequency: WeeklyHabitFrequency(const [
          DateTime.monday,
          DateTime.wednesday,
        ]),
        startDate: DateTime(2026, 8, 1),
      );
      final stats = calculator.calculateForHabit(
        habit: habit,
        conclusions: [
          _conclusion(habit.id, DateTime(2026, 8, 10), true),
          _conclusion(habit.id, DateTime(2026, 8, 12), true),
        ],
        now: DateTime(2026, 8, 13),
      );

      expect(stats.currentStreak, 2);
      expect(stats.bestStreak, 2);
    });

    test('Classifica dias concluídos, perdidos, pendentes e inativos.', () {
      final habit = _dailyHabit(startDate: DateTime(2026, 8, 14));
      final stats = calculator.calculateForHabit(
        habit: habit,
        conclusions: [
          _conclusion(habit.id, DateTime(2026, 8, 14), true),
          _conclusion(habit.id, today, false),
        ],
        now: today,
      );

      expect(stats.statusOn(DateTime(2026, 8, 13)), HabitDayStatus.inactive);
      expect(stats.statusOn(DateTime(2026, 8, 14)), HabitDayStatus.completed);
      expect(stats.statusOn(DateTime(2026, 8, 15)), HabitDayStatus.missed);
      expect(stats.statusOn(today), HabitDayStatus.missed);
      expect(stats.statusOn(DateTime(2026, 8, 17)), HabitDayStatus.pending);
    });

    test('Retorna métricas zeradas para um hábito futuro.', () {
      final habit = _dailyHabit(startDate: DateTime(2026, 9, 1));
      final stats = calculator.calculateForHabit(
        habit: habit,
        conclusions: const [],
        now: today,
      );

      expect(stats.successRate, 0);
      expect(stats.currentStreak, 0);
      expect(stats.bestStreak, 0);
      expect(stats.totalCompletions, 0);
    });

    test('Calcula a sequência final de um hábito encerrado.', () {
      final habit = HabitModel(
        id: 'encerrado',
        iconCode: 0,
        name: 'Hábito encerrado',
        conclusionType: HabitConclusionType.yesNo,
        frequency: const DailyHabitFrequency(),
        startDate: DateTime(2026, 7, 1),
        endDate: DateTime(2026, 7, 31),
      );
      final stats = calculator.calculateForHabit(
        habit: habit,
        conclusions: [
          _conclusion(habit.id, DateTime(2026, 7, 30), true),
          _conclusion(habit.id, DateTime(2026, 7, 31), true),
        ],
        now: today,
      );

      expect(stats.currentStreak, 2);
      expect(stats.statusOn(DateTime(2026, 8, 1)), HabitDayStatus.inactive);
    });

    test('Ignora conclusões futuras legadas nas métricas e no calendário.', () {
      final habit = _dailyHabit(startDate: DateTime(2026, 8, 14));

      final stats = calculator.calculateForHabit(
        habit: habit,
        conclusions: [
          _conclusion(habit.id, DateTime(2026, 8, 15), true),
          _conclusion(habit.id, DateTime(2026, 8, 17), true),
        ],
        now: today,
      );

      expect(stats.totalCompletions, 1);
      expect(stats.bestStreak, 1);
      expect(stats.statusOn(DateTime(2026, 8, 17)), HabitDayStatus.pending);
    });

    test('Mantém a sequência durante a virada do ano.', () {
      final habit = _dailyHabit(startDate: DateTime(2025, 12, 30));

      final stats = calculator.calculateForHabit(
        habit: habit,
        conclusions: [
          _conclusion(habit.id, DateTime(2025, 12, 31), true),
          _conclusion(habit.id, DateTime(2026, 1, 1), true),
        ],
        now: DateTime(2026, 1, 2),
      );

      expect(stats.currentStreak, 2);
      expect(stats.bestStreak, 2);
    });
  });
}

HabitModel _dailyHabit({
  required DateTime startDate,
  HabitConclusionType type = HabitConclusionType.yesNo,
  int? goal,
}) => HabitModel(
  id: 'habito',
  iconCode: 0,
  name: 'Hábito diário',
  conclusionType: type,
  goalQuantity: goal,
  frequency: const DailyHabitFrequency(),
  startDate: startDate,
);

ConcludedHabitsModel _conclusion(String id, DateTime date, Object value) =>
    ConcludedHabitsModel(
      habitId: id,
      conclusionDate: date,
      conclusionValue: switch (value) {
        bool value => YesNoCompletionValue(value),
        int value => QuantityCompletionValue(value),
        _ => throw ArgumentError.value(value),
      },
    );
