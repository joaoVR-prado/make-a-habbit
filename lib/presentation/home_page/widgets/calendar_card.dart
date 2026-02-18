import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarCard extends StatelessWidget {
  final String dayName;
  final String dayNumber;
  final bool isSelected;
  final VoidCallback onTap;

  const CalendarCard({
    super.key,
    required this.dayName,
    required this.dayNumber,
    required this.isSelected,
    required this.onTap

  });

   @override
  Widget build(BuildContext context){
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.all(4),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 62,
          height: 82,
          child: Padding(
            padding: const EdgeInsetsGeometry.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  dayName, 
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  dayNumber,
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