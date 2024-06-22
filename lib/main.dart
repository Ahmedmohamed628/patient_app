import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:patient/app_info/app_info.dart';
import 'package:patient/patient_screens/Screens/Chat/Chat.dart';
import 'package:patient/patient_screens/Screens/Hisorty/History.dart';
import 'package:patient/patient_screens/Screens/Medications/Medications.dart';
import 'package:patient/patient_screens/Screens/Medications/db/db.helper.dart';
import 'package:patient/patient_screens/Screens/Root/Root.dart';
import 'package:patient/patient_screens/Screens/Root/google_maps.dart';
import 'package:patient/patient_screens/Screens/Root/search_destination_page.dart';
import 'package:patient/patient_screens/Screens/Settings/Settings.dart';
import 'package:patient/patient_screens/Screens/Settings/update_ptofile.dart';
import 'package:patient/patient_screens/homeScreen_patient.dart';
import 'package:patient/patient_screens/screen_patient_registeration.dart';
import 'package:patient/splash_screen/splash_screen.dart';
import 'package:provider/provider.dart';

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
      appId: '1:237732499396:android:4be660d63196dc67cfde91',
      messagingSenderId: '237732499396',
      projectId: 'emergency-app-da505',
      storageBucket: 'emergency-app-da505.appspot.com',
    ),
  );
  FirebaseFirestore.instance.settings =
      Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);

  await GetStorage.init();
  await DBHelper.initDb();

  // Initialize cameras
  await initializeAppAndCameras();
  // WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
  // MyLocationManager locationManager = MyLocationManager();
  // await locationManager.isServiceEnabled();
  // await locationManager.requestService();
  // await Permission.locationWhenInUse.isDenied.then((valueOfPermission){
  //   if(valueOfPermission){
  //     Permission.locationWhenInUse.request();
  //   }
  // });
}

List<CameraDescription>? cameras;

Future<void> initializeAppAndCameras() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: GetMaterialApp(
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
          GoogleMapScreen.routeName: (context) => GoogleMapScreen(),
          SearchDestinationPage.routeName: (context) => SearchDestinationPage(),
        },
      ),
    );
  }
}
