import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_create_habit_title.dart';

class ChooseHabitName extends ConsumerStatefulWidget {
  const ChooseHabitName({super.key});

  @override
  ConsumerState<ChooseHabitName> createState() => _ChooseHabitName();

}

class _ChooseHabitName extends ConsumerState<ChooseHabitName>{
  // final habitNameController = TextEditingController();
  // final habitDescriptionController = TextEditingController();

  // @override
  // void dispose() {
  //   super.dispose();
  //   habitNameController.dispose();
  //   habitDescriptionController.dispose();

  // }

  @override
  Widget build(BuildContext context) {
    final selectedHabitType = ref.watch(draftConclusionTypeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CommonCreateHabitTitle(titleText: 'Como vai ser o seu hábito?'),
        _buildTextInputCard(
          context: context,
          ref: ref,
          provider: draftConclusionNameProvider,
          label: 'Hábito',
          hint: 'Ex: Treino de Musculação...',
          keyboardType: TextInputType.text

        ),

        if(selectedHabitType == HabitConclusionType.goalQuantity) ...[
          const SizedBox(height: 16),
          _buildTextInputCard(
            context: context,
            ref: ref,
            provider: draftConclusionNameProvider,
            label: 'Meta diária',
            hint: 'Ex: Beber água 2x ao dia',
            keyboardType: TextInputType.number

          ),

        ],

          _buildTextInputCard(
            context: context,
            ref: ref,
            provider: draftConclusionNameProvider,
            label: 'Descrição',
            hint: 'Descrição(opcional)',
            keyboardType: TextInputType.text

          ),
        
      ],
    );
  }

  Widget _buildTextInputCard({
    required BuildContext context,
    required WidgetRef ref,
    required StateProvider<String> provider,
    required String label,
    required String hint,
    required TextInputType keyboardType,
  }){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            color: AppColors.cardBackgrounColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextFormField(
                initialValue: ref.read(provider),
                keyboardType: keyboardType,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref.read(provider.notifier).state = value;
                },
              ),
            ),
          ),
        ),
      ],
    );


  }

}