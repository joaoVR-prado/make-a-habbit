import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarCard extends ConsumerStatefulWidget {
  const CalendarCard({super.key});

  @override
  ConsumerState<CalendarCard> createState() => _CalendarCard();

}

class _CalendarCard extends ConsumerState<CalendarCard>{
  @override
  Widget build(BuildContext context){
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: (){},
        child: SizedBox(
          width: 62,
          height: 82,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'QUI', 
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  '08',
                  style: Theme.of(context).textTheme.labelLarge,
                )
              ],
            )
          ),
          
        ),
      )
    );


  }

}