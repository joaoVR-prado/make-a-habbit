import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/notifications/notification_config_model.dart';
import 'package:make_a_habbit/domain/repositories/habit_repository.dart';
import 'package:make_a_habbit/domain/use_cases/clear_habit_data.dart';
import 'package:make_a_habbit/domain/use_cases/delete_habit.dart';
import 'package:make_a_habbit/domain/use_cases/habit_operation_result.dart';
import 'package:make_a_habbit/domain/use_cases/save_habit.dart';

class HabitController extends AsyncNotifier<List<HabitModel>> {
  HabitController({
    required Provider<HabitRepository> habits,
    required Provider<SaveHabit> saveHabit,
    required Provider<DeleteHabit> deleteHabit,
    required Provider<ClearHabitData> clearHabitData,
    required void Function(Ref ref) invalidateConclusions,
  }) : _habits = habits,
       _saveHabit = saveHabit,
       _deleteHabit = deleteHabit,
       _clearHabitData = clearHabitData,
       _invalidateConclusions = invalidateConclusions;

  final Provider<HabitRepository> _habits;
  final Provider<SaveHabit> _saveHabit;
  final Provider<DeleteHabit> _deleteHabit;
  final Provider<ClearHabitData> _clearHabitData;
  final void Function(Ref ref) _invalidateConclusions;

  bool _isOperating = false;
  List<HabitModel>? _lastSuccessfulData;

  @override
  Future<List<HabitModel>> build() async {
    final habits = ref.read(_habits).getAll();
    _lastSuccessfulData = habits;
    return habits;
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () async => ref.read(_habits).getAll(),
    );
    if (result case AsyncData(:final value)) {
      _lastSuccessfulData = value;
    }
    state = result;
  }

  Future<HabitOperationResult> addHabit(
    HabitModel habit,
    NotificationConfigModel notification,
  ) async {
    return _runExclusive((current) async {
      final result = await ref.read(_saveHabit)(
        habit: habit,
        notification: notification,
      );
      return (result, [...current, habit]);
    });
  }

  Future<HabitOperationResult> updateHabit(
    HabitModel habit,
    NotificationConfigModel notification,
  ) async {
    return _runExclusive((current) async {
      final result = await ref.read(_saveHabit)(
        habit: habit,
        notification: notification,
      );
      return (
        result,
        [
          for (final item in current)
            if (item.id == habit.id) habit else item,
        ],
      );
    });
  }

  Future<HabitOperationResult> deleteHabit(String id) async {
    return _runExclusive((current) async {
      final result = await ref.read(_deleteHabit)(id);
      _invalidateConclusions(ref);
      return (result, current.where((item) => item.id != id).toList());
    });
  }

  Future<HabitOperationResult> clearAllData() async {
    if (_isOperating) {
      throw StateError('Já existe uma operação de hábito em andamento.');
    }
    _isOperating = true;
    try {
      state = const AsyncLoading();
      final result = await ref.read(_clearHabitData)();
      _lastSuccessfulData = const [];
      state = const AsyncData([]);
      _invalidateConclusions(ref);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError<List<HabitModel>>(error, stackTrace);
      rethrow;
    } finally {
      _isOperating = false;
    }
  }

  List<HabitModel> getHabitsForDate(DateTime date) {
    final allHabits = state.value ?? const <HabitModel>[];

    return allHabits.where((habit) => habit.isHabitActiveOn(date)).toList();
  }

  Future<HabitOperationResult> _runExclusive(
    Future<(HabitOperationResult, List<HabitModel>)> Function(List<HabitModel>)
    operation,
  ) async {
    if (_isOperating) {
      throw StateError('Já existe uma operação de hábito em andamento.');
    }
    _isOperating = true;
    try {
      final current = state.value ?? _lastSuccessfulData ?? await future;
      state = const AsyncLoading();
      final (result, updated) = await operation(current);
      _lastSuccessfulData = updated;
      state = AsyncData(updated);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError<List<HabitModel>>(error, stackTrace);
      rethrow;
    } finally {
      _isOperating = false;
    }
  }
}
