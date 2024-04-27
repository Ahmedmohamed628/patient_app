import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../authentication/login/login_screen.dart';
import '../theme/theme.dart';

class SplashScreen extends StatelessWidget {
  static const String routeName = 'splash screen';

  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 4), () {
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    });
    return Scaffold(
        backgroundColor: MyTheme.redColor,
        body: Center(
          child: Lottie.asset('assets/images/ambulance_splash.json'),
        ));
  }
}
