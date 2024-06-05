import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:patient/patient_screens/homeScreen_patient.dart';

import '../authentication/login/login_screen.dart';
import '../theme/theme.dart';

class SplashScreen extends StatelessWidget {
  static const String routeName = 'splash screen';

  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 4), () {
      // lma ygy el app yft7 hyro7 3la el homeScreen lw howa 3amel login aw loginScreen lw lsa m3mlsh login
      FirebaseAuth.instance.currentUser == null
          ? Navigator.of(context).pushReplacementNamed(LoginScreen.routeName)
          : Navigator.of(context)
              .pushReplacementNamed(HomeScreenPatient.routeName);
    });
    return Scaffold(
        backgroundColor: MyTheme.redColor,
        body: Center(
          child: Lottie.asset('assets/images/ambulance_splash.json'),
        ));
  }
}
