import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/app/providers/controller_providers.dart';
import 'package:make_a_habbit/app/providers/dependency_providers.dart';
import 'package:make_a_habbit/app/providers/use_case_providers.dart';
import 'package:make_a_habbit/core/providers/clock_provider.dart';
import 'package:make_a_habbit/domain/entities/conclusions/concluded_habits_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/domain/services/clock.dart';
import 'package:make_a_habbit/presentation/habits/widgets/complete_habit.dart';

final class _FixedClock implements Clock {
  @override
  DateTime now() => DateTime(2026, 8, 24, 14, 30);
}

final class _EmptyConcludedHabitsController extends ConcludedHabitsController {
  _EmptyConcludedHabitsController()
    : super(
        conclusions: concludedHabitsRepositoryProvider,
        recordConclusion: recordHabitConclusionProvider,
      );

  @override
  Future<List<ConcludedHabitsModel>> build() async => const [];
}

void main() {
  group('LAYOUT DO DIÁLOGO DE CONCLUSÃO', () {
    testWidgets(
      'Permite rolagem sem overflow quando a altura disponível é reduzida.',
      (tester) async {
        tester.view.physicalSize = const Size(400, 364);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final habit = HabitModel(
          id: 'habito-quantitativo',
          iconCode: 0,
          name: 'Beber Água',
          conclusionType: HabitConclusionType.goalQuantity,
          goalQuantity: 8,
          frequency: const DailyHabitFrequency(),
          startDate: DateTime(2026, 8, 24),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              clockProvider.overrideWithValue(_FixedClock()),
              selectedDateProvider.overrideWith((ref) => DateTime(2026, 8, 24)),
              concludedHabitsControllerProvider.overrideWith(
                _EmptyConcludedHabitsController.new,
              ),
            ],
            child: MaterialApp(
              home: Scaffold(body: CompleteHabit(habit: habit)),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(SingleChildScrollView), findsOneWidget);
        expect(
          find.byKey(const Key('quantity_conclusion_input')),
          findsOneWidget,
        );
      },
    );
  });
}
