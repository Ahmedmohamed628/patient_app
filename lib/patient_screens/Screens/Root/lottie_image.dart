import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Lottie.asset('assets/images/ambulance_come2.json',
        height: 130, width: 130);
  }
}
