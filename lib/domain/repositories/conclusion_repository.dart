import 'package:make_a_habbit/data/models/concluded_habits/concluded_habits_model.dart';

abstract interface class ConclusionRepository {
  List<ConcludedHabitsModel> getAll();
  List<ConcludedHabitsModel> getHistory(String habitId);
  Future<void> save(ConcludedHabitsModel conclusion);
  Future<void> delete(String habitId, DateTime date);
  Future<void> deleteByHabit(String habitId);
  Future<void> clear();
}
