import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/controllers/habits/draft_habit_notifier.dart';
import 'package:make_a_habbit/core/providers/clock_provider.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/data/providers/habit_use_case_providers.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_create_habit_title.dart';

class ChooseStartDate extends ConsumerStatefulWidget {
  const ChooseStartDate({super.key});

  @override
  ConsumerState<ChooseStartDate> createState() => _ChooseStartDate();
}

class _ChooseStartDate extends ConsumerState<ChooseStartDate> {
  @override
  Widget build(BuildContext context) {
    // Dia de inicio
    final draftState = ref.watch(draftHabitProvider);
    final startDate = draftState.startDate!;
    String textStartDate = '';

    final today = ref.watch(clockProvider).now();
    final tomorrow = today.add(const Duration(days: 1));

    if (startDate.year == today.year &&
        startDate.month == today.month &&
        startDate.day == today.day) {
      textStartDate = 'Hoje';
    } else if (startDate.year == tomorrow.year &&
        startDate.month == tomorrow.month &&
        startDate.day == tomorrow.day) {
      textStartDate = 'Amanhã';
    } else {
      final day = startDate.day.toString().padLeft(2, '0');
      final month = startDate.month.toString().padLeft(2, '0');
      final year = startDate.year;
      textStartDate = '$day/$month/$year';
    }

    final endDate = draftState.endDate;
    final isSelectedEnd = endDate != null;
    String textEndDate = 'Opcional';

    if (isSelectedEnd) {
      final today = ref.watch(clockProvider).now();
      final tomorrow = today.add(const Duration(days: 1));

      final isToday =
          endDate.year == today.year &&
          endDate.month == today.month &&
          endDate.day == today.day;

      final isTomorrow =
          endDate.year == tomorrow.year &&
          endDate.month == tomorrow.month &&
          endDate.day == tomorrow.day;

      if (isToday) {
        textEndDate = 'Hoje';
      } else if (isTomorrow) {
        textEndDate = 'Amanhã';
      } else {
        final day = endDate.day.toString().padLeft(2, '0');
        final month = endDate.month.toString().padLeft(2, '0');
        final year = endDate.year;
        textEndDate = '$day/$month/$year';
      }
    }
    // Horário de lembrete
    final reminderTime = draftState.reminderTime;
    final isReminderSelected = reminderTime != null;

    final reminderText = isReminderSelected
        ? reminderTime.format(context)
        : 'Vazio';

    // Habilitar Streak
    final isStreakEnabled = draftState.isStreakEnabled;

    return Column(
      children: [
        CommonCreateHabitTitle(
          titleText: 'Defina o início da sua \n atividade:',
        ),
        // Data de Inicio
        _buildListTile(
          context: context,
          leadingIcon: Icons.calendar_month,
          tileTitle: 'Data de início',
          selectedDate: textStartDate,
          isSelected: true,
          onTap: () async {
            final now = ref.read(clockProvider).now();
            final todayOnly = DateTime(now.year, now.month, now.day);
            final todayOrSelectedDate = startDate;
            final DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: todayOrSelectedDate,
              firstDate: todayOnly,
              lastDate: DateTime(ref.read(clockProvider).now().year + 1),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.homePageIconColor,
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (selectedDate != null) {
              ref
                  .read(draftHabitProvider.notifier)
                  .updateStartDate(selectedDate);
            }
          },
        ),
        // Data de Fim
        _buildListTile(
          context: context,
          leadingIcon: Icons.calendar_today,
          tileTitle: 'Data alvo',
          selectedDate: textEndDate,
          isSelected: isSelectedEnd,
          onTap: () async {
            final draftState = ref.watch(draftHabitProvider);
            final firstDateAllowed = draftState.startDate!;
            final initialDate = draftState.endDate ?? firstDateAllowed;
            final DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: firstDateAllowed,
              lastDate: DateTime(ref.read(clockProvider).now().year + 3),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.homePageIconColor,
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (selectedDate != null) {
              ref.read(draftHabitProvider.notifier).updateEndDate(selectedDate);
            }
          },
          onClear: () {
            ref.read(draftHabitProvider.notifier).clearEndDate();
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
            ref.read(draftHabitProvider.notifier).clearReminderTime();
          },
          onTap: () async {
            final isAllowed = await ref.read(
              ensureNotificationPermissionProvider,
            )();

            if (!isAllowed) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Precisamos da sua permissão para te lembrar do hábito!',
                    ),
                  ),
                );
              }
              return; // Sai do onTap
            }

            if (!context.mounted) return;

            final now = ref.read(clockProvider).now();
            final initialTime =
                reminderTime ?? TimeOfDay(hour: now.hour, minute: now.minute);
            final TimeOfDay? selectedTime = await showTimePicker(
              context: context,
              initialTime: initialTime,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.homePageIconColor,
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (selectedTime != null) {
              //ref.read(draftReminderTimeNotificationProvider.notifier).state = selectedTime;
              ref
                  .read(draftHabitProvider.notifier)
                  .updateReminderTime(selectedTime);
            }
          },
        ),
        // Habilitar notificacao de streak do habito
        _buildStreakSwitch(
          context: context,
          secondaryIcon: Icons.notification_important,
          tileTitle: 'Acompanhar hábito',
          isStreakEnabled: isStreakEnabled,
        ),
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
  }) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 8, horizontal: 8),
      child: ListTile(
        leading: Icon(
          leadingIcon,
          color: AppColors.positiveActionDialogTextColor,
          size: 38,
        ),
        title: Text(tileTitle, style: Theme.of(context).textTheme.titleLarge),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              margin: const EdgeInsets.only(left: 18),
              elevation: isSelected ? 4 : 0,
              color: isSelected
                  ? AppColors.positiveActionDialogTextColor
                  : AppColors.cardBackgrounColor,
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
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (isSelected && onClear != null)
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
                      child: Icon(Icons.clear, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakSwitch({
    required BuildContext context,
    required IconData secondaryIcon,
    required String tileTitle,
    required bool isStreakEnabled,
  }) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 8, horizontal: 8),
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
        title: Text(tileTitle, style: Theme.of(context).textTheme.titleLarge),
        value: isStreakEnabled,
        onChanged: (bool newValue) async {
          // Valida permissao do usuario para mostrar notificacoes
          if (newValue == true) {
            final isAllowed = await ref.read(
              ensureNotificationPermissionProvider,
            )();

            if (!isAllowed) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Permita as notificações para usar a Ofensiva!',
                    ),
                  ),
                );
              }
              return; // Sai do onChanged sem salvar
            }
          }
          //ref.read(draftEnableStreakProvider.notifier).state = newValue;
          ref.read(draftHabitProvider.notifier).toggleStreak(newValue);
        },
      ),
    );
  }
}
