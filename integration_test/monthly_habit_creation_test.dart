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

  group('CRIAÇÃO E PERSISTÊNCIA DE HÁBITO MENSAL', () {
    testWidgets('Cria um hábito mensal e restaura os dias após reiniciar.', (
      tester,
    ) async {
      final fixedDate = DateTime(2026, 8, 15, 14, 30);
      final fixedClock = _FixedClock(fixedDate);

      await _pumpApp(tester, fixedClock);

      await tester.tap(find.byKey(const ValueKey('create_habit')));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('habit_category_financiesIcon')),
      );
      await tester.pumpAndSettle();
      await tapFlowButton(tester);

      await tester.tap(find.byKey(const ValueKey('conclusion_type_yesNo')));
      await tester.pumpAndSettle();
      await tapFlowButton(tester);

      await tester.enterText(
        find.byKey(const ValueKey('input_name')),
        'Revisar Finanças',
      );
      await tester.pumpAndSettle();
      await tapFlowButton(tester);

      await tester.tap(find.byKey(const ValueKey('frequency_type_monthly')));
      await tester.pumpAndSettle();

      final dayFifteen = find.byKey(const ValueKey('monthly_day_15'));
      await tester.ensureVisible(dayFifteen);
      await tester.tap(dayFifteen);
      await tester.pumpAndSettle();

      final lastDay = find.byKey(const ValueKey('monthly_day_32'));
      await tester.ensureVisible(lastDay);
      await tester.tap(lastDay);
      await tester.pumpAndSettle();
      await tapFlowButton(tester);

      await tapFlowButton(tester, finish: true);

      expect(find.text('Revisar Finanças'), findsOneWidget);

      final habitsBox = Hive.box<HabitDto>('habits');
      expect(habitsBox.length, 1);

      final persistedHabit = habitsBox.values.single.toDomain();
      expect(persistedHabit.conclusionType, HabitConclusionType.yesNo);
      expect(persistedHabit.frequency, isA<MonthlyHabitFrequency>());
      expect(persistedHabit.frequency.type, HabitFrequencyType.monthly);
      expect(persistedHabit.frequency.selectedDays, [15, 32]);
      _expectSameDate(persistedHabit.startDate, fixedDate);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await HiveTestEnvironment.restart();

      await _pumpApp(tester, fixedClock);

      expect(find.text('Revisar Finanças'), findsOneWidget);
      expect(Hive.box<HabitDto>('habits').length, 1);

      final habitTile = find.ancestor(
        of: find.text('Revisar Finanças'),
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
        find.byKey(const ValueKey('frequency_type_monthly')),
        findsOneWidget,
      );
      _expectDaySelected(tester, 15);
      _expectDaySelected(tester, 32);
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
    of: find.byKey(ValueKey('monthly_day_$day')),
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
