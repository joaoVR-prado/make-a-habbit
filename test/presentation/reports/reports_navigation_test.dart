import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/core/providers/clock_provider.dart';
import 'package:make_a_habbit/app/providers/dependency_providers.dart';
import 'package:make_a_habbit/domain/entities/conclusions/concluded_habits_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/domain/repositories/conclusion_repository.dart';
import 'package:make_a_habbit/domain/repositories/habit_repository.dart';
import 'package:make_a_habbit/domain/services/clock.dart';
import 'package:make_a_habbit/presentation/home_page/views/home_page.dart';
import 'package:make_a_habbit/presentation/reports/views/reports_page.dart';
import 'package:mocktail/mocktail.dart';

final class _MockHabitRepository extends Mock implements HabitRepository {}

final class _MockConclusionRepository extends Mock
    implements ConclusionRepository {}

final class _FixedClock implements Clock {
  const _FixedClock(this.value);
  final DateTime value;
  @override
  DateTime now() => value;
}

void main() {
  final today = DateTime(2026, 8, 16);

  group('NAVEGAÇÃO DOS RELATÓRIOS', () {
    testWidgets('Abre a visão geral por padrão e alterna para meus hábitos.', (
      tester,
    ) async {
      final habits = [
        _habit(
          id: 'encerrado',
          name: 'Z Encerrado',
          start: DateTime(2026, 1),
          end: DateTime(2026, 7, 31),
        ),
        _habit(id: 'futuro', name: 'A Futuro', start: DateTime(2026, 9)),
        _habit(id: 'ativo-b', name: 'Beber água', start: DateTime(2026, 1)),
        _habit(id: 'ativo-a', name: 'Alongar', start: DateTime(2026, 1)),
      ];
      await _pumpReports(tester, habits: habits, today: today);

      final segmented = tester.widget<SegmentedButton>(
        find.byKey(const Key('reports-segmented-control')),
      );
      expect(segmented.selected.single.toString(), contains('general'));
      expect(find.text('Hábitos Concluídos (Últimos 7 dias)'), findsOneWidget);

      await tester.tap(find.text('Hábitos'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('habit-reports-list')), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Alongar')).dy,
        lessThan(tester.getTopLeft(find.text('Beber água')).dy),
      );
      expect(
        tester.getTopLeft(find.text('Beber água')).dy,
        lessThan(tester.getTopLeft(find.text('A Futuro')).dy),
      );
      expect(
        tester.getTopLeft(find.text('A Futuro')).dy,
        lessThan(tester.getTopLeft(find.text('Z Encerrado')).dy),
      );
      expect(find.text('Ativo'), findsNWidgets(2));
      expect(find.text('Começa em 01/09/2026'), findsOneWidget);
      expect(find.text('Encerrado'), findsOneWidget);
    });

    testWidgets('Exibe uma mensagem quando não existem hábitos.', (
      tester,
    ) async {
      await _pumpReports(tester, habits: const [], today: today);

      await tester.tap(find.text('Hábitos'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('empty-habit-reports')), findsOneWidget);
    });

    testWidgets('Abre o detalhe e permite navegar entre os meses.', (
      tester,
    ) async {
      final habit = _habit(
        id: 'ativo',
        name: 'Beber água',
        start: DateTime(2026, 8, 1),
      );
      await _pumpReports(tester, habits: [habit], today: today);
      await tester.tap(find.text('Hábitos'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Beber água'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('habit-success-rate')), findsOneWidget);
      expect(find.text('Agosto 2026'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('report-day-2026-8-15-missed')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('report-day-2026-8-16-pending')),
        findsOneWidget,
      );

      await tester.ensureVisible(find.byKey(const Key('next-report-month')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('next-report-month')));
      await tester.pump();
      expect(find.text('Setembro 2026'), findsOneWidget);
    });

    testWidgets('Ajusta a AppBar e a busca conforme a visão selecionada.', (
      tester,
    ) async {
      final habit = _habit(
        id: 'ativo',
        name: 'Beber água',
        start: DateTime(2026, 1),
      );
      await _pumpHome(tester, habits: [habit], today: today);

      await tester.tap(find.text('RELATÓRIOS'));
      await tester.pumpAndSettle();

      expect(find.text('Relatórios'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_month), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byKey(const Key('search-habit-reports')), findsNothing);

      await tester.tap(find.text('Hábitos'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('search-habit-reports')), findsOneWidget);

      await tester.tap(find.byKey(const Key('search-habit-reports')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Beber');
      await tester.pump();
      await tester.tap(find.text('Beber água'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('habit-success-rate')), findsOneWidget);
    });
  });
}

Future<void> _pumpReports(
  WidgetTester tester, {
  required List<HabitModel> habits,
  required DateTime today,
}) => _pumpApp(
  tester,
  habits: habits,
  today: today,
  home: const Scaffold(body: ReportsPage()),
);

Future<void> _pumpHome(
  WidgetTester tester, {
  required List<HabitModel> habits,
  required DateTime today,
}) => _pumpApp(tester, habits: habits, today: today, home: const HomePage());

Future<void> _pumpApp(
  WidgetTester tester, {
  required List<HabitModel> habits,
  required DateTime today,
  required Widget home,
}) async {
  final habitRepository = _MockHabitRepository();
  final conclusionRepository = _MockConclusionRepository();
  when(habitRepository.getAll).thenReturn(habits);
  when(conclusionRepository.getAll).thenReturn(<ConcludedHabitsModel>[]);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        habitRepositoryProvider.overrideWithValue(habitRepository),
        concludedHabitsRepositoryProvider.overrideWithValue(
          conclusionRepository,
        ),
        clockProvider.overrideWithValue(_FixedClock(today)),
      ],
      child: MaterialApp(home: home),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

HabitModel _habit({
  required String id,
  required String name,
  required DateTime start,
  DateTime? end,
}) => HabitModel(
  id: id,
  iconCode: 10,
  name: name,
  conclusionType: HabitConclusionType.yesNo,
  frequency: const DailyHabitFrequency(),
  startDate: start,
  endDate: end,
);
