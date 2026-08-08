import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/data/models/notifications/notification_config_model.dart';
import 'package:make_a_habbit/data/repositories/notification_config_repository.dart';
import 'package:make_a_habbit/domain/repositories/notification_config_repository.dart';

final notificationConfigRepositoryProvider =
  Provider<NotificationConfigRepository>((ref) {
    return HiveNotificationConfigRepository(
      Hive.box<NotificationConfigModel>('notifications'),
    );
  });
