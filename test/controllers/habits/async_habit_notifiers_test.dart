import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/data/models/concluded_habits/concluded_habits_model.dart';
import 'package:make_a_habbit/data/providers/concluded_habits_repository_provider.dart';
import 'package:make_a_habbit/data/providers/habit_repository_provider.dart';
import 'package:make_a_habbit/domain/repositories/conclusion_repository.dart';
import 'package:make_a_habbit/domain/repositories/habit_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockConclusionRepository extends Mock implements ConclusionRepository {}
class _MockHabitRepository extends Mock implements HabitRepository {}
class _FakeConclusion extends Fake implements ConcludedHabitsModel {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeConclusion()));

  group('ESTADO ASSÍNCRONO DOS HÁBITOS', () {
    test('Transiciona de carregando para dados.', () async {
      final repository = _MockHabitRepository();
      when(() => repository.getAll()).thenReturn([]);
      final container = ProviderContainer(
        overrides: [habitRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      expect(container.read(habitControllerProvider), isA<AsyncLoading>());
      await container.read(habitControllerProvider.future);
      expect(container.read(habitControllerProvider), isA<AsyncData>());
    });

    test('Transiciona para erro e carrega os dados ao tentar novamente.', () async {
      final repository = _MockHabitRepository();
      when(() => repository.getAll()).thenThrow(Exception('leitura'));
      final container = ProviderContainer(
        overrides: [habitRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(habitControllerProvider.future),
        throwsException,
      );
      expect(container.read(habitControllerProvider), isA<AsyncError>());

      when(() => repository.getAll()).thenReturn([]);
      await container.read(habitControllerProvider.notifier).retry();
      expect(container.read(habitControllerProvider), isA<AsyncData>());
    });
  });

  group('ESTADO ASSÍNCRONO DAS CONCLUSÕES', () {
    test('Transiciona de carregando para dados.', () async {
      final repository = _MockConclusionRepository();
      when(() => repository.getAll()).thenReturn([]);
      final container = ProviderContainer(
        overrides: [
          concludedHabitsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(concludedHabitsControllerProvider), isA<AsyncLoading>());
      await container.read(concludedHabitsControllerProvider.future);
      expect(
        container.read(concludedHabitsControllerProvider),
        isA<AsyncData<List<ConcludedHabitsModel>>>(),
      );
    });

    test('Transiciona de carregando para erro e permite tentar novamente.', () async {
      final repository = _MockConclusionRepository();
      when(() => repository.getAll()).thenThrow(Exception('leitura'));
      final container = ProviderContainer(
        overrides: [
          concludedHabitsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(concludedHabitsControllerProvider.future),
        throwsException,
      );
      expect(container.read(concludedHabitsControllerProvider), isA<AsyncError>());

      when(() => repository.getAll()).thenReturn([]);
      await container.read(concludedHabitsControllerProvider.notifier).retry();
      expect(
        container.read(concludedHabitsControllerProvider),
        isA<AsyncData<List<ConcludedHabitsModel>>>(),
      );
    });

    test('Rejeita uma segunda gravação enquanto a primeira está em andamento.', () async {
      final repository = _MockConclusionRepository();
      final pendingSave = Completer<void>();
      when(() => repository.getAll()).thenReturn([]);
      when(() => repository.save(any())).thenAnswer((_) => pendingSave.future);
      final container = ProviderContainer(
        overrides: [
          concludedHabitsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      await container.read(concludedHabitsControllerProvider.future);
      final notifier = container.read(concludedHabitsControllerProvider.notifier);

      final first = notifier.saveYesNoConclusion(
        habitId: 'habito',
        date: DateTime(2026, 8, 13),
        completed: true,
      );
      await Future<void>.delayed(Duration.zero);

      await expectLater(
        notifier.saveYesNoConclusion(
          habitId: 'habito',
          date: DateTime(2026, 8, 13),
          completed: false,
        ),
        throwsStateError,
      );
      pendingSave.complete();
      await first;
      verify(() => repository.save(any())).called(1);
    });
  });
}
