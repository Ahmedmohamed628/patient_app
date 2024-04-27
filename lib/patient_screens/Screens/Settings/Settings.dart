import 'package:flutter/material.dart';

import '../../../theme/theme.dart';

class SettingsScreen extends StatelessWidget {
  static const String routeName = 'settings-screen-patient';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.redColor,
        title: Text('Settings', style: TextStyle(color: MyTheme.whiteColor)),
        centerTitle: true,
      ),
      backgroundColor: MyTheme.whiteColor,
    );
  }
}
