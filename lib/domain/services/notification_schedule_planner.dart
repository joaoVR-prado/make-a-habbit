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
  static const _boundedScheduleHorizonDays = 60;

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
    final today = DateTime(now.year, now.month, now.day);
    final startDate = DateTime(
      habit.startDate.year,
      habit.startDate.month,
      habit.startDate.day,
    );
    if (startDate.isAfter(today)) return const [];
    final endDate = habit.endDate == null
        ? null
        : DateTime(
            habit.endDate!.year,
            habit.endDate!.month,
            habit.endDate!.day,
          );
    if (endDate != null && endDate.isBefore(today)) return const [];

    final baseId = habit.notificationId ?? baseIdForHabit(habit.id);
    if (endDate != null) {
      return _planBoundedSchedules(
        habit: habit,
        baseId: baseId,
        reminderEnabled: reminderEnabled,
        streakEnabled: streakEnabled,
        currentStreak: currentStreak,
        now: now,
        endDate: endDate,
      );
    }
    final notifications = <PlannedNotification>[];

    if (reminderEnabled && habit.notificationTime != null) {
      notifications.addAll(_planReminders(habit, baseId, now));
    }
    if (streakEnabled) {
      notifications.addAll(
        _planStreakNotifications(habit, baseId, now, currentStreak),
      );
    }

    return notifications;
  }

  List<PlannedNotification> _planBoundedSchedules({
    required HabitModel habit,
    required int baseId,
    required bool reminderEnabled,
    required bool streakEnabled,
    required int currentStreak,
    required DateTime now,
    required DateTime endDate,
  }) {
    final notifications = <PlannedNotification>[];
    final today = DateTime(now.year, now.month, now.day);
    final lastHorizonDay = DateTime(
      today.year,
      today.month,
      today.day + _boundedScheduleHorizonDays - 1,
    );
    final lastDay = endDate.isBefore(lastHorizonDay) ? endDate : lastHorizonDay;
    final reminderTime = habit.notificationTime;
    final streakBody = currentStreak == 0
        ? 'Vamos começar sua ofensiva de ${habit.name} hoje?'
        : 'Você completou ${habit.name} por $currentStreak dias. Continue persistindo!';

    for (var offset = 0; offset < _boundedScheduleHorizonDays; offset++) {
      final date = DateTime(today.year, today.month, today.day + offset);
      if (date.isAfter(lastDay)) break;
      if (!habit.isHabitActiveOn(date)) continue;

      if (reminderEnabled && reminderTime != null) {
        final occurrence = DateTime(
          date.year,
          date.month,
          date.day,
          reminderTime.hour,
          reminderTime.minute,
        );
        if (occurrence.isAfter(now)) {
          notifications.add(
            PlannedNotification(
              id: baseId + offset,
              title: 'Hora do seu hábito!',
              body: 'Não se esqueça de completar o hábito ${habit.name}',
              category: PlannedNotificationCategory.reminder,
              schedule: ExactDateSchedule(occurrence),
            ),
          );
        }
      }

      if (streakEnabled) {
        final occurrence = DateTime(date.year, date.month, date.day, 12);
        if (occurrence.isAfter(now)) {
          notifications.add(
            PlannedNotification(
              id: baseId + 1000 + offset,
              title: 'Make a Habbit!',
              body: streakBody,
              category: PlannedNotificationCategory.streak,
              schedule: ExactDateSchedule(occurrence),
            ),
          );
        }
      }
    }
    return notifications;
  }

  List<PlannedNotification> _planStreakNotifications(
    HabitModel habit,
    int baseId,
    DateTime now,
    int currentStreak,
  ) {
    final body = currentStreak == 0
        ? 'Vamos começar sua ofensiva de ${habit.name} hoje?'
        : 'Você completou ${habit.name} por $currentStreak dias. Continue persistindo!';

    PlannedNotification streak(int id, PlannedNotificationSchedule schedule) =>
        PlannedNotification(
          id: id,
          title: 'Make a Habbit!',
          body: body,
          category: PlannedNotificationCategory.streak,
          schedule: schedule,
        );

    return switch (habit.frequency.type) {
      HabitFrequencyType.daily => [
        streak(
          baseId + 1000,
          const RepeatingCalendarSchedule(hour: 12, minute: 0),
        ),
      ],
      HabitFrequencyType.weekly => [
        for (final weekday in habit.frequency.selectedDays)
          streak(
            baseId + 1000 + weekday,
            RepeatingCalendarSchedule(weekday: weekday, hour: 12, minute: 0),
          ),
      ],
      HabitFrequencyType.monthly => _planMonthlyStreaks(
        habit,
        baseId,
        now,
        streak,
      ),
    };
  }

  List<PlannedNotification> _planMonthlyStreaks(
    HabitModel habit,
    int baseId,
    DateTime now,
    PlannedNotification Function(int, PlannedNotificationSchedule) streak,
  ) {
    final result = <PlannedNotification>[
      for (final day in habit.frequency.selectedDays)
        if (day >= 1 && day <= 31)
          streak(
            baseId + 1000 + day,
            RepeatingCalendarSchedule(day: day, hour: 12, minute: 0),
          ),
    ];
    if (habit.frequency.selectedDays.contains(lastDayOfMonth)) {
      final dates = _nextLastDays(
        now,
        DateTime(0, 1, 1, 12),
        _lastDayHorizon,
        habit: habit,
      );
      for (var index = 0; index < dates.length; index++) {
        result.add(
          streak(baseId + 1050 + index, ExactDateSchedule(dates[index])),
        );
      }
    }
    return result;
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
          final dates = _nextLastDays(now, time, _lastDayHorizon, habit: habit);
          for (var index = 0; index < dates.length; index++) {
            result.add(
              reminder(baseId + 200 + index, ExactDateSchedule(dates[index])),
            );
          }
        }
        return result;
    }
  }

  List<DateTime> _nextLastDays(
    DateTime now,
    DateTime time,
    int count, {
    HabitModel? habit,
  }) {
    final dates = <DateTime>[];
    var monthOffset = 0;
    while (dates.length < count && monthOffset < 120) {
      final monthStart = DateTime(now.year, now.month + monthOffset);
      final lastDay = DateTime(monthStart.year, monthStart.month + 1, 0);
      final occurrence = DateTime(
        lastDay.year,
        lastDay.month,
        lastDay.day,
        time.hour,
        time.minute,
      );
      if (habit?.endDate case final endDate?) {
        final occurrenceDay = DateTime(
          occurrence.year,
          occurrence.month,
          occurrence.day,
        );
        final endDay = DateTime(endDate.year, endDate.month, endDate.day);
        if (occurrenceDay.isAfter(endDay)) break;
      }
      if (occurrence.isAfter(now) &&
          (habit == null || habit.isHabitActiveOn(occurrence))) {
        dates.add(occurrence);
      }
      monthOffset++;
    }
    return dates;
  }
}
