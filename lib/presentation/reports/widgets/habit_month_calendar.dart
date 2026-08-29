import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/core/providers/clock_provider.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/data/models/reports/habit_detail_stats_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';

class HabitMonthCalendar extends ConsumerStatefulWidget {
  const HabitMonthCalendar({
    super.key,
    required this.habit,
    required this.stats,
  });

  final HabitModel habit;
  final HabitDetailStatsModel stats;

  @override
  ConsumerState<HabitMonthCalendar> createState() => _HabitMonthCalendarState();
}

class _HabitMonthCalendarState extends ConsumerState<HabitMonthCalendar> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(ref.read(clockProvider).now());
    final start = _dateOnly(widget.habit.startDate);
    final end = widget.habit.endDate == null
        ? null
        : _dateOnly(widget.habit.endDate!);
    final initial = start.isAfter(today)
        ? start
        : end != null && end.isBefore(today)
        ? end
        : today;
    _displayedMonth = DateTime(initial.year, initial.month);
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(_displayedMonth.year, _displayedMonth.month);
    final daysInMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;
    final leadingEmptyCells = firstDay.weekday - 1;
    return Card(
      color: AppColors.cardBackgrounColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  key: const Key('previous-report-month'),
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    '${_monthName(_displayedMonth.month)} ${_displayedMonth.year}',
                    key: const Key('displayed-report-month'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  key: const Key('next-report-month'),
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                ),
              ],
            ),
            Row(
              children: [
                for (final day in [
                  'SEG',
                  'TER',
                  'QUA',
                  'QUI',
                  'SEX',
                  'SÁB',
                  'DOM',
                ])
                  Expanded(
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall,
                      // style: const TextStyle(
                      //   fontSize: 10,
                      //   fontWeight: FontWeight.bold,
                      // ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: leadingEmptyCells + daysInMonth,
              itemBuilder: (context, index) {
                if (index < leadingEmptyCells) return const SizedBox.shrink();
                final day = index - leadingEmptyCells + 1;
                final date = DateTime(
                  _displayedMonth.year,
                  _displayedMonth.month,
                  day,
                );
                final status = widget.stats.statusOn(date);
                return _DayCell(date: date, status: status);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _changeMonth(int offset) {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + offset,
      );
    });
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.date, required this.status});

  final DateTime date;
  final HabitDayStatus status;

  @override
  Widget build(BuildContext context) {
    final background = switch (status) {
      HabitDayStatus.completed => Colors.green,
      HabitDayStatus.missed => Colors.red,
      HabitDayStatus.pending => AppColors.calendarSecondaryColor,
      HabitDayStatus.inactive => Colors.transparent,
    };
    return Container(
      key: ValueKey(
        'report-day-${date.year}-${date.month}-${date.day}-${status.name}',
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        // border: status == HabitDayStatus.pending
        //   ? Border.all(color: AppColors.homePageIconColor)
        //   : null,
      ),
      child: Text(
        '${date.day}',
        style: TextStyle(
          color: status == HabitDayStatus.inactive
              ? Colors.white54
              : Colors.white,
          fontWeight: status == HabitDayStatus.inactive
              ? FontWeight.normal
              : FontWeight.bold,
        ),
      ),
    );
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

String _monthName(int month) => const [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
][month - 1];
