import 'package:flutter/material.dart';

class CommonHorizontalDivider extends StatelessWidget{
  const CommonHorizontalDivider({super.key});

  @override 
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Divider(
        thickness: 0.5,
        color: Color(0xFF459AC3), 
        indent: 30,
        endIndent: 30,
      ),
    );
  }

}