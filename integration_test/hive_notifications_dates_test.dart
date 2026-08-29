import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:integration_test/integration_test.dart';
import 'package:make_a_habbit/core/providers/clock_provider.dart';
import 'package:make_a_habbit/data/dtos/conclusion_dto.dart';
import 'package:make_a_habbit/data/dtos/habit_dto.dart';
import 'package:make_a_habbit/data/dtos/notification_config_dto.dart';
import 'package:make_a_habbit/app/providers/dependency_providers.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/services/clock.dart';
import 'package:make_a_habbit/domain/services/notification_scheduler.dart';
import 'package:make_a_habbit/main.dart';
import 'package:make_a_habbit/presentation/home_page/widgets/habits_list_tile.dart';

import 'helpers/hive_test_environment.dart';
import 'helpers/next_page_habit_creation.dart';
import 'helpers/setup_integration_tests.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setupIntegrationTests();

  group('HIVE, NOTIFICAÇÕES E DATAS', () {
    testWidgets('Persiste lembrete e ofensiva e reconcilia após reiniciar.', (
      tester,
    ) async {
      final fixedDate = DateTime(2026, 8, 24, 14, 30);
      final fixedClock = _FixedClock(fixedDate);
      final scheduler = _RecordingNotificationScheduler();

      await _pumpApp(tester, fixedClock, scheduler);
      await _advanceToDateSettings(tester, habitName: 'Ler à Tarde');

      await tester.tap(find.byKey(const Key('reminder_time_option')));
      await tester.pumpAndSettle();

      final timePicker = find.byType(TimePickerDialog);
      expect(timePicker, findsOneWidget);
      final confirmTime = find.descendant(
        of: timePicker,
        matching: find.text('OK'),
      );
      expect(confirmTime, findsOneWidget);
      await tester.tap(confirmTime);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('streak_notification_switch')));
      await tester.pumpAndSettle();
      await tapFlowButton(tester, finish: true);

      expect(find.text('Ler à Tarde'), findsOneWidget);
      expect(scheduler.permissionChecks, 2);
      expect(scheduler.permissionRequests, 0);

      final habitsBox = Hive.box<HabitDto>('habits');
      final notificationsBox = Hive.box<NotificationConfigDto>('notifications');
      expect(habitsBox.length, 1);
      expect(notificationsBox.length, 1);

      final persistedHabit = habitsBox.values.single.toDomain();
      final persistedConfig = notificationsBox.values.single.toDomain();
      expect(persistedHabit.notificationTime, isNotNull);
      _expectSameMinute(persistedHabit.notificationTime!, fixedDate);
      expect(persistedConfig.isReminderEnabled, isTrue);
      expect(persistedConfig.isStreakEnabled, isTrue);
      expect(persistedConfig.customTimeNotification, hasLength(1));
      _expectSameMinute(
        persistedConfig.customTimeNotification.single,
        fixedDate,
      );
      expect(scheduler.replacements, isNotEmpty);
      expect(scheduler.replacements.last.reminderEnabled, isTrue);
      expect(scheduler.replacements.last.streakEnabled, isTrue);

      await _restartApp(tester, fixedClock, scheduler);

      expect(find.text('Ler à Tarde'), findsOneWidget);
      expect(Hive.box<NotificationConfigDto>('notifications').length, 1);
      expect(scheduler.replacements.length, greaterThanOrEqualTo(2));
      expect(scheduler.replacements.last.habit.id, persistedHabit.id);
      expect(scheduler.replacements.last.reminderEnabled, isTrue);
      expect(scheduler.replacements.last.streakEnabled, isTrue);

      await _openHabitForEditing(tester, 'Ler à Tarde');
      for (var page = 0; page < 4; page++) {
        await tapFlowButton(tester);
      }

      final reminderOption = find.byKey(const Key('reminder_time_option'));
      expect(reminderOption, findsOneWidget);
      expect(
        find.descendant(of: reminderOption, matching: find.text('14:30')),
        findsOneWidget,
      );
      final streakSwitch = tester.widget<SwitchListTile>(
        find.byKey(const Key('streak_notification_switch')),
      );
      expect(streakSwitch.value, isTrue);
    });

    testWidgets(
      'Exibe o hábito na data futura e impede sua conclusão antecipada.',
      (tester) async {
        final fixedDate = DateTime(2026, 8, 24, 14, 30);
        final fixedClock = _FixedClock(fixedDate);
        final scheduler = _RecordingNotificationScheduler();

        await _pumpApp(tester, fixedClock, scheduler);
        await _advanceToDateSettings(tester, habitName: 'Começar Amanhã');

        await tester.tap(find.byKey(const Key('start_date_option')));
        await tester.pumpAndSettle();

        final datePicker = find.byType(DatePickerDialog);
        expect(datePicker, findsOneWidget);
        final tomorrow = find.descendant(
          of: datePicker,
          matching: find.text('25'),
        );
        expect(tomorrow, findsOneWidget);
        await tester.tap(tomorrow);
        await tester.pumpAndSettle();

        final confirmDate = find.descendant(
          of: datePicker,
          matching: find.text('OK'),
        );
        expect(confirmDate, findsOneWidget);
        await tester.tap(confirmDate);
        await tester.pumpAndSettle();

        final startDateOption = find.byKey(const Key('start_date_option'));
        expect(
          find.descendant(of: startDateOption, matching: find.text('Amanhã')),
          findsOneWidget,
        );

        await tapFlowButton(tester, finish: true);

        expect(find.text('Começar Amanhã'), findsNothing);
        final persistedHabit = Hive.box<HabitDto>(
          'habits',
        ).values.single.toDomain();
        _expectSameDay(persistedHabit.startDate, DateTime(2026, 8, 25));

        final tomorrowCard = find.byKey(
          const ValueKey('home-calendar-2026-8-25'),
        );
        expect(tomorrowCard, findsOneWidget);
        await tester.tap(tomorrowCard);
        await tester.pumpAndSettle();

        expect(find.text('Começar Amanhã'), findsOneWidget);
        await _openHabitDialog(tester, 'Começar Amanhã');

        expect(
          find.text('Não é possível concluir um hábito em uma data futura.'),
          findsOneWidget,
        );
        final completeButton = tester.widget<TextButton>(
          find.byKey(const Key('complete_habit_text_button')),
        );
        expect(completeButton.onPressed, isNull);
        expect(Hive.box<ConclusionDto>('conclusions').values, isEmpty);
      },
    );
  });
}

Future<void> _advanceToDateSettings(
  WidgetTester tester, {
  required String habitName,
}) async {
  await tester.tap(find.byKey(const ValueKey('create_habit')));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const ValueKey('habit_category_studiesIcon')));
  await tester.pumpAndSettle();
  await tapFlowButton(tester);

  await tester.tap(find.byKey(const ValueKey('conclusion_type_yesNo')));
  await tester.pumpAndSettle();
  await tapFlowButton(tester);

  await tester.enterText(find.byKey(const ValueKey('input_name')), habitName);
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tapFlowButton(tester);

  await tester.tap(find.byKey(const ValueKey('frequency_type_daily')));
  await tester.pumpAndSettle();
  await tapFlowButton(tester);
}

Future<void> _openHabitForEditing(WidgetTester tester, String habitName) async {
  final habitTile = find.ancestor(
    of: find.text(habitName),
    matching: find.byType(HabitsListTile),
  );
  expect(habitTile, findsOneWidget);
  await tester.tap(habitTile);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('edit_habit_text_button')));
  await tester.pumpAndSettle();
}

Future<void> _openHabitDialog(WidgetTester tester, String habitName) async {
  final habitTile = find.ancestor(
    of: find.text(habitName),
    matching: find.byType(HabitsListTile),
  );
  expect(habitTile, findsOneWidget);
  await tester.tap(habitTile);
  await tester.pumpAndSettle();
}

Future<void> _restartApp(
  WidgetTester tester,
  Clock clock,
  NotificationScheduler scheduler,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await HiveTestEnvironment.restart();
  await _pumpApp(tester, clock, scheduler);
}

Future<void> _pumpApp(
  WidgetTester tester,
  Clock clock,
  NotificationScheduler scheduler,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(clock),
        notificationSchedulerProvider.overrideWithValue(scheduler),
      ],
      child: const MainApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void _expectSameMinute(DateTime actual, DateTime expected) {
  expect(actual.year, expected.year);
  expect(actual.month, expected.month);
  expect(actual.day, expected.day);
  expect(actual.hour, expected.hour);
  expect(actual.minute, expected.minute);
}

void _expectSameDay(DateTime actual, DateTime expected) {
  expect(actual.year, expected.year);
  expect(actual.month, expected.month);
  expect(actual.day, expected.day);
}

final class _FixedClock implements Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}

final class _ScheduleReplacement {
  const _ScheduleReplacement({
    required this.habit,
    required this.reminderEnabled,
    required this.streakEnabled,
  });

  final HabitModel habit;
  final bool reminderEnabled;
  final bool streakEnabled;
}

final class _RecordingNotificationScheduler implements NotificationScheduler {
  final List<_ScheduleReplacement> replacements = [];
  int permissionChecks = 0;
  int permissionRequests = 0;

  @override
  Future<void> cancelForHabit(String habitId) async {}

  @override
  Future<bool> isPermissionGranted() async {
    permissionChecks++;
    return true;
  }

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return true;
  }

  @override
  Future<void> replaceSchedules({
    required HabitModel habit,
    required bool reminderEnabled,
    required bool streakEnabled,
    required DateTime now,
    int currentStreak = 0,
  }) async {
    replacements.add(
      _ScheduleReplacement(
        habit: habit,
        reminderEnabled: reminderEnabled,
        streakEnabled: streakEnabled,
      ),
    );
  }
}
