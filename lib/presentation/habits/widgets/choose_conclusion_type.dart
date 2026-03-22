import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_create_habit_title.dart';

class ChooseConclusionType extends ConsumerStatefulWidget {
  const ChooseConclusionType({super.key});

  @override
  ConsumerState<ChooseConclusionType> createState() => _ChooseConclusionType();

}

class _ChooseConclusionType extends ConsumerState<ChooseConclusionType>{
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CommonCreateHabitTitle(titleText: 'Escolha uma opção de avaliação \n do seu progresso'),

      ],
    );
  }
}