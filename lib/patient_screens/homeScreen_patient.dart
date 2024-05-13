import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'Screens/Chat/Chat.dart';
import 'Screens/Hisorty/History.dart';
import 'Screens/Medications/Medications.dart';
import 'Screens/Root/Root.dart';
import 'Screens/Settings/Settings.dart';

class HomeScreenPatient extends StatefulWidget {
  static const String routeName = 'Home-screen-patient';

  @override
  State<HomeScreenPatient> createState() => _HomeScreenPatientState();
}

class _HomeScreenPatientState extends State<HomeScreenPatient> {
  int selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: MyTheme.redColor,
        ),
        child: BottomAppBar(
          color: MyTheme.redColor,
          shape: CircularNotchedRectangle(),
          notchMargin: 8,
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            selectedItemColor: MyTheme.whiteColor,
            unselectedItemColor: MyTheme.grayColor,
            onTap: (index) {
              selectedIndex = index;

              setState(() {});
            },
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.chat, size: 22), label: 'Chat'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.medication_liquid, size: 22),
                  label: 'Medication'),
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 22),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.history, size: 22), label: 'History'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_pin_rounded, size: 22),
                  label: 'Profile'),
            ],
          ),
        ),
      ),
      body: tabs[selectedIndex],
    );
  }

  List<Widget> tabs = [
    ChatScreenPatient(),
    MedicationScreen(),
    RootScreen(),
    HistoryScreenPatient(),
    ProfileScreen()
  ];
}
