import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/models/notifications/notification_config_model.dart';

abstract class IHabitRepository{
  List<HabitModel> getAllHabits();
  HabitModel? getOneHabit(String id);
  Future<void> addHabit(HabitModel habit);
  Future<void> updateHabit(HabitModel habit);
  Future<void> deleteHabit(String id);
  Future<void> clearAllData();
  Future<void> saveNotification(String habitId, NotificationConfigModel notification);
  Future<NotificationConfigModel?> getNotification(String habitId);

}

class HabitRepository implements IHabitRepository {
  final Box<HabitModel> _habitBox;
  final Box<NotificationConfigModel> _notificationBox;
  //final Box<ConcludedHabitsModel> _conclusionBox;

  HabitRepository(
    this._habitBox,
    this._notificationBox
    //this._conclusionBox

  );

  // Hábitos:
  @override
  List<HabitModel> getAllHabits(){
    return _habitBox.values.toList();

  }

  @override
  HabitModel? getOneHabit(String id){
    return _habitBox.get(id);

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

  @override
  Future<void> clearAllData() async{
    await _habitBox.clear();
    //await _conclusionBox.clear();

  }

  // NOTIFICACOES //
  @override
  Future<void> saveNotification(String habitId, NotificationConfigModel notification) async{
    final notificationBox = Hive.box<NotificationConfigModel>('notifications');
    await notificationBox.put(habitId, notification);

  }

  @override
  Future<NotificationConfigModel?> getNotification(String habitId) async {
    // O Hive é maravilhoso, é só dar um .get() passando o ID!
    return _notificationBox.get(habitId); 
    
  }

}

