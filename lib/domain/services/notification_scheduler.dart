import 'package:make_a_habbit/data/models/habits/habit_model.dart';

abstract interface class NotificationScheduler {
  Future<void> replaceSchedules({
    required HabitModel habit,
    required bool reminderEnabled,
    required bool streakEnabled,
    required DateTime now,
    int currentStreak = 0,
  });

  Future<void> cancelForHabit(String habitId);
  Future<bool> isPermissionGranted();
  Future<bool> requestPermission();
}
