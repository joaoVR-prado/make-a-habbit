import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/repositories/habit_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final habitRepositoryProvider = Provider<IHabitRepository>((ref){
  final habitBox = Hive.box<HabitModel>('habits');

  return HabitRepository(
    habitBox
    
  );

});