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
                child: InkWell(
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
              );
            }).toList(),
          ),
        )
      // Expanded(
      //   child: RadioGroup<HabitFrequencyType>(
      //     groupValue: selectedFrequency,
      //     onChanged: (HabitFrequencyType? newValue){
      //       if(newValue != null){
      //         ref.read(draftFrequencyTypeProvider.notifier).state = newValue;

      //       }
      //     },
      //     child: ListView(
      //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      //       children: HabitFrequencyType.values.map((type) {
      //         return Padding(
      //           padding: const EdgeInsetsGeometry.only(bottom: 12),
      //           child: RadioListTile<HabitFrequencyType>(
      //             title: Text(
      //               type.title,
      //               style: Theme.of(context).textTheme.bodyLarge,
      //             ),
      //             value: type,
      //             activeColor: AppColors.positiveActionDialogTextColor,
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(12),
                    
      //             ),
                  
      //           ),
      //         );
      //       }).toList(),
      //     ),
      //   )
      // )
    ],
    );
  }

}
