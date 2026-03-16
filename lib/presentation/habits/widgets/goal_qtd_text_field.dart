import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/controllers/habits/concluded_habits_controller.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/providers/concluded_habits_repository_provider.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_horizontal_divider.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_vertical_divider.dart';

class GoalQtdTextField extends ConsumerStatefulWidget {
  final HabitModel habit;
  const GoalQtdTextField({
    super.key,
    required this.habit
  });
  

  @override
  ConsumerState<GoalQtdTextField> createState() => _GoalQtdTextFieldState();
}

class _GoalQtdTextFieldState extends ConsumerState<GoalQtdTextField> {
  // final TextEditingController _qtdController = TextEditingController(text: '0');
  late TextEditingController _qtdController;
  @override
  void initState(){
    super.initState();

    final selectedDate = ref.read(selectedDateProvider);
    final getAllConclusions = ref.read(concludedHabitsControllerProvider);

    final dailyHabitConclusion = getAllConclusions.where((i) => 
      i.habitId == widget.habit.id &&
      i.conclusionDate.year == selectedDate.year &&
      i.conclusionDate.month == selectedDate.month &&
      i.conclusionDate.day == selectedDate.day
    ).firstOrNull;

    final doneQuantity = dailyHabitConclusion?.conclusionValue ?? 0;
    _qtdController = TextEditingController(text: doneQuantity.toString());

  }

  @override
  void dispose() {
    _qtdController.dispose();
    super.dispose();
    
  }
  
  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final getAllConlusions = ref.watch(concludedHabitsControllerProvider);

    // Busca a conclusao do habito
    final dailyHabitConclusion = getAllConlusions.where((i) => 
      i.habitId == widget.habit.id &&
      i.conclusionDate.year == selectedDate.year &&
      i.conclusionDate.month == selectedDate.month &&
      i.conclusionDate.day == selectedDate.day
    ).firstOrNull;

    // Pega a quantidade ja feita
    final doneQuantity = dailyHabitConclusion?.conclusionValue ?? 0;

    return Column(
      children: [
        // Campo de QTD
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 28),
          child: TextFormField(
            controller: _qtdController,
            style: TextTheme.of(context).labelLarge!.copyWith(
              color: AppColors.qtdTextColor
            ),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 11),
              filled: true,
              fillColor: AppColors.dialogTextColor,
              
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)
              ),
              // Diminuir quantidade
              prefixIcon: IconButton(
                onPressed: (){
                  int currentValue = int.tryParse(_qtdController.text) ?? 0;
                  _updateQuantity(currentValue - 1);
          
                }, 
                icon: Icon(
                  Icons.remove,
                  color: AppColors.iconQtdColor,
                )
              ),
              // Aumentar Quantidade
                suffixIcon: IconButton(
                onPressed: (){
                  int currentValue = int.tryParse(_qtdController.text) ?? 0;
                  _updateQuantity(currentValue + 1);
          
                }, 
                icon: Icon(
                  Icons.add,
                  color: AppColors.iconQtdColor,
                )
              )
            ),
          
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 28),
          child: TextFormField(
            style: TextTheme.of(context).labelSmall!.copyWith(
              color: AppColors.qtdTextColor
            ),
            readOnly: true,
            maxLines: 2,
            initialValue: 'Hoje \n $doneQuantity/${widget.habit.goalQuantity}',
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 11),
              filled: true,
              fillColor: AppColors.dialogTextColor,
              enabled: false,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)
              ),
            ),
          ),
        ),
        CommonHorizontalDivider(),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
            // Cancelar
            TextButton(
              onPressed: (){
                Navigator.pop(context);
                
              },
              child: Text(
                'CANCELAR',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: AppColors.dialogTextColor,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            CommonVerticalDivider(),
            // Concluir
            TextButton(
              onPressed: (){
                // final selectedDate = ref.read(selectedDateProvider);
                final concludedQtd = int.tryParse(_qtdController.text) ?? 1;
                ref.read(concludedHabitsControllerProvider.notifier).saveOrUpdateConclusion(
                  habitId: widget.habit.id, 
                  date: selectedDate, 
                  value: concludedQtd
                );

                if (context.mounted){
                  Navigator.pop(context);

                }
              
              },
              child: Text(
                'ACEITAR',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: AppColors.positiveActionDialogTextColor,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            ],
          ),
        ),
      ],
    );
  }

  void _updateQuantity(int newValue){
    if(newValue >=0){
      _qtdController.text = newValue.toString();

      _qtdController.selection = TextSelection.fromPosition(
        TextPosition(offset: _qtdController.text.length),

      );
    }
  }
}