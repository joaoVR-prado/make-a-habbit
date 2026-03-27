import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/core/utils/enums/habit_status.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';
import 'package:make_a_habbit/data/providers/concluded_habits_repository_provider.dart';
import 'package:make_a_habbit/presentation/habits/views/create_habit_page.dart';
import 'package:make_a_habbit/presentation/habits/widgets/edit_or_complete_habit_dialog.dart';
import 'package:make_a_habbit/presentation/home_page/widgets/habit_search.dart';
import 'package:make_a_habbit/presentation/home_page/widgets/habits_list_tile.dart';
import 'package:make_a_habbit/presentation/home_page/widgets/horizontal_calendar.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';

class HomePage extends ConsumerStatefulWidget{
    const HomePage({super.key});

    @override
    ConsumerState<HomePage> createState() => _HomePageState();

}

class _HomePageState extends ConsumerState<HomePage>{
  
  @override
  Widget build(BuildContext context){
      final selectedDate = ref.watch(selectedDateProvider);
      ref.watch(habitControllerProvider);
      final habitsForSelectedDate = ref.read(habitControllerProvider.notifier).getHabitsForDate(selectedDate);

      return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.calendar_month, size: 38),
              color: AppColors.homePageIconColor,
              onPressed: () async{
                final currentDate = ref.read(selectedDateProvider);
            
                final DateTime? selectedDate = await showDatePicker(
                  context: context, 
                  initialDate: currentDate,
                  firstDate: DateTime(DateTime.now().year - 1), // Ano passado
                  lastDate: DateTime(DateTime.now().year + 1),// Vai até ano que vem
            
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.homePageIconColor,
                          onPrimary: Colors.white,
                          onSurface: Colors.black
                        )
                      ), 
                      child: child!
                    );
                  },
                );
                if(selectedDate != null && selectedDate != currentDate){
                  ref.read(selectedDateProvider.notifier).state = selectedDate;
            
                }
              },
            ),
            title: Text(
              '${_getDayName(selectedDate.weekday)} - ${_getMonthName(selectedDate.month)}. ${selectedDate.day} - ${selectedDate.year}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.search, size: 32),
                  color: AppColors.homePageIconColor,
                  onPressed: () async {
                    final allHabits = ref.read(habitControllerProvider);

                    final result = await showSearch(
                      context: context, 
                      delegate: HabitSearch(habits: allHabits),

                    );
                    if (result != null){
                      if (context.mounted){
                        showDialog(
                          context: context, 
                          builder: (BuildContext dialogContext){
                            return EditOrCompleteHabitDialog(habit: result);
                          }
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: (){
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateHabitPage()
                )
              );
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

                    // Verificacoes sobre a conclusao do habito
                    final selectedDate = ref.watch(selectedDateProvider);
                    final getAllConclusions = ref.watch(concludedHabitsControllerProvider);

                    final dailyConclusion = getAllConclusions.where((c) => 
                      c.habitId == habit.id &&
                      c.conclusionDate.year == selectedDate.year &&
                      c.conclusionDate.month == selectedDate.month &&
                      c.conclusionDate.day == selectedDate.day
                    ).firstOrNull;

                    HabitStatus habitStatus = HabitStatus.pending;

                    if (habit.conclusionType == HabitConclusionType.goalQuantity) {
                      final doneQuantity = dailyConclusion?.conclusionValue ?? 0;
                      final targetQuantity = habit.goalQuantity ?? 1;

                      if (doneQuantity >= targetQuantity) {
                        habitStatus = HabitStatus.done;
                      }
                    } else {
                      if (dailyConclusion != null) {
                        if (dailyConclusion.conclusionValue == true) {
                          habitStatus = HabitStatus.done;
                        } else if (dailyConclusion.conclusionValue == false) {
                          habitStatus = HabitStatus.incomplete;
                        }
                      }
                    }

                    return Column(
                      children: [
                        HabitsListTile(
                          habit: habit,
                          habitStatus: habitStatus,
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
          bottomNavigationBar: Padding(
            padding: EdgeInsetsGeometry.only(bottom: 10),
            child: BottomAppBar(
              height: 60,
              color: AppColors.bottomAppBarcolor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextButton(
                      onPressed: (){}, // TODO: Carregar tela de habitos
                      child: Text(
                        'HÁBITOS',
                        style: Theme.of(context).textTheme.labelMedium,
                      )
                    ),
                  ),
                  const SizedBox(width: 48),
                  Expanded(
                    flex: 2,
                    child: TextButton(
                      onPressed: (){}, // TODO: Carregar tela de relatórios
                      child: Text(
                        'RELATÓRIOS',
                        style: Theme.of(context).textTheme.labelMedium,
                      )
                    ),
                  ),
                ],
              ),
            ),
          ),
      );
  }

    void _addTestHabit(){
        final newHabit = HabitModel(
          id: '5', 
          iconCode: 4, 
          name: 'Beber 3 Litros de agua',
          description: "Todos os Dias",
          conclusionType: HabitConclusionType.goalQuantity,
          goalQuantity: 3,
          frequency: HabitFrequency(type: HabitFrequencyType.daily),
          startDate: DateTime.now()

        );

        ref.read(habitControllerProvider.notifier).addHabit(newHabit);

    }

    String _getDayName(int weekday){
      const days = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB', 'DOM'];
      return days[weekday - 1];

    }

    String _getMonthName(int month){
      const months = ['JAN', 'FEV', 'MAR', 'ABR', 'MAIO', 'JUN', 'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'];
      return months[month - 1];

    }


}