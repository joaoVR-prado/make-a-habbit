import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/controllers/habits/draft_habit_notifier.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_create_habit_title.dart';

class ChooseHabitName extends ConsumerStatefulWidget {
  const ChooseHabitName({super.key});

  @override
  ConsumerState<ChooseHabitName> createState() => _ChooseHabitName();

}

class _ChooseHabitName extends ConsumerState<ChooseHabitName>{
  late final TextEditingController _qtdController;

  @override
  void initState() {
    super.initState();
    final quantity = ref.read(draftHabitProvider).goalQuantity;
    _qtdController = TextEditingController(text: quantity);

  }

  @override
  void dispose() {
    super.dispose();
    _qtdController.dispose();

  }

  @override
  Widget build(BuildContext context) {
    final draftState = ref.watch(draftHabitProvider);
    final selectedHabitType = draftState.conclusionType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CommonCreateHabitTitle(titleText: 'Como vai ser o seu hábito?'),
        _buildTextInputCard(
          key: const ValueKey('input_name'),
          context: context,
          value: draftState.name,
          onChanged: (newName) {
            ref.read(draftHabitProvider.notifier).updateName(newName);
          },
          label: 'Ex: Treino de Musculação...',
          hint: 'Hábito', //Hábito
          keyboardType: TextInputType.text

        ),

        if(selectedHabitType == HabitConclusionType.goalQuantity) ...[
          const SizedBox(height: 16),
          _buildQuantityInputCard(
            key: const ValueKey('input_quantity'),
            context: context,
            ref: ref,
            label: 'Ex: Beber água 2x ao dia.', 
            hint: '0',
          ),
          
        ],
        _buildTextInputCard(
          key: const ValueKey('input_description'),
          context: context,
          value: draftState.description,
          onChanged: (newDescription) {
            ref.read(draftHabitProvider.notifier).updateDescription(newDescription);

          },
          label: 'Ex: Quero ler 10 páginas de um livro por dia pois...', //Descrição(opcional)
          hint: 'Descrição(opcional)',
          keyboardType: TextInputType.text

        ),
      ],
    );
  }

  Widget _buildTextInputCard({
    required BuildContext context,
    required Key key,
    required String value,
    required Function(String) onChanged,
    required String label,
    required String hint,
    required TextInputType keyboardType,
  }){
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            color: AppColors.cardBackgrounColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: TextFormField(
                initialValue: value,
                keyboardType: keyboardType,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.black.withValues(alpha: 0.5)
                  ),
                  border: InputBorder.none,
                ),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              fontSize: 10
            ),
          ),
        ),
      ],
    );

  }

  Widget _buildQuantityInputCard({
    required BuildContext context,
    required Key key,
    required WidgetRef ref,
    required String label,
    required String hint,
  }) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            color: AppColors.cardBackgrounColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), 
              child: TextFormField(
                controller: _qtdController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.black.withValues(alpha: 0.5)
                  ),
                  border: InputBorder.none,
                  prefixIcon: IconButton(
                    onPressed: () {
                      int currentValue = int.tryParse(_qtdController.text) ?? 0;
                      if (currentValue > 0) {
                        currentValue--;
                        _qtdController.text = currentValue.toString();
                        ref.read(draftHabitProvider.notifier).updateGoalQuantity(currentValue.toString());
                      }
                    }, 
                    icon: Icon(
                      Icons.remove, 
                      color: Colors.white,
                      size: 32,
                    )
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      int currentValue = int.tryParse(_qtdController.text) ?? 0;
                      currentValue++;
                      _qtdController.text = currentValue.toString();
                      ref.read(draftHabitProvider.notifier).updateGoalQuantity(currentValue.toString());
                    }, 
                    icon: Icon(
                      Icons.add,
                      size: 32,
                      color: Colors.white
                    )
                  )
                ),
                onChanged: (value) {
                  ref.read(draftHabitProvider.notifier).updateGoalQuantity(value);
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 10),
          ),
        ),
      ],
    );
  }

}