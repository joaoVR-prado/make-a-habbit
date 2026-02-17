import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:make_a_habbit/core/theme/app_theme.dart';
import 'package:make_a_habbit/data/models/concluded_habits/concluded_habits_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';
import 'package:make_a_habbit/data/models/notifications/notification_config_model.dart';
import 'package:make_a_habbit/presentation/home_page/views/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized;

  // Iniciar Hive
  await Hive.initFlutter();

  // Adapters
  Hive.registerAdapter(HabitConclusionTypeAdapter());
  Hive.registerAdapter(HabitFrequencyAdapter());
  Hive.registerAdapter(HabitFrequencyTypeAdapter());
  Hive.registerAdapter(NotificationConfigModelAdapter());
  Hive.registerAdapter(HabitModelAdapter());
  Hive.registerAdapter(ConcludedHabitsModelAdapter());

  // Iniciar as Box do Hive
  await Hive.openBox<HabitModel>('habits');
  await Hive.openBox<ConcludedHabitsModel>('conclusions');

  runApp(ProviderScope(child: const MainApp()));
  
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Make a Habbit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      //   useMaterial3: true
      // ),
      home: HomePage(),

    );
  }
}
