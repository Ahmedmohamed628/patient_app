import 'package:flutter/material.dart';
import 'package:patient/model/address_model.dart';

class AppInfo extends ChangeNotifier {
  AddressModel? pickUpLocation;
  AddressModel? destinationLocation;

  void updatePickUpLocation(AddressModel pickUpModel) {
    pickUpLocation = pickUpModel;
    notifyListeners();
  }

  void updateDestinationLocation(AddressModel destinationModel) {
    destinationLocation = destinationModel;
    notifyListeners();
  }
}
