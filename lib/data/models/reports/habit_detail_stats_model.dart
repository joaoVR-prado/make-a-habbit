import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';

enum HabitDayStatus { inactive, completed, missed, pending }

final class HabitDetailStatsModel {
  HabitDetailStatsModel({
    required this.successRate,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalCompletions,
    required HabitModel habit,
    required DateTime now,
    required Set<DateTime> completedDates,
    required Set<DateTime> incompleteDates,
  }) : _habit = habit,
       _today = _dateOnly(now),
       _completedDates = Set.unmodifiable(completedDates.map(_dateOnly)),
       _incompleteDates = Set.unmodifiable(incompleteDates.map(_dateOnly));

  final double successRate;
  final int currentStreak;
  final int bestStreak;
  final int totalCompletions;
  final HabitModel _habit;
  final DateTime _today;
  final Set<DateTime> _completedDates;
  final Set<DateTime> _incompleteDates;

  HabitDayStatus statusOn(DateTime date) {
    final day = _dateOnly(date);
    if (!_habit.isHabitActiveOn(day)) return HabitDayStatus.inactive;
    if (_completedDates.contains(day)) return HabitDayStatus.completed;
    if (_incompleteDates.contains(day)) return HabitDayStatus.missed;
    if (day.isBefore(_today)) return HabitDayStatus.missed;
    return HabitDayStatus.pending;
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
