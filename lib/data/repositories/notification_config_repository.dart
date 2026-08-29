import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/data/dtos/notification_config_dto.dart';
import 'package:make_a_habbit/domain/entities/notifications/notification_config_model.dart';
import 'package:make_a_habbit/domain/repositories/notification_config_repository.dart';

class HiveNotificationConfigRepository implements NotificationConfigRepository {
  HiveNotificationConfigRepository(this._box);

  final Box<NotificationConfigDto> _box;

  @override
  NotificationConfigModel? get(String habitId) => _box.get(habitId)?.toDomain();

  @override
  Future<void> save(String habitId, NotificationConfigModel notification) =>
      _box.put(habitId, NotificationConfigDto.fromDomain(notification));

  @override
  Future<void> delete(String habitId) => _box.delete(habitId);

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}
