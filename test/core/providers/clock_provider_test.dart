import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/controllers/habits/draft_habit_notifier.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/core/providers/clock_provider.dart';
import 'package:make_a_habbit/domain/services/clock.dart';

class _FixedClock implements Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}

void main() {
  group('RELÓGIO', () {
    test('Inicia o rascunho e a data selecionada com o relógio informado.', () {
      final fixedDate = DateTime(2026, 8, 9, 15, 30);
      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(_FixedClock(fixedDate)),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(draftHabitProvider).startDate, fixedDate);
      expect(
        container.read(selectedDateProvider),
        DateTime(2026, 8, 9),
      );
    });

    test('Usa o relógio informado ao limpar o rascunho', () {
      final fixedDate = DateTime(2026, 8, 9, 15, 30);
      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(_FixedClock(fixedDate)),
        ],
      );
      addTearDown(container.dispose);

      container.read(draftHabitProvider.notifier).updateName('Temporário');
      container.read(draftHabitProvider.notifier).clear();

      expect(container.read(draftHabitProvider).startDate, fixedDate);
      expect(container.read(draftHabitProvider).name, isEmpty);
    });
  });
}
