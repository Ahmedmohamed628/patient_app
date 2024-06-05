import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:patient/healthconnectdata.dart';
import 'package:patient/healthconnectmethodes.dart';
import '../../../theme/theme.dart';

class HistoryScreenPatient extends StatefulWidget {
  static const String routeName = 'History-screen';

  @override
  _HistoryScreenPatientState createState() => _HistoryScreenPatientState();
}

class _HistoryScreenPatientState extends State<HistoryScreenPatient> {
  List<HealthDataPoint> _healthDataList = [];
  final types = dataTypesAndroid;

  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

  bool _isLoading = true;
  bool _hasPermissions = true;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    fetchData();
  }

  Future<void> requestPermissions() async {
    // Initialize the list of permissions
    List<HealthDataAccess> permissions =
        types.map((e) => HealthDataAccess.READ_WRITE).toList();

    // Request permissions
    bool hasPermissions = await health.requestAuthorization(types);
  }

  // void initializePermissions() {
  //   permissions = types.map((e) => HealthDataAccess.READ_WRITE).toList();
  // }

  /// Fetch data points from the health plugin and show them in the app.
  Future<void> fetchData() async {
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

    // Update the UI
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.redColor,
        title: Text('History', style: TextStyle(color: MyTheme.whiteColor)),
        centerTitle: true,
      ),
      backgroundColor: MyTheme.whiteColor,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _healthDataList.isEmpty
              ? Center(child: Text('No data available'))
              : ListView.builder(
                  itemCount: _healthDataList.length,
                  itemBuilder: (context, index) {
                    final data = _healthDataList[index];
                    return ListTile(
                      title: Text('${data.typeString}: ${data.value}'),
                      subtitle: Text('Date: ${data.dateFrom}'),
                    );
                  },
                ),
    );
  }
}
