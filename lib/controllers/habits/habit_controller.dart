import 'package:flutter_riverpod/legacy.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/providers/habit_repository_provider.dart';
import 'package:riverpod/riverpod.dart';

class HabitController extends Notifier<List<HabitModel>> {
  @override
  List<HabitModel> build(){
    final repository = ref.read(habitRepositoryProvider);

    return repository.getAllHabits();

  }

  Future<void> addHabit(HabitModel habit) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.addHabit(habit);
    state = [...state, habit];

  }

  Future<void> updateHabit(HabitModel habit) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.updateHabit(habit);

    state = [
      for(final i in state)
        if(i.id == habit.id) habit else i
 
    ];

  }

  Future<void> deleteHabit(String id) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.deleteHabit(id);
    state = state.where((i) => i.id !=id).toList();

  }

  Future<void> clearAllData() async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.clearAllData();
    state = [];

  }

  List<HabitModel> getHabitsForDate(DateTime date){
    final allHabits = state;

    return allHabits.where((habit) => habit.isHabitActiveOn(date)).toList();

  }

}

final habitControllerProvider = NotifierProvider<HabitController, List<HabitModel>>((){
  return HabitController();
  
});

final selectedDateProvider = StateProvider<DateTime>((ref){
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);

});




