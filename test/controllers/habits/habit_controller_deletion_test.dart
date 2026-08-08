import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';
import 'package:make_a_habbit/data/providers/habit_repository_provider.dart';
import 'package:make_a_habbit/data/repositories/habit_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockHabitRepository extends Mock implements IHabitRepository {}

void main() {
  late _MockHabitRepository repository;
  late ProviderContainer container;
  late HabitModel habit;

  setUp(() {
    habit = HabitModel(
      id: 'habito',
      iconCode: 0,
      name: 'Beber água',
      conclusionType: HabitConclusionType.yesNo,
      frequency: HabitFrequency(type: HabitFrequencyType.daily),
      startDate: DateTime(2026, 8, 8),
    );
    repository = _MockHabitRepository();
    when(() => repository.getAllHabits()).thenReturn([habit]);
    container = ProviderContainer(
      overrides: [habitRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  group('TESTES DE ESTADO DA EXCLUSÃO DE UM HÁBITO', () {
    test('Remove o estado de um hábito apenas se o repositório tiver sucesso.', () async {
      final deletion = Completer<void>();
      when(() => repository.deleteHabit(habit.id)).thenAnswer(
        (_) => deletion.future,
      );

      final future = container
        .read(habitControllerProvider.notifier)
        .deleteHabit(habit.id);

      expect(container.read(habitControllerProvider), contains(habit));
      deletion.complete();
      await future;
      expect(container.read(habitControllerProvider), isEmpty);
    });

    test('Mantém o hábito caso o repositório falhe em apagar o mesmo.', () async {
      when(() => repository.deleteHabit(habit.id)).thenThrow(
        Exception('Falha no armazenamento'),
      );

      await expectLater(
        container.read(habitControllerProvider.notifier).deleteHabit(habit.id),
        throwsException,
      );

      expect(container.read(habitControllerProvider), contains(habit));
    });


  });


}
