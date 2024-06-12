import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:location/location.dart';
import 'package:patient/my_location_manager.dart';
import 'package:patient/patient_screens/Screens/Root/google_maps.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../healthconnectmethodes.dart';
import '../../../theme/theme.dart';

class RootScreen extends StatefulWidget {
  static const String routeName = 'Root';

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  MyLocationManager locationManager = MyLocationManager();

  // StreamSubscription<LocationData>? streamSubscription;
  late Timer timer;
  Position? currentPositionOfUser;

  @override
  void initState() {
    super.initState();
    requestPermission();

    // trackUserLocation();
    timer = Timer.periodic(Duration(seconds: 30), (timer) {
      fetchData(() {
        print('-----Inside-------');
        timer.cancel();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // locationManager.myLocation.changeSettings(
    //   accuracy: LocationAccuracy.high,
    //   distanceFilter: 5,
    //   interval: 1000,
    // );
    return Scaffold(
      backgroundColor: MyTheme.whiteColor,
      appBar: AppBar(
        title: Text("Ambulance", style: TextStyle(color: MyTheme.whiteColor)),
        centerTitle: true,
        backgroundColor: Color(0xFFa00c0e),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // fetchData();
                  Navigator.of(context).pushNamed(GoogleMapScreen.routeName);
                },
                child: CircleAvatar(
                  backgroundColor: Color(0xFFa00c0e),
                  radius: 65,
                  backgroundImage:
                      AssetImage('assets/images/ambulance_icon.png'),
                ),
              ),
              Text(
                'click for Ambulance',
                style: TextStyle(
                    fontSize: 30.0,
                    color: MyTheme.redColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'DancingScript'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //todo: function : 3shan ytl3 ask ll permission awl mayft7 el app
  // trackUserLocation()async{
  //   var locationData = await locationManager.getUserLocation();
  //   print(locationData?.latitude?? 0);
  //   print(locationData?.longitude?? 0);
  //   streamSubscription = locationManager.updateUserLocation().listen((newLocation) {
  //     print(newLocation.longitude);
  //     print(newLocation.latitude);
  //   });
  // }
  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  //   streamSubscription?.cancel();
  // }

  // function: 3shan tgeeb el location bta3 el user
// getCurrentLiveLocationOfUser()async{
//     Position positionOfUser = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
//     currentPositionOfUser = positionOfUser;
//     LatLng positionOfUserInLatLng = LatLng(currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);
//     CameraPosition cameraPosition = CameraPosition(target: positionOfUserInLatLng, zoom: 15);
//     controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
//
// }

//function: 3shan tgeeb => 1- request gps ... 2- permission el location
  // requestPermission() async {
  //   await locationManager.isServiceEnabled();
  //   await locationManager.requestService();
  //   await Permission.locationWhenInUse.isDenied.then((valueOfPermission) {
  //     if (valueOfPermission) {
  //       Permission.locationWhenInUse.request();
  //     }
  //   });
  // }

  Future<void> requestPermission() async {
    bool isLocationServiceEnabled = await locationManager.isServiceEnabled();
    if (!isLocationServiceEnabled) {
      await locationManager.requestService();
    }

    bool isLocationPermissionDenied =
        await Permission.locationWhenInUse.isDenied;
    if (isLocationPermissionDenied) {
      await Permission.locationWhenInUse.request();
    }

    // bool isNotificationPermissionDenied =
    //     await Permission.notification.isDenied;
    // if (isNotificationPermissionDenied) {
    //   await Permission.notification.request();
    // }
  }
}
