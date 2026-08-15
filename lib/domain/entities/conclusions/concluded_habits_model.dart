import 'package:make_a_habbit/domain/entities/conclusions/completion_value.dart';

class ConcludedHabitsModel {
  const ConcludedHabitsModel({
    required this.habitId,
    required this.conclusionDate,
    required this.conclusionValue,
    this.note,
  });

  final String habitId;
  final DateTime conclusionDate;
  final CompletionValue conclusionValue;
  final String? note;
}
