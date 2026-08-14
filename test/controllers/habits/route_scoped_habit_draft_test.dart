import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/controllers/habits/draft_habit_notifier.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';

HabitModel _habit(String id, String name) => HabitModel(
  id: id,
  iconCode: 0,
  name: name,
  conclusionType: HabitConclusionType.yesNo,
  frequency: HabitFrequency.fromType(type: HabitFrequencyType.daily),
  startDate: DateTime(2026, 8, 13),
);

void main() {
  group('ESCOPO DO RASCUNHO POR ROTA', () {
    test('Uma nova criação começa limpa após outro escopo ser descartado.', () {
      final firstRoute = ProviderContainer(
        overrides: [
          draftHabitInitialStateProvider.overrideWithValue(null),
        ],
      );
      firstRoute.read(draftHabitProvider.notifier).updateName('Temporário');
      expect(firstRoute.read(draftHabitProvider).name, 'Temporário');
      firstRoute.dispose();

      final secondRoute = ProviderContainer(
        overrides: [
          draftHabitInitialStateProvider.overrideWithValue(null),
        ],
      );
      addTearDown(secondRoute.dispose);

      expect(secondRoute.read(draftHabitProvider).name, isEmpty);
      expect(secondRoute.read(draftHabitProvider).existingId, isNull);
    });

    test('Edições sequenciais recebem estados iniciais independentes.', () {
      final firstHabit = _habit('1', 'Beber água');
      final secondHabit = _habit('2', 'Caminhar cedo');
      final firstRoute = ProviderContainer(
        overrides: [
          draftHabitInitialStateProvider.overrideWithValue(
            DraftHabitState.forEdit(firstHabit, null),
          ),
        ],
      );
      final secondRoute = ProviderContainer(
        overrides: [
          draftHabitInitialStateProvider.overrideWithValue(
            DraftHabitState.forEdit(secondHabit, null),
          ),
        ],
      );
      addTearDown(firstRoute.dispose);
      addTearDown(secondRoute.dispose);

      firstRoute.read(draftHabitProvider.notifier).updateName('Alterado');

      expect(firstRoute.read(draftHabitProvider).name, 'Alterado');
      expect(secondRoute.read(draftHabitProvider).name, 'Caminhar cedo');
      expect(secondRoute.read(draftHabitProvider).existingId, '2');
    });

    test('O mesmo escopo preserva o rascunho durante a navegação interna.', () {
      final routeScope = ProviderContainer(
        overrides: [
          draftHabitInitialStateProvider.overrideWithValue(null),
        ],
      );
      addTearDown(routeScope.dispose);

      routeScope.read(draftHabitProvider.notifier).updateName('Ler um livro');
      routeScope.read(draftHabitProvider.notifier).updateGoalQuantity('10');

      expect(routeScope.read(draftHabitProvider).name, 'Ler um livro');
      expect(routeScope.read(draftHabitProvider).goalQuantity, '10');
    });
  });
}
