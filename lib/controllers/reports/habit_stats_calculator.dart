import 'package:make_a_habbit/domain/entities/conclusions/concluded_habits_model.dart';
import 'package:make_a_habbit/domain/entities/conclusions/completion_value.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/data/models/reports/habit_stats_model.dart';
import 'package:make_a_habbit/data/models/reports/habit_detail_stats_model.dart';

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
        _conclusionKey(conclusion.habitId, conclusion.conclusionDate):
            conclusion,
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
      bestStreakGeral: _bestStreak(habits, conclusions, today),
      weeklyCompletionHistory: weeklyData,
    );
  }

  HabitDetailStatsModel calculateForHabit({
    required HabitModel habit,
    required List<ConcludedHabitsModel> conclusions,
    required DateTime now,
  }) {
    final today = _dateOnly(now);
    final conclusionsByDate = <DateTime, ConcludedHabitsModel>{
      for (final conclusion in conclusions)
        if (conclusion.habitId == habit.id)
          _dateOnly(conclusion.conclusionDate): conclusion,
    };
    final completedDates = conclusionsByDate.entries
        .where(
          (entry) =>
              !entry.key.isAfter(today) &&
              habit.isHabitActiveOn(entry.key) &&
              _isCompleted(habit, entry.value),
        )
        .map((entry) => entry.key)
        .toSet();
    final incompleteDates = conclusionsByDate.entries
        .where(
          (entry) =>
              !entry.key.isAfter(today) &&
              habit.isHabitActiveOn(entry.key) &&
              !_isCompleted(habit, entry.value),
        )
        .map((entry) => entry.key)
        .toSet();

    var scheduledDays = 0;
    var completedDays = 0;
    for (var daysAgo = 0; daysAgo < 30; daysAgo++) {
      final date = today.subtract(Duration(days: daysAgo));
      if (!habit.isHabitActiveOn(date)) continue;
      scheduledDays++;
      if (completedDates.contains(date)) completedDays++;
    }

    return HabitDetailStatsModel(
      successRate: scheduledDays == 0 ? 0 : completedDays / scheduledDays * 100,
      currentStreak: _currentStreak(habit, completedDates, today),
      bestStreak: _bestStreakForHabit(habit, completedDates),
      totalCompletions: completedDates.length,
      habit: habit,
      now: today,
      completedDates: completedDates,
      incompleteDates: incompleteDates,
    );
  }

  int _bestStreak(
    List<HabitModel> habits,
    List<ConcludedHabitsModel> conclusions,
    DateTime today,
  ) {
    var bestOverall = 0;
    for (final habit in habits) {
      final completedDates =
          conclusions
              .where(
                (conclusion) =>
                    conclusion.habitId == habit.id &&
                    !_dateOnly(conclusion.conclusionDate).isAfter(today) &&
                    habit.isHabitActiveOn(conclusion.conclusionDate) &&
                    _isCompleted(habit, conclusion),
              )
              .map((conclusion) => _dateOnly(conclusion.conclusionDate))
              .toSet()
              .toList()
            ..sort();

      final bestForHabit = _bestStreakForHabit(habit, completedDates.toSet());
      if (bestForHabit > bestOverall) bestOverall = bestForHabit;
    }
    return bestOverall;
  }

  int _bestStreakForHabit(HabitModel habit, Set<DateTime> completedDates) {
    final dates = completedDates.toList()..sort();
    var current = 0;
    var best = 0;
    DateTime? previous;
    for (final date in dates) {
      if (previous == null) {
        current = 1;
      } else {
        final gap = _civilDayNumber(date) - _civilDayNumber(previous);
        final missedActiveDay =
            Iterable<int>.generate(gap - 1, (index) => index + 1)
                .map((offset) => _addCivilDays(previous!, offset))
                .any(habit.isHabitActiveOn);
        current = missedActiveDay ? 1 : current + 1;
      }
      if (current > best) best = current;
      previous = date;
    }
    return best;
  }

  int _currentStreak(
    HabitModel habit,
    Set<DateTime> completedDates,
    DateTime today,
  ) {
    if (_dateOnly(habit.startDate).isAfter(today)) return 0;
    var cursor = habit.endDate != null && habit.endDate!.isBefore(today)
        ? _dateOnly(habit.endDate!)
        : today;
    var streak = 0;

    while (!cursor.isBefore(_dateOnly(habit.startDate))) {
      if (habit.isHabitActiveOn(cursor)) {
        if (completedDates.contains(cursor)) {
          streak++;
        } else if (cursor == today) {
        } else {
          break;
        }
      }
      cursor = _addCivilDays(cursor, -1);
    }
    return streak;
  }

  bool _isCompleted(HabitModel habit, ConcludedHabitsModel? conclusion) {
    if (conclusion == null) return false;
    if (habit.conclusionType == HabitConclusionType.goalQuantity) {
      return switch (conclusion.conclusionValue) {
        QuantityCompletionValue(:final value) =>
          value >= (habit.goalQuantity ?? 1),
        _ => false,
      };
    }
    return switch (conclusion.conclusionValue) {
      YesNoCompletionValue(:final value) => value,
      _ => false,
    };
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _addCivilDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);

  int _civilDayNumber(DateTime date) => DateTime.utc(
    date.year,
    date.month,
    date.day,
  ).difference(DateTime.utc(1970)).inDays;

  String _conclusionKey(String habitId, DateTime date) {
    final normalized = _dateOnly(date);
    return '${habitId}_${normalized.toIso8601String()}';
  }
}
