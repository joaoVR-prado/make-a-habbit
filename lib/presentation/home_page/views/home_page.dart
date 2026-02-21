import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/core/utils/enums/habit_status.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';
import 'package:make_a_habbit/presentation/home_page/widgets/calendar_card.dart';
import 'package:make_a_habbit/presentation/home_page/widgets/habits_list_tile.dart';
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          appBar: AppBar(
              title: const Text('Meus Hábitos', style: TextStyle(color: Colors.white),),
              centerTitle: true,
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
          body: Column(
            children: [
              // Calendario
              Padding(
                padding: EdgeInsetsGeometry.symmetric(vertical: 16),
                child: HorizontalCalendar()
              ),
              // Habitos
              Expanded(
                child: ListView.builder(
                  itemCount: habitsForSelectedDate.length,
                  itemBuilder: (context, index) {
                    final habit = habitsForSelectedDate[index];
                    return Column(
                      children: [
                        HabitsListTile(
                          habit: habit, 
                          habitStatus: HabitStatus.incomplete, 
                          onStatusTap: (){
                            print('Teste se ta fununciando: ${habit.name}');
                          }
                        ),
                        if(index != habitsForSelectedDate.length - 1)
                          Padding(
                            padding: EdgeInsetsGeometry.only(left: 10, right: 10),
                            child: const Divider(
                              thickness: 0.3,
                              height: 2,
                            ),
                        )
                      ],
                    );
                  },

                )
              )
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            height: 50,
            color: AppColors.bottomAppBarcolor,
            // shape: const CircularNotchedRectangle(),
            // notchMargin: 8.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 2,
                  child: TextButton(
                    onPressed: (){}, 
                    child: Text(
                      'HÁBITOS',
                      style: Theme.of(context).textTheme.labelMedium,
                    )
                  ),
                ),
                const SizedBox(width: 48),
                // Expanded(
                //   flex: 1,
                //   child: OutlinedButton(
                //     onPressed: (){}, 
                //     child: Icon(
                //       Icons.add,
                //       color: Colors.white,
                //       size: 42,
                //     ),
                //   ),
                // ),
                Expanded(
                  flex: 2,
                  child: TextButton(
                    onPressed: (){}, 
                    child: Text(
                      'RELATÓRIOS',
                      style: Theme.of(context).textTheme.labelMedium,
                    )
                  ),
                ),
              ],
            ),
          ),
      );

  }

    void _addTestHabit(){
        final newHabit = HabitModel(
            id: '1', 
            iconCode: 0, 
            name: 'Não fumar',
            description: "Parar de fumar todos os dias",
            conclusionType: HabitConclusionType.yesNo,
            frequency: HabitFrequency(type: HabitFrequencyType.daily), 
            startDate: DateTime.now()
        );

        ref.read(habitControllerProvider.notifier).addHabit(newHabit);

    }


}