import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/domain/entities/conclusions/completion_value.dart';
import 'package:make_a_habbit/domain/entities/conclusions/concluded_habits_model.dart';
import 'package:make_a_habbit/data/providers/concluded_habits_repository_provider.dart';
import 'package:make_a_habbit/data/providers/habit_use_case_providers.dart';

class ConcludedHabitsController
    extends AsyncNotifier<List<ConcludedHabitsModel>> {
  bool _isOperating = false;
  List<ConcludedHabitsModel>? _lastSuccessfulData;

  @override
  Future<List<ConcludedHabitsModel>> build() async {
    final conclusions = ref.read(concludedHabitsRepositoryProvider).getAll();
    _lastSuccessfulData = conclusions;
    return conclusions;
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () async => ref.read(concludedHabitsRepositoryProvider).getAll(),
    );
    if (result case AsyncData(:final value)) {
      _lastSuccessfulData = value;
    }
    state = result;
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
    await _runExclusive((current) async {
      final conclusion = await ref.read(recordHabitConclusionProvider)(
        habitId: habitId,
        date: date,
        value: value,
      );
      final index = current.indexWhere(
        (item) =>
            item.habitId == habitId &&
            item.conclusionDate == conclusion.conclusionDate,
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
      final current = state.value ?? _lastSuccessfulData ?? await future;
      state = const AsyncLoading();
      final updated = await operation(current);
      _lastSuccessfulData = updated;
      state = AsyncData(updated);
    } on ArgumentError {
      state = AsyncData(_lastSuccessfulData ?? const []);
      rethrow;
    } catch (error, stackTrace) {
      state = AsyncError<List<ConcludedHabitsModel>>(error, stackTrace);
      rethrow;
    } finally {
      _isOperating = false;
    }
  }
}
