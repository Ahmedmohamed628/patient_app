import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:patient/patient_screens/Screens/Chat/Chat.dart';
import 'package:patient/patient_screens/Screens/Hisorty/History.dart';
import 'package:patient/patient_screens/Screens/Medications/Medications.dart';
import 'package:patient/patient_screens/Screens/Medications/db/db.helper.dart';
import 'package:patient/patient_screens/Screens/Root/Root.dart';
import 'package:patient/patient_screens/Screens/Settings/Settings.dart';
import 'package:patient/patient_screens/Screens/Settings/update_ptofile.dart';
import 'package:patient/patient_screens/homeScreen_patient.dart';
import 'package:patient/patient_screens/screen_patient_registeration.dart';
import 'package:patient/splash_screen/splash_screen.dart';
import 'authentication/login/login_screen.dart';
import 'authentication/register/register_screen.dart';

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: 'AIzaSyDGoIsHdQjW9hidXSdbW3xS4YqKVGfYJGI',
    appId: '1:237732499396:android:fc5cf8ca28138255cfde91',
    messagingSenderId: 'sendid',
    projectId: 'emergency-app-da505',
    storageBucket: 'emergency-app-da505.appspot.com',
  ));
  FirebaseFirestore.instance.settings =
      Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);

  await GetStorage.init();
  await DBHelper.initDb();
  // WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.routeName,
      //RegisterScreen.routeName //ScreenSelection.routeName
      routes: {
        SplashScreen.routeName: (context) => SplashScreen(),
        LoginScreen.routeName: (context) => LoginScreen(),
        RegisterScreen.routeName: (context) => RegisterScreen(),
        RootScreen.routeName: (context) => RootScreen(),
        ProfileScreen.routeName: (context) => ProfileScreen(),
        HistoryScreenPatient.routeName: (context) => HistoryScreenPatient(),
        ChatScreenPatient.routeName: (context) => ChatScreenPatient(),
        MedicationScreen.routeName: (context) => MedicationScreen(),
        HomeScreenPatient.routeName: (context) => HomeScreenPatient(),
        ScreenPatientRegisteration.routeName: (context) =>
            ScreenPatientRegisteration(),
        // UpdateProfileScreen.routeName: (context) => UpdateProfileScreen(),
        ProfilePage.routeName: (context) => ProfilePage(),
      },
    );
  }
}
