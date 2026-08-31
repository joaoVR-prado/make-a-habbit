import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:make_a_habbit/controllers/notifications/notifications_controller.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/data/services/awesome_notification_scheduler.dart';
import 'package:make_a_habbit/data/storage/hive_local_storage.dart';

typedef BootstrapStep = Future<void> Function();
typedef BootstrapErrorReporter = void Function(Object error, StackTrace stack);

final class AppBootstrap {
  AppBootstrap({
    BootstrapStep? initializeStorage,
    BootstrapStep? initializeNotifications,
    BootstrapStep? resetLocalStorage,
    BootstrapStep? cancelNotifications,
    BootstrapErrorReporter? reportNonFatalError,
  }) : _initializeStorage = initializeStorage ?? _storage.initialize,
       _initializeNotifications =
           initializeNotifications ?? _initializeAwesomeNotifications,
       _resetLocalStorage = resetLocalStorage ?? _storage.reset,
       _cancelNotifications = cancelNotifications ?? _cancelAllNotifications,
       _reportNonFatalError = reportNonFatalError ?? _reportFlutterError;

  static final _storage = HiveLocalStorage();

  final BootstrapStep _initializeStorage;
  final BootstrapStep _initializeNotifications;
  final BootstrapStep _resetLocalStorage;
  final BootstrapStep _cancelNotifications;
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

  Future<void> resetLocalData() async {
    try {
      await _resetLocalStorage();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        AppBootstrapException(stage: AppBootstrapStage.reset, cause: error),
        stackTrace,
      );
    }

    try {
      await _cancelNotifications();
    } catch (error, stackTrace) {
      _reportNonFatalError(error, stackTrace);
    }
  }

  static Future<void> _cancelAllNotifications() =>
      AwesomeNotifications().cancelAll();

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

enum AppBootstrapStage { storage, reset }

final class AppBootstrapException implements Exception {
  const AppBootstrapException({required this.stage, required this.cause});

  final AppBootstrapStage stage;
  final Object cause;

  @override
  String toString() => switch (stage) {
    AppBootstrapStage.storage =>
      'Falha ao inicializar o armazenamento local: $cause',
    AppBootstrapStage.reset => 'Falha ao apagar o armazenamento local: $cause',
  };
}
