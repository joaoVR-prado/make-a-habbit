import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/controllers/habits/concluded_habits_controller.dart';
import 'package:make_a_habbit/data/models/concluded_habits/concluded_habits_model.dart';
import 'package:make_a_habbit/data/repositories/concluded_habits_repository.dart';

final concludedHabitsRepositoryProvider = Provider<IConcludedHabitsRepository>((ref){
  final box = Hive.box<ConcludedHabitsModel>('conclusions');
  return ConcludedHabitsRepository(box);

});

final concludedHabitsControllerProvider = NotifierProvider<ConcludedHabitsController, List<ConcludedHabitsModel>>(() {
  return ConcludedHabitsController();

});