import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:patient/app_info/app_info.dart';
import 'package:patient/methods/common_methods.dart';
import 'package:patient/patient_screens/Screens/Root/search_destination_page.dart';
import 'package:patient/theme/theme.dart';
import 'package:provider/provider.dart';

import '../../../loading_dialog.dart';
import '../../../model/direction_details.dart';

String googleMapKey = 'AIzaSyDGoIsHdQjW9hidXSdbW3xS4YqKVGfYJGI';

class GoogleMapScreen extends StatefulWidget {
  static const String routeName = 'google-maps-screen';

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  // String googleMapKey = 'AIzaSyDGoIsHdQjW9hidXSdbW3xS4YqKVGfYJGI';
  Position? currentPositionOfUser;
  double searchContainerHeight = 276;
  double bottomMapPadding = 0;
  double rideDetailsContainerHeight = 0;
  DirectionDetails? tripDirectionDetailsInfo;
  CommonMethods cMethods = CommonMethods();

  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();

  GoogleMapController? controllerGoogleMap;

  // todo: el 3 functions dool ms2oleen 3n t8eer google maps theme (updateMapTheme, getJsonFileFromTheme, setGoogleMapStyle)
  // void updateMapTheme(GoogleMapController controller){
  //   getJsonFileFromTheme("theme/google_map_retro_style.json").then((value)=> setGoogleMapStyle(value, controller));
  // }
  // Future<String> getJsonFileFromTheme(String mapStylePath)async{
  //   ByteData byteData = await rootBundle.load(mapStylePath);
  //   var list = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
  //   return utf8.decode(list);
  // }
  // setGoogleMapStyle(String googleMapStyle, GoogleMapController controller){
  //   controller.setMapStyle(googleMapStyle);
  // }

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
  }

  @override
  Widget build(BuildContext context) {
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
            initialCameraPosition: googlePlexInitialPosition,
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController mapController) {
              controllerGoogleMap = mapController;
              // updateMapTheme(controllerGoogleMap!);
              googleMapCompleterController.complete(controllerGoogleMap);
              getCurrentLiveLocationOfUser();
            },
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
                        log("destinationLocation ================================================================" +
                            destinationLocation);
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
          // ride details container
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
                                    onTap: () {},
                                    child: Lottie.asset(
                                        'assets/images/ambulance_come2.json',
                                        height: 130,
                                        width: 130),
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
  }
}
