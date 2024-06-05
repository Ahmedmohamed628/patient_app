import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:patient/methods/common_methods.dart';
import 'package:patient/model/prediction_model.dart';
import 'package:patient/patient_screens/Screens/Root/google_maps.dart';
import 'package:patient/patient_screens/Screens/Root/prediction_place_ui.dart';
import 'package:patient/theme/theme.dart';
import 'package:provider/provider.dart';

import '../../../app_info/app_info.dart';

class SearchDestinationPage extends StatefulWidget {
  static const String routeName = 'search-destination-page';

  @override
  State<SearchDestinationPage> createState() => _SearchDestinationPageState();
}

class _SearchDestinationPageState extends State<SearchDestinationPage> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController destinationTextEditingController =
      TextEditingController();
  List<PredictionModel> destinationPredictionsPLacesList = [];

  // (places api) place auto complete =>
  searchLocation(String locationName) async {
    if (locationName.length > 1) {
      String apiPlacesUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$locationName&key=$googleMapKey&components=country:eg";
      var responseFromPlacesAPI =
          await CommonMethods.sendRequestToAPI(apiPlacesUrl);
      if (responseFromPlacesAPI == "error") {
        return;
      }
      if (responseFromPlacesAPI["status"] == "OK") {
        var predictionResultInJson = responseFromPlacesAPI["predictions"];
        var predictionsList = (predictionResultInJson as List)
            .map((eachPlacePrediction) =>
                PredictionModel.fromJson(eachPlacePrediction))
            .toList();
        setState(() {
          destinationPredictionsPLacesList = predictionsList;
        });
        // log("predictionResultInJson ==================================================================== "+ predictionResultInJson.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String userAddress = Provider.of<AppInfo>(context, listen: false)
            .pickUpLocation!
            .humanReadableAddress ??
        "";
    pickUpTextEditingController.text = userAddress;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 10,
              child: Container(
                height: 230,
                decoration: BoxDecoration(
                  color: MyTheme.redColor,
                  boxShadow: [
                    BoxShadow(
                        color: MyTheme.redColor,
                        blurRadius: 5,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7)),
                  ],
                ),
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 24, top: 48, right: 24, bottom: 20),
                  child: Column(
                    children: [
                      SizedBox(height: 6),
                      //icon button - title
                      Stack(
                        children: [
                          GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Icon(
                                LineAwesomeIcons.angle_left,
                                color: MyTheme.whiteColor,
                              )),
                          Center(
                            child: Text(
                              'set destination location',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      //pickup textField
                      Row(
                        children: [
                          Image.asset('assets/images/initial.png',
                              height: 16, width: 16),
                          SizedBox(width: 18),
                          Expanded(
                              child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(3),
                              child: TextField(
                                controller: pickUpTextEditingController,
                                decoration: InputDecoration(
                                  hintText: 'Pick up address',
                                  fillColor: Colors.white12,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 11, top: 9, bottom: 9),
                                ),
                              ),
                            ),
                          )),
                        ],
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      // destination text field
                      Row(
                        children: [
                          Image.asset('assets/images/final.png',
                              height: 16, width: 16),
                          SizedBox(width: 18),
                          Expanded(
                              child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(3),
                              child: TextField(
                                controller: destinationTextEditingController,
                                onChanged: (inputText) {
                                  searchLocation(inputText);
                                },
                                decoration: InputDecoration(
                                  hintText: 'Destination address',
                                  fillColor: Colors.white12,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 11, top: 9, bottom: 9),
                                ),
                              ),
                            ),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //display prediction result for destination place
            (destinationPredictionsPLacesList.length > 0)
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListView.separated(
                      padding: EdgeInsets.all(0),
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 3,
                          child: PredictionPlaceUI(
                            predictedPLaceData:
                                destinationPredictionsPLacesList[index],
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          SizedBox(height: 2),
                      itemCount: destinationPredictionsPLacesList.length,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
