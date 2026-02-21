import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';
import 'package:make_a_habbit/presentation/home_page/widgets/calendar_card.dart';
import 'package:make_a_habbit/presentation/home_page/widgets/horizontal_calendar.dart';
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
      final selectedDate = ref.watch(selectedDateProvider);

      ref.watch(habitControllerProvider);
      final habitsForSelectedDate = ref.read(habitControllerProvider.notifier).getHabitsForDate(selectedDate);

      return Scaffold(
          appBar: AppBar(
              title: const Text('Meus Hábitos', style: TextStyle(color: Colors.white),),
              centerTitle: true,
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsetsGeometry.symmetric(vertical: 16),
                child: HorizontalCalendar()
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: habitsForSelectedDate.length,
                  itemBuilder: (context, index) {
                    final habit = habitsForSelectedDate[index];
                    return ListTile(
                      leading: const Icon(
                          Icons.circle_outlined
                      ),
                      title: Text(
                        habit.name,
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                      subtitle: Text(
                        habit.frequency.type.name,
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                      trailing: IconButton(
                          onPressed: (){
                              ref.read(habitControllerProvider.notifier).deleteHabit(habit.id);
      
                          }, 
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                      ),
                  );
                  },

                )
              )
              // habitsList.isEmpty
              //     ? const Center(
              //         child: Text(
              //             'Nenhum hábito criado. \n Começe agora mesmo!',
              //             textAlign: TextAlign.center,
              //             style: TextStyle(fontSize: 18, color: Colors.grey),
              //         )
              //     )
              //     : ListView.builder(
              //         itemCount: habitsList.length,
              //         itemBuilder: (context, index){
              //             final habit = habitsList[index];
              //             return ListTile(
              //                 leading: const Icon(
              //                     Icons.circle_outlined
              //                 ),
              //                 title: Text(habit.name),
              //                 subtitle: Text(habit.frequency.type.name),
              //                 trailing: IconButton(
              //                     onPressed: (){
              //                         ref.read(habitControllerProvider.notifier).deleteHabit(habit.id);
              
              //                     }, 
              //                     icon: Icon(Icons.delete),
              //                     color: Colors.red,
              //                 ),
              //             );
              //         },
              //     ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: (){
                _addTestHabit();

            },
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
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