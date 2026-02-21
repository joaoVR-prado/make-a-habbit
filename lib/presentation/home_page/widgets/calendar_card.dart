import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';

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
      // color: isSelected ? Colors.black : AppColors.cardBackgrounColor,
      margin: const EdgeInsets.all(4),
      elevation: isSelected ? 4 : 0,
      color: isSelected ? AppColors.calendarMainColor : AppColors.cardBackgrounColor,
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          if(isSelected)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 48,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.calendarSecondaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6)
                  )
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
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
                ),
              )
            )
        ],
      ),

      // child: InkWell(
      //   onTap: onTap,
      //   child: SizedBox(
      //     width: 62,
      //     height: 82,
      //     child: Padding(
      //       padding: const EdgeInsetsGeometry.symmetric(vertical: 8),
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.center,
      //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //         children: [
      //           Text(
      //             dayName, 
      //             style: Theme.of(context).textTheme.labelSmall,
      //           ),
      //           Text(
      //             dayNumber,
      //             style: Theme.of(context).textTheme.labelLarge,
      //           )
      //         ],
      //       )
      //     ),
          
      //   ),
      // )
    );
  }

}