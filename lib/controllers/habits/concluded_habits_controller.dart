import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/domain/entities/conclusions/completion_value.dart';
import 'package:make_a_habbit/domain/entities/conclusions/concluded_habits_model.dart';
import 'package:make_a_habbit/data/providers/concluded_habits_repository_provider.dart';
import 'package:make_a_habbit/core/providers/clock_provider.dart';

class ConcludedHabitsController
    extends AsyncNotifier<List<ConcludedHabitsModel>> {
  bool _isOperating = false;

  @override
  Future<List<ConcludedHabitsModel>> build() async {
    return ref.read(concludedHabitsRepositoryProvider).getAll();
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => ref.read(concludedHabitsRepositoryProvider).getAll(),
    );
  }

  Future<void> saveYesNoConclusion({
    required String habitId,
    required DateTime date,
    required bool completed,
  }) => _saveConclusion(
    habitId: habitId,
    date: date,
    value: YesNoCompletionValue(completed),
  );

  Future<void> saveQuantityConclusion({
    required String habitId,
    required DateTime date,
    required int quantity,
  }) => _saveConclusion(
    habitId: habitId,
    date: date,
    value: QuantityCompletionValue(quantity),
  );

  Future<void> _saveConclusion({
    required String habitId,
    required DateTime date,
    required CompletionValue value,
  }) async {
    final formattedDate = DateTime(date.year, date.month, date.day);
    final now = ref.read(clockProvider).now();
    final today = DateTime(now.year, now.month, now.day);
    if (formattedDate.isAfter(today)) {
      throw ArgumentError.value(
        date,
        'date',
        'Não é possível concluir um hábito em uma data futura.',
      );
    }
    await _runExclusive((current) async {
      final conclusion = ConcludedHabitsModel(
        habitId: habitId,
        conclusionDate: formattedDate,
        conclusionValue: value,
      );
      await ref.read(concludedHabitsRepositoryProvider).save(conclusion);
      final index = current.indexWhere(
        (item) =>
            item.habitId == habitId && item.conclusionDate == formattedDate,
      );
      return index < 0
          ? [...current, conclusion]
          : [
              for (var i = 0; i < current.length; i++)
                if (i == index) conclusion else current[i],
            ];
    });
  }

  Future<void> removeConclusion(String habitId, DateTime date) async {
    await _runExclusive((current) async {
      final formattedDate = DateTime(date.year, date.month, date.day);
      await ref
          .read(concludedHabitsRepositoryProvider)
          .delete(habitId, formattedDate);
      return current
          .where(
            (item) =>
                !(item.habitId == habitId &&
                    item.conclusionDate == formattedDate),
          )
          .toList(growable: false);
    });
  }

  Future<void> _runExclusive(
    Future<List<ConcludedHabitsModel>> Function(List<ConcludedHabitsModel>)
    operation,
  ) async {
    if (_isOperating) {
      throw StateError('Já existe uma operação de conclusão em andamento.');
    }
    _isOperating = true;
    try {
      final current = await future;
      state = const AsyncLoading();
      state = AsyncData(await operation(current));
    } catch (error, stackTrace) {
      state = AsyncError<List<ConcludedHabitsModel>>(error, stackTrace);
      rethrow;
    } finally {
      _isOperating = false;
    }
  }
}
