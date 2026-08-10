import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';
import 'package:make_a_habbit/data/services/awesome_notification_scheduler.dart';
import 'package:mocktail/mocktail.dart';

class _MockAwesomeNotifications extends Mock implements AwesomeNotifications {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      NotificationContent(id: 0, channelKey: 'teste'),
    );
    registerFallbackValue(NotificationCalendar(second: 0));
  });

  group('AwesomeNotificationScheduler', () {
    test('Cancela agendas anteriores antes de criar as novas.', () async {
      final awesome = _MockAwesomeNotifications();
      final habit = HabitModel(
        id: 'habit-1',
        iconCode: 0,
        name: 'Beber água',
        conclusionType: HabitConclusionType.yesNo,
        frequency: HabitFrequency.fromType(type: HabitFrequencyType.daily),
        startDate: DateTime(2026, 8, 8),
        notificationId: 1100,
        notificationTime: DateTime(2026, 8, 8, 9),
      );
      when(
        () => awesome.cancelSchedulesByGroupKey(habit.id),
      ).thenAnswer((_) async {});
      when(
        () => awesome.getLocalTimeZoneIdentifier(),
      ).thenAnswer((_) async => 'America/Sao_Paulo');
      when(
        () => awesome.createNotification(
          content: any(named: 'content'),
          schedule: any(named: 'schedule'),
        ),
      ).thenAnswer((_) async => true);
      final scheduler = AwesomeNotificationScheduler(notifications: awesome);

      await scheduler.replaceSchedules(
        habit: habit,
        reminderEnabled: true,
        streakEnabled: false,
        now: DateTime(2026, 8, 8),
      );

      verifyInOrder([
        () => awesome.cancelSchedulesByGroupKey(habit.id),
        () => awesome.getLocalTimeZoneIdentifier(),
        () => awesome.createNotification(
          content: any(named: 'content'),
          schedule: any(named: 'schedule'),
        ),
      ]);
    });
  });
}
