import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:make_a_habbit/controllers/notifications/notifications_controller.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/data/dtos/conclusion_dto.dart';
import 'package:make_a_habbit/data/dtos/habit_dto.dart';
import 'package:make_a_habbit/data/dtos/notification_config_dto.dart';
import 'package:make_a_habbit/data/services/awesome_notification_scheduler.dart';

typedef BootstrapStep = Future<void> Function();
typedef BootstrapErrorReporter = void Function(Object error, StackTrace stack);

final class AppBootstrap {
  AppBootstrap({
    BootstrapStep? initializeStorage,
    BootstrapStep? initializeNotifications,
    BootstrapErrorReporter? reportNonFatalError,
  }) : _initializeStorage = initializeStorage ?? _initializeHive,
       _initializeNotifications =
           initializeNotifications ?? _initializeAwesomeNotifications,
       _reportNonFatalError = reportNonFatalError ?? _reportFlutterError;

  final BootstrapStep _initializeStorage;
  final BootstrapStep _initializeNotifications;
  final BootstrapErrorReporter _reportNonFatalError;

  Future<void> initialize() async {
    try {
      await _initializeStorage();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        AppBootstrapException(stage: AppBootstrapStage.storage, cause: error),
        stackTrace,
      );
    }

    try {
      await _initializeNotifications();
    } catch (error, stackTrace) {
      _reportNonFatalError(error, stackTrace);
    }
  }

  static Future<void> _initializeHive() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(HabitDtoAdapter().typeId)) {
      Hive.registerAdapter(HabitDtoAdapter());
    }
    if (!Hive.isAdapterRegistered(ConclusionDtoAdapter().typeId)) {
      Hive.registerAdapter(ConclusionDtoAdapter());
    }
    if (!Hive.isAdapterRegistered(NotificationConfigDtoAdapter().typeId)) {
      Hive.registerAdapter(NotificationConfigDtoAdapter());
    }

    if (!Hive.isBoxOpen('habits')) {
      await Hive.openBox<HabitDto>('habits');
    }
    if (!Hive.isBoxOpen('notifications')) {
      await Hive.openBox<NotificationConfigDto>('notifications');
    }
    if (!Hive.isBoxOpen('conclusions')) {
      await Hive.openBox<ConclusionDto>('conclusions');
    }
  }

  static Future<void> _initializeAwesomeNotifications() async {
    final notifications = AwesomeNotifications();
    final initialized = await notifications.initialize(
      'resource://mipmap/ic_launcher',
      [
        NotificationChannel(
          channelGroupKey: 'habit_channel_group',
          channelKey: AwesomeNotificationScheduler.channelKey,
          channelName: 'Notificações de Hábitos',
          channelDescription: 'Canal de notificações para lembretes de hábitos',
          defaultColor: AppColors.darkBlue,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          defaultPrivacy: NotificationPrivacy.Private,
          locked: false,
          channelShowBadge: true,
        ),
      ],
    );
    if (!initialized) {
      throw StateError('O serviço de notificações não pôde ser inicializado.');
    }

    final listenersConfigured = await notifications.setListeners(
      onActionReceivedMethod: NotificationsController.onActionReceivedMethod,
    );
    if (!listenersConfigured) {
      throw StateError(
        'Os listeners de notificações não puderam ser configurados.',
      );
    }
  }

  static void _reportFlutterError(Object error, StackTrace stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'make_a_habbit',
        context: ErrorDescription('inicializando notificações locais'),
      ),
    );
  }
}

enum AppBootstrapStage { storage }

final class AppBootstrapException implements Exception {
  const AppBootstrapException({required this.stage, required this.cause});

  final AppBootstrapStage stage;
  final Object cause;

  @override
  String toString() => 'Falha ao inicializar o armazenamento local: $cause';
}
