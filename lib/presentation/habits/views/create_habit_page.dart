import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/core/utils/enums/habit_icon.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';
import 'package:make_a_habbit/data/models/notifications/notification_config_model.dart';
import 'package:make_a_habbit/presentation/habits/widgets/choose_conclusion_type.dart';
import 'package:make_a_habbit/presentation/habits/widgets/choose_frequency_type.dart';
import 'package:make_a_habbit/presentation/habits/widgets/choose_habit_category.dart';
import 'package:make_a_habbit/presentation/habits/widgets/choose_habit_name.dart';
import 'package:make_a_habbit/presentation/habits/widgets/choose_start_date.dart';
import 'package:uuid/uuid.dart';

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
      _saveDraft();

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

  void _saveDraft() async{
    final name = ref.read(draftConclusionNameProvider);
    final selectedCategory = ref.read(draftCategoryProvider);
    final conclusionType = ref.read(draftConclusionTypeProvider)!;
    final goalQuantityStr = ref.read(draftConclusionGoalQuantityProvider);
    final habitDescription = ref.read(draftConclusionDescriptionQuantityProvider);
    
    final frequencyType = ref.read(draftFrequencyTypeProvider)!;
    final weeklyDays = ref.read(draftWeeklyDaysProvider);
    final monthlyDays = ref.read(draftMonthlyDaysProvider);
    
    final startDate = ref.read(draftStartDateProvider)!;
    final endDate = ref.read(draftEndDateProvider);
    
    final reminderTime = ref.read(draftReminderTimeNotificationProvider);
    final isStreakEnabled = ref.read(draftEnableStreakProvider);
    
    // OPERAÇÔES DO HIVE

    // Ve o tipo de frequencia para salavr os dias escolhidos
    List<int>? selectedDays;
    if (frequencyType == HabitFrequencyType.weekly) {
      selectedDays = weeklyDays;
    } else if (frequencyType == HabitFrequencyType.monthly) {
      selectedDays = monthlyDays;
    }

    final habitFrequency = HabitFrequency(
      type: frequencyType,
      selectedDays: selectedDays,

    );

    int? goalQuantity;
    if (conclusionType == HabitConclusionType.goalQuantity) {
      goalQuantity = int.tryParse(goalQuantityStr);
    }

    DateTime? notificationDateTime;
    if (reminderTime != null) {
      final now = DateTime.now();
      notificationDateTime = DateTime(
        now.year, 
        now.month, 
        now.day, 
        reminderTime.hour, 
        reminderTime.minute
      );
    }

    var uuid = Uuid();
    final id = uuid.v4();
    final notificationId = id;
    
    final newHabit = HabitModel(
      id: id,
      iconCode: selectedCategory!.code,
      name: name.trim(),
      description: habitDescription,
      conclusionType: conclusionType,
      goalQuantity: goalQuantity,
      frequency: habitFrequency,
      startDate: startDate,
      endDate: endDate,
      notificationId: notificationId.hashCode,
      notificationTime: notificationDateTime,

    );

    // Chama a box de habitos
    final habitBox = Hive.box<HabitModel>('habits');
    await habitBox.put(newHabit.id, newHabit);

    // Chama a box de notificacoes
    final notificationsBox = Hive.box<NotificationConfigModel>('notifications');
    final newNotification = NotificationConfigModel(
      isReminderEnabled: reminderTime != null,
      isStreakEnabled: isStreakEnabled,
      customTimeNotification: notificationDateTime != null ? [notificationDateTime] : [],
    );

    await notificationsBox.put(newHabit.id, newNotification);

    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Hábito criado com sucesso!',
            style: Theme.of(context).textTheme.labelMedium,
            
          ),
          backgroundColor: AppColors.calendarMainColor,
          duration: Duration(seconds: 3),
        ),
      );
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
                  ChooseFrequencyType(),
                  ChooseStartDate(),
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
    final selectedName = ref.watch(draftConclusionNameProvider);
    final selectedQuantity = ref.watch(draftConclusionGoalQuantityProvider);
    final selectedFrequencyType = ref.watch(draftFrequencyTypeProvider);
    final selectedWeeklyDays = ref.watch(draftWeeklyDaysProvider);
    final selectedMonthlyDays = ref.watch(draftMonthlyDaysProvider);
    final selectedStartDate = ref.watch(draftStartDateProvider);

    // Dados opcionais qque não podem morrer na transicao de telas
    ref.watch(draftConclusionDescriptionQuantityProvider);

    bool canGoNext = true;

    // Regra da tela 1 do cadastro
    if(_currentPage == 0 && selectedCategory == null){
      canGoNext = false;

    } else if(_currentPage == 1 && selectedType == null){  // Regra da tela 2 do cadastro
      canGoNext = false;

    } else if(_currentPage == 2){  // Regra de tela 3 do cadastro

      if (selectedName.trim().isEmpty || selectedName.trim().length < 3) {
        canGoNext = false;
      } else if (selectedType == HabitConclusionType.goalQuantity) {
        if (selectedQuantity.trim().isEmpty || selectedQuantity == '0') {
          canGoNext = false;

        }
      }
      
    } else if(_currentPage == 3 ){
      if(selectedFrequencyType == null){
        canGoNext = false;
      } else if(selectedFrequencyType == HabitFrequencyType.weekly && selectedWeeklyDays.isEmpty){
        canGoNext = false;

      } else if(selectedFrequencyType == HabitFrequencyType.monthly && selectedMonthlyDays.isEmpty){
        canGoNext = false;

      }

    } else if(_currentPage == 4){
      if(selectedStartDate == null){
        canGoNext = false;

      }

    }
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

}