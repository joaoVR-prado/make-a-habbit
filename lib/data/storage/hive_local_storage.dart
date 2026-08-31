import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:make_a_habbit/data/dtos/conclusion_dto.dart';
import 'package:make_a_habbit/data/dtos/habit_dto.dart';
import 'package:make_a_habbit/data/dtos/notification_config_dto.dart';

typedef HiveInitializer = Future<void> Function();

final class HiveBoxNames {
  const HiveBoxNames._();

  static const habits = 'habits';
  static const notifications = 'notifications';
  static const conclusions = 'conclusions';

  static const all = [habits, notifications, conclusions];
}

final class HiveLocalStorage {
  HiveLocalStorage({HiveInterface? hive, HiveInitializer? initializeHive})
    : _hive = hive ?? Hive,
      _initializeHive = initializeHive ?? Hive.initFlutter;

  final HiveInterface _hive;
  final HiveInitializer _initializeHive;

  Future<void> initialize() async {
    await _initializeHive();
    _registerAdapters();

    final habits = await _openBox<HabitDto>(HiveBoxNames.habits);
    final notifications = await _openBox<NotificationConfigDto>(
      HiveBoxNames.notifications,
    );
    final conclusions = await _openBox<ConclusionDto>(HiveBoxNames.conclusions);

    _validatePersistedData(habits, notifications, conclusions);
  }

  Future<void> reset() async {
    await _hive.close();
    await Future.wait(
      HiveBoxNames.all.map((boxName) => _hive.deleteBoxFromDisk(boxName)),
      eagerError: false,
    );
  }

  Future<Box<T>> _openBox<T>(String name) async {
    if (_hive.isBoxOpen(name)) return _hive.box<T>(name);
    return _hive.openBox<T>(name);
  }

  void _registerAdapters() {
    _registerAdapter(HabitDtoAdapter());
    _registerAdapter(ConclusionDtoAdapter());
    _registerAdapter(NotificationConfigDtoAdapter());
  }

  void _registerAdapter<T>(TypeAdapter<T> adapter) {
    if (!_hive.isAdapterRegistered(adapter.typeId)) {
      _hive.registerAdapter(adapter);
    }
  }

  void _validatePersistedData(
    Box<HabitDto> habits,
    Box<NotificationConfigDto> notifications,
    Box<ConclusionDto> conclusions,
  ) {
    for (final dto in habits.values) {
      dto.toDomain();
    }
    for (final dto in notifications.values) {
      dto.toDomain();
    }
    for (final dto in conclusions.values) {
      dto.toDomain();
    }
  }
}
