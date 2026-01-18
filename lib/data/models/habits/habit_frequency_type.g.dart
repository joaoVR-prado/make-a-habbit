// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_frequency_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitFrequencyTypeAdapter extends TypeAdapter<HabitFrequencyType> {
  @override
  final typeId = 3;

  @override
  HabitFrequencyType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitFrequencyType.daily;
      case 1:
        return HabitFrequencyType.weekly;
      case 2:
        return HabitFrequencyType.monthly;
      case 3:
        return HabitFrequencyType.daysInterval;
      default:
        return HabitFrequencyType.daily;
    }
  }

  @override
  void write(BinaryWriter writer, HabitFrequencyType obj) {
    switch (obj) {
      case HabitFrequencyType.daily:
        writer.writeByte(0);
      case HabitFrequencyType.weekly:
        writer.writeByte(1);
      case HabitFrequencyType.monthly:
        writer.writeByte(2);
      case HabitFrequencyType.daysInterval:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitFrequencyTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
