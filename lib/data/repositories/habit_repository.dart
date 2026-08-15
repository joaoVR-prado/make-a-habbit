import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/data/dtos/habit_dto.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/repositories/habit_repository.dart';

export 'package:make_a_habbit/domain/repositories/habit_repository.dart';

class HiveHabitRepository implements HabitRepository {
  HiveHabitRepository(this._box);

  final Box<HabitDto> _box;

  @override
  List<HabitModel> getAll() =>
      _box.values.map((dto) => dto.toDomain()).toList(growable: false);

  @override
  HabitModel? getById(String id) => _box.get(id)?.toDomain();

  @override
  Future<void> add(HabitModel habit) =>
      _box.put(habit.id, HabitDto.fromDomain(habit));

  @override
  Future<void> update(HabitModel habit) =>
      _box.put(habit.id, HabitDto.fromDomain(habit));

  @override
  Future<void> delete(String id) => _box.delete(id);

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}
