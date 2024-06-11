import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:patient/healthconnectdata.dart';
import 'package:patient/theme/theme.dart';

class WatchHistory extends StatefulWidget {
  // final GlobalKey<ScaffoldState> scaffoldKey;
  // const Screen2({Key? key, required this.scaffoldKey}) : super(key: key);
  @override
  State<WatchHistory> createState() => _WatchHistoryState();
}

class _WatchHistoryState extends State<WatchHistory> {
  List<HealthDataPoint> _healthDataList = [];
  final types = dataTypesAndroid;
  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

  bool _isLoading = true;
  bool _hasPermissions = true;
  final userCurrent = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    fetchData();
  }

  Future<void> uploadHealthDataToFirestore() async {
    List<String> healthDataStrings = _healthDataList.map((data) {
      return '${data.typeString}: ${data.value} at ${data.dateFrom}';
    }).toList();

    await FirebaseFirestore.instance
        .collection('patients')
        .doc(userCurrent!.uid)
        .update({'WatchHistory': FieldValue.arrayUnion(healthDataStrings)});
  }

  Future<void> requestPermissions() async {
    // Initialize the list of permissions
    List<HealthDataAccess> permissions =
        types.map((e) => HealthDataAccess.READ_WRITE).toList();

    // Request permissions
    bool hasPermissions = await health.requestAuthorization(types);
  }

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
    // Upload data to Firestore
    await uploadHealthDataToFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.redColor,
        title:
            Text('watch History', style: TextStyle(color: MyTheme.whiteColor)),
        leading: IconButton(
          icon: Icon(LineAwesomeIcons.angle_left, color: MyTheme.whiteColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
      ),
      backgroundColor: MyTheme.whiteColor,
      body: Column(
        children: [
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _healthDataList.isEmpty
                  ? Center(child: Text('No data available'))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _healthDataList.length,
                        itemBuilder: (context, index) {
                          final data = _healthDataList[index];
                          return ListTile(
                            title: Text('${data.typeString}: ${data.value}'),
                            subtitle: Text('Date: ${data.dateFrom}'),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}
