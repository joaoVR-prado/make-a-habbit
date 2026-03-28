import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_create_habit_title.dart';

class ChooseFrequencyType extends ConsumerStatefulWidget {
  const ChooseFrequencyType({super.key});

  @override
  ConsumerState<ChooseFrequencyType> createState() => _ChooseFrequencyType();

}

class _ChooseFrequencyType extends ConsumerState<ChooseFrequencyType>{ 
  @override
  Widget build(BuildContext context) {
    final selectedFrequency = ref.watch(draftFrequencyTypeProvider);
    return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      CommonCreateHabitTitle(titleText: 'Defina uma frequência para  \n seu hábito: '),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: HabitFrequencyType.values.map((type) {
            final isSelected = selectedFrequency == type;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      ref.read(draftFrequencyTypeProvider.notifier).state = type;
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? AppColors.positiveActionDialogTextColor : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? AppColors.positiveActionDialogTextColor : Colors.white,
                                width: 2.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  type.title, 
                                  style: Theme.of(context).textTheme.bodyLarge
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  if(isSelected && type == HabitFrequencyType.weekly) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: _buildWeeklySelector(context, ref),
                    )
                  ],
                  if(isSelected && type == HabitFrequencyType.monthly) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: _buildMonthlySelector(context, ref),
                    )
                  ]
                ],
              ),
            );
          }).toList(),
        ),
      )
    ],
    );
  }

  //here

  Widget _buildFrequencyTypeDaysCard({
    required BuildContext context,
    required String text,
    required bool isSelected,
    required VoidCallback onTap
  }){
    return Card(
      margin: const EdgeInsets.all(4),
      elevation: isSelected ? 4 : 0,
      color: isSelected ? AppColors.calendarMainColor : AppColors.cardBackgrounColor,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          children: [
            if(isSelected) ...[
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 32,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.calendarSecondaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)
                    )
                  ),
                ),
              )
            ],
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Center(
                      child: Text(
                        text,
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: isSelected ? Colors.white : Colors.black 
                        ),
                      ),
                    ),
                  ),
                ),
              )
            )
          ],
        
        ),
      ),

    );

  }

  Widget _buildWeeklySelector(
    BuildContext context,
    WidgetRef ref
  ){
    final selectedDays = ref.watch(draftWeeklyDaysProvider);

    final weekDays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(weekDays.length, (index){
        final dayIndex = index + 1;
        final isSelected = selectedDays.contains(dayIndex);

        return _buildFrequencyTypeDaysCard(
          context: context, 
          text: weekDays[index], 
          isSelected: isSelected, 
          onTap: (){
            final notifier = ref.read(draftWeeklyDaysProvider.notifier);
            if(isSelected){
              notifier.state = selectedDays.where((d) => d != dayIndex).toList();

            } else{
              notifier.state = [...selectedDays, dayIndex];

            }

          }

          
        );

      }),
    );
  }

  Widget _buildMonthlySelector(BuildContext context, WidgetRef ref) {
    final selectedDays = ref.watch(draftMonthlyDaysProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(32, (index) {
        
        final dayValue = index + 1; 
        
        // Se for o 32, o texto será "Últ", senão será o próprio número
        final text = dayValue == 32 ? 'Últ' : dayValue.toString();
        
        final isSelected = selectedDays.contains(dayValue);

        return _buildFrequencyTypeDaysCard(
          context: context,
          text: text,
          isSelected: isSelected,
          onTap: () {
            final notifier = ref.read(draftMonthlyDaysProvider.notifier);
            
            if (isSelected) {
              notifier.state = selectedDays.where((d) => d != dayValue).toList();
            } else {
              notifier.state = [...selectedDays, dayValue];
            }
          },
        );
      }),
    );
  }

}
