import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/data/dtos/conclusion_dto.dart';
import 'package:make_a_habbit/data/dtos/habit_dto.dart';
import 'package:make_a_habbit/data/dtos/notification_config_dto.dart';
import 'package:make_a_habbit/domain/entities/conclusions/completion_value.dart';
import 'package:make_a_habbit/domain/entities/conclusions/concluded_habits_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/domain/entities/notifications/notification_config_model.dart';

void main() {
  group('ADAPTADORES BINÁRIOS DO HIVE', () {
    late Directory hiveDirectory;

    setUpAll(() async {
      hiveDirectory = await Directory.systemTemp.createTemp(
        'make_a_habbit_adapters_',
      );
      Hive.init(hiveDirectory.path);
      Hive.registerAdapter(HabitDtoAdapter());
      Hive.registerAdapter(ConclusionDtoAdapter());
      Hive.registerAdapter(NotificationConfigDtoAdapter());
    });

    tearDownAll(() async {
      await Hive.close();
      if (await hiveDirectory.exists()) {
        await hiveDirectory.delete(recursive: true);
      }
    });

    test('Grava e recupera um hábito pelo adaptador binário.', () async {
      final original = HabitModel(
        id: 'habito-binario',
        iconCode: 10,
        name: 'Beber água',
        description: 'Ao longo do dia',
        conclusionType: HabitConclusionType.goalQuantity,
        goalQuantity: 8,
        frequency: WeeklyHabitFrequency(const [1, 3, 5]),
        startDate: DateTime(2026, 8, 16),
        endDate: DateTime(2026, 12, 31),
        notificationId: 123,
        notificationTime: DateTime(2026, 8, 16, 9),
      );
      var box = await Hive.openBox<HabitDto>('habit-adapter-test');
      await box.put(original.id, HabitDto.fromDomain(original));
      await box.close();

      box = await Hive.openBox<HabitDto>('habit-adapter-test');
      final persistedDto = box.get(original.id)!;
      final restored = persistedDto.toDomain();

      expect(persistedDto.conclusionTypeName, 'goalQuantity');
      expect(persistedDto.frequencyTypeName, 'weekly');
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.description, original.description);
      expect(restored.conclusionType, original.conclusionType);
      expect(restored.goalQuantity, original.goalQuantity);
      expect(restored.frequency.type, HabitFrequencyType.weekly);
      expect(restored.frequency.selectedDays, [1, 3, 5]);
      expect(restored.startDate, original.startDate);
      expect(restored.endDate, original.endDate);
      expect(restored.notificationId, original.notificationId);
      expect(restored.notificationTime, original.notificationTime);
      await box.close();
    });

    test('Grava e recupera uma conclusão pelo adaptador binário.', () async {
      final original = ConcludedHabitsModel(
        habitId: 'habito-binario',
        conclusionDate: DateTime(2026, 8, 16),
        conclusionValue: QuantityCompletionValue(6),
        note: 'Quase alcancei a meta',
      );
      var box = await Hive.openBox<ConclusionDto>('conclusion-adapter-test');
      await box.put('conclusao', ConclusionDto.fromDomain(original));
      await box.close();

      box = await Hive.openBox<ConclusionDto>('conclusion-adapter-test');
      final restored = box.get('conclusao')!.toDomain();

      expect(restored.habitId, original.habitId);
      expect(restored.conclusionDate, original.conclusionDate);
      expect((restored.conclusionValue as QuantityCompletionValue).value, 6);
      expect(restored.note, original.note);
      await box.close();
    });

    test('Grava e recupera uma notificação pelo adaptador binário.', () async {
      final original = NotificationConfigModel(
        isReminderEnabled: true,
        isStreakEnabled: true,
        customTimeNotification: [DateTime(2026, 8, 16, 9)],
      );
      var box = await Hive.openBox<NotificationConfigDto>(
        'notification-adapter-test',
      );
      await box.put(
        'habito-binario',
        NotificationConfigDto.fromDomain(original),
      );
      await box.close();

      box = await Hive.openBox<NotificationConfigDto>(
        'notification-adapter-test',
      );
      final restored = box.get('habito-binario')!.toDomain();

      expect(restored.isReminderEnabled, isTrue);
      expect(restored.isStreakEnabled, isTrue);
      expect(restored.customTimeNotification, original.customTimeNotification);
      await box.close();
    });

    test('Lê os índices de enum gravados pela versão anterior.', () async {
      final original = HabitModel(
        id: 'habito-legado',
        iconCode: 10,
        name: 'Caminhar',
        conclusionType: HabitConclusionType.yesNo,
        frequency: MonthlyHabitFrequency(const [1, 15]),
        startDate: DateTime(2026, 8, 16),
      );
      Hive.registerAdapter(_LegacyHabitDtoAdapter(), override: true);
      var box = await Hive.openBox<HabitDto>('legacy-habit-adapter-test');
      await box.put(original.id, HabitDto.fromDomain(original));
      await box.close();

      Hive.registerAdapter(HabitDtoAdapter(), override: true);
      box = await Hive.openBox<HabitDto>('legacy-habit-adapter-test');
      final persistedDto = box.get(original.id)!;
      final restored = persistedDto.toDomain();

      expect(persistedDto.conclusionTypeName, 'yesNo');
      expect(persistedDto.frequencyTypeName, 'monthly');
      expect(restored.conclusionType, HabitConclusionType.yesNo);
      expect(restored.frequency.type, HabitFrequencyType.monthly);
      expect(restored.frequency.selectedDays, [1, 15]);
      await box.close();
    });
  });
}

final class _LegacyHabitDtoAdapter extends TypeAdapter<HabitDto> {
  @override
  int get typeId => 0;

  @override
  HabitDto read(BinaryReader reader) {
    throw UnsupportedError('O adaptador legado é usado apenas para escrita.');
  }

  @override
  void write(BinaryWriter writer, HabitDto obj) {
    final values = <Object?>[
      obj.id,
      obj.iconCode,
      obj.name,
      HabitConclusionType.values.byName(obj.conclusionTypeName).index,
      obj.goalQuantity,
      HabitFrequencyType.values.byName(obj.frequencyTypeName).index,
      obj.selectedDays,
      obj.startDate,
      obj.endDate,
      obj.description,
      obj.notificationId,
      obj.notificationTime,
    ];
    writer.writeByte(values.length);
    for (var index = 0; index < values.length; index++) {
      writer
        ..writeByte(index)
        ..write(values[index]);
    }
  }
}
