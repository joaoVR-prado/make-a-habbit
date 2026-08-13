import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/controllers/habits/draft_habit_notifier.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/core/providers/clock_provider.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';
import 'package:make_a_habbit/data/models/notifications/notification_config_model.dart';
import 'package:make_a_habbit/domain/services/notification_schedule_planner.dart';
import 'package:make_a_habbit/domain/use_cases/habit_operation_result.dart';
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

  Future<void> _saveDraft() async{
    final draftState = ref.read(draftHabitProvider);
    final category = draftState.category;
    final conclusionType = draftState.conclusionType;
    final frequencyType = draftState.frequencyType;
    final startDate = draftState.startDate;
    if (category == null ||
        conclusionType == null ||
        frequencyType == null ||
        startDate == null) {
      _showValidationError('Preencha todos os campos obrigatórios.');
      return;
    }

    // Verifica se é edição de hábito
    var uuid = Uuid();
    final existingId = draftState.existingId;

    // OPERAÇÔES DO HIVE //
    // Ve o tipo de frequencia para salavr os dias escolhidos
    List<int>? selectedDays;
    if (frequencyType == HabitFrequencyType.weekly) {
      selectedDays = draftState.weeklyDays;
    } else if (frequencyType == HabitFrequencyType.monthly) {
      selectedDays = draftState.monthlyDays;
    }

    late final HabitFrequency habitFrequency;
    try {
      habitFrequency = HabitFrequency.fromType(
        type: frequencyType,
        selectedDays: selectedDays,
      );
    } on ArgumentError catch (error) {
      _showValidationError(error.message?.toString() ?? 'Frequência inválida.');
      return;
    }

    int? goalQuantity;
    if (conclusionType == HabitConclusionType.goalQuantity) {
      goalQuantity = int.tryParse(draftState.goalQuantity);
    }

    DateTime? notificationDateTime;
    if (draftState.reminderTime != null) {
      final reminderTime = draftState.reminderTime!;
      final now = ref.read(clockProvider).now();
      notificationDateTime = DateTime(
        now.year, 
        now.month, 
        now.day, 
        reminderTime.hour,
        reminderTime.minute,
      );
    }

    final id = existingId ?? uuid.v4();
    final notificationId = const NotificationSchedulePlanner().baseIdForHabit(id);
    
    late final HabitModel newHabit;
    try {
      newHabit = HabitModel(
        id: id,
        iconCode: category.code,
        name: draftState.name,
        description: draftState.description,
        conclusionType: conclusionType,
        goalQuantity: goalQuantity,
        frequency: habitFrequency,
        startDate: startDate,
        endDate: draftState.endDate,
        notificationId: notificationId,
        notificationTime: notificationDateTime,
      );
    } on ArgumentError catch (error) {
      _showValidationError(error.message?.toString() ?? 'Hábito inválido.');
      return;
    }

    final newNotification = NotificationConfigModel(
      isReminderEnabled: draftState.reminderTime != null,
      isStreakEnabled: draftState.isStreakEnabled,
      customTimeNotification: notificationDateTime != null ? [notificationDateTime] : [],

    );

    final result = existingId == null
        ? await ref
            .read(habitControllerProvider.notifier)
            .addHabit(newHabit, newNotification)
        : await ref
            .read(habitControllerProvider.notifier)
            .updateHabit(newHabit, newNotification);

    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.hasPartialFailures
                ? _partialFailureMessage(result)
                : existingId == null
                    ? 'Hábito criado com sucesso!'
                    : 'Hábito atualizado com sucesso!',
            style: Theme.of(context).textTheme.labelMedium,
            
          ),
          backgroundColor: AppColors.calendarMainColor,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pop(context);

    }

  }

  String _partialFailureMessage(HabitOperationResult result) {
    final failures = result.failures;
    if (failures.contains(HabitOperationFailure.notificationConfig)) {
      return 'Hábito salvo, mas as preferências de notificação não foram salvas.';
    }
    return 'Hábito salvo, mas não foi possível agendar o lembrete.';
  }

  void _showValidationError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
    final draftState = ref.watch(draftHabitProvider);
    bool canGoNext = true;

    // Regra da tela 1 do cadastro
    if(_currentPage == 0 && draftState.category == null){
      canGoNext = false;

    } else if(_currentPage == 1 && draftState.conclusionType == null){  // Regra da tela 2 do cadastro
      canGoNext = false;

    } else if(_currentPage == 2){  // Regra de tela 3 do cadastro
      if (draftState.name.trim().isEmpty || draftState.name.trim().length < 3) {
        canGoNext = false;
      } else if (draftState.conclusionType == HabitConclusionType.goalQuantity) {
        if (draftState.goalQuantity.trim().isEmpty || draftState.goalQuantity == '0') {
          canGoNext = false;
        }
      }
      
    } else if(_currentPage == 3 ){ // Regra da tela 4
      if(draftState.frequencyType == null){
        canGoNext = false;
      } else if(draftState.frequencyType == HabitFrequencyType.weekly && draftState.weeklyDays.isEmpty){
        canGoNext = false;
      } else if(draftState.frequencyType == HabitFrequencyType.monthly && draftState.monthlyDays.isEmpty){
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
