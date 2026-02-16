import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';
import 'package:riverpod/riverpod.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';

class HomePage extends ConsumerStatefulWidget{
    const HomePage({super.key});

    @override
    ConsumerState<HomePage> createState() => _HomePageState();

}

class _HomePageState extends ConsumerState<HomePage>{
    @override
    Widget build(BuildContext context){
        final habitsList = ref.watch(habitControllerProvider);

        return Scaffold(
            appBar: AppBar(
                title: const Text('Meus Hábitos'),
                centerTitle: true,
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            body: habitsList.isEmpty
                ? const Center(
                    child: Text(
                        'Nenhum hábito criado. \n Começe agora mesmo!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                    )
                )
                : ListView.builder(
                    itemCount: habitsList.length,
                    itemBuilder: (context, index){
                        final habit = habitsList[index];
                        return ListTile(
                            leading: const Icon(
                                Icons.circle_outlined
                            ),
                            title: Text(habit.name),
                            subtitle: Text(habit.frequency.type.name),
                            trailing: IconButton(
                                onPressed: (){
                                    ref.read(habitControllerProvider.notifier).deleteHabit(habit.id);

                                }, 
                                icon: Icon(Icons.delete),
                                color: Colors.red,
                            ),
                        );
                    },
                ),
                floatingActionButton: FloatingActionButton(
                    onPressed: (){
                        _addTestHabit();

                    }
                ),
        );

    }

    void _addTestHabit(){
        final newHabit = HabitModel(
            id: '1', 
            iconCode: 1, 
            name: '2 cigarros por dia', 
            conclusionType: HabitConclusionType.goalQuantity,
            goalQuantity: 2, 
            frequency: HabitFrequency(type: HabitFrequencyType.daily), 
            startDate: DateTime.now()
        );

        ref.read(habitControllerProvider.notifier).addHabit(newHabit);

    }


}