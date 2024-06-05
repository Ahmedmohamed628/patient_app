import 'dart:async';

import 'package:health/health.dart';

import 'healthconnectdata.dart';

List<HealthDataPoint> _healthDataList = [];

final types = dataTypesAndroid;

// final permissions = types.map((e) => HealthDataAccess.READ).toList();
// Or READ and WRITE
final permissions = types.map((e) => HealthDataAccess.READ_WRITE).toList();

// create a HealthFactory for use in the app
HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

/// Fetch data points from the health plugin and show them in the app.
Future fetchData(void Function() callBack) async {
  // get data within the last 24 hours
  final now = DateTime.now();
  final yesterday = now.subtract(Duration(hours: 24));

  // Clear old data points
  _healthDataList.clear();

  try {
    // fetch health data
    List<HealthDataPoint> healthData =
        await health.getHealthDataFromTypes(yesterday, now, types);
    // save all the new data points (only the first 100)
    _healthDataList.addAll(
        (healthData.length < 100) ? healthData : healthData.sublist(0, 100));
  } catch (error) {
    print("Exception in getHealthDataFromTypes: $error");
  }
  // filter out duplicates
  _healthDataList = HealthFactory.removeDuplicates(_healthDataList);
  // print the results
  // _healthDataList.forEach((x) => print(x));
  // update the UI to display the
  bool isLowOx = false;
  bool isLowHR = false;
  for (var healthData in _healthDataList) {
    if (healthData.type == HealthDataType.BLOOD_OXYGEN &&
        healthData.value is NumericHealthValue &&
        double.parse(healthData.value.toString()) <= 90) {
      isLowOx = true;
    }
    if (healthData.type == HealthDataType.HEART_RATE &&
        healthData.value is NumericHealthValue &&
        double.parse(healthData.value.toString()) <= 55) {
      isLowHR = true;
    }
    if (isLowOx && isLowHR) {
      callBack();
      return;
    }
  }
}
