// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_config_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationConfigModelAdapter
    extends TypeAdapter<NotificationConfigModel> {
  @override
  final typeId = 10;

  @override
  NotificationConfigModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationConfigModel(
      isReminderEnabled: fields[0] as bool,
      isStreakEnabled: fields[1] as bool,
      customTimeNotification: (fields[2] as List).cast<DateTime>(),
    );
  }

  @override
  void write(BinaryWriter writer, NotificationConfigModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.isReminderEnabled)
      ..writeByte(1)
      ..write(obj.isStreakEnabled)
      ..writeByte(2)
      ..write(obj.customTimeNotification);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationConfigModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
