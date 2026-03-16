import 'package:flutter/material.dart';

class CommonVerticalDivider extends StatelessWidget{
  const CommonVerticalDivider({super.key});

  @override 
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: VerticalDivider(
        width: 10,
        thickness: 0.5,
        color: Color(0xFF459AC3)
      ),
    );
  }

}