import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/domain/services/notification_schedule_planner.dart';
import 'package:make_a_habbit/domain/services/notification_scheduler.dart';

class AwesomeNotificationScheduler implements NotificationScheduler {
  AwesomeNotificationScheduler({
    AwesomeNotifications? notifications,
    NotificationSchedulePlanner planner = const NotificationSchedulePlanner(),
  }) : _notifications = notifications ?? AwesomeNotifications(),
       _planner = planner;

  static const channelKey = 'habit_reminders_v2';

  final AwesomeNotifications _notifications;
  final NotificationSchedulePlanner _planner;

  @override
  Future<void> replaceSchedules({
    required HabitModel habit,
    required bool reminderEnabled,
    required bool streakEnabled,
    required DateTime now,
    int currentStreak = 0,
  }) async {
    await cancelForHabit(habit.id);
    final timeZone = await _notifications.getLocalTimeZoneIdentifier();
    final plans = _planner.plan(
      habit: habit,
      reminderEnabled: reminderEnabled,
      streakEnabled: streakEnabled,
      currentStreak: currentStreak,
      now: now,
    );

    for (final plan in plans) {
      await _notifications.createNotification(
        content: NotificationContent(
          id: plan.id,
          channelKey: channelKey,
          groupKey: habit.id,
          title: plan.title,
          body: plan.body,
          category: plan.category == PlannedNotificationCategory.reminder
              ? NotificationCategory.Reminder
              : NotificationCategory.Status,
          wakeUpScreen: true,
        ),
        schedule: _toAwesomeSchedule(plan.schedule, timeZone),
      );
    }
  }

  NotificationSchedule _toAwesomeSchedule(
    PlannedNotificationSchedule schedule,
    String timeZone,
  ) {
    return switch (schedule) {
      RepeatingCalendarSchedule() => NotificationCalendar(
        timeZone: timeZone,
        day: schedule.day,
        weekday: schedule.weekday,
        hour: schedule.hour,
        minute: schedule.minute,
        second: 0,
        repeats: true,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
      ExactDateSchedule() => NotificationCalendar(
        timeZone: timeZone,
        year: schedule.date.year,
        month: schedule.date.month,
        day: schedule.date.day,
        hour: schedule.date.hour,
        minute: schedule.date.minute,
        second: 0,
        repeats: false,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    };
  }

  @override
  Future<void> cancelForHabit(String habitId) =>
      _notifications.cancelSchedulesByGroupKey(habitId);

  @override
  Future<bool> isPermissionGranted() =>
      _notifications.isNotificationAllowed();

  @override
  Future<bool> requestPermission() =>
      _notifications.requestPermissionToSendNotifications();
}
