import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:integration_test/integration_test.dart';
import 'package:make_a_habbit/core/providers/clock_provider.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/data/dtos/habit_dto.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/domain/services/clock.dart';
import 'package:make_a_habbit/main.dart';
import 'package:make_a_habbit/presentation/home_page/widgets/habits_list_tile.dart';

import 'helpers/hive_test_environment.dart';
import 'helpers/next_page_habit_creation.dart';
import 'helpers/setup_integration_tests.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setupIntegrationTests();

  group('CRIAÇÃO E PERSISTÊNCIA DE HÁBITO SEMANAL', () {
    testWidgets('Cria um hábito semanal e restaura os dias após reiniciar.', (
      tester,
    ) async {
      final fixedDate = DateTime(2026, 8, 24, 14, 30);
      final fixedClock = _FixedClock(fixedDate);

      await _pumpApp(tester, fixedClock);

      await tester.tap(find.byKey(const ValueKey('create_habit')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('habit_category_sportsIcon')));
      await tester.pumpAndSettle();
      await tapFlowButton(tester);

      await tester.tap(find.byKey(const ValueKey('conclusion_type_yesNo')));
      await tester.pumpAndSettle();
      await tapFlowButton(tester);

      await tester.enterText(
        find.byKey(const ValueKey('input_name')),
        'Treinar na Semana',
      );
      await tester.pumpAndSettle();
      await tapFlowButton(tester);

      await tester.tap(find.byKey(const ValueKey('frequency_type_weekly')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('weekly_day_1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('weekly_day_3')));
      await tester.pumpAndSettle();
      await tapFlowButton(tester);

      await tapFlowButton(tester, finish: true);

      expect(find.text('Treinar na Semana'), findsOneWidget);

      final habitsBox = Hive.box<HabitDto>('habits');
      expect(habitsBox.length, 1);

      final persistedHabit = habitsBox.values.single.toDomain();
      expect(persistedHabit.conclusionType, HabitConclusionType.yesNo);
      expect(persistedHabit.frequency, isA<WeeklyHabitFrequency>());
      expect(persistedHabit.frequency.type, HabitFrequencyType.weekly);
      expect(persistedHabit.frequency.selectedDays, [1, 3]);
      _expectSameDate(persistedHabit.startDate, fixedDate);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await HiveTestEnvironment.restart();

      await _pumpApp(tester, fixedClock);

      expect(find.text('Treinar na Semana'), findsOneWidget);
      expect(Hive.box<HabitDto>('habits').length, 1);

      final habitTile = find.ancestor(
        of: find.text('Treinar na Semana'),
        matching: find.byType(HabitsListTile),
      );
      expect(habitTile, findsOneWidget);

      await tester.ensureVisible(habitTile);
      await tester.tap(habitTile);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('edit_habit_text_button')));
      await tester.pumpAndSettle();

      await tapFlowButton(tester);
      await tapFlowButton(tester);
      await tapFlowButton(tester);

      expect(
        find.byKey(const ValueKey('frequency_type_weekly')),
        findsOneWidget,
      );
      _expectDaySelected(tester, 1);
      _expectDaySelected(tester, 3);
    });
  });
}

Future<void> _pumpApp(WidgetTester tester, Clock clock) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [clockProvider.overrideWithValue(clock)],
      child: const MainApp(),
    ),
  );
  await tester.pumpAndSettle();
}

final class _FixedClock implements Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}

void _expectDaySelected(WidgetTester tester, int day) {
  final dayCard = find.ancestor(
    of: find.byKey(ValueKey('weekly_day_$day')),
    matching: find.byType(Card),
  );
  expect(dayCard, findsOneWidget);
  expect(
    tester.widget<Card>(dayCard).color,
    AppColors.positiveActionDialogTextColor,
  );
}

void _expectSameDate(DateTime actual, DateTime expected) {
  expect(actual.year, expected.year);
  expect(actual.month, expected.month);
  expect(actual.day, expected.day);
}
