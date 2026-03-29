import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_create_habit_title.dart';

class ChooseStartDate extends ConsumerStatefulWidget {
  const ChooseStartDate({super.key});

  @override
  ConsumerState<ChooseStartDate> createState() => _ChooseStartDate();

}

class _ChooseStartDate extends ConsumerState<ChooseStartDate>{
  @override
  Widget build(BuildContext context) {
    // Dia de inicio
    final startDate = ref.watch(draftStartDateProvider);
    final isSelectedStart = startDate != null;
    String textStartDate = 'Amanhã';

    if(startDate != null){
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));

      final isToday =
        startDate.year == today.year &&
        startDate.month == today.month &&
        startDate.day == today.day;
      
      final isTomorrow = 
        startDate.year == tomorrow.year && 
        startDate.month == tomorrow.month && 
        startDate.day == tomorrow.day;

      if(isToday){
        textStartDate = 'Hoje';
      }else if (isTomorrow) {
        textStartDate = 'Amanhã';
      }else {
        final day = startDate.day.toString().padLeft(2, '0');
        final month = startDate.month.toString().padLeft(2, '0');
        final year = startDate.year;
        textStartDate = '$day/$month/$year';

      }
    }
    
    // Dia de fim (Opcional)
    final endDate = ref.watch(draftEndDateProvider);
    final isSelectedEnd = endDate != null;
    String textEndDate = 'Opcional';

    if(isSelectedEnd){
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));

      final isToday =
        endDate.year == today.year &&
        endDate.month == today.month &&
        endDate.day == today.day;
      
      final isTomorrow = 
        endDate.year == tomorrow.year && 
        endDate.month == tomorrow.month && 
        endDate.day == tomorrow.day;

      if(isToday){
        textEndDate = 'Hoje';
      }else if (isTomorrow) {
        textEndDate = 'Amanhã';
      }else {
        final day = endDate.day.toString().padLeft(2, '0');
        final month = endDate.month.toString().padLeft(2, '0');
        final year = endDate.year;
        textEndDate = '$day/$month/$year';

      }

    }
    // Horário de lembrete
    final reminderTime = ref.watch(draftReminderTimeNotificationProvider);
    final isReminderSelected = reminderTime != null;

    final reminderText = isReminderSelected ? reminderTime.format(context) : 'Vazio';

    // Habilitar Streak
    final isStreakEnabled = ref.watch(draftEnableStreakProvider);

    return Column(
      children: [
        CommonCreateHabitTitle(titleText: 'Defina o início da sua \n atividade:'),
        // Data de Inicio
        _buildListTile(
          context: context, 
          leadingIcon: Icons.calendar_month, 
          tileTitle: 'Data de início', 
          selectedDate: textStartDate, 
          isSelected: isSelectedStart, 
          onTap: () async{
            final now = DateTime.now();
            final todayOnly = DateTime(now.year, now.month, now.day);
            final todayOrSelectedDate = ref.read(draftStartDateProvider) ?? todayOnly.add(const Duration(days: 1));
            final DateTime? selectedDate = await showDatePicker(
              context: context, 
              initialDate: todayOrSelectedDate,
              firstDate: todayOnly,
              lastDate: DateTime(DateTime.now().year + 1),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.homePageIconColor,
                      onPrimary: Colors.white,
                      onSurface: Colors.black
                    )
                  ), 
                  child: child!
                );
              },
            );
            if(selectedDate != null){
              ref.read(draftStartDateProvider.notifier).state = selectedDate;
        
            }
          }
        ),
        // Data de Fim
        _buildListTile(
          context: context, 
          leadingIcon: Icons.calendar_today, 
          tileTitle: 'Data alvo', 
          selectedDate: textEndDate, 
          isSelected: isSelectedEnd, 
          onTap: () async{
            final now = DateTime.now();
            final todayOnly = DateTime(now.year, now.month, now.day);
            final startDate = ref.read(draftStartDateProvider);
            final firstDateAllowed = startDate ?? todayOnly;
            final initialDate = ref.read(draftEndDateProvider) ?? firstDateAllowed;
              final DateTime? selectedDate = await showDatePicker(
                context: context, 
                initialDate: initialDate,
                firstDate: firstDateAllowed,
                lastDate: DateTime(DateTime.now().year + 3),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.homePageIconColor,
                        onPrimary: Colors.white,
                        onSurface: Colors.black
                      )
                    ), 
                    child: child!
                  );
                },
              );
              if(selectedDate != null){
                ref.read(draftEndDateProvider.notifier).state = selectedDate;
          
              }
          },
          onClear: () {
            ref.read(draftEndDateProvider.notifier).state = null;
          },
        ),
        // Horário de Lembrte
        _buildListTile(
          context: context, 
          leadingIcon: Icons.notification_add, 
          tileTitle: 'Horário do lembrete', 
          selectedDate: reminderText,
          isSelected: isReminderSelected,
          onClear: () {
            ref.read(draftReminderTimeNotificationProvider.notifier).state = null;

          },
          onTap: () async{
            final initialTime = reminderTime ?? TimeOfDay.now();
            final TimeOfDay? selectedTime = await showTimePicker(
              context: context, 
              initialTime: initialTime,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                    primary: AppColors.homePageIconColor,
                    onPrimary: Colors.white,
                    onSurface: Colors.black
                    )
                  ),
                  child: child!
                );
              },
            );
            if(selectedTime != null){
              ref.read(draftReminderTimeNotificationProvider.notifier).state = selectedTime;

            }

          }
        ),
        // Habilitar notificacao de streak do habito
        _buildStreakSwitch(
          context: context, 
          secondaryIcon: Icons.notification_important, 
          tileTitle: 'Acompanhar hábito', 
          isStreakEnabled: isStreakEnabled, 
        )
      ],
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData leadingIcon,
    required String tileTitle,
    required String selectedDate,
    required bool isSelected,
    required VoidCallback onTap,
    VoidCallback? onClear,

  }){
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(
        vertical: 8,
        horizontal: 8
      ),
      child: ListTile(
        leading: Icon(
          leadingIcon,
          color: AppColors.positiveActionDialogTextColor,
          size: 38,
        ),
        title: Text(
          tileTitle, 
          style: Theme.of(context).textTheme.titleLarge,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              margin: const EdgeInsets.only(left: 18),
              elevation: isSelected ? 4 : 0,
              color: isSelected ? AppColors.positiveActionDialogTextColor : AppColors.cardBackgrounColor,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: 112,
                height: 36,
                child: InkWell(
                  onTap: onTap,
                  child: Center(
                    child: Text(
                      selectedDate, //'Amanhã'
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 20
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if(isSelected && onClear != null)
              Padding(
                padding: const EdgeInsetsGeometry.only(left: 12),
                child: InkWell(
                  onTap: onClear,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.calendarMainColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white, // Um cinza clarinho para não pesar
                        width: 0.1, // Espessura da borda
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsetsGeometry.all(6),
                      child: Icon(
                        Icons.clear,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              )
            ]
        ),
      ),
    );
  }

  Widget _buildStreakSwitch({
  required BuildContext context,
  required IconData secondaryIcon,
  required String tileTitle,
  required bool isStreakEnabled,

}){
  return Padding(
    padding: EdgeInsetsGeometry.symmetric(
      vertical: 8,
      horizontal: 8
    ),
    child: SwitchListTile(
      activeThumbColor: Colors.white,
      activeTrackColor: AppColors.positiveActionDialogTextColor,
      inactiveThumbColor: Colors.black87,
      inactiveTrackColor: AppColors.cardBackgrounColor,
      secondary: Icon(
        secondaryIcon,
        color: AppColors.positiveActionDialogTextColor,
        size: 38,
      ),
      title: Text(
        tileTitle, 
        style: Theme.of(context).textTheme.titleLarge,
      ),
      value: isStreakEnabled,
      onChanged: (bool newValue) {
        ref.read(draftEnableStreakProvider.notifier).state = newValue;
      },
    ),
  );
}

}
