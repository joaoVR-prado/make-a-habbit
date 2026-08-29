import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:integration_test/integration_test.dart';
import 'package:make_a_habbit/core/providers/clock_provider.dart';
import 'package:make_a_habbit/data/dtos/conclusion_dto.dart';
import 'package:make_a_habbit/data/dtos/habit_dto.dart';
import 'package:make_a_habbit/app/providers/dependency_providers.dart';
import 'package:make_a_habbit/data/repositories/concluded_habits_repository.dart';
import 'package:make_a_habbit/data/repositories/habit_repository.dart';
import 'package:make_a_habbit/domain/entities/conclusions/completion_value.dart';
import 'package:make_a_habbit/domain/entities/conclusions/concluded_habits_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/domain/services/clock.dart';
import 'package:make_a_habbit/domain/services/notification_scheduler.dart';
import 'package:make_a_habbit/main.dart';

import 'helpers/setup_integration_tests.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setupIntegrationTests();

  group('RELATÓRIOS, NAVEGAÇÃO E BUSCA', () {
    testWidgets(
      'Exibe métricas reais e navega da visão geral ao calendário do hábito.',
      (tester) async {
        final today = DateTime(2026, 8, 16, 14, 30);
        final water = _habit(
          id: 'agua',
          name: 'Beber Água',
          startDate: DateTime(2026, 8, 1),
        );
        final stretch = _habit(
          id: 'alongar',
          name: 'Alongar',
          startDate: DateTime(2026, 8, 1),
        );
        final future = _habit(
          id: 'futuro',
          name: 'A Futuro',
          startDate: DateTime(2026, 9, 1),
        );
        final ended = _habit(
          id: 'encerrado',
          name: 'Z Encerrado',
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 6, 30),
        );

        await _seedHabits([ended, future, water, stretch]);
        await _seedYesNoConclusion(water.id, DateTime(2026, 8, 15));
        await _seedYesNoConclusion(water.id, DateTime(2026, 8, 16));

        await _pumpApp(tester, _FixedClock(today));
        await tester.tap(find.byKey(const Key('home-reports-tab')));
        await tester.pumpAndSettle();

        expect(find.text('Relatórios'), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsNothing);
        expect(find.byIcon(Icons.calendar_month), findsNothing);
        _expectCardValue(tester, 'general-success-rate', '6.3%');
        _expectCardValue(tester, 'general-best-streak', '2 dias');
        _expectCardValue(tester, 'general-total-habits', '2');
        _expectCardValue(tester, 'general-completed-today', '1');

        await tester.tap(find.byKey(const Key('reports-habits-segment')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('habit-reports-list')), findsOneWidget);
        expect(
          tester.getTopLeft(find.text('Alongar')).dy,
          lessThan(tester.getTopLeft(find.text('Beber Água')).dy),
        );
        expect(
          tester.getTopLeft(find.text('Beber Água')).dy,
          lessThan(tester.getTopLeft(find.text('A Futuro')).dy),
        );
        expect(
          tester.getTopLeft(find.text('A Futuro')).dy,
          lessThan(tester.getTopLeft(find.text('Z Encerrado')).dy),
        );

        await tester.tap(find.byKey(const ValueKey('habit-report-agua')));
        await tester.pumpAndSettle();

        _expectCardValue(tester, 'habit-success-rate', '12.5%');
        _expectCardValue(tester, 'habit-current-streak', '2 dias');
        _expectCardValue(tester, 'habit-best-streak', '2 dias');
        _expectCardValue(tester, 'habit-total-completions', '2');
        expect(find.text('Agosto 2026'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('report-day-2026-8-14-missed')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('report-day-2026-8-15-completed')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('report-day-2026-8-16-completed')),
          findsOneWidget,
        );

        await tester.ensureVisible(find.byKey(const Key('next-report-month')));
        await tester.tap(find.byKey(const Key('next-report-month')));
        await tester.pump();
        expect(find.text('Setembro 2026'), findsOneWidget);

        await tester.tap(find.byKey(const Key('habit-detail-back-button')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('habit-reports-list')), findsOneWidget);
        expect(find.byKey(const Key('reports-habits-segment')), findsOneWidget);
      },
    );

    testWidgets('Busca um hábito e abre o relatório detalhado correto.', (
      tester,
    ) async {
      final today = DateTime(2026, 8, 16, 14, 30);
      await _seedHabits([
        _habit(id: 'agua', name: 'Beber Água', startDate: DateTime(2026, 8, 1)),
        _habit(
          id: 'leitura',
          name: 'Ler Livro',
          startDate: DateTime(2026, 8, 1),
        ),
      ]);
      await _seedYesNoConclusion('leitura', today);

      await _pumpApp(tester, _FixedClock(today));
      await tester.tap(find.byKey(const Key('home-reports-tab')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('reports-habits-segment')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('search-habit-reports')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Ler');
      await tester.pump();

      expect(
        find.byKey(const ValueKey('habit-search-result-leitura')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('habit-search-result-agua')),
        findsNothing,
      );

      await tester.tap(
        find.byKey(const ValueKey('habit-search-result-leitura')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ler Livro'), findsOneWidget);
      _expectCardValue(tester, 'habit-total-completions', '1');
      expect(
        find.byKey(const ValueKey('report-day-2026-8-16-completed')),
        findsOneWidget,
      );
    });
  });
}

Future<void> _seedHabits(List<HabitModel> habits) async {
  final repository = HiveHabitRepository(Hive.box<HabitDto>('habits'));
  for (final habit in habits) {
    await repository.add(habit);
  }
}

Future<void> _seedYesNoConclusion(String habitId, DateTime date) {
  final repository = HiveConclusionRepository(
    Hive.box<ConclusionDto>('conclusions'),
  );
  return repository.save(
    ConcludedHabitsModel(
      habitId: habitId,
      conclusionDate: DateTime(date.year, date.month, date.day),
      conclusionValue: const YesNoCompletionValue(true),
    ),
  );
}

Future<void> _pumpApp(WidgetTester tester, Clock clock) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(clock),
        notificationSchedulerProvider.overrideWithValue(
          _NoopNotificationScheduler(),
        ),
      ],
      child: const MainApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void _expectCardValue(
  WidgetTester tester,
  String cardKey,
  String expectedValue,
) {
  final card = find.byKey(ValueKey(cardKey));
  expect(card, findsOneWidget);
  expect(
    find.descendant(of: card, matching: find.text(expectedValue)),
    findsOneWidget,
  );
}

HabitModel _habit({
  required String id,
  required String name,
  required DateTime startDate,
  DateTime? endDate,
}) => HabitModel(
  id: id,
  iconCode: 10,
  name: name,
  conclusionType: HabitConclusionType.yesNo,
  frequency: const DailyHabitFrequency(),
  startDate: startDate,
  endDate: endDate,
);

final class _FixedClock implements Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}

final class _NoopNotificationScheduler implements NotificationScheduler {
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
