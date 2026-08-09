import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/controllers/habits/concluded_habits_controller.dart';
import 'package:make_a_habbit/data/models/concluded_habits/concluded_habits_model.dart';
import 'package:make_a_habbit/data/models/concluded_habits/completion_value.dart';
import 'package:make_a_habbit/data/providers/concluded_habits_repository_provider.dart';
import 'package:make_a_habbit/domain/repositories/conclusion_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockConclusionRepository extends Mock implements ConclusionRepository {}
class _FakeConclusion extends Fake implements ConcludedHabitsModel {}

void main() {
  late _MockConclusionRepository repository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(_FakeConclusion());
  });

  setUp(() {
    repository = _MockConclusionRepository();
    when(() => repository.getAll()).thenReturn([]);
    container = ProviderContainer(
      overrides: [
        concludedHabitsRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  group('Registro tipado de conclusões', () {
    test('salva uma conclusão do tipo sim ou não', () async {
      when(() => repository.save(any())).thenAnswer((_) async {});

      await container
          .read(concludedHabitsControllerProvider.notifier)
          .saveYesNoConclusion(
            habitId: 'habit-1',
            date: DateTime(2026, 8, 8, 15),
            completed: true,
          );

      final saved = container.read(concludedHabitsControllerProvider).single;
      expect(saved.conclusionDate, DateTime(2026, 8, 8));
      expect(saved.conclusionValue, isA<YesNoCompletionValue>());
      expect((saved.conclusionValue as YesNoCompletionValue).value, isTrue);
    });

    test('salva uma conclusão do tipo quantidade', () async {
      when(() => repository.save(any())).thenAnswer((_) async {});

      await container
          .read(concludedHabitsControllerProvider.notifier)
          .saveQuantityConclusion(
            habitId: 'habit-1',
            date: DateTime(2026, 8, 8),
            quantity: 4,
          );

      final saved = container.read(concludedHabitsControllerProvider).single;
      expect(saved.conclusionValue, isA<QuantityCompletionValue>());
      expect((saved.conclusionValue as QuantityCompletionValue).value, 4);
    });

    test('não chama o repositório quando a quantidade é negativa', () async {
      expect(
        () => container
            .read(concludedHabitsControllerProvider.notifier)
            .saveQuantityConclusion(
              habitId: 'habit-1',
              date: DateTime(2026, 8, 8),
              quantity: -1,
            ),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(() => repository.save(any()));
    });
  });
}
