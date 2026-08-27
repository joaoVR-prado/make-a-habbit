import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:integration_test/integration_test.dart';
import 'package:make_a_habbit/core/providers/clock_provider.dart';
import 'package:make_a_habbit/core/utils/enums/habit_icon.dart';
import 'package:make_a_habbit/data/dtos/conclusion_dto.dart';
import 'package:make_a_habbit/data/dtos/habit_dto.dart';
import 'package:make_a_habbit/data/dtos/notification_config_dto.dart';
import 'package:make_a_habbit/domain/entities/conclusions/completion_value.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/domain/services/clock.dart';
import 'package:make_a_habbit/main.dart';
import 'package:make_a_habbit/presentation/home_page/widgets/habits_list_tile.dart';

import 'helpers/hive_test_environment.dart';
import 'helpers/next_page_habit_creation.dart';
import 'helpers/setup_integration_tests.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setupIntegrationTests();

  group('CICLO DE VIDA DE HÁBITOS', () {
    testWidgets(
      'Edita um hábito sem duplicá-lo e mantém as alterações após reiniciar.',
      (tester) async {
        final fixedDate = DateTime(2026, 8, 24, 14, 30);
        final fixedClock = _FixedClock(fixedDate);

        await _pumpApp(tester, fixedClock);
        await _createDailyHabit(tester, name: 'Caminhar');

        final habitsBox = Hive.box<HabitDto>('habits');
        expect(habitsBox.length, 1);
        final originalId = habitsBox.values.single.id;

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await HiveTestEnvironment.restart();
        await _pumpApp(tester, fixedClock);

        expect(find.text('Caminhar'), findsOneWidget);

        await _openHabitDialog(tester, 'Caminhar');
        await tester.tap(find.byKey(const ValueKey('edit_habit_text_button')));
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const ValueKey('habit_category_sportsIcon')),
        );
        await tester.pumpAndSettle();
        await tapFlowButton(tester);

        await tapFlowButton(tester);

        await tester.enterText(
          find.byKey(const ValueKey('input_name')),
          'Correr no Parque',
        );
        await tester.enterText(
          find.byKey(const ValueKey('input_description')),
          'Treino de trinta minutos',
        );
        await _dismissKeyboard(tester);
        await tapFlowButton(tester);

        await tester.tap(find.byKey(const ValueKey('frequency_type_weekly')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('weekly_day_1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('weekly_day_3')));
        await tester.pumpAndSettle();
        await tapFlowButton(tester);

        await tapFlowButton(tester, finish: true);

        expect(find.text('Caminhar'), findsNothing);
        expect(find.text('Correr no Parque'), findsOneWidget);
        expect(find.text('Treino de trinta minutos'), findsOneWidget);

        final editedBox = Hive.box<HabitDto>('habits');
        expect(editedBox.length, 1);
        final editedHabit = editedBox.values.single.toDomain();
        expect(editedHabit.id, originalId);
        expect(editedHabit.name, 'Correr no Parque');
        expect(editedHabit.description, 'Treino de trinta minutos');
        expect(editedHabit.iconCode, HabitIcon.sportsIcon.code);
        expect(editedHabit.frequency, isA<WeeklyHabitFrequency>());
        expect(editedHabit.frequency.type, HabitFrequencyType.weekly);
        expect(editedHabit.frequency.selectedDays, [1, 3]);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await HiveTestEnvironment.restart();

        await _pumpApp(tester, fixedClock);

        expect(find.text('Caminhar'), findsNothing);
        expect(find.text('Correr no Parque'), findsOneWidget);
        expect(find.text('Treino de trinta minutos'), findsOneWidget);

        final restartedBox = Hive.box<HabitDto>('habits');
        expect(restartedBox.length, 1);
        final restartedHabit = restartedBox.values.single.toDomain();
        expect(restartedHabit.id, originalId);
        expect(restartedHabit.name, 'Correr no Parque');
        expect(restartedHabit.iconCode, HabitIcon.sportsIcon.code);
        expect(restartedHabit.frequency.selectedDays, [1, 3]);
      },
    );

    testWidgets('Exclui um hábito definitivamente após a confirmação.', (
      tester,
    ) async {
      final fixedDate = DateTime(2026, 8, 24, 14, 30);
      final fixedClock = _FixedClock(fixedDate);

      await _pumpApp(tester, fixedClock);
      await _createDailyHabit(tester, name: 'Hábito Temporário');

      expect(Hive.box<HabitDto>('habits').length, 1);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await HiveTestEnvironment.restart();
      await _pumpApp(tester, fixedClock);

      expect(Hive.box<NotificationConfigDto>('notifications').length, 1);

      await _saveYesNoConclusion(tester, 'Hábito Temporário', completed: true);
      expect(Hive.box<ConclusionDto>('conclusions').length, 1);

      await _openHabitDialog(tester, 'Hábito Temporário');
      await tester.tap(find.byKey(const ValueKey('delete_habit_text_button')));
      await tester.pumpAndSettle();

      expect(
        find.text('Deseja realmente excluir esse hábito?'),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('confirm_delete_habit_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hábito Temporário'), findsNothing);
      expect(find.text('Hábito excluído com sucesso!'), findsOneWidget);
      expect(Hive.box<HabitDto>('habits').values, isEmpty);
      expect(Hive.box<ConclusionDto>('conclusions').values, isEmpty);
      expect(Hive.box<NotificationConfigDto>('notifications').values, isEmpty);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await HiveTestEnvironment.restart();
      await _pumpApp(tester, fixedClock);

      expect(find.text('Hábito Temporário'), findsNothing);
      expect(Hive.box<HabitDto>('habits').values, isEmpty);
      expect(Hive.box<ConclusionDto>('conclusions').values, isEmpty);
      expect(Hive.box<NotificationConfigDto>('notifications').values, isEmpty);
    });

    testWidgets(
      'Atualiza uma conclusão de sim ou não sem duplicar o registro.',
      (tester) async {
        final fixedDate = DateTime(2026, 8, 24, 14, 30);
        final fixedClock = _FixedClock(fixedDate);

        await _pumpApp(tester, fixedClock);
        await _createDailyHabit(tester, name: 'Meditar');
        await _restartApp(tester, fixedClock);

        _expectHabitStatus(tester, 'Meditar', 'pending');

        await _saveYesNoConclusion(tester, 'Meditar', completed: true);

        _expectHabitStatus(tester, 'Meditar', 'done');
        final conclusionsBox = Hive.box<ConclusionDto>('conclusions');
        expect(conclusionsBox.length, 1);
        final completedConclusion = conclusionsBox.values.single.toDomain();
        expect(
          completedConclusion.conclusionValue,
          isA<YesNoCompletionValue>().having(
            (value) => value.value,
            'valor',
            isTrue,
          ),
        );

        await _saveYesNoConclusion(tester, 'Meditar', completed: false);

        _expectHabitStatus(tester, 'Meditar', 'incomplete');
        expect(conclusionsBox.length, 1);
        final incompleteConclusion = conclusionsBox.values.single.toDomain();
        expect(
          incompleteConclusion.conclusionValue,
          isA<YesNoCompletionValue>().having(
            (value) => value.value,
            'valor',
            isFalse,
          ),
        );

        await _restartApp(tester, fixedClock);

        _expectHabitStatus(tester, 'Meditar', 'incomplete');
        expect(Hive.box<ConclusionDto>('conclusions').length, 1);
      },
    );

    testWidgets(
      'Atualiza uma conclusão quantitativa e reflete o alcance da meta.',
      (tester) async {
        final fixedDate = DateTime(2026, 8, 24, 14, 30);
        final fixedClock = _FixedClock(fixedDate);

        await _pumpApp(tester, fixedClock);
        await _createQuantitativeDailyHabit(
          tester,
          name: 'Beber Água',
          goal: 8,
        );
        await _restartApp(tester, fixedClock);

        _expectHabitStatus(tester, 'Beber Água', 'pending');

        await _saveQuantityConclusion(tester, 'Beber Água', 3);

        _expectHabitStatus(tester, 'Beber Água', 'pending');
        final conclusionsBox = Hive.box<ConclusionDto>('conclusions');
        expect(conclusionsBox.length, 1);
        final partialConclusion = conclusionsBox.values.single.toDomain();
        expect(
          partialConclusion.conclusionValue,
          isA<QuantityCompletionValue>().having(
            (value) => value.value,
            'quantidade',
            3,
          ),
        );

        await _saveQuantityConclusion(tester, 'Beber Água', 8);

        _expectHabitStatus(tester, 'Beber Água', 'done');
        expect(conclusionsBox.length, 1);
        final completedConclusion = conclusionsBox.values.single.toDomain();
        expect(
          completedConclusion.conclusionValue,
          isA<QuantityCompletionValue>().having(
            (value) => value.value,
            'quantidade',
            8,
          ),
        );

        await _restartApp(tester, fixedClock);

        _expectHabitStatus(tester, 'Beber Água', 'done');
        expect(Hive.box<ConclusionDto>('conclusions').length, 1);
      },
    );
  });
}

Future<void> _createDailyHabit(
  WidgetTester tester, {
  required String name,
}) async {
  await tester.tap(find.byKey(const ValueKey('create_habit')));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const ValueKey('habit_category_healthIcon')));
  await tester.pumpAndSettle();
  await tapFlowButton(tester);

  await tester.tap(find.byKey(const ValueKey('conclusion_type_yesNo')));
  await tester.pumpAndSettle();
  await tapFlowButton(tester);

  await tester.enterText(find.byKey(const ValueKey('input_name')), name);
  await _dismissKeyboard(tester);
  await tapFlowButton(tester);

  await tester.tap(find.byKey(const ValueKey('frequency_type_daily')));
  await tester.pumpAndSettle();
  await tapFlowButton(tester);

  await tapFlowButton(tester, finish: true);
  expect(find.text(name), findsOneWidget);
}

Future<void> _createQuantitativeDailyHabit(
  WidgetTester tester, {
  required String name,
  required int goal,
}) async {
  await tester.tap(find.byKey(const ValueKey('create_habit')));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const ValueKey('habit_category_healthIcon')));
  await tester.pumpAndSettle();
  await tapFlowButton(tester);

  await tester.tap(find.byKey(const ValueKey('conclusion_type_goalQuantity')));
  await tester.pumpAndSettle();
  await tapFlowButton(tester);

  await tester.enterText(find.byKey(const ValueKey('input_name')), name);
  await tester.enterText(
    find.byKey(const ValueKey('input_quantity')),
    goal.toString(),
  );
  await _dismissKeyboard(tester);
  await tapFlowButton(tester);

  await tester.tap(find.byKey(const ValueKey('frequency_type_daily')));
  await tester.pumpAndSettle();
  await tapFlowButton(tester);

  await tapFlowButton(tester, finish: true);
  expect(find.text(name), findsOneWidget);
}

Future<void> _openHabitDialog(WidgetTester tester, String habitName) async {
  final habitTile = find.ancestor(
    of: find.text(habitName),
    matching: find.byType(HabitsListTile),
  );
  expect(habitTile, findsOneWidget);

  await tester.ensureVisible(habitTile);
  await tester.tap(habitTile);
  await tester.pumpAndSettle();
}

Future<void> _saveYesNoConclusion(
  WidgetTester tester,
  String habitName, {
  required bool completed,
}) async {
  await _openHabitDialog(tester, habitName);
  await tester.tap(find.byKey(const ValueKey('complete_habit_text_button')));
  await tester.pumpAndSettle();
  await tester.tap(
    find.byKey(
      ValueKey(
        completed ? 'yes_no_complete_option' : 'yes_no_incomplete_option',
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('save_yes_no_conclusion_button')));
  await tester.pumpAndSettle();
}

Future<void> _saveQuantityConclusion(
  WidgetTester tester,
  String habitName,
  int quantity,
) async {
  await _openHabitDialog(tester, habitName);
  await tester.tap(find.byKey(const ValueKey('complete_habit_text_button')));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const ValueKey('quantity_conclusion_input')),
    quantity.toString(),
  );
  await _dismissKeyboard(tester);
  await tester.tap(
    find.byKey(const ValueKey('save_quantity_conclusion_button')),
  );
  await tester.pumpAndSettle();
}

void _expectHabitStatus(
  WidgetTester tester,
  String habitName,
  String statusKey,
) {
  final habitTile = find.ancestor(
    of: find.text(habitName),
    matching: find.byType(HabitsListTile),
  );
  expect(habitTile, findsOneWidget);
  expect(
    find.descendant(of: habitTile, matching: find.byKey(ValueKey(statusKey))),
    findsOneWidget,
  );
}

Future<void> _restartApp(WidgetTester tester, Clock clock) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await HiveTestEnvironment.restart();
  await _pumpApp(tester, clock);
}

Future<void> _dismissKeyboard(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
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
