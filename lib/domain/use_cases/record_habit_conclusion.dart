import 'package:make_a_habbit/domain/entities/conclusions/completion_value.dart';
import 'package:make_a_habbit/domain/entities/conclusions/concluded_habits_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/domain/repositories/conclusion_repository.dart';
import 'package:make_a_habbit/domain/repositories/habit_repository.dart';
import 'package:make_a_habbit/domain/services/clock.dart';

final class RecordHabitConclusion {
  const RecordHabitConclusion({
    required HabitRepository habits,
    required ConclusionRepository conclusions,
    required Clock clock,
  }) : _habits = habits,
       _conclusions = conclusions,
       _clock = clock;

  final HabitRepository _habits;
  final ConclusionRepository _conclusions;
  final Clock _clock;

  Future<ConcludedHabitsModel> call({
    required String habitId,
    required DateTime date,
    required CompletionValue value,
  }) async {
    final habit = _habits.getById(habitId);
    if (habit == null) {
      throw ArgumentError.value(habitId, 'habitId', 'O hábito não existe.');
    }

    final conclusionDate = DateTime(date.year, date.month, date.day);
    final now = _clock.now();
    final today = DateTime(now.year, now.month, now.day);
    if (conclusionDate.isAfter(today)) {
      throw ArgumentError.value(
        date,
        'date',
        'Não é possível concluir um hábito em uma data futura.',
      );
    }
    if (!habit.isHabitActiveOn(conclusionDate)) {
      throw ArgumentError.value(
        date,
        'date',
        'O hábito não está agendado para esta data.',
      );
    }

    final isCompatible = switch ((habit.conclusionType, value)) {
      (HabitConclusionType.yesNo, YesNoCompletionValue()) => true,
      (HabitConclusionType.goalQuantity, QuantityCompletionValue()) => true,
      _ => false,
    };
    if (!isCompatible) {
      throw ArgumentError.value(
        value,
        'value',
        'O tipo da conclusão é incompatível com o hábito.',
      );
    }

    final conclusion = ConcludedHabitsModel(
      habitId: habitId,
      conclusionDate: conclusionDate,
      conclusionValue: value,
    );
    await _conclusions.save(conclusion);
    return conclusion;
  }
}
