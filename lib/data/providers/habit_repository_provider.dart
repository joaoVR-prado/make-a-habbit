import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/data/models/concluded_habits/concluded_habits_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/repositories/habit_repository.dart';
import 'package:riverpod/riverpod.dart';

final habitRepositoryProvider = Provider<IHabitRepository>((ref){
  final habitBox = Hive.box<HabitModel>('habits');
  final conclusionBox = Hive.box<ConcludedHabitsModel>('conclusions');

  return HabitRepository(
    habitBox, 
    conclusionBox
  );

});