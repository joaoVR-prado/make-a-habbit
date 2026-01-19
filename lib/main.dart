import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:make_a_habbit/data/models/concluded_habits/concluded_habits_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';
import 'package:make_a_habbit/data/models/notifications/notification_config_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized;

  // Iniciar Hive
  await Hive.initFlutter();

  // Adapters
  Hive.registerAdapter(HabitConclusionTypeAdapter());
  Hive.registerAdapter(HabitConclusionTypeAdapter());
  Hive.registerAdapter(HabitFrequencyAdapter());
  Hive.registerAdapter(NotificationConfigModelAdapter());
  Hive.registerAdapter(HabitModelAdapter());
  Hive.registerAdapter(ConcludedHabitsModelAdapter());

  // Iniciar as Box do Hive
  await Hive.openBox<HabitModel>('habits');
  await Hive.openBox<ConcludedHabitsModel>('conclusions');


  runApp(const MainApp());
  
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
