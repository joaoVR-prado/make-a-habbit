import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/data/dtos/conclusion_dto.dart';
import 'package:make_a_habbit/domain/entities/conclusions/concluded_habits_model.dart';
import 'package:make_a_habbit/domain/repositories/conclusion_repository.dart';

export 'package:make_a_habbit/domain/repositories/conclusion_repository.dart';

class HiveConclusionRepository implements ConclusionRepository {
  HiveConclusionRepository(this._box);

  final Box<ConclusionDto> _box;

  @override
  List<ConcludedHabitsModel> getAll() =>
      _box.values.map((dto) => dto.toDomain()).toList(growable: false);

  @override
  List<ConcludedHabitsModel> getHistory(String habitId) => _box.values
      .map((dto) => dto.toDomain())
      .where((conclusion) => conclusion.habitId == habitId)
      .toList(growable: false);

  @override
  Future<void> save(ConcludedHabitsModel conclusion) {
    return _box.put(
      _key(conclusion.habitId, conclusion.conclusionDate),
      ConclusionDto.fromDomain(conclusion),
    );
  }

  @override
  Future<void> delete(String habitId, DateTime date) {
    return _box.delete(_key(habitId, date));
  }

  @override
  Future<void> deleteByHabit(String habitId) async {
    final keys = _box.keys.where(
      (key) => _box.get(key)?.toDomain().habitId == habitId,
    );
    await _box.deleteAll(keys.toList(growable: false));
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }

  String _key(String habitId, DateTime date) =>
      '${habitId}_${date.year}-${date.month}-${date.day}';
}
