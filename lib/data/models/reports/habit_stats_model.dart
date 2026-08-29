class HabitStatsModel {
  final int totalHabits;
  final int completedToday;
  final double generalSuccessRate;
  final int bestStreakGeral;
  final Map<DateTime, int> weeklyCompletionHistory;

  HabitStatsModel({
    required this.totalHabits,
    required this.completedToday,
    required this.generalSuccessRate,
    required this.bestStreakGeral,
    required this.weeklyCompletionHistory,
  });
}
