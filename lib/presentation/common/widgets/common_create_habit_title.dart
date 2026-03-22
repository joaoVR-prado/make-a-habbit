import 'package:flutter/material.dart';

class CommonCreateHabitTitle extends StatelessWidget {
  final String titleText;

  const CommonCreateHabitTitle({
    super.key,
    required this.titleText
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 38, bottom: 24, left: 24, right: 24),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          titleText,
          style: TextTheme.of(context).titleLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

}