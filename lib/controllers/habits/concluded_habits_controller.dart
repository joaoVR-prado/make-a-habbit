import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/data/models/concluded_habits/concluded_habits_model.dart';
import 'package:make_a_habbit/data/providers/concluded_habits_repository_provider.dart';
import 'package:make_a_habbit/data/repositories/concluded_habits_repository.dart';

class ConcludedHabitsController extends Notifier<List<ConcludedHabitsModel>>  {
  @override
  List<ConcludedHabitsModel> build(){
    final repository = ref.read(concludedHabitsRepositoryProvider);
    return repository.getAllConclusions();

  }

  Future<void> saveOrUpdateConclusion({
    required String habitId,
    required DateTime date,
    required dynamic value
  }) async{
    final repository = ref.read(concludedHabitsRepositoryProvider);

    final formattedDate = DateTime(date.year, date.month, date.day);

    final newConclusion = ConcludedHabitsModel(
      habitId: habitId, 
      conclusionDate: formattedDate, 
      conclusionValue: value
    );

    await repository.saveOrUpdateConclusion(newConclusion);

    final existingIndex = state.indexWhere((i) =>
      i.habitId == habitId &&
      i.conclusionDate.year == formattedDate.year &&
      i.conclusionDate.month == formattedDate.month &&
      i.conclusionDate.day == formattedDate.day 
    );

    // TODO: Chamar repositorio

    if(existingIndex >= 0){
      state = [
        for(int i =0; i < state.length; i++)
          if (i == existingIndex) newConclusion else state[i]
      ];

    } else{
      state = [...state, newConclusion];

    }

  }

  Future<void> removeConclusion(String habitId, DateTime date) async{
    final repository = ref.read(concludedHabitsRepositoryProvider);
    final formattedDate = DateTime(date.year, date.month, date.day);

    await repository.removeConclusion(habitId, formattedDate);

    state = state.where((c) => 
      !(c.habitId == habitId && 
        c.conclusionDate.year == formattedDate.year &&
        c.conclusionDate.month == formattedDate.month &&
        c.conclusionDate.day == formattedDate.day)
    ).toList();

  }

}

// final concludedHabitsControllerProvider = NotifierProvider<ConcludedHabitsController, List<ConcludedHabitsModel>>(() {
//   return ConcludedHabitsController();
  
// });