import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:lottie/lottie.dart';
import 'package:patient/app_info/app_info.dart';
import 'package:patient/methods/common_methods.dart';
import 'package:patient/patient_screens/Screens/Root/lottie_image.dart';
import 'package:patient/patient_screens/Screens/Root/search_destination_page.dart';
import 'package:patient/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';

import '../../../global/trip_var.dart';
import '../../../info_dialog.dart';
import '../../../loading_dialog.dart';
import '../../../methods/manage_drivers_methods.dart';
import '../../../methods/push_notification_service.dart';
import '../../../model/direction_details.dart';
import '../../../model/my_user.dart';
import '../../../model/online_nearby_drivers.dart';

String googleMapKey = 'AIzaSyDGoIsHdQjW9hidXSdbW3xS4YqKVGfYJGI';

class GoogleMapScreen extends StatefulWidget {
  static const String routeName = "google-map-screen";

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  Position? currentPositionOfUser;
  double searchContainerHeight = 276;
  double bottomMapPadding = 0;
  double rideDetailsContainerHeight = 0;
  double requestContainerHeight = 0;
  double tripContainerHeight = 0;
  DirectionDetails? tripDirectionDetailsInfo;
  List<LatLng> polylineCoOrdinates = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  String stateOfApp = "normal";
  bool nearbyOnlineDriversKeysLoaded = false;
  BitmapDescriptor? hospitalCarIconNearbyDriver;
  DatabaseReference? tripRequestRef;
  List<OnlineNearbyHospitalsDrivers>? availableNearbyOnlineAmbulanceDriversList;
  CommonMethods cMethods = CommonMethods();

  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();

  GoogleMapController? controllerGoogleMap;

  static const CameraPosition googlePlexInitialPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  displayUserRideDetailsContainer() async {
    // draw route between pickUp & destination
    //directions api
    await retrieveDirectionDetails();
    setState(() {
      searchContainerHeight = 0;
      bottomMapPadding = 240;
      rideDetailsContainerHeight = 242;
    });
  }

  retrieveDirectionDetails() async {
    var pickUpLocation =
        Provider.of<AppInfo>(context, listen: false).pickUpLocation;
    var destinationLocation =
        Provider.of<AppInfo>(context, listen: false).destinationLocation;

    var pickUpGeographicCoOrdinates = LatLng(
        pickUpLocation!.latitudePosition!, pickUpLocation.longitudePosition!);
    var destinationGeographicCoOrdinates = LatLng(
        destinationLocation!.latitudePosition!,
        destinationLocation.longitudePosition!);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Getting direction..."),
    );
    // directions api
    var detailsFromDirectionAPI =
        await CommonMethods.getDirectionDetailsFromAPI(
            pickUpGeographicCoOrdinates, destinationGeographicCoOrdinates);
    setState(() {
      tripDirectionDetailsInfo = detailsFromDirectionAPI;
    });
    Navigator.pop(context);

    //draw route from pickIp to destination:
    PolylinePoints pointsPolyline = PolylinePoints();
    List<PointLatLng> latLngPointsFromPickUpToDestination =
        pointsPolyline.decodePolyline(tripDirectionDetailsInfo!.encodedPoints!);
    polylineCoOrdinates.clear();

    if (latLngPointsFromPickUpToDestination.isNotEmpty) {
      latLngPointsFromPickUpToDestination.forEach(
        (PointLatLng latLngPoint) {
          polylineCoOrdinates
              .add(LatLng(latLngPoint.latitude, latLngPoint.longitude));
        },
      );
    }

    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId("polylineID"),
        color: Colors.indigo,
        points: polylineCoOrdinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polylineSet.add(polyline);
    });

    // fit the polyline into the map
    LatLngBounds boundsLatLng;
    if (pickUpGeographicCoOrdinates.latitude >
            destinationGeographicCoOrdinates.latitude &&
        pickUpGeographicCoOrdinates.longitude >
            destinationGeographicCoOrdinates.longitude) {
      boundsLatLng = LatLngBounds(
          southwest: destinationGeographicCoOrdinates,
          northeast: pickUpGeographicCoOrdinates);
    } else if (pickUpGeographicCoOrdinates.longitude >
        destinationGeographicCoOrdinates.longitude) {
      boundsLatLng = LatLngBounds(
          southwest: LatLng(pickUpGeographicCoOrdinates.latitude,
              destinationGeographicCoOrdinates.longitude),
          northeast: LatLng(destinationGeographicCoOrdinates.latitude,
              pickUpGeographicCoOrdinates.longitude));
    } else if (pickUpGeographicCoOrdinates.latitude >
        destinationGeographicCoOrdinates.latitude) {
      boundsLatLng = LatLngBounds(
          southwest: LatLng(destinationGeographicCoOrdinates.latitude,
              pickUpGeographicCoOrdinates.longitude),
          northeast: LatLng(pickUpGeographicCoOrdinates.latitude,
              destinationGeographicCoOrdinates.longitude));
    } else {
      boundsLatLng = LatLngBounds(
          southwest: pickUpGeographicCoOrdinates,
          northeast: destinationGeographicCoOrdinates);
    }

    controllerGoogleMap!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 72));

    // add markers to pickUp and destination points:
    Marker pickUpPointMarker = Marker(
      markerId: MarkerId("pickUpPointMarkerID"),
      position: pickUpGeographicCoOrdinates,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
          title: pickUpLocation.placeName, snippet: "PickUp location"),
    );
    Marker destinationPointMarker = Marker(
      markerId: MarkerId("destinationPointMarkerID"),
      position: destinationGeographicCoOrdinates,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(
          title: destinationLocation.placeName,
          snippet: "Destination location"),
    );
    setState(() {
      markerSet.add(pickUpPointMarker);
      markerSet.add(destinationPointMarker);
    });

    // add circles to pickUp and destination points:
    Circle pickUpPointCircle = Circle(
      circleId: CircleId("pickUpCircleID"),
      strokeColor: Colors.blue,
      strokeWidth: 4,
      radius: 1,
      center: pickUpGeographicCoOrdinates,
      fillColor: Colors.blue,
    );
    Circle destinationPointCircle = Circle(
      circleId: CircleId("destinationCircleID"),
      strokeColor: Colors.blue,
      strokeWidth: 4,
      radius: 1,
      center: destinationGeographicCoOrdinates,
      fillColor: Colors.blue,
    );

    setState(() {
      circleSet.add(pickUpPointCircle);
      circleSet.add(destinationPointCircle);
    });
  }

  resetAppNow() {
    setState(() {
      polylineCoOrdinates.clear();
      polylineSet.clear();
      markerSet.clear();
      circleSet.clear();
      rideDetailsContainerHeight = 0;
      requestContainerHeight = 0;
      tripContainerHeight = 0;
      searchContainerHeight = 276;
      bottomMapPadding = 300;

      status = "";
      nameDriver = "";
      photoDriver = "";
      phoneNumberDriver = "";
      carDetailsDriver = "";
      tripStatusDisplay = 'Driver is Arriving';
    });
    // Restart.restartApp();
  }

  cancelRideRequest() {
    //remove ride request from database
    tripRequestRef!.remove();

    setState(() {
      stateOfApp = "normal";
    });
  }

  displayRequestContainer() {
    setState(() {
      rideDetailsContainerHeight = 0;
      requestContainerHeight = 220;
      bottomMapPadding = 200;
    });

    //send ambulance (ride) request
    makeTripRequest();
  }

  updateAvailableNearbyOnlineDriversOnMap() {
    setState(() {
      markerSet.clear();
    });

    Set<Marker> markersTempSet = Set<Marker>();

    for (OnlineNearbyHospitalsDrivers eachOnlineNearbyDriver
        in ManageDriversMethods.nearbyOnlineDriversList) {
      LatLng driverCurrentPosition = LatLng(
          eachOnlineNearbyDriver.latHospitalDriver!,
          eachOnlineNearbyDriver.lngHospitalDriver!);

      Marker driverMarker = Marker(
        markerId: MarkerId("hospital driver ID = " +
            eachOnlineNearbyDriver.uidHospitalDriver.toString()),
        position: driverCurrentPosition,
        icon: hospitalCarIconNearbyDriver!,
      );

      markersTempSet.add(driverMarker);
    }

    setState(() {
      markerSet = markersTempSet;
    });
  }

  makeDriverNearbyCarIcon() {
    if (hospitalCarIconNearbyDriver == null) {
      ImageConfiguration configuration =
          createLocalImageConfiguration(context, size: Size(0.5, 0.5));
      BitmapDescriptor.fromAssetImage(
        configuration,
        "assets/images/ambulance_tracking.png",
      ).then((iconImage) {
        hospitalCarIconNearbyDriver = iconImage;
      });
    }
  }

  initializeGeoFireListener() {
    Geofire.initialize("onlineHospitals");
    Geofire.queryAtLocation(currentPositionOfUser!.latitude,
            currentPositionOfUser!.longitude, 22)!
        .listen((driverEvent) {
      if (driverEvent != null) {
        //onlineHospital .. 3dd el online hospital drivers
        var onlineDriverChild = driverEvent["callBack"];

        switch (onlineDriverChild) {
          // case1: lw el hospital driver d5l gowa el radius b3d ma kan bara
          case Geofire.onKeyEntered:
            OnlineNearbyHospitalsDrivers onlineNearbyDrivers =
                OnlineNearbyHospitalsDrivers(); // kol driver 3ndo el (1-key.. 2-latitude.. 3-longitude)
            onlineNearbyDrivers.uidHospitalDriver = driverEvent["key"];
            onlineNearbyDrivers.latHospitalDriver = driverEvent["latitude"];
            onlineNearbyDrivers.lngHospitalDriver = driverEvent["longitude"];
            ManageDriversMethods.nearbyOnlineDriversList
                .add(onlineNearbyDrivers);
            if (nearbyOnlineDriversKeysLoaded == true) {
              //update drivers on google map
              updateAvailableNearbyOnlineDriversOnMap();
            }
            break;

          //case2: lw el hospital driver bra el radius
          case Geofire.onKeyExited:
            ManageDriversMethods.removeDriverFromList(driverEvent["key"]);
            //update drivers on google map
            updateAvailableNearbyOnlineDriversOnMap();
            break;

          // case3: lw el hospital driver byt7rk gowa el radius
          case Geofire.onKeyMoved:
            OnlineNearbyHospitalsDrivers onlineNearbyDrivers =
                OnlineNearbyHospitalsDrivers();
            onlineNearbyDrivers.uidHospitalDriver = driverEvent["key"];
            onlineNearbyDrivers.latHospitalDriver = driverEvent["latitude"];
            onlineNearbyDrivers.lngHospitalDriver = driverEvent["longitude"];
            ManageDriversMethods.updateOnlineNearbyDriversLocation(
                onlineNearbyDrivers);
            //update drivers on google map
            updateAvailableNearbyOnlineDriversOnMap();
            break;

          // case4: kol el hospital drivers gowa el radius ybano
          case Geofire.onGeoQueryReady:
            nearbyOnlineDriversKeysLoaded = true;
            //update drivers on google map
            updateAvailableNearbyOnlineDriversOnMap();
            break;
        }
      }
    });
  }

  makeTripRequest() {
    tripRequestRef =
        FirebaseDatabase.instance.ref().child("tripRequests").push();

    var pickUpLocation =
        Provider.of<AppInfo>(context, listen: false).pickUpLocation;
    var dropOffDestinationLocation =
        Provider.of<AppInfo>(context, listen: false).destinationLocation;

    Map pickUpCoOrdinatesMap = {
      "latitude": pickUpLocation!.latitudePosition.toString(),
      "longitude": pickUpLocation.longitudePosition.toString(),
    };

    Map dropOffDestinationCoOrdinatesMap = {
      "latitude": dropOffDestinationLocation!.latitudePosition.toString(),
      "longitude": dropOffDestinationLocation.longitudePosition.toString(),
    };

    //el mafrood tb2a hospital coordinates
    Map driverCoOrdinates = {
      "latitude": "",
      "longitude": "",
    };

    Map dataMap = {
      "tripID": tripRequestRef!.key,
      "publishDateTime": DateTime.now().toString(),
      "userName": FirebaseAuth.instance.currentUser!.displayName,
      "userPhone": FirebaseAuth.instance.currentUser!.phoneNumber,
      "userID": FirebaseAuth.instance.currentUser!.uid,
      "pickUpLatLng": pickUpCoOrdinatesMap,
      "destinationLatLng": dropOffDestinationCoOrdinatesMap,
      "pickUpAddress": pickUpLocation.placeName,
      "destinationAddress": dropOffDestinationLocation.placeName,
      "driverID": "waiting",
      "carDetails": "",
      "driverLocation": driverCoOrdinates,
      "driverName": "",
      "driverPhone": "",
      "driverPhoto": "",
      "status": "new",
    };

    tripRequestRef!.set(dataMap);

    // tripStreamSubscription = tripRequestRef!.onValue.listen((eventSnapshot) async {
    //   if(eventSnapshot.snapshot.value == null)
    //   {
    //     return;
    //   }
    //
    //   if((eventSnapshot.snapshot.value as Map)["driverName"] != null)
    //   {
    //     nameDriver = (eventSnapshot.snapshot.value as Map)["driverName"];
    //   }
    //
    //   if((eventSnapshot.snapshot.value as Map)["driverPhone"] != null)
    //   {
    //     phoneNumberDriver = (eventSnapshot.snapshot.value as Map)["driverPhone"];
    //   }
    //
    //   if((eventSnapshot.snapshot.value as Map)["driverPhoto"] != null)
    //   {
    //     photoDriver = (eventSnapshot.snapshot.value as Map)["driverPhoto"];
    //   }
    //
    //   if((eventSnapshot.snapshot.value as Map)["carDetails"] != null)
    //   {
    //     carDetailsDriver = (eventSnapshot.snapshot.value as Map)["carDetails"];
    //   }
    //
    //   if((eventSnapshot.snapshot.value as Map)["status"] != null)
    //   {
    //     status = (eventSnapshot.snapshot.value as Map)["status"];
    //   }
    //
    //   if((eventSnapshot.snapshot.value as Map)["driverLocation"] != null)
    //   {
    //     double driverLatitude = double.parse((eventSnapshot.snapshot.value as Map)["driverLocation"]["latitude"].toString());
    //     double driverLongitude = double.parse((eventSnapshot.snapshot.value as Map)["driverLocation"]["longitude"].toString());
    //     LatLng driverCurrentLocationLatLng = LatLng(driverLatitude, driverLongitude);
    //
    //     if(status == "accepted")
    //     {
    //       //update info for pickup to user on UI
    //       //info from driver current location to user pickup location
    //       updateFromDriverCurrentLocationToPickUp(driverCurrentLocationLatLng);
    //     }
    //     else if(status == "arrived")
    //     {
    //       //update info for arrived - when driver reach at the pickup point of user
    //       setState(() {
    //         tripStatusDisplay = 'Driver has Arrived';
    //       });
    //     }
    //     else if(status == "ontrip")
    //     {
    //       //update info for dropoff to user on UI
    //       //info from driver current location to user dropoff location
    //       updateFromDriverCurrentLocationToDropOffDestination(driverCurrentLocationLatLng);
    //     }
    //   }
    //
    //   if(status == "accepted")
    //   {
    //     displayTripDetailsContainer();
    //
    //     Geofire.stopListener();
    //
    //     //remove drivers markers
    //     setState(() {
    //       markerSet.removeWhere((element) => element.markerId.value.contains("driver"));
    //     });
    //   }
    //
    //   if(status == "ended")
    //   {
    //     if((eventSnapshot.snapshot.value as Map)["fareAmount"] != null)
    //     {
    //       double fareAmount = double.parse((eventSnapshot.snapshot.value as Map)["fareAmount"].toString());
    //
    //       var responseFromPaymentDialog = await showDialog(
    //         context: context,
    //         builder: (BuildContext context) => PaymentDialog(fareAmount: fareAmount.toString()),
    //       );
    //
    //       if(responseFromPaymentDialog == "paid")
    //       {
    //         tripRequestRef!.onDisconnect();
    //         tripRequestRef = null;
    //
    //         tripStreamSubscription!.cancel();
    //         tripStreamSubscription = null;
    //
    //         resetAppNow();
    //
    //         Restart.restartApp();
    //       }
    //     }
    //   }
    // });
  }

  // lw m3ndeesh available driver (ambulance)
  searchDriver() {
    if (availableNearbyOnlineAmbulanceDriversList!.length == 0) {
      cancelRideRequest();
      resetAppNow();
      noDriverAvailable();
      return;
    }

    var currentAmbulance = availableNearbyOnlineAmbulanceDriversList![0];
    sendNotificationToDriver(currentAmbulance);

    availableNearbyOnlineAmbulanceDriversList!.removeAt(0);
  }

  noDriverAvailable() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => InfoDialog(
              title: "No Ambulance Available",
              description:
                  "No ambulance found in the nearby location. Please try again shortly.",
            ));
  }

  sendNotificationToDriver(OnlineNearbyHospitalsDrivers currentDriver) {
    log("im at DatabaseReference");
    //update driver's newTripStatus - assign tripID to current driver
    DatabaseReference currentDriverRef = FirebaseDatabase.instance
        .ref()
        .child("Hospital")
        .child(currentDriver.uidHospitalDriver.toString())
        .child("newTripStatus");

    currentDriverRef.set(tripRequestRef!.key);
    log("im at tokenOfCurrentDriverRef");

    //get current driver device recognition token
    DatabaseReference tokenOfCurrentDriverRef = FirebaseDatabase.instance
        .ref()
        .child("Hospital")
        .child(currentDriver.uidHospitalDriver.toString())
        .child("deviceToken");
    log("im at tokenOfCurrentDriverRef");

    tokenOfCurrentDriverRef.once().then((dataSnapshot) {
      if (dataSnapshot.snapshot.value != null) {
        String deviceToken = dataSnapshot.snapshot.value.toString();

        // send notification
        PushNotificationService.sendNotificationToSelectedDriver(
            deviceToken, context, tripRequestRef!.key.toString(), 'test name');
      } else {
        return;
      }

      const oneTickPerSec = Duration(seconds: 1);

      // var timerCountDown = Timer.periodic(oneTickPerSec, (timer)
      // {
      //   requestTimeoutDriver = requestTimeoutDriver - 1;
      //
      //   //when trip request is not requesting means trip request cancelled - stop timer
      //   if(stateOfApp != "requesting")
      //   {
      //     timer.cancel();
      //     currentDriverRef.set("cancelled");
      //     currentDriverRef.onDisconnect();
      //     requestTimeoutDriver = 20;
      //   }
      //
      //   //when trip request is accepted by online nearest available driver
      //   currentDriverRef.onValue.listen((dataSnapshot)
      //   {
      //     if(dataSnapshot.snapshot.value.toString() == "accepted")
      //     {
      //       timer.cancel();
      //       currentDriverRef.onDisconnect();
      //       requestTimeoutDriver = 20;
      //     }
      //   });
      //
      //   //if 20 seconds passed - send notification to next nearest online available driver
      //   if(requestTimeoutDriver == 0)
      //   {
      //     currentDriverRef.set("timeout");
      //     timer.cancel();
      //     currentDriverRef.onDisconnect();
      //     requestTimeoutDriver = 20;
      //
      //     //send notification to next nearest online available driver
      //     searchDriver();
      //   }
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    makeDriverNearbyCarIcon();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.redColor,
        title: Text('Map', style: TextStyle(color: MyTheme.whiteColor)),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              LineAwesomeIcons.angle_left,
              color: MyTheme.whiteColor,
            )),
      ),
      body: Stack(
        children: [
          // google map
          GoogleMap(
            mapType: MapType.normal,
            polylines: polylineSet,
            markers: markerSet,
            circles: circleSet,
            initialCameraPosition: googlePlexInitialPosition,
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController mapController) {
              controllerGoogleMap = mapController;
              // updateMapTheme(controllerGoogleMap!);
              googleMapCompleterController.complete(controllerGoogleMap);
              getCurrentLiveLocationOfUser();
            },
          ),

          /// icon reset the searching
          Positioned(
            top: 20,
            left: 19,
            child: GestureDetector(
              onTap: () {
                resetAppNow();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white30,
                      blurRadius: 5,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: MyTheme.redColor,
                  radius: 20,
                  child: Icon(Icons.close, color: MyTheme.whiteColor),
                ),
              ),
            ),
          ),

          /// search location icon button
          Positioned(
            left: 20,
            right: 0,
            bottom: -70,
            child: Container(
              height: searchContainerHeight,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      var responseFromSearchPage = await Navigator.of(context)
                          .pushNamed(SearchDestinationPage.routeName);
                      if (responseFromSearchPage == "placeSelected") {
                        String destinationLocation =
                            Provider.of<AppInfo>(context, listen: false)
                                    .destinationLocation!
                                    .placeName ??
                                "";
                        // log("destinationLocation ================================================================" + destinationLocation);
                        displayUserRideDetailsContainer();
                      }
                    },
                    child: Icon(
                      Icons.search,
                      color: MyTheme.whiteColor,
                      size: 25,
                    ),
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(24),
                        backgroundColor: MyTheme.redColor),
                  )
                ],
              ),
            ),
          ),

          /// ride details container
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: rideDetailsContainerHeight,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white12,
                    blurRadius: 15.0,
                    spreadRadius: 0.5,
                    offset: Offset(.7, .7),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: SizedBox(
                        height: 200,
                        child: Card(
                          elevation: 10,
                          child: Container(
                            width: MediaQuery.of(context).size.width * .70,
                            color: Colors.black45,
                            child: Padding(
                              padding: EdgeInsets.only(top: 8, bottom: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          (tripDirectionDetailsInfo != null)
                                              ? tripDirectionDetailsInfo!
                                                  .distanceTextString!
                                              : "",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          (tripDirectionDetailsInfo != null)
                                              ? tripDirectionDetailsInfo!
                                                  .durationTextString!
                                              : "",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        // Text(
                                        //   (tripDirectionDetailsInfo != null) ? tripDirectionDetailsInfo!.durationTextString! : "",
                                        //   style: const TextStyle(
                                        //     fontSize: 16,
                                        //     color: Colors.white70,
                                        //     fontWeight: FontWeight.bold,
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),

                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        stateOfApp = "Requesting";
                                      });
                                      displayRequestContainer();
                                      // get nearest available hospitals (online drivers)
                                      availableNearbyOnlineAmbulanceDriversList =
                                          ManageDriversMethods
                                              .nearbyOnlineDriversList;

                                      //search driver (hospital)
                                      searchDriver();
                                    },
                                    child: LottieImage(),
                                    // Image.asset(
                                    //   "assets/images/ambulance_coming.jpg",
                                    //   height: 122,
                                    //   width: 122,
                                    // ),
                                  ),

                                  // Text(
                                  //   "\$ 12", style: const TextStyle(
                                  //     fontSize: 18,
                                  //     color: Colors.white70,
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// request container
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: requestContainerHeight,
              decoration: const BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15.0,
                    spreadRadius: 0.5,
                    offset: Offset(
                      0.7,
                      0.7,
                    ),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      width: 200,
                      child: LoadingAnimationWidget.flickr(
                        leftDotColor: Colors.white70,
                        rightDotColor: MyTheme.redColor,
                        size: 50,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        resetAppNow();
                        cancelRideRequest();
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(width: 1.5, color: Colors.grey),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getCurrentLiveLocationOfUser() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUser = positionOfUser;
    LatLng positionOfUserInLatLng = LatLng(
        currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: positionOfUserInLatLng, zoom: 15);
    controllerGoogleMap!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    await CommonMethods.convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(
        currentPositionOfUser!, context);
    await initializeGeoFireListener();
  }
}
