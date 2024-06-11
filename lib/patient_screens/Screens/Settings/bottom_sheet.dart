import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:path/path.dart';
import 'package:patient/model/my_user.dart';
import 'package:patient/patient_screens/Screens/Chat/Chat.dart';
import 'package:patient/patient_screens/Screens/Chat/private_chat.dart';
import 'package:patient/patient_screens/Screens/Settings/update_ptofile.dart';

import '../../../theme/theme.dart';

class BottomSheetSettings extends StatefulWidget {
  @override
  State<BottomSheetSettings> createState() => _BottomSheetSettingsState();
}

class _BottomSheetSettingsState extends State<BottomSheetSettings> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(ProfilePage.routeName);
            },
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(LineAwesomeIcons.edit),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              Text('Edit profile',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 15)),
            ]),
            style: ElevatedButton.styleFrom(
                backgroundColor: MyTheme.senderMessageColor),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          // ElevatedButton(
          //   onPressed: () {
          //   },
          //   child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          //     Icon(LineAwesomeIcons.helping_hands),
          //     SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          //     Text('Support       ',
          //         style: TextStyle(
          //             color: Colors.white,
          //             fontWeight: FontWeight.w400,
          //             fontSize: 15)),
          //   ]),
          //   style: ElevatedButton.styleFrom(
          //       backgroundColor: MyTheme.senderMessageColor),
          // ),
        ],
      ),
    );
  }
}
