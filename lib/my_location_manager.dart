import 'package:location/location.dart';

class MyLocationManager {
  Location myLocation = Location();

  /*
  1- permission location
  2- request permission
  3- gps
  4- request open gps
   */

  // 1st function: htrg3ly el status fe 7ala lw el user waf2
  Future<bool> isPermissionGranted() async {
    var permissionStatus = await myLocation.hasPermission();
    return permissionStatus == PermissionStatus.granted;
  }

  // 2nd function: htlob mn el user el permission
  Future<bool> requestPermission() async {
    var permissionStatus = await myLocation.requestPermission();
    return permissionStatus == PermissionStatus.granted;
  }

  //3rd function: 3lshan y3ml enable ll gps
  Future<bool> isServiceEnabled() async {
    var serviceEnabled = await myLocation.serviceEnabled();
    return serviceEnabled;
  }

  // 4th function: lw el gps msh mfto7 eft7o
  Future<bool> requestService() async {
    var serviceEnabled = await myLocation.requestService();
    return serviceEnabled;
  }

// 5th function: ageeb el user location
  Future<LocationData?> getUserLocation() async {
    var permissionStatus = await requestPermission();
    var serviceEnabled = await requestService();
    if (!permissionStatus || !serviceEnabled) {
      return null;
    }
    return myLocation.getLocation();
  }

  // 6th function: 3shan ageeb el location bta3 el user lw et8eer ( listen on changed location)
  Stream<LocationData> updateUserLocation() {
    return myLocation.onLocationChanged;
  }
}
