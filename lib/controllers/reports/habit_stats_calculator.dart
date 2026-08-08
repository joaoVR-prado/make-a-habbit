import 'package:make_a_habbit/data/models/concluded_habits/concluded_habits_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';
import 'package:make_a_habbit/data/models/reports/habit_stats_model.dart';

class HabitStatsCalculator {
  const HabitStatsCalculator();

  HabitStatsModel calculate({
    required List<HabitModel> habits,
    required List<ConcludedHabitsModel> conclusions,
    required DateTime now,
  }) {
    final today = _dateOnly(now);
    final conclusionsByHabitAndDate = <String, ConcludedHabitsModel>{
      for (final conclusion in conclusions)
        _conclusionKey(conclusion.habitId, conclusion.conclusionDate): conclusion,
    };

    final weeklyData = <DateTime, int>{};
    for (var daysAgo = 6; daysAgo >= 0; daysAgo--) {
      final date = today.subtract(Duration(days: daysAgo));
      weeklyData[date] = habits.where((habit) {
        if (!habit.isHabitActiveOn(date)) return false;
        return _isCompleted(
          habit,
          conclusionsByHabitAndDate[_conclusionKey(habit.id, date)],
        );
      }).length;
    }

    var activeHabitDays = 0;
    var completedHabitDays = 0;
    for (var daysAgo = 0; daysAgo < 30; daysAgo++) {
      final date = today.subtract(Duration(days: daysAgo));
      for (final habit in habits) {
        if (!habit.isHabitActiveOn(date)) continue;
        activeHabitDays++;
        if (_isCompleted(
          habit,
          conclusionsByHabitAndDate[_conclusionKey(habit.id, date)],
        )) {
          completedHabitDays++;
        }
      }
    }

    return HabitStatsModel(
      totalHabits: habits.where((habit) => habit.isHabitActiveOn(today)).length,
      completedToday: weeklyData[today] ?? 0,
      generalSuccessRate: activeHabitDays == 0
          ? 0
          : completedHabitDays / activeHabitDays * 100,
      bestStreakGeral: _bestStreak(habits, conclusions),
      weeklyCompletionHistory: weeklyData,
    );
  }

  int _bestStreak(
    List<HabitModel> habits,
    List<ConcludedHabitsModel> conclusions,
  ) {
    var bestOverall = 0;
    for (final habit in habits) {
      final completedDates = conclusions
          .where(
            (conclusion) =>
                conclusion.habitId == habit.id &&
                habit.isHabitActiveOn(conclusion.conclusionDate) &&
                _isCompleted(habit, conclusion),
          )
          .map((conclusion) => _dateOnly(conclusion.conclusionDate))
          .toSet()
          .toList()
        ..sort();

      var current = 0;
      var bestForHabit = 0;
      DateTime? previous;
      for (final date in completedDates) {
        if (previous == null) {
          current = 1;
        } else {
          final gap = date.difference(previous).inDays;
          final missedActiveDay = Iterable<int>.generate(
            gap - 1,
            (index) => index + 1,
          )
              .map((offset) => previous!.add(Duration(days: offset)))
              .any(habit.isHabitActiveOn);
          current = missedActiveDay ? 1 : current + 1;
        }
        if (current > bestForHabit) bestForHabit = current;
        previous = date;
      }
      if (bestForHabit > bestOverall) bestOverall = bestForHabit;
    }
    return bestOverall;
  }

  bool _isCompleted(
    HabitModel habit,
    ConcludedHabitsModel? conclusion,
  ) {
    if (conclusion == null) return false;
    if (habit.conclusionType == HabitConclusionType.goalQuantity) {
      final value = conclusion.conclusionValue;
      return value is num && value >= (habit.goalQuantity ?? 1);
    }
    return conclusion.conclusionValue == true;
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  String _conclusionKey(String habitId, DateTime date) {
    final normalized = _dateOnly(date);
    return '${habitId}_${normalized.toIso8601String()}';
  }
}
