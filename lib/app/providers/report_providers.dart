import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/app/providers/controller_providers.dart';
import 'package:make_a_habbit/controllers/reports/habit_stats_calculator.dart';
import 'package:make_a_habbit/core/providers/clock_provider.dart';
import 'package:make_a_habbit/data/models/reports/habit_detail_stats_model.dart';
import 'package:make_a_habbit/data/models/reports/habit_stats_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';

final habitStatsProvider = Provider.autoDispose<AsyncValue<HabitStatsModel>>((
  ref,
) {
  final habits = ref.watch(habitControllerProvider);
  final conclusions = ref.watch(concludedHabitsControllerProvider);

  return habits.when(
    loading: () => const AsyncLoading(),
    error: AsyncError.new,
    data: (habitList) => conclusions.when(
      loading: () => const AsyncLoading(),
      error: AsyncError.new,
      data: (conclusionList) => AsyncData(
        const HabitStatsCalculator().calculate(
          habits: habitList,
          conclusions: conclusionList,
          now: ref.watch(clockProvider).now(),
        ),
      ),
    ),
  );
});

final habitDetailStatsProvider = Provider.autoDispose
    .family<AsyncValue<HabitDetailStatsModel>, HabitModel>((ref, habit) {
      final conclusions = ref.watch(concludedHabitsControllerProvider);
      return conclusions.when(
        loading: () => const AsyncLoading(),
        error: AsyncError.new,
        data: (items) => AsyncData(
          const HabitStatsCalculator().calculateForHabit(
            habit: habit,
            conclusions: items,
            now: ref.watch(clockProvider).now(),
          ),
        ),
      );
    });
