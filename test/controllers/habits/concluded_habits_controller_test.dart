import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/domain/entities/conclusions/completion_value.dart';
import 'package:make_a_habbit/domain/entities/conclusions/concluded_habits_model.dart';
import 'package:make_a_habbit/app/providers/controller_providers.dart';
import 'package:make_a_habbit/app/providers/dependency_providers.dart';
import 'package:make_a_habbit/domain/repositories/conclusion_repository.dart';
import 'package:make_a_habbit/core/providers/clock_provider.dart';
import 'package:make_a_habbit/domain/services/clock.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/domain/repositories/habit_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockConclusionRepository extends Mock implements ConclusionRepository {}

class _MockHabitRepository extends Mock implements HabitRepository {}

class _FakeConclusion extends Fake implements ConcludedHabitsModel {}

class _FixedClock implements Clock {
  @override
  DateTime now() => DateTime(2026, 8, 16, 12);
}

void main() {
  late _MockConclusionRepository repository;
  late _MockHabitRepository habits;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(_FakeConclusion());
  });

  setUp(() async {
    repository = _MockConclusionRepository();
    habits = _MockHabitRepository();
    when(() => repository.getAll()).thenReturn([]);
    when(() => habits.getById(any())).thenAnswer((invocation) {
      final id = invocation.positionalArguments.single as String;
      return id == 'habit-1'
          ? _habit(
              id: id,
              conclusionType: HabitConclusionType.goalQuantity,
              goalQuantity: 3,
            )
          : _habit(id: id);
    });
    container = ProviderContainer(
      overrides: [
        concludedHabitsRepositoryProvider.overrideWithValue(repository),
        habitRepositoryProvider.overrideWithValue(habits),
        clockProvider.overrideWithValue(_FixedClock()),
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

      final saved = container
          .read(concludedHabitsControllerProvider)
          .requireValue
          .single;
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

      final saved = container
          .read(concludedHabitsControllerProvider)
          .requireValue
          .single;
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

    test('não permite registrar uma conclusão em uma data futura', () async {
      await expectLater(
        container
            .read(concludedHabitsControllerProvider.notifier)
            .saveYesNoConclusion(
              habitId: 'habito',
              date: DateTime(2026, 8, 17),
              completed: true,
            ),
        throwsA(isA<ArgumentError>()),
      );

      verifyNever(() => repository.save(any()));
      expect(
        container.read(concludedHabitsControllerProvider),
        isA<AsyncData<List<ConcludedHabitsModel>>>(),
      );
    });

    test('permite tentar novamente depois de uma falha ao salvar', () async {
      var attempts = 0;
      when(() => repository.save(any())).thenAnswer((_) async {
        attempts++;
        if (attempts == 1) throw Exception('armazenamento');
      });
      final notifier = container.read(
        concludedHabitsControllerProvider.notifier,
      );

      await expectLater(
        notifier.saveYesNoConclusion(
          habitId: 'habito',
          date: DateTime(2026, 8, 8),
          completed: true,
        ),
        throwsException,
      );
      await notifier.saveYesNoConclusion(
        habitId: 'habito',
        date: DateTime(2026, 8, 8),
        completed: true,
      );

      expect(attempts, 2);
      expect(
        container.read(concludedHabitsControllerProvider),
        isA<AsyncData>(),
      );
    });
  });
}

HabitModel _habit({
  String id = 'habito',
  HabitConclusionType conclusionType = HabitConclusionType.yesNo,
  int? goalQuantity,
}) => HabitModel(
  id: id,
  iconCode: 1,
  name: 'Hábito válido',
  conclusionType: conclusionType,
  goalQuantity: goalQuantity,
  frequency: const DailyHabitFrequency(),
  startDate: DateTime(2026, 1, 1),
);
