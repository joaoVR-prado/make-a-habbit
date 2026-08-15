import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';

enum PlannedNotificationCategory { reminder, streak }

sealed class PlannedNotificationSchedule {
  const PlannedNotificationSchedule();
}

class RepeatingCalendarSchedule extends PlannedNotificationSchedule {
  const RepeatingCalendarSchedule({
    required this.hour,
    required this.minute,
    this.weekday,
    this.day,
  });

  final int hour;
  final int minute;
  final int? weekday;
  final int? day;
}

class ExactDateSchedule extends PlannedNotificationSchedule {
  const ExactDateSchedule(this.date);

  final DateTime date;
}

class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.schedule,
  });

  final int id;
  final String title;
  final String body;
  final PlannedNotificationCategory category;
  final PlannedNotificationSchedule schedule;
}

class NotificationSchedulePlanner {
  const NotificationSchedulePlanner();

  static const lastDayOfMonth = MonthlyHabitFrequency.lastDayOfMonth;
  static const _lastDayHorizon = 12;

  int baseIdForHabit(String habitId) {
    var hash = 0x811c9dc5;
    for (final codeUnit in habitId.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return (1 + hash % 1900000) * 1100;
  }

  List<PlannedNotification> plan({
    required HabitModel habit,
    required bool reminderEnabled,
    required bool streakEnabled,
    required DateTime now,
    int currentStreak = 0,
  }) {
    final baseId = habit.notificationId ?? baseIdForHabit(habit.id);
    final notifications = <PlannedNotification>[];

    if (reminderEnabled && habit.notificationTime != null) {
      notifications.addAll(_planReminders(habit, baseId, now));
    }
    if (streakEnabled) {
      notifications.add(
        PlannedNotification(
          id: baseId + 1000,
          title: 'Make a Habbit!',
          body: currentStreak == 0
              ? 'Vamos começar sua ofensiva de ${habit.name} hoje?'
              : 'Você completou ${habit.name} por $currentStreak dias. Continue persistindo!',
          category: PlannedNotificationCategory.streak,
          schedule: const RepeatingCalendarSchedule(hour: 12, minute: 0),
        ),
      );
    }

    return notifications;
  }

  List<PlannedNotification> _planReminders(
    HabitModel habit,
    int baseId,
    DateTime now,
  ) {
    final time = habit.notificationTime!;
    final title = 'Hora do seu hábito!';
    final body = 'Não se esqueça de completar o hábito ${habit.name}';

    PlannedNotification reminder(int id, PlannedNotificationSchedule schedule) {
      return PlannedNotification(
        id: id,
        title: title,
        body: body,
        category: PlannedNotificationCategory.reminder,
        schedule: schedule,
      );
    }

    switch (habit.frequency.type) {
      case HabitFrequencyType.daily:
        return [
          reminder(
            baseId,
            RepeatingCalendarSchedule(hour: time.hour, minute: time.minute),
          ),
        ];
      case HabitFrequencyType.weekly:
        return [
          for (final weekday in habit.frequency.selectedDays)
            reminder(
              baseId + weekday,
              RepeatingCalendarSchedule(
                weekday: weekday,
                hour: time.hour,
                minute: time.minute,
              ),
            ),
        ];
      case HabitFrequencyType.monthly:
        final days = habit.frequency.selectedDays;
        final result = <PlannedNotification>[
          for (final day in days)
            if (day >= 1 && day <= 31)
              reminder(
                baseId + 100 + day,
                RepeatingCalendarSchedule(
                  day: day,
                  hour: time.hour,
                  minute: time.minute,
                ),
              ),
        ];
        if (days.contains(lastDayOfMonth)) {
          final dates = _nextLastDays(now, time, _lastDayHorizon);
          for (var index = 0; index < dates.length; index++) {
            result.add(
              reminder(
                baseId + 200 + index,
                ExactDateSchedule(dates[index]),
              ),
            );
          }
        }
        return result;
    }
  }

  List<DateTime> _nextLastDays(DateTime now, DateTime time, int count) {
    final dates = <DateTime>[];
    var monthOffset = 0;
    while (dates.length < count) {
      final monthStart = DateTime(now.year, now.month + monthOffset);
      final lastDay = DateTime(monthStart.year, monthStart.month + 1, 0);
      final occurrence = DateTime(
        lastDay.year,
        lastDay.month,
        lastDay.day,
        time.hour,
        time.minute,
      );
      if (occurrence.isAfter(now)) dates.add(occurrence);
      monthOffset++;
    }
    return dates;
  }
}
