import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../blocs/theme_bloc.dart';

class AppName extends StatelessWidget {
  final double fontSize;
  const AppName({Key? key, required this.fontSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tb = context.watch<ThemeBloc>();
    return RichText(
      text: TextSpan(
        text: 'EL HORIZONTE', //first part
        style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            letterSpacing: -0.5,
            fontWeight: FontWeight.w900,
            color: tb.darkTheme == false
                ? Colors.grey[800]
                : Color.fromARGB(255, 234, 234, 234)),
      ),
    );
  }
}
