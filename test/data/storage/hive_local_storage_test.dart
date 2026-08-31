import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/data/dtos/habit_dto.dart';
import 'package:make_a_habbit/data/storage/hive_local_storage.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';

void main() {
  late Directory temporaryDirectory;
  late HiveLocalStorage storage;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'make_a_habbit_local_storage_',
    );
    storage = HiveLocalStorage(
      initializeHive: () async => Hive.init(temporaryDirectory.path),
    );
  });

  tearDown(() async {
    await Hive.close();
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  group('ARMAZENAMENTO LOCAL DO HIVE', () {
    test('Abre todas as caixas necessárias para o aplicativo.', () async {
      await storage.initialize();

      expect(Hive.isBoxOpen(HiveBoxNames.habits), isTrue);
      expect(Hive.isBoxOpen(HiveBoxNames.notifications), isTrue);
      expect(Hive.isBoxOpen(HiveBoxNames.conclusions), isTrue);
    });

    test('Rejeita dados que violam as regras do domínio.', () async {
      await storage.initialize();
      await Hive.box<HabitDto>(HiveBoxNames.habits).put(
        'invalido',
        HabitDto(
          id: 'invalido',
          iconCode: 0,
          name: 'X',
          conclusionTypeName: HabitConclusionType.yesNo.name,
          goalQuantity: null,
          frequencyTypeName: HabitFrequencyType.daily.name,
          selectedDays: const [],
          startDate: DateTime(2026, 8, 30),
          endDate: null,
          description: null,
          notificationId: null,
          notificationTime: null,
        ),
      );
      await Hive.close();

      await expectLater(storage.initialize(), throwsArgumentError);
    });

    test(
      'Apaga apenas as caixas locais conhecidas e permite recomeçar.',
      () async {
        await storage.initialize();
        await Hive.box<HabitDto>(HiveBoxNames.habits).put(
          'invalido',
          HabitDto(
            id: 'invalido',
            iconCode: 0,
            name: 'X',
            conclusionTypeName: HabitConclusionType.yesNo.name,
            goalQuantity: null,
            frequencyTypeName: HabitFrequencyType.daily.name,
            selectedDays: const [],
            startDate: DateTime(2026, 8, 30),
            endDate: null,
            description: null,
            notificationId: null,
            notificationTime: null,
          ),
        );

        await storage.reset();
        await storage.initialize();

        expect(Hive.box<HabitDto>(HiveBoxNames.habits).values, isEmpty);
      },
    );
  });
}
