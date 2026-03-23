import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_create_habit_title.dart';

class ChooseConclusionType extends ConsumerStatefulWidget {
  const ChooseConclusionType({super.key});

  @override
  ConsumerState<ChooseConclusionType> createState() => _ChooseConclusionType();

}

class _ChooseConclusionType extends ConsumerState<ChooseConclusionType>{
  @override
  Widget build(BuildContext context) {
    final selectedHabitType = ref.watch(draftConclusionTypeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CommonCreateHabitTitle(titleText: 'Escolha uma opção de avaliação \n do seu progresso'),
        _buildHabitTypeCard(
          context: context, 
          ref: ref, 
          title: 'COM SIM OU NÃO', 
          subtitle: 'Se você quer registrar se obteve sucesso ou não em sua atividade.', 
          type: HabitConclusionType.yesNo, 
          isSelected: selectedHabitType == HabitConclusionType.yesNo
        ),
        _buildHabitTypeCard(
          context: context, 
          ref: ref, 
          title: 'COM UMA QUANTIDADE', 
          subtitle: 'Se você quer estipular um número como meta ou limite para a atividade.', 
          type: HabitConclusionType.goalQuantity, 
          isSelected: selectedHabitType == HabitConclusionType.goalQuantity
        )
      ],
    );
  }

  Widget _buildHabitTypeCard({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required HabitConclusionType type,
    required bool isSelected,

  }){
    return  Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(6)),
            color: isSelected 
              ? AppColors.homePageIconColor
              : AppColors.cardBackgrounColor,
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: (){
                ref.read(draftConclusionTypeProvider.notifier).state = type;
              },
              child: Padding(
                padding: const EdgeInsetsGeometry.symmetric(vertical: 12),
                child: Text(
                  title,
                  style: TextTheme.of(context).bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsetsGeometry.only(bottom: 12),
          child: Text(
            subtitle,
            style: TextTheme.of(context).labelSmall!.copyWith(
              fontSize: 10
            ),
          ),
        ),
      ],
    );  

  }
}