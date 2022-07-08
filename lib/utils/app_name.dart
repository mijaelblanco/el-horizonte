import 'package:flutter/material.dart';

class AppName extends StatelessWidget {
  final double fontSize;
  const AppName({Key? key, required this.fontSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'EL HORIZONTE', //first part
        style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            letterSpacing: -0.5,
            fontWeight: FontWeight.w900,
            color: Colors.grey[800]),
      ),
    );
  }
}
