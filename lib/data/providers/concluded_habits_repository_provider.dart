import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/controllers/habits/concluded_habits_controller.dart';
import 'package:make_a_habbit/data/dtos/conclusion_dto.dart';
import 'package:make_a_habbit/domain/entities/conclusions/concluded_habits_model.dart';
import 'package:make_a_habbit/data/repositories/concluded_habits_repository.dart';

final concludedHabitsRepositoryProvider = Provider<ConclusionRepository>((ref) {
  return HiveConclusionRepository(
    Hive.box<ConclusionDto>('conclusions'),
  );
});

final concludedHabitsControllerProvider =
    AsyncNotifierProvider<ConcludedHabitsController, List<ConcludedHabitsModel>>(
      ConcludedHabitsController.new,
      retry: (_, _) => null,
    );
