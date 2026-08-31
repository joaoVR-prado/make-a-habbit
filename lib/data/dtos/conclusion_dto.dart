import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/domain/entities/conclusions/completion_value.dart';
import 'package:make_a_habbit/domain/entities/conclusions/concluded_habits_model.dart';
import 'package:make_a_habbit/data/dtos/persisted_field_reader.dart';

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

  ConcludedHabitsModel toDomain() {
    final conclusionValue = switch ((isYesNo, yesNoValue, quantityValue)) {
      (true, final bool value, null) => YesNoCompletionValue(value),
      (false, null, final int value) => QuantityCompletionValue(value),
      (true, null, _) => throw const FormatException(
        'Conclusão do tipo sim ou não sem valor persistido.',
      ),
      (false, _, null) => throw const FormatException(
        'Conclusão quantitativa sem valor persistido.',
      ),
      _ => throw const FormatException(
        'Conclusão persistida possui valores incompatíveis com o seu tipo.',
      ),
    };

    return ConcludedHabitsModel(
      habitId: habitId,
      conclusionDate: conclusionDate,
      conclusionValue: conclusionValue,
      note: note,
    );
  }
}

final class ConclusionDtoAdapter extends TypeAdapter<ConclusionDto> {
  @override
  int get typeId => 4;
  @override
  ConclusionDto read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, Object?>{
      for (var index = 0; index < count; index++)
        reader.readByte(): reader.read(),
    };
    return ConclusionDto(
      habitId: readRequiredField<String>(fields, 0, 'conclusion.habitId'),
      conclusionDate: readRequiredField<DateTime>(fields, 1, 'conclusion.date'),
      isYesNo: readRequiredField<bool>(fields, 2, 'conclusion.isYesNo'),
      yesNoValue: readOptionalField<bool>(fields, 3, 'conclusion.yesNoValue'),
      quantityValue: readOptionalIntField(
        fields,
        4,
        'conclusion.quantityValue',
      ),
      note: readOptionalField<String>(fields, 5, 'conclusion.note'),
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
      writer
        ..writeByte(index)
        ..write(values[index]);
    }
  }
}
