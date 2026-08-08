import 'package:make_a_habbit/data/models/habits/habit_model.dart';

abstract interface class HabitRepository {
  List<HabitModel> getAll();
  HabitModel? getById(String id);
  Future<void> add(HabitModel habit);
  Future<void> update(HabitModel habit);
  Future<void> delete(String id);
  Future<void> clear();
}
