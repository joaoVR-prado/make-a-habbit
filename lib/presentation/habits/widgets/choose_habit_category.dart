import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/core/utils/enums/habit_icon.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_icon_container.dart';

class ChooseHabitCategory extends ConsumerStatefulWidget {
  const ChooseHabitCategory({super.key});

  @override
  ConsumerState<ChooseHabitCategory> createState() => _ChooseHabitCategory();

}

class _ChooseHabitCategory extends ConsumerState<ChooseHabitCategory>{
  final habitCategories = HabitIcon.values;
  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(draftCategoryProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 38, bottom: 24, left: 24, right: 24),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              'Selecione uma categoria para o seu hábito:',
              style: TextTheme.of(context).titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: const EdgeInsets.all(16),
            children: 
              List.generate(habitCategories.length, (index){
                final currentCategory = habitCategories[index];
                final isSelected = currentCategory == selectedCategory;
                return Card(
                  color: isSelected
                    ? AppColors.homePageIconColor 
                    : AppColors.cardBackgrounColor,
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(6)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: (){
                      ref.read(draftCategoryProvider.notifier).state = currentCategory;
          
                    }, 
                    child: Padding(
                      padding: const EdgeInsetsGeometry.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          CommonIconContainer(
                            habitIcon: currentCategory, 
                            alpha: 0.4,
                            size: 32,
                            padding: 4,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              currentCategory.iconLabel,
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontWeight: FontWeight.bold
                                ),
                              overflow: TextOverflow.ellipsis,
                            )
                          )
                        ],
                      ),
                    )
                  )
                );
              }
            )
          ),
        ),
      ],
    );
  }

}
