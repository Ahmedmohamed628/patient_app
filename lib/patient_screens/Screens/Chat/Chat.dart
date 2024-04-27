import 'package:flutter/material.dart';

import '../../../screens_chat/mobile_layout_screen.dart';
import '../../../screens_chat/web_layout_screen.dart';
import '../../../utils/responsive_layout.dart';

class ChatScreenPatient extends StatelessWidget {
  static const String routeName = 'Chat-screen-patient';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
          mobileScreenLayout: MobileLayoutScreen(),
          webScreenLayout: WebLayoutScreen()),
    );
  }
}

//Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyTheme.redColor,
//         title: Text('Chat', style: TextStyle(color: MyTheme.whiteColor)),
//         centerTitle: true,
//       ),
//       backgroundColor: MyTheme.whiteColor,
//     );
