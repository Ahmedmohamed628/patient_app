import 'package:flutter/material.dart';
import 'package:patient/app_info/app_info.dart';
import 'package:patient/loading_dialog.dart';
import 'package:patient/methods/common_methods.dart';
import 'package:patient/model/address_model.dart';
import 'package:patient/model/prediction_model.dart';
import 'package:patient/patient_screens/Screens/Root/google_maps.dart';
import 'package:patient/theme/theme.dart';
import 'package:provider/provider.dart';

class PredictionPlaceUI extends StatefulWidget {
  PredictionModel? predictedPLaceData;

  PredictionPlaceUI({this.predictedPLaceData});

  @override
  State<PredictionPlaceUI> createState() => _PredictionPlaceUIState();
}

class _PredictionPlaceUIState extends State<PredictionPlaceUI> {
  //place details -places api
  fetchClickedPLaceDetails(String placeID) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Getting details..."),
    );
    String urlPlaceDetailsAPI =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$googleMapKey";
    var responseFromPlaceDetailsAPI =
        await CommonMethods.sendRequestToAPI(urlPlaceDetailsAPI);
    Navigator.of(context).pop();
    if (responseFromPlaceDetailsAPI == "error") {
      return;
    }
    if (responseFromPlaceDetailsAPI["status"] == "OK") {
      AddressModel destinationLocation = AddressModel();
      destinationLocation.placeName =
          responseFromPlaceDetailsAPI["result"]["name"];
      destinationLocation.latitudePosition =
          responseFromPlaceDetailsAPI["result"]["geometry"]["location"]["lat"];
      destinationLocation.longitudePosition =
          responseFromPlaceDetailsAPI["result"]["geometry"]["location"]["lng"];
      destinationLocation.placeID = placeID;
      Provider.of<AppInfo>(context, listen: false)
          .updateDestinationLocation(destinationLocation);
      Navigator.pop(context, "placeSelected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        fetchClickedPLaceDetails(
            widget.predictedPLaceData!.place_id.toString());
      },
      child: Container(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(children: [
              Icon(
                Icons.share_location,
                color: Colors.white38,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      widget.predictedPLaceData!.main_text.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16, color: MyTheme.whiteColor),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.predictedPLaceData!.secondary_text.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.white38),
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 10),
          ],
        ),
      ),
      style: ElevatedButton.styleFrom(
          backgroundColor: MyTheme.mobileChatBoxColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    );
  }
}
