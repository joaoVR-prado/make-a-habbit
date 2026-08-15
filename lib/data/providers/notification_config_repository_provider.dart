import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/data/dtos/notification_config_dto.dart';
import 'package:make_a_habbit/data/repositories/notification_config_repository.dart';
import 'package:make_a_habbit/domain/repositories/notification_config_repository.dart';

final notificationConfigRepositoryProvider =
  Provider<NotificationConfigRepository>((ref) {
    return HiveNotificationConfigRepository(
      Hive.box<NotificationConfigDto>('notifications'),
    );
  });
