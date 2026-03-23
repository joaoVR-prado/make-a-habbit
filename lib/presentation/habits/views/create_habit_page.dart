import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/presentation/habits/widgets/choose_conclusion_type.dart';
import 'package:make_a_habbit/presentation/habits/widgets/choose_habit_category.dart';
import 'package:make_a_habbit/presentation/habits/widgets/choose_habit_name.dart';

class CreateHabitPage extends ConsumerStatefulWidget {
  const CreateHabitPage({super.key});

  @override
  ConsumerState<CreateHabitPage> createState() => _CreateHabitPageStage();

}

class _CreateHabitPageStage extends ConsumerState<CreateHabitPage>{
  late final PageController _pageController;
  int _currentPage = 0;
  final int _totalPages = 5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();

  }

  void _nextPage() {
    if(_currentPage < _totalPages - 1){
      _pageController.nextPage(
        duration: const Duration(
          milliseconds: 300
        ), 
        curve: Curves.easeInOut
      );
    } else{
      Navigator.pop(context);
    }
  }

  void _previousPage(){
    if(_currentPage > 0){
      _pageController.previousPage(
        duration: const Duration(
          milliseconds: 300,
        ), 
        curve: Curves.easeInOut
      );
    } else{
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index){
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  //_buildDummyPage('Tela 1: Escolha a Categoria'),
                  ChooseHabitCategory(),
                  ChooseConclusionType(),
                  ChooseHabitName(),
                  //_buildDummyPage('Tela 2: Tipo de hábito'),
                  //_buildDummyPage('Tela 3: Detalhes e Cores'),
                  _buildDummyPage('Tela 4: Frequência'),
                  _buildDummyPage('Tela 5: Lembretes e Resumo'),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        )
      ),
    );
  }
  
  Widget _buildBottomBar(){
    final selectedCategory = ref.watch(draftCategoryProvider);
    final selectedType = ref.watch(draftConclusionTypeProvider);
    bool canGoNext = true;

    // Regra da tela 1 do cadastro
    if(_currentPage == 0 && selectedCategory == null){
      canGoNext = false;

    } else if(_currentPage == 1 && selectedType == null){  // Regra da tela 2 do cadastro
      canGoNext = false;

    }

    // TODO: Novas Regras
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.bottomAppBarcolor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _previousPage, 
            child: Text(
              _currentPage == 0 ? 'CANCELAR' : 'ANTERIOR',
              style: Theme.of(context).textTheme.labelMedium,
            )
          ),
          Row(
            children: List.generate(
              _totalPages,
              (index) {
                final isCompletedOrActive = index <= _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompletedOrActive 
                      ? AppColors.positiveActionDialogTextColor
                      : AppColors.darkBlue,
                    border: Border.all(
                      color: AppColors.positiveActionDialogTextColor
                    )
                  ),
                );
              },
            ),
          ),
          Visibility(
            visible: canGoNext,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: TextButton(
              onPressed: _nextPage,
              child: Text(
                _currentPage == _totalPages -1 ? 'FINALIZAR' : 'PRÓXIMA',
                style: Theme.of(context).textTheme.labelMedium,
              )
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDummyPage(String title){
    return Center(
      child: Text(
        title,
      ),
    );
  }

}