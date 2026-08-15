import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/domain/entities/conclusions/completion_value.dart';
import 'package:make_a_habbit/domain/entities/conclusions/concluded_habits_model.dart';

final class ConclusionDto {
  const ConclusionDto({
    required this.habitId,
    required this.conclusionDate,
    required this.isYesNo,
    required this.yesNoValue,
    required this.quantityValue,
    required this.note,
  });

  factory ConclusionDto.fromDomain(ConcludedHabitsModel conclusion) {
    final value = conclusion.conclusionValue;
    return ConclusionDto(
      habitId: conclusion.habitId,
      conclusionDate: conclusion.conclusionDate,
      isYesNo: value is YesNoCompletionValue,
      yesNoValue: value is YesNoCompletionValue ? value.value : null,
      quantityValue: value is QuantityCompletionValue ? value.value : null,
      note: conclusion.note,
    );
  }

  final String habitId;
  final DateTime conclusionDate;
  final bool isYesNo;
  final bool? yesNoValue;
  final int? quantityValue;
  final String? note;

  ConcludedHabitsModel toDomain() => ConcludedHabitsModel(
    habitId: habitId,
    conclusionDate: conclusionDate,
    conclusionValue: isYesNo
        ? YesNoCompletionValue(yesNoValue!)
        : QuantityCompletionValue(quantityValue!),
    note: note,
  );
}

final class ConclusionDtoAdapter extends TypeAdapter<ConclusionDto> {
  @override
  int get typeId => 4;
  @override
  ConclusionDto read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, Object?>{
      for (var index = 0; index < count; index++) reader.readByte(): reader.read(),
    };
    return ConclusionDto(
      habitId: fields[0] as String,
      conclusionDate: fields[1] as DateTime,
      isYesNo: fields[2] as bool,
      yesNoValue: fields[3] as bool?,
      quantityValue: (fields[4] as num?)?.toInt(),
      note: fields[5] as String?,
    );
  }
  @override
  void write(BinaryWriter writer, ConclusionDto obj) {
    final values = <Object?>[
      obj.habitId,
      obj.conclusionDate,
      obj.isYesNo,
      obj.yesNoValue,
      obj.quantityValue,
      obj.note,
    ];
    writer.writeByte(values.length);
    for (var index = 0; index < values.length; index++) {
      writer..writeByte(index)..write(values[index]);
    }
  }
}
