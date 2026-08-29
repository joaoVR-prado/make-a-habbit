import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/core/providers/clock_provider.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/data/dtos/habit_dto.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/domain/services/clock.dart';
import 'package:make_a_habbit/main.dart';

import 'helpers/next_page_habit_creation.dart';
import 'helpers/hive_test_environment.dart';
import 'helpers/setup_integration_tests.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setupIntegrationTests();

  group('CRIACAO E PERSISTENCIA DE HABITOS', () {
    testWidgets('Cria um habito e verifica sua persistencia', (tester) async {
      final fixedDate = DateTime(2026, 8, 23, 14, 30);
      final fixedClock = _FixedClock(fixedDate);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [clockProvider.overrideWithValue(fixedClock)],
          child: const MainApp(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('create_habit')));
      await tester.pumpAndSettle();

      // Categoria
      await tester.tap(find.byKey(const ValueKey('habit_category_healthIcon')));
      await tester.pumpAndSettle();
      await tapFlowButton(tester);

      // Avaliacao de Progresso
      await tester.tap(find.byKey(const ValueKey('conclusion_type_yesNo')));
      await tester.pumpAndSettle();
      await tapFlowButton(tester);

      // Nome
      await tester.enterText(
        find.byKey(const ValueKey('input_name')),
        'Beber Agua',
      );
      await tester.pumpAndSettle();
      await tapFlowButton(tester);

      // Frequencia
      await tester.tap(find.byKey(const ValueKey('frequency_type_daily')));
      await tester.pumpAndSettle();
      await tapFlowButton(tester);

      _expectStartDateIsToday();

      await tapFlowButton(tester, finish: true);

      expect(find.text('Beber Agua'), findsOneWidget);

      final habitsBox = Hive.box<HabitDto>('habits');
      expect(habitsBox.length, 1);

      final persistedHabit = habitsBox.values.single.toDomain();
      expect(persistedHabit.name, 'Beber Agua');
      expect(persistedHabit.conclusionType, HabitConclusionType.yesNo);
      expect(persistedHabit.frequency.type, HabitFrequencyType.daily);
      _expectSameDate(persistedHabit.startDate, fixedDate);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      // Reinicia o APP e verifica persistencia
      await HiveTestEnvironment.restart();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [clockProvider.overrideWithValue(fixedClock)],
          child: const MainApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Beber Agua'), findsOneWidget);
      expect(Hive.box<HabitDto>('habits').length, 1);

      // Acha o card e o Abre novamente
      final habitCardName = find.text('Beber Agua');

      expect(
        habitCardName,
        findsOneWidget,
        reason: 'O hábito criado deveria estar visível.',
      );

      final habitCard = find.ancestor(
        of: habitCardName,
        matching: find.byType(Card),
      );

      expect(
        habitCard,
        findsOneWidget,
        reason: 'O hábito deveria possuir uma área clicável.',
      );

      await tester.ensureVisible(habitCard);
      await tester.tap(habitCard);
      await tester.pumpAndSettle();

      // Clica em Editar
      await tester.tap(find.byKey(const ValueKey('edit_habit_text_button')));
      await tester.pumpAndSettle();

      // Procura o Card correto e verifica se ele está selecionado
      final habitCategory = find.text('Saúde');
      final habitCategoryCard = find.ancestor(
        of: habitCategory,
        matching: find.byType(Card),
      );

      final Card cardHabitWidget = tester.widget(habitCategoryCard);

      expect(cardHabitWidget.color, equals(AppColors.homePageIconColor));

      await tapFlowButton(tester);
      await tester.pumpAndSettle();

      // Repete o teste acima para o tipo de avaliacao de um habito
      final habitConclusionType = find.byKey(
        const ValueKey('conclusion_type_yesNo'),
      );
      final habitConclusionTypeCard = find.ancestor(
        of: habitConclusionType,
        matching: find.byType(Card),
      );

      final Card cardConclusionWidget = tester.widget(habitConclusionTypeCard);

      expect(cardConclusionWidget.color, equals(AppColors.homePageIconColor));

      await tapFlowButton(tester);
      await tester.pumpAndSettle();

      // Valido se o nome do habito esta igual
      expect(find.text('Beber Agua'), findsOneWidget);

      await tapFlowButton(tester);
      await tester.pumpAndSettle();

      // Verifico se a frequencia esta correta
      final habitInkwell = find.byKey(const ValueKey('frequency_type_daily'));

      final habitFrequencyTypeContainer = find.descendant(
        of: habitInkwell,
        matching: find.byType(Container),
      );

      final Container radioButtonWidget = tester.widget(
        habitFrequencyTypeContainer,
      );
      final BoxDecoration decoration =
          radioButtonWidget.decoration as BoxDecoration;

      expect(decoration.color, equals(AppColors.positiveActionDialogTextColor));

      await tapFlowButton(tester);
      await tester.pumpAndSettle();

      // Verifica card da data de inicio
      _expectStartDateIsToday();
    });
  });
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

  expect(
    startDateTile,
    findsOneWidget,
    reason: 'A opção de data inicial deveria estar visível.',
  );

  expect(
    find.descendant(of: startDateTile, matching: find.text('Hoje')),
    findsOneWidget,
    reason: 'A data inicial deveria estar preenchida com o dia atual.',
  );
}

void _expectSameDate(DateTime actual, DateTime expected) {
  expect(actual.year, expected.year);
  expect(actual.month, expected.month);
  expect(actual.day, expected.day);
}
