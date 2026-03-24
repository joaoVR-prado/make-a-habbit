import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_create_habit_title.dart';

class ChooseFrequencyType extends ConsumerStatefulWidget {
  const ChooseFrequencyType({super.key});

  @override
  ConsumerState<ChooseFrequencyType> createState() => _ChooseFrequencyType();

}

class _ChooseFrequencyType extends ConsumerState<ChooseFrequencyType>{ 
  @override
  Widget build(BuildContext context) {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CommonCreateHabitTitle(titleText: 'Defina uma frequência para  \n seu hábito: '),
        // Checkbox(
        //   value: true, 
        //   onChanged: null
        // )
      ],
      
     );
  }
  

}