import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/presentation/home_page/widgets/calendar_card.dart';

class HorizontalCalendar extends ConsumerStatefulWidget {
  const HorizontalCalendar({super.key});

  @override
  ConsumerState<HorizontalCalendar> createState() => _HorizontalCalendarState();
  
}

class _HorizontalCalendarState extends ConsumerState<HorizontalCalendar>{
    // Lista do calendário
  final double _cardWidth = 62;
  final double _padding = 8;
  late final double _itemSize;

  late final DateTime _startDate;
  late final ScrollController _scrollController;

  @override
  void initState(){
    super.initState();

    _itemSize = _cardWidth + _padding;

    final now = DateTime.now();
    _startDate = DateTime(now.year - 1, 1, 1);

    // Calcula no calendario o dia de hoje (Do dia atual ate o ano anterior, no dia 1 do mes 1)
    final daysUntilToday = _daysBetween(_startDate, now); 

    // Calcula o card do dia atual com base no calculo acima e no card
    final initialDay = daysUntilToday * _itemSize;

    // Deixa o scroll focado no dia atual
    _scrollController = ScrollController(initialScrollOffset: initialDay);

  }

  int _daysBetween(DateTime from, DateTime to){
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();

  }

  @override
  void dispose(){
    _scrollController.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context){
    return SizedBox(
      height: 90,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 365 * 2, // Ana retroativo + ano atual
        itemExtent: _itemSize,
        itemBuilder: (context, index){
          final date = _startDate.add(Duration(days: index));
          final isSelected = date.day == DateTime.now().day && date.month == DateTime.now().month;

          return Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: _padding / 2),
            child: CalendarCard(
              dayName: _getDayName(date.weekday),
              dayNumber: date.day.toString(),
              isSelected: isSelected,
              onTap: (){}
            ),
          );

        }
      ),
    );
  }

  String _getDayName(int weekday){
    const days = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB', 'DOM'];
    return days[weekday - 1];

  }


}