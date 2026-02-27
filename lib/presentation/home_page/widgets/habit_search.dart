import 'package:flutter/material.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/core/utils/enums/habit_icon.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';

class HabitSearch extends SearchDelegate{
  final List<HabitModel> habits;

  HabitSearch({required this.habits})
    : super(searchFieldLabel: 'Buscar hábito...');

  @override
  List<Widget>? buildActions(BuildContext context){
    return [
      if(query.isNotEmpty)
        IconButton(
          onPressed: (){
            query = '';
            showSuggestions(context);
          }, 
          icon: const Icon(Icons.clear, size: 32),
          color: AppColors.homePageIconColor,
        )

    ];

  }

  @override
  Widget? buildLeading(BuildContext context){
    return IconButton(
      onPressed: (){
        close(context, null);
      }, 
      icon: const Icon(Icons.arrow_back, size: 32),
      color: AppColors.homePageIconColor,
    );

  }

  @override
  Widget buildResults(BuildContext context){
    return buildSuggestions(context);

  }

  @override 
  Widget buildSuggestions(BuildContext context){
    final filteredHabits = habits.where((habit){
      return habit.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredHabits.length,
      itemBuilder: (context, index){
        final habit = filteredHabits[index];
        final habitIcon = HabitIcon.fromCode(habit.iconCode);
        return Padding(
          padding: EdgeInsetsGeometry.symmetric(vertical: 2, horizontal: 12),
          child: ListTile(
            title: Text(
              habit.name,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            leading: Icon(
              habitIcon.iconData,
              color: habitIcon.color,
            ),
            onTap: (){
              close(context, habit);
            },
          ),
        );
      }
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.black),
      ),
      // ...
    );
  }

}