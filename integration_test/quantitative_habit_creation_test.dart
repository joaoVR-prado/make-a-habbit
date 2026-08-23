import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:integration_test/integration_test.dart';
import 'package:make_a_habbit/core/providers/clock_provider.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/data/dtos/habit_dto.dart';
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

  group('CRIAÇÃO E PERSISTÊNCIA DE HÁBITO QUANTITATIVO', () {
    testWidgets(
      'Cria um hábito quantitativo e restaura sua meta após reiniciar.',
      (tester) async {
        final fixedDate = DateTime(2026, 8, 23, 14, 30);
        final fixedClock = _FixedClock(fixedDate);

        await _pumpApp(tester, fixedClock);

        await tester.tap(find.byKey(const ValueKey('create_habit')));
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const ValueKey('habit_category_healthIcon')),
        );
        await tester.pumpAndSettle();
        await tapFlowButton(tester);

        await tester.tap(
          find.byKey(const ValueKey('conclusion_type_goalQuantity')),
        );
        await tester.pumpAndSettle();
        await tapFlowButton(tester);

        await tester.enterText(
          find.byKey(const ValueKey('input_name')),
          'Beber Oito Copos',
        );
        await tester.enterText(
          find.byKey(const ValueKey('input_quantity')),
          '8',
        );
        await tester.pumpAndSettle();
        await tapFlowButton(tester);

        await tester.tap(find.byKey(const ValueKey('frequency_type_daily')));
        await tester.pumpAndSettle();
        await tapFlowButton(tester);

        _expectStartDateIsToday();
        await tapFlowButton(tester, finish: true);

        expect(find.text('Beber Oito Copos'), findsOneWidget);

        final habitsBox = Hive.box<HabitDto>('habits');
        expect(habitsBox.length, 1);

        final persistedHabit = habitsBox.values.single.toDomain();
        expect(persistedHabit.name, 'Beber Oito Copos');
        expect(persistedHabit.conclusionType, HabitConclusionType.goalQuantity);
        expect(persistedHabit.goalQuantity, 8);
        expect(persistedHabit.frequency.type, HabitFrequencyType.daily);
        _expectSameDate(persistedHabit.startDate, fixedDate);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await HiveTestEnvironment.restart();

        await _pumpApp(tester, fixedClock);

        expect(find.text('Beber Oito Copos'), findsOneWidget);
        expect(Hive.box<HabitDto>('habits').length, 1);

        final habitCard = find.ancestor(
          of: find.text('Beber Oito Copos'),
          matching: find.byType(HabitsListTile),
        );
        expect(habitCard, findsOneWidget);

        await tester.ensureVisible(habitCard);
        await tester.tap(habitCard);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('edit_habit_text_button')));
        await tester.pumpAndSettle();

        await tapFlowButton(tester);

        final conclusionType = find.byKey(
          const ValueKey('conclusion_type_goalQuantity'),
        );
        final conclusionTypeCard = find.ancestor(
          of: conclusionType,
          matching: find.byType(Card),
        );
        final selectedCard = tester.widget<Card>(conclusionTypeCard);
        expect(selectedCard.color, AppColors.homePageIconColor);

        await tapFlowButton(tester);

        final nameField = tester.widget<TextFormField>(
          find.byKey(const ValueKey('input_name')),
        );
        final quantityField = tester.widget<TextFormField>(
          find.byKey(const ValueKey('input_quantity')),
        );

        expect(nameField.initialValue, 'Beber Oito Copos');
        expect(quantityField.controller?.text, '8');
        
      },
    );
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

void _expectStartDateIsToday() {
  final startDateTile = find.ancestor(
    of: find.text('Data de início'),
    matching: find.byType(ListTile),

  );

  expect(startDateTile, findsOneWidget);
  expect(
    find.descendant(of: startDateTile, matching: find.text('Hoje')),
    findsOneWidget,

  );
}

void _expectSameDate(DateTime actual, DateTime expected) {
  expect(actual.year, expected.year);
  expect(actual.month, expected.month);
  expect(actual.day, expected.day);

}
