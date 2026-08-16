import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:make_a_habbit/core/utils/enums/habit_status.dart';
import 'package:make_a_habbit/core/providers/clock_provider.dart';
import 'package:make_a_habbit/domain/entities/conclusions/completion_value.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/domain/entities/notifications/notification_config_model.dart';
import 'package:make_a_habbit/data/providers/concluded_habits_repository_provider.dart';
import 'package:make_a_habbit/data/providers/habit_repository_provider.dart';
import 'package:make_a_habbit/data/providers/habit_use_case_providers.dart';
import 'package:make_a_habbit/data/providers/notification_config_repository_provider.dart';
import 'package:make_a_habbit/domain/use_cases/habit_operation_result.dart';

class HabitController extends AsyncNotifier<List<HabitModel>> {
  bool _isOperating = false;
  List<HabitModel>? _lastSuccessfulData;

  @override
  Future<List<HabitModel>> build() async {
    final habits = ref.read(habitRepositoryProvider).getAll();
    _lastSuccessfulData = habits;
    return habits;
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () async => ref.read(habitRepositoryProvider).getAll(),
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
      final result = await ref.read(saveHabitProvider)(
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
      final result = await ref.read(saveHabitProvider)(
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
      final result = await ref.read(deleteHabitProvider)(id);
      ref.invalidate(concludedHabitsControllerProvider);
      return (result, current.where((item) => item.id != id).toList());
    });
  }

  Future<void> clearAllData() async {
    if (_isOperating) {
      throw StateError('Já existe uma operação de hábito em andamento.');
    }
    _isOperating = true;
    try {
      await future;
      state = const AsyncLoading();
      await ref.read(concludedHabitsRepositoryProvider).clear();
      await ref.read(notificationConfigRepositoryProvider).clear();
      await ref.read(habitRepositoryProvider).clear();
      state = const AsyncData([]);
      ref.invalidate(concludedHabitsControllerProvider);
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

final habitControllerProvider =
    AsyncNotifierProvider<HabitController, List<HabitModel>>(() {
      return HabitController();
    }, retry: (_, _) => null);

final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = ref.watch(clockProvider).now();
  return DateTime(now.year, now.month, now.day);
});

// Listagem dos habitos
final dailyHabitsDisplayProvider =
    Provider.autoDispose<AsyncValue<List<HabitDisplayModel>>>((ref) {
      // Verificacoes sobre a conclusao do habito
      final selectedDate = ref.watch(selectedDateProvider);
      final habits = ref.watch(habitControllerProvider);
      final conclusions = ref.watch(concludedHabitsControllerProvider);
      if (habits case AsyncError(:final error, :final stackTrace)) {
        return AsyncError(error, stackTrace);
      }
      if (conclusions case AsyncError(:final error, :final stackTrace)) {
        return AsyncError(error, stackTrace);
      }
      final allHabits = habits.value;
      final allConclusions = conclusions.value;
      if (allHabits == null || allConclusions == null) {
        return const AsyncLoading();
      }
      final activeHabitsForDate = allHabits
          .where((h) => h.isHabitActiveOn(selectedDate))
          .toList();

      return AsyncData(
        activeHabitsForDate.map((habit) {
          final dailyConclusion = allConclusions
              .where(
                (c) =>
                    c.habitId == habit.id &&
                    c.conclusionDate.year == selectedDate.year &&
                    c.conclusionDate.month == selectedDate.month &&
                    c.conclusionDate.day == selectedDate.day,
              )
              .firstOrNull;

          HabitStatus habitStatus = HabitStatus.pending;

          if (habit.conclusionType == HabitConclusionType.goalQuantity) {
            final doneQuantity = switch (dailyConclusion?.conclusionValue) {
              QuantityCompletionValue(:final value) => value,
              _ => 0,
            };
            final targetQuantity = habit.goalQuantity ?? 1;
            if (doneQuantity >= targetQuantity) {
              habitStatus = HabitStatus.done;
            }
          } else {
            if (dailyConclusion != null) {
              habitStatus = switch (dailyConclusion.conclusionValue) {
                YesNoCompletionValue(value: true) => HabitStatus.done,
                YesNoCompletionValue(value: false) => HabitStatus.incomplete,
                _ => HabitStatus.pending,
              };
            }
          }

          // Retorna os habitos filtrados para a UI
          return HabitDisplayModel(habit: habit, status: habitStatus);
        }).toList(),
      );
    });

// Classe para a UI
class HabitDisplayModel {
  final HabitModel habit;
  final HabitStatus status;

  HabitDisplayModel({required this.habit, required this.status});
}
