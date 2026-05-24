import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/controllers/habits/draft_habit_notifier.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
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
    final draftState = ref.read(draftHabitProvider);

    // Verifica se é edição de hábito
    var uuid = Uuid();
    final existingId = draftState.existingId;

    // OPERAÇÔES DO HIVE //
    // Ve o tipo de frequencia para salavr os dias escolhidos
    List<int>? selectedDays;
    if (draftState.frequencyType == HabitFrequencyType.weekly) {
      selectedDays = draftState.weeklyDays;
    } else if (draftState.frequencyType == HabitFrequencyType.monthly) {
      selectedDays = draftState.monthlyDays;
    }

    final habitFrequency = HabitFrequency(
      type: draftState.frequencyType!,
      selectedDays: selectedDays,

    );

    int? goalQuantity;
    if (draftState.conclusionType == HabitConclusionType.goalQuantity) {
      goalQuantity = int.tryParse(draftState.goalQuantity);
    }

    DateTime? notificationDateTime;
    if (draftState.reminderTime != null) {
      final now = DateTime.now();
      notificationDateTime = DateTime(
        now.year, 
        now.month, 
        now.day, 
        draftState.reminderTime!.hour, 
        draftState.reminderTime!.minute
      );
    }

    final id = existingId ?? uuid.v4();
    final notificationId = id;
    
    final newHabit = HabitModel(
      id: id,
      iconCode: draftState.category!.code, //selectedCategory!.code,
      name:draftState.name.trim(),
      description: draftState.description,
      conclusionType: draftState.conclusionType!,
      goalQuantity: goalQuantity,
      frequency: habitFrequency,
      startDate: draftState.startDate!,
      endDate: draftState.endDate,
      notificationId: notificationId.hashCode.abs(),
      notificationTime: notificationDateTime,

    );

    final newNotification = NotificationConfigModel(
      isReminderEnabled: draftState.reminderTime != null,
      isStreakEnabled: draftState.isStreakEnabled,
      customTimeNotification: notificationDateTime != null ? [notificationDateTime] : [],

    );

    if (existingId == null) {
      await ref.read(habitControllerProvider.notifier).addHabit(newHabit, newNotification);

    } else {
      await ref.read(habitControllerProvider.notifier).updateHabit(newHabit, newNotification);

    }

    // Lógica das notificações //
    if(existingId != null){
      // Cancela notificacao e streak
      await AwesomeNotifications().cancelSchedulesByGroupKey(newHabit.id);

    }

    // Agenda notificacao de lembrete
    if(draftState.reminderTime != null){
      _scheduleHabitReminder(newHabit);

    }

    // Agenda notificacao de Streak
    if(draftState.isStreakEnabled){
      _scheduleStreakReminder(newHabit, currentStreak: 0);
      
    }

    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existingId == null ? 'Hábito criado com sucesso!' 
            : 'Hábito atualizado com sucesso!' ,
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

  // Agenda notificacao de lembrete
  Future<void> _scheduleHabitReminder(HabitModel habit) async {
    if (habit.notificationTime == null) return;
    final notificationTime = habit.notificationTime!;
    final String localTimeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
    final String title = 'Hora do seu hábito!';
    final String body = 'Não se esqueça de completar o hábito ${habit.name}';
    final NotificationCategory category = NotificationCategory.Reminder;

    // Verifica a frequencia
    if (habit.frequency.type == HabitFrequencyType.daily) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: habit.notificationId!, 
          channelKey: 'habit_reminders_v2',
          groupKey: habit.id,
          title: title,
          body: body,
          category: category,
          wakeUpScreen: true, 
        ),
        schedule: NotificationCalendar(
          timeZone: localTimeZone, // <--- ADICIONADO AQUI
          hour: notificationTime.hour,
          minute: notificationTime.minute,
          second: 0,
          millisecond: 0,
          repeats: true,
          preciseAlarm: true,
          allowWhileIdle: true
        ),
      );
    } else if (habit.frequency.type == HabitFrequencyType.weekly) { // Habitos semanais
      for (int weekday in habit.frequency.selectedDays!) {
        int androidWeekday = weekday == 7 ? 1 : weekday + 1;

        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: habit.notificationId! + weekday, 
            channelKey: 'habit_reminders_v2',
            groupKey: habit.id,
            title: title,
            body: body,
            category: category,
            wakeUpScreen: true, 
          ),
          schedule: NotificationCalendar(
            timeZone: localTimeZone,
            weekday: androidWeekday,
            hour: notificationTime.hour,
            minute: notificationTime.minute,
            second: 0,
            millisecond: 0,
            repeats: true,
            preciseAlarm: true,
            allowWhileIdle: true
          ),
        );
      }
    } else if (habit.frequency.type == HabitFrequencyType.monthly) { // Habitos mensais
      for (int day in habit.frequency.selectedDays!) {
        
       //DIA 32: O Calendário nativo só vai até 31
        int validDay = day;
        if (day == 32) {
          validDay = 28; 

        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: habit.notificationId! + day + 100, 
            channelKey: 'habit_reminders_v2',
            groupKey: habit.id,
            title: title,
            body: body,
            category: category,
            wakeUpScreen: true, 
          ),
          schedule: NotificationCalendar(
            timeZone: localTimeZone, 
            day: validDay,           
            hour: notificationTime.hour,
            minute: notificationTime.minute,
            second: 0,
            millisecond: 0,
            repeats: true,
            preciseAlarm: true,
            allowWhileIdle: true
          ),
        );
        }
      }
    }
  }

  // Função para agendar a notificação de Ofensiva (Sempre às 12h)
  Future<void> _scheduleStreakReminder(HabitModel habit, {required int currentStreak}) async {
    final streakNotificationId = habit.notificationId! + 10000; 
    final String localTimeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();

    String notification;
    if (currentStreak == 0) {
      notification = 'Vamos começar sua ofensiva de ${habit.name} hoje? ';
    } else {
      notification = 'Você completou ${habit.name} por $currentStreak dias, parabéns! Continue persistindo! ';
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: streakNotificationId,
        channelKey: 'habit_reminders_v2',
        title: 'Sua Ofensiva! ',
        groupKey: habit.id,
        body: notification,
        category: NotificationCategory.Status,
        wakeUpScreen: true, 
      ),
      schedule: NotificationCalendar( 
        timeZone: localTimeZone, // <--- ADICIONADO AQUI
        hour: 12,
        minute: 0,
        second: 0,
        millisecond: 0,
        repeats: true,
        preciseAlarm: true,
        allowWhileIdle: true
      ),
    );
  }

}