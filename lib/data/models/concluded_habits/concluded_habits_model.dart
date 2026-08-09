import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/data/models/concluded_habits/completion_value.dart';

part 'concluded_habits_model.g.dart';

@HiveType(typeId: 4)
class ConcludedHabitsModel extends HiveObject {
  @HiveField(0)
  final String habitId; //UUID

  @HiveField(1)
  final DateTime conclusionDate;

  @HiveField(2)
  final CompletionValue conclusionValue;

  @HiveField(3)
  final String? note;

  ConcludedHabitsModel({
    required this.habitId,
    required this.conclusionDate,
    required this.conclusionValue,
    this.note

  }); 

}
