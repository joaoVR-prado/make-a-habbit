// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitConclusionTypeAdapter extends TypeAdapter<HabitConclusionType> {
  @override
  final typeId = 1;

  @override
  HabitConclusionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitConclusionType.yesNo;
      case 1:
        return HabitConclusionType.goalQuantity;
      default:
        return HabitConclusionType.yesNo;
    }
  }

  @override
  void write(BinaryWriter writer, HabitConclusionType obj) {
    switch (obj) {
      case HabitConclusionType.yesNo:
        writer.writeByte(0);
      case HabitConclusionType.goalQuantity:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitConclusionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
