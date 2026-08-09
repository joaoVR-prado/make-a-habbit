import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:make_a_habbit/core/utils/enums/habit_status.dart';
import 'package:make_a_habbit/data/models/concluded_habits/completion_value.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';
import 'package:make_a_habbit/data/models/notifications/notification_config_model.dart';
import 'package:make_a_habbit/data/providers/concluded_habits_repository_provider.dart';
import 'package:make_a_habbit/data/providers/habit_repository_provider.dart';
import 'package:make_a_habbit/data/providers/notification_config_repository_provider.dart';

class HabitController extends Notifier<List<HabitModel>> {
  @override
  List<HabitModel> build(){
    final repository = ref.read(habitRepositoryProvider);

    return repository.getAll();

  }

  Future<void> addHabit(HabitModel habit, NotificationConfigModel notification) async {
    final repository = ref.read(habitRepositoryProvider);
    final notifications = ref.read(notificationConfigRepositoryProvider);
    await repository.add(habit);
    await notifications.save(habit.id, notification);

    state = [...state, habit];

  }

  Future<void> updateHabit(HabitModel habit, NotificationConfigModel notification) async {
    final repository = ref.read(habitRepositoryProvider);
    final notifications = ref.read(notificationConfigRepositoryProvider);
    await repository.update(habit);
    await notifications.save(habit.id, notification);

    state = [
      for(final i in state)
        if(i.id == habit.id) habit else i
 
    ];

  }

  Future<void> deleteHabit(String id) async {
    final repository = ref.read(habitRepositoryProvider);
    final notifications = ref.read(notificationConfigRepositoryProvider);
    final conclusions = ref.read(concludedHabitsRepositoryProvider);

    await conclusions.deleteByHabit(id);
    await notifications.delete(id);
    await repository.delete(id);
    state = state.where((i) => i.id !=id).toList();
    ref.invalidate(concludedHabitsControllerProvider);

  }

  Future<void> clearAllData() async {
    final repository = ref.read(habitRepositoryProvider);
    final notifications = ref.read(notificationConfigRepositoryProvider);
    final conclusions = ref.read(concludedHabitsRepositoryProvider);

    await conclusions.clear();
    await notifications.clear();
    await repository.clear();
    state = [];
    ref.invalidate(concludedHabitsControllerProvider);

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


// Listagem dos habitos
final dailyHabitsDisplayProvider = Provider.autoDispose<List<HabitDisplayModel>>((ref){

  // Verificacoes sobre a conclusao do habito
  final selectedDate = ref.watch(selectedDateProvider);
  final allHabits = ref.watch(habitControllerProvider);
  final allConclusions = ref.watch(concludedHabitsControllerProvider);
  final activeHabitsForDate = allHabits.where((h) => h.isHabitActiveOn(selectedDate)).toList();

  return activeHabitsForDate.map((habit) {
    final dailyConclusion = allConclusions.where((c) => 
      c.habitId == habit.id &&
      c.conclusionDate.year == selectedDate.year &&
      c.conclusionDate.month == selectedDate.month &&
      c.conclusionDate.day == selectedDate.day
    ).firstOrNull;

    HabitStatus habitStatus = HabitStatus.pending;

    if (habit.conclusionType == HabitConclusionType.goalQuantity) {
      final doneQuantity = switch (dailyConclusion?.conclusionValue) {
        QuantityCompletionValue(:final value) => value,
        _ => 0,
      };
      final targetQuantity = habit.goalQuantity ?? 1;
      if (doneQuantity >= targetQuantity) {
        habitStatus = HabitStatus.done;
      }
    } else {
      if (dailyConclusion != null) {
        habitStatus = switch (dailyConclusion.conclusionValue) {
          YesNoCompletionValue(value: true) => HabitStatus.done,
          YesNoCompletionValue(value: false) => HabitStatus.incomplete,
          _ => HabitStatus.pending,
        };
      }
    }

    // Retorna os habitos filtrados para a UI
    return HabitDisplayModel(habit: habit, status: habitStatus);
  }).toList();
});

// Classe para a UI
class HabitDisplayModel{
  final HabitModel habit;
  final HabitStatus status;

  HabitDisplayModel({
    required this.habit,
    required this.status,

  });

}
