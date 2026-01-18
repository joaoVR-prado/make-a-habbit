// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitModelAdapter extends TypeAdapter<HabitModel> {
  @override
  final typeId = 0;

  @override
  HabitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitModel(
      id: fields[0] as String,
      iconCode: (fields[1] as num).toInt(),
      name: fields[2] as String,
      conclusionType: fields[3] as HabitConclusionType,
      goalQuantity: (fields[4] as num?)?.toInt(),
      frequency: fields[5] as HabitFrequency,
      startData: fields[6] as DateTime,
      endData: fields[7] as DateTime?,
      description: fields[8] as String?,
      notificationId: (fields[9] as num?)?.toInt(),
      notificationTime: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, HabitModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.iconCode)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.conclusionType)
      ..writeByte(4)
      ..write(obj.goalQuantity)
      ..writeByte(5)
      ..write(obj.frequency)
      ..writeByte(6)
      ..write(obj.startData)
      ..writeByte(7)
      ..write(obj.endData)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.notificationId)
      ..writeByte(10)
      ..write(obj.notificationTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
