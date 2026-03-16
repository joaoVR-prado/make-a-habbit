import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/data/models/concluded_habits/concluded_habits_model.dart';

abstract class IConcludedHabitsRepository{
  List<ConcludedHabitsModel> getAllConclusions();
  List<ConcludedHabitsModel> getHistory(String habitId);
  Future<void> saveOrUpdateConclusion(ConcludedHabitsModel conclusion);
  Future<void> removeConclusion(String habitId, DateTime date);

}

class ConcludedHabitsRepository implements IConcludedHabitsRepository {
  final Box<ConcludedHabitsModel> _conclusionBox;

  ConcludedHabitsRepository(this._conclusionBox);

  @override
  List<ConcludedHabitsModel> getAllConclusions(){
    return _conclusionBox.values.toList();

  }

  @override
  List<ConcludedHabitsModel> getHistory(String habitId){
    return _conclusionBox.values
      .where((conclusion) => conclusion.habitId == habitId)
      .toList();

  }

  @override
  Future<void> saveOrUpdateConclusion(ConcludedHabitsModel conclusion) async{
    final date = conclusion.conclusionDate;
    final uniqueKey = '${conclusion.habitId}_${date.year}-${date.month}-${date.day}';

    await _conclusionBox.put(uniqueKey, conclusion);

  }

  @override
  Future<void> removeConclusion(String habitId, DateTime date) async {
    final uniqueKey = '${habitId}_${date.year}-${date.month}-${date.day}';
    await _conclusionBox.delete(uniqueKey);

  }

}