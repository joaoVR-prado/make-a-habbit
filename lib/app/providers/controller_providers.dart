import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:make_a_habbit/app/providers/dependency_providers.dart';
import 'package:make_a_habbit/app/providers/use_case_providers.dart';
import 'package:make_a_habbit/controllers/habits/concluded_habits_controller.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/core/providers/clock_provider.dart';
import 'package:make_a_habbit/core/utils/enums/habit_status.dart';
import 'package:make_a_habbit/domain/entities/conclusions/completion_value.dart';
import 'package:make_a_habbit/domain/entities/conclusions/concluded_habits_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';

export 'package:make_a_habbit/controllers/habits/concluded_habits_controller.dart'
    show ConcludedHabitsController;
export 'package:make_a_habbit/controllers/habits/habit_controller.dart'
    show HabitController;

final concludedHabitsControllerProvider =
    AsyncNotifierProvider<
      ConcludedHabitsController,
      List<ConcludedHabitsModel>
    >(
      () => ConcludedHabitsController(
        conclusions: concludedHabitsRepositoryProvider,
        recordConclusion: recordHabitConclusionProvider,
      ),
      retry: (_, _) => null,
    );

final habitControllerProvider =
    AsyncNotifierProvider<HabitController, List<HabitModel>>(
      () => HabitController(
        habits: habitRepositoryProvider,
        saveHabit: saveHabitProvider,
        deleteHabit: deleteHabitProvider,
        clearHabitData: clearHabitDataProvider,
        invalidateConclusions: (ref) {
          ref.invalidate(concludedHabitsControllerProvider);
        },
      ),
      retry: (_, _) => null,
    );

final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = ref.watch(clockProvider).now();
  return DateTime(now.year, now.month, now.day);
});

final dailyHabitsDisplayProvider =
    Provider.autoDispose<AsyncValue<List<HabitDisplayModel>>>((ref) {
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
          .where((habit) => habit.isHabitActiveOn(selectedDate))
          .toList();

      return AsyncData(
        activeHabitsForDate
            .map((habit) {
              final dailyConclusion = allConclusions
                  .where(
                    (conclusion) =>
                        conclusion.habitId == habit.id &&
                        _isSameDay(conclusion.conclusionDate, selectedDate),
                  )
                  .firstOrNull;

              var habitStatus = HabitStatus.pending;
              if (habit.conclusionType == HabitConclusionType.goalQuantity) {
                final doneQuantity = switch (dailyConclusion?.conclusionValue) {
                  QuantityCompletionValue(:final value) => value,
                  _ => 0,
                };
                if (doneQuantity >= (habit.goalQuantity ?? 1)) {
                  habitStatus = HabitStatus.done;
                }
              } else if (dailyConclusion != null) {
                habitStatus = switch (dailyConclusion.conclusionValue) {
                  YesNoCompletionValue(value: true) => HabitStatus.done,
                  YesNoCompletionValue(value: false) => HabitStatus.incomplete,
                  _ => HabitStatus.pending,
                };
              }

              return HabitDisplayModel(habit: habit, status: habitStatus);
            })
            .toList(growable: false),
      );
    });

bool _isSameDay(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

final class HabitDisplayModel {
  const HabitDisplayModel({required this.habit, required this.status});

  final HabitModel habit;
  final HabitStatus status;
}
