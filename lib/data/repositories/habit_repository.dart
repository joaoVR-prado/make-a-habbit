import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/data/models/concluded_habits/concluded_habits_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';

abstract class IHabitRepository{
  List<HabitModel> getAllHabits();
  Future<void> addHabit(HabitModel habit);
  Future<void> updateHabit(HabitModel habit);
  Future<void> deleteHabit(String id);

  List<ConcludedHabitsModel> getHistory(String habitId);
  Future<void> markAsDone(ConcludedHabitsModel conclusion);
  Future<void> removeConclusion(String conclusionKey);

}

class HabitRepository implements IHabitRepository {
  final Box<HabitModel> _habitBox;
  final Box<ConcludedHabitsModel> _conclusionBox;

  HabitRepository(
    this._habitBox,
    this._conclusionBox

  );

  // Hábitos:
  @override
  List<HabitModel> getAllHabits(){
    return _habitBox.values.toList();

  }

  @override
  Future<void> addHabit(HabitModel habit) async {
    await _habitBox.put(habit.id, habit);

  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    await _habitBox.put(habit.id, habit);

  }

  @override
  Future<void> deleteHabit(String id) async {
    await _habitBox.delete(id);

  }

  // Hábitos Concluidos
  @override 
  List<ConcludedHabitsModel> getHistory(String habitId){
    return _conclusionBox.values
      .where((conclusion) => conclusion.habitId == habitId)
      .toList();

  }

  @override
  Future<void> markAsDone(ConcludedHabitsModel conclusion) async{
    await _conclusionBox.add(conclusion);

  }

  @override   
  Future<void> removeConclusion(String conclusionKey) async{
    await _conclusionBox.delete(conclusionKey);

  }

}