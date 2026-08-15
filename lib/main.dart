import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:make_a_habbit/controllers/notifications/notifications_controller.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/core/theme/app_theme.dart';
import 'package:make_a_habbit/data/dtos/conclusion_dto.dart';
import 'package:make_a_habbit/data/dtos/habit_dto.dart';
import 'package:make_a_habbit/data/dtos/notification_config_dto.dart';
import 'package:make_a_habbit/presentation/home_page/views/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Iniciar Hive
  await Hive.initFlutter();

  // Adapters
  Hive.registerAdapter(HabitDtoAdapter());
  Hive.registerAdapter(ConclusionDtoAdapter());
  Hive.registerAdapter(NotificationConfigDtoAdapter());

  // Iniciar as Box do Hive
  await Hive.openBox<HabitDto>('habits');
  await Hive.openBox<NotificationConfigDto>('notifications');
  await Hive.openBox<ConclusionDto>('conclusions');

  // Inicia a biblioteca Awesome_notifications
  await AwesomeNotifications().initialize(
    // TODO: Colocar icone do coelho na pasta android/app/src/main/res/drawable
    'resource://mipmap/ic_launcher',
    [
      NotificationChannel(
        channelGroupKey: 'habit_channel_group',
        channelKey: 'habit_reminders_v2', 
        channelName: 'Notificacoes de Habitos', 
        channelDescription: 'Canal de notificacoes para lembrete de habitos',
        defaultColor: AppColors.darkBlue,
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        defaultPrivacy: NotificationPrivacy.Public,
        locked: true,
        channelShowBadge: true

      )
    ]

  );

  // Configura app para escutar notificacoes fora do app
  await AwesomeNotifications().setListeners(
    onActionReceivedMethod: NotificationsController.onActionReceivedMethod,
  );

  runApp(ProviderScope(child: const MainApp()));
  
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Calendario
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate, 
        GlobalCupertinoLocalizations.delegate,

      ],
      
      supportedLocales: const [
        Locale('pt', 'BR')
        
      ],

      title: 'Make a Habbit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: HomePage(),

    );
  }
}
