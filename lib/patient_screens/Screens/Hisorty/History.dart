import 'package:flutter/material.dart';
import 'package:patient/patient_screens/Screens/Hisorty/chronicDiseases.dart';
import 'package:patient/patient_screens/Screens/Hisorty/prescription.dart';
import 'package:patient/patient_screens/Screens/Hisorty/smartWatch.dart';
import 'package:patient/theme/theme.dart';

class HistoryScreenPatient extends StatefulWidget {
  static const String routeName = 'History-screen';

  @override
  _HistoryScreenPatientState createState() => _HistoryScreenPatientState();
}

class _HistoryScreenPatientState extends State<HistoryScreenPatient> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: MyTheme.redColor,
        title: Text('chronic Diseases',
            style: TextStyle(color: MyTheme.whiteColor)),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: MyTheme.redColor,
              ),
              child: Text(
                'Medical History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // ListTile(
            //   leading: Icon(Icons.home),
            //   title: Text('Screen 1'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     Navigator.pushReplacement(context,
            //         MaterialPageRoute(builder: (context) => Screen1()));
            //   },
            // ),
            ListTile(
              leading: Icon(Icons.watch),
              title: Text('Watch History'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => WatchHistory()));
              },
            ),
            ListTile(
              leading: Icon(Icons.medical_information_outlined),
              title: Text('prescription and analysis'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Prescription()));
              },
            ),
          ],
        ),
      ),
      body: ChronicDiseas(), // Default screen when the app starts
    );
  }
}
