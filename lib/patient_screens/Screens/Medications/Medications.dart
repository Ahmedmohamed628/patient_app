import 'package:flutter/material.dart';

import '../../../theme/theme.dart';

class MedicationScreen extends StatelessWidget {
  static const String routeName = 'Medication-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.redColor,
        title: Text('Medications', style: TextStyle(color: MyTheme.whiteColor)),
        centerTitle: true,
      ),
      backgroundColor: MyTheme.whiteColor,
    );
  }
}
