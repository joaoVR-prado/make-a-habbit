import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/domain/entities/conclusions/completion_value.dart';
import 'package:make_a_habbit/domain/entities/conclusions/concluded_habits_model.dart';
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

  setUp(() async {
    repository = _MockConclusionRepository();
    when(() => repository.getAll()).thenReturn([]);
    container = ProviderContainer(
      overrides: [
        concludedHabitsRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(concludedHabitsControllerProvider.future);
  });

  group('Registro tipado de conclusões', () {
    test('salva uma conclusão do tipo sim ou não', () async {
      when(() => repository.save(any())).thenAnswer((_) async {});

      await container
          .read(concludedHabitsControllerProvider.notifier)
          .saveYesNoConclusion(
            habitId: 'habito',
            date: DateTime(2026, 8, 8, 15),
            completed: true,
          );

      final saved = container.read(concludedHabitsControllerProvider).requireValue.single;
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

      final saved = container.read(concludedHabitsControllerProvider).requireValue.single;
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
