import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/controllers/reports/habit_stats_calculator.dart';
import 'package:make_a_habbit/core/providers/clock_provider.dart';
import 'package:make_a_habbit/data/models/reports/habit_stats_model.dart';
import 'package:make_a_habbit/data/providers/concluded_habits_repository_provider.dart';

final habitStatsProvider = Provider.autoDispose<AsyncValue<HabitStatsModel>>((ref) {
  final habits = ref.watch(habitControllerProvider);
  final conclusions = ref.watch(concludedHabitsControllerProvider);

  return habits.when(
    loading: () => const AsyncLoading(),
    error: (error, stackTrace) => AsyncError(error, stackTrace),
    data: (habitList) => conclusions.when(
      loading: () => const AsyncLoading(),
      error: (error, stackTrace) => AsyncError(error, stackTrace),
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
