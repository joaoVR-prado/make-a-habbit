// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'concluded_habits_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConcludedHabitsModelAdapter extends TypeAdapter<ConcludedHabitsModel> {
  @override
  final typeId = 4;

  @override
  ConcludedHabitsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConcludedHabitsModel(
      habitId: fields[0] as String,
      conclusionDate: fields[1] as DateTime,
      conclusionValue: fields[2] as dynamic,
      note: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ConcludedHabitsModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.habitId)
      ..writeByte(1)
      ..write(obj.conclusionDate)
      ..writeByte(2)
      ..write(obj.conclusionValue)
      ..writeByte(3)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConcludedHabitsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
