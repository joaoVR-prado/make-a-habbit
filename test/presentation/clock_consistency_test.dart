import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/core/providers/clock_provider.dart';
import 'package:make_a_habbit/data/providers/notification_scheduler_provider.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/domain/services/clock.dart';
import 'package:make_a_habbit/domain/services/notification_scheduler.dart';
import 'package:make_a_habbit/presentation/habits/widgets/complete_habit.dart';
import 'package:make_a_habbit/presentation/habits/widgets/choose_start_date.dart';
import 'package:make_a_habbit/presentation/home_page/widgets/horizontal_calendar.dart';
import 'package:make_a_habbit/presentation/reports/widgets/weekly_graphic_card.dart';

final class _FixedClock implements Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}

final class _AllowedNotificationScheduler implements NotificationScheduler {
  @override
  Future<void> cancelForHabit(String habitId) async {}

  @override
  Future<bool> isPermissionGranted() async => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> replaceSchedules({
    required HabitModel habit,
    required bool reminderEnabled,
    required bool streakEnabled,
    required DateTime now,
    int currentStreak = 0,
  }) async {}
}

void main() {
  group('CONSISTÊNCIA DO RELÓGIO NA APRESENTAÇÃO', () {
    testWidgets('Centraliza o calendário horizontal na data informada.', (
      tester,
    ) async {
      final fixedDate = DateTime(2026, 8, 16, 15, 30);

      await _pumpWithClock(
        tester,
        fixedDate: fixedDate,
        child: const Scaffold(body: HorizontalCalendar()),
      );

      final listView = tester.widget<ListView>(find.byType(ListView));
      final startDate = DateTime(2025, 1, 1);
      final expectedDays = DateTime(
        fixedDate.year,
        fixedDate.month,
        fixedDate.day,
      ).difference(startDate).inDays;

      expect(listView.controller!.initialScrollOffset, expectedDays * 70);
      expect(listView.semanticChildCount, 731);
    });

    testWidgets('Monta o relatório semanal a partir da data informada.', (
      tester,
    ) async {
      final fixedDate = DateTime(2026, 8, 16, 15, 30);
      final weeklyData = <DateTime, int>{
        for (var index = 0; index < 7; index++)
          DateTime(2026, 8, 10 + index): index + 1,
      };

      await _pumpWithClock(
        tester,
        fixedDate: fixedDate,
        child: Scaffold(body: WeeklyGraphicCard(weeklyData: weeklyData)),
      );

      final chart = tester.widget<BarChart>(find.byType(BarChart));
      final values = chart.data.barGroups
          .map((group) => group.barRods.single.toY)
          .toList();

      expect(values, [1, 2, 3, 4, 5, 6, 7]);
      expect(chart.data.maxY, 10);
    });

    testWidgets('Expande o gráfico quando há mais de dez conclusões.', (
      tester,
    ) async {
      final fixedDate = DateTime(2026, 8, 16, 15, 30);

      await _pumpWithClock(
        tester,
        fixedDate: fixedDate,
        child: Scaffold(
          body: WeeklyGraphicCard(weeklyData: {DateTime(2026, 8, 16): 14}),
        ),
      );

      final chart = tester.widget<BarChart>(find.byType(BarChart));
      expect(chart.data.maxY, 14);
    });

    testWidgets('Exibe no diálogo a data informada pelo relógio.', (
      tester,
    ) async {
      final fixedDate = DateTime(2026, 8, 16, 15, 30);
      final habit = HabitModel(
        id: 'habito',
        iconCode: 10,
        name: 'Beber água',
        conclusionType: HabitConclusionType.yesNo,
        frequency: const DailyHabitFrequency(),
        startDate: fixedDate,
      );

      await _pumpWithClock(
        tester,
        fixedDate: fixedDate,
        child: Scaffold(body: CompleteHabit(habit: habit)),
      );

      expect(find.text('16/08/2026'), findsOneWidget);
    });

    testWidgets('Inicia o seletor de horário com o relógio informado.', (
      tester,
    ) async {
      final fixedDate = DateTime(2026, 8, 16, 15, 30);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clockProvider.overrideWithValue(_FixedClock(fixedDate)),
            notificationSchedulerProvider.overrideWithValue(
              _AllowedNotificationScheduler(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: ChooseStartDate()),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Vazio'));
      await tester.pumpAndSettle();

      final picker = tester.widget<TimePickerDialog>(
        find.byType(TimePickerDialog),
      );
      expect(picker.initialTime, const TimeOfDay(hour: 15, minute: 30));
    });
  });
}

Future<void> _pumpWithClock(
  WidgetTester tester, {
  required DateTime fixedDate,
  required Widget child,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [clockProvider.overrideWithValue(_FixedClock(fixedDate))],
      child: MaterialApp(home: child),
    ),
  );
  await tester.pump();
}
