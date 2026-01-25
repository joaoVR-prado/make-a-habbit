import 'package:flutter/material.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency_type.dart';
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

  Future<bool> isHabitActiveToday(String id, DateTime date) async{
    final repository = ref.read(habitRepositoryProvider);
    final habit = repository.getOneHabit(id);

    // Primeiro valido se o habito ja comecou
    if(!haveHabitStarted(habit!.startDate)) return false;

    // Segundo valido se o habito ja foi concluido
    if(habit.endDate != null){
      if (isHabitConcluded(habit.endDate!)) return false;

    }

    // Pegamos a frequencia e vemos se o hábito deve aparecer hoje
    final habitFrequencyType = habit.frequency.type;

    if(habitFrequencyType == HabitFrequencyType.daily){
      return true;

    } else if(habitFrequencyType == HabitFrequencyType.weekly){
      return habit.frequency.daysOfWeek!.contains(date.weekday) ? true : false;

    } else if(habitFrequencyType == HabitFrequencyType.monthly){
      return (habit.frequency.daysOfMonth!.contains(DateUtils.getDaysInMonth(date.year, date.month))) ? true : false;

    } else{
      return false;

    }
    
  }

}

final habitControllerProvider = NotifierProvider<HabitController, List<HabitModel>>((){
  return HabitController();
  
});

bool haveHabitStarted(DateTime startDate){
  return DateTime.now().isAfter(startDate) ? true : false;

}

bool isHabitConcluded(DateTime endDate){
  return DateTime.now().isAfter(endDate) ? true : false;
  

}


