import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:patient/authentication/login/login_screen.dart';
import 'package:patient/dialog_utils.dart';
import 'package:patient/patient_screens/Screens/Settings/update_ptofile.dart';

import '../../../authentication/register/register_navigator.dart';
import '../../../methods/common_methods.dart';
import '../../../theme/theme.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = 'profile-screen-patient';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  CommonMethods cMethods = CommonMethods();
  late RegisterNavigator navigator;

  // sign out function
  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut().then((value) => Navigator.of(context)
        .pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false));
  }

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.redColor,
        title: Text('Profile', style: TextStyle(color: MyTheme.whiteColor)),
        centerTitle: true,
      ),
      backgroundColor: MyTheme.whiteColor,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Stack(children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image(
                      image: AssetImage('assets/images/user.jpg'),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.04,
                    width: MediaQuery.of(context).size.width * 0.08,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: MyTheme.redColor),
                    child: Icon(LineAwesomeIcons.alternate_pencil,
                        color: Colors.white, size: 20),
                  ),
                ),
              ]),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Text('Ahmed Mohamed',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('ahmed.mohamed7patient@gmail.com',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              SizedBox(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(UpdateProfileScreen.routeName);
                  },
                  child: Text('Edit profile',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: MyTheme.senderMessageColor),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              const Divider(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              ListTile(
                tileColor: MyTheme.messageColor.withOpacity(0.1),
                onTap: () {},
                leading: Container(
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.13,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: MyTheme.searchBarColor.withOpacity(0.6)),
                  child: Icon(LineAwesomeIcons.cog),
                ),
                title: Text('Settings',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                trailing: Container(
                  height: MediaQuery.of(context).size.height * 0.03,
                  width: MediaQuery.of(context).size.width * 0.09,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: MyTheme.searchBarColor.withOpacity(0.1)),
                  child: Icon(LineAwesomeIcons.angle_right,
                      color: Colors.grey, size: 18),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              ListTile(
                tileColor: MyTheme.messageColor.withOpacity(0.1),
                onTap: () {},
                leading: Container(
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.13,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: MyTheme.redColor.withOpacity(0.1)),
                  child: Icon(LineAwesomeIcons.paint_roller),
                ),
                title: Text('Theme',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                trailing: Container(
                  height: MediaQuery.of(context).size.height * 0.03,
                  width: MediaQuery.of(context).size.width * 0.09,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: MyTheme.searchBarColor.withOpacity(0.1)),
                  child: Icon(LineAwesomeIcons.angle_right,
                      color: Colors.grey, size: 18),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              ListTile(
                tileColor: MyTheme.messageColor.withOpacity(0.1),
                onTap: () {
                  DialogUtils.showMessage(
                    context,
                    title: 'Sign_out ',
                    ' Are you sure to sign_out?',
                    barrierDismissible: false,
                    posActionName: 'yes',
                    posAction: () {
                      _signOut(context);
                      cMethods.displaySnackBar(
                          'Signed out successfully.', context);
                    },
                    negActionName: 'no',
                    negAction: () {},
                  );
                },
                leading: Container(
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.13,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: MyTheme.redColor.withOpacity(0.6)),
                  child: Icon(LineAwesomeIcons.alternate_sign_out),
                ),
                title: Text('Log_out',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                // trailing: Container(
                //   height: MediaQuery.of(context).size.height*0.03 , width: MediaQuery.of(context).size.width*0.09 ,
                //   decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(100),
                //       color: MyTheme.searchBarColor.withOpacity(0.1)),
                //   child: Icon(LineAwesomeIcons.angle_right, color: Colors.grey, size: 18),
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
