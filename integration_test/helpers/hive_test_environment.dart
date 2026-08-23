import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/data/dtos/conclusion_dto.dart';
import 'package:make_a_habbit/data/dtos/habit_dto.dart';
import 'package:make_a_habbit/data/dtos/notification_config_dto.dart';

final class HiveTestEnvironment {
  HiveTestEnvironment._();

  static Directory? _directory;

  static Future<void> initialize() async {
    _directory ??= await Directory.systemTemp.createTemp(
      'make_a_habbit_integration_',
    );

    Hive.init(_directory!.path);
    _registerAdapters();

    await Future.wait([
      Hive.openBox<HabitDto>('habits'),
      Hive.openBox<NotificationConfigDto>('notifications'),
      Hive.openBox<ConclusionDto>('conclusions'),
    ]);
  }

  static Future<void> restart() async {
    await Hive.close();
    await initialize();
  }

  static Future<void> clear() async {
    await Future.wait([
      Hive.box<HabitDto>('habits').clear(),
      Hive.box<NotificationConfigDto>('notifications').clear(),
      Hive.box<ConclusionDto>('conclusions').clear(),
    ]);
  }

  static Future<void> dispose() async {
    await Hive.close();

    final directory = _directory;
    _directory = null;

    if (directory != null && await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HabitDtoAdapter());
    }

    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(ConclusionDtoAdapter());
    }

    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(NotificationConfigDtoAdapter());
    }
  }
}