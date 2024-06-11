// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:health/health.dart';
// import 'package:patient/authentication/component/custom_text_form_field.dart';
// import 'package:patient/healthconnectdata.dart';
// import 'package:patient/healthconnectmethodes.dart';
// import '../../../theme/theme.dart';
// import 'package:firebase_core/firebase_core.dart';

// class HistoryScreenPatient extends StatefulWidget {
//   static const String routeName = 'History-screen';

//   @override
//   _HistoryScreenPatientState createState() => _HistoryScreenPatientState();
// }

// class _HistoryScreenPatientState extends State<HistoryScreenPatient> {
//   List<HealthDataPoint> _healthDataList = [];
//   final types = dataTypesAndroid;
//   final TextEditingController _diseaseController = TextEditingController();
//   List<String> _diseases = [];
//   final userCurrent = FirebaseAuth.instance.currentUser;

//   HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

//   bool _isLoading = true;
//   bool _hasPermissions = false;

//   @override
//   void initState() {
//     super.initState();
//     requestPermissions();
//     fetchData();
//     fetchDiseases();
//   }

//   Future<void> requestPermissions() async {
//     // Initialize the list of permissions
//     List<HealthDataAccess> permissions =
//         types.map((e) => HealthDataAccess.READ_WRITE).toList();

//     // Request permissions
//     bool hasPermissions = await health.requestAuthorization(types);
//   }

//   Future<void> fetchData() async {
//     // get data within the last 24 hours
//     final now = DateTime.now();
//     final yesterday = now.subtract(Duration(hours: 24));

//     // Clear old data points
//     _healthDataList.clear();

//     try {
//       // fetch health data
//       List<HealthDataPoint> healthData =
//           await health.getHealthDataFromTypes(yesterday, now, types);
//       // save all the new data points (only the first 100)
//       _healthDataList.addAll(
//           (healthData.length < 100) ? healthData : healthData.sublist(0, 100));
//     } catch (error) {
//       print("Exception in getHealthDataFromTypes: $error");
//     }
//     // filter out duplicates
//     _healthDataList = HealthFactory.removeDuplicates(_healthDataList);

//     // Update the UI
//     setState(() {
//       _isLoading = false;
//     });
//     // Upload data to Firestore
//     await uploadHealthDataToFirestore();
//   }

//   Future<void> fetchDiseases() async {
//     final doc = await FirebaseFirestore.instance
//         .collection('patients')
//         .doc(userCurrent!.uid)
//         .get();
//     if (doc.exists) {
//       setState(() {
//         _diseases = List<String>.from(doc.data()?['chronicDiseases'] ?? []);
//       });
//     }
//   }

//   Future<void> _addDisease() async {
//     if (_diseaseController.text.isNotEmpty) {
//       final newDisease = _diseaseController.text;

//       await FirebaseFirestore.instance
//           .collection('patients')
//           .doc(userCurrent!.uid)
//           .update({
//         'chronicDiseases': FieldValue.arrayUnion([newDisease])
//       });

//       setState(() {
//         _diseases.add(newDisease);
//         _diseaseController.clear();
//       });
//     }
//   }

//   Future<void> _editDisease(String oldDisease, String newDisease) async {
//     if (newDisease.isNotEmpty) {
//       await FirebaseFirestore.instance
//           .collection('patients')
//           .doc(userCurrent!.uid)
//           .update({
//         'chronicDiseases': FieldValue.arrayRemove([oldDisease])
//       });
//       await FirebaseFirestore.instance
//           .collection('patients')
//           .doc(userCurrent!.uid)
//           .update({
//         'chronicDiseases': FieldValue.arrayUnion([newDisease])
//       });

//       setState(() {
//         _diseases[_diseases.indexOf(oldDisease)] = newDisease;
//       });
//     }
//   }

//   Future<void> _deleteDisease(String disease) async {
//     await FirebaseFirestore.instance
//         .collection('patients')
//         .doc(userCurrent!.uid)
//         .update({
//       'chronicDiseases': FieldValue.arrayRemove([disease])
//     });

//     setState(() {
//       _diseases.remove(disease);
//     });
//   }

//   Future<void> uploadHealthDataToFirestore() async {
//     List<String> healthDataStrings = _healthDataList.map((data) {
//       return '${data.typeString}: ${data.value} at ${data.dateFrom}';
//     }).toList();

//     await FirebaseFirestore.instance
//         .collection('patients')
//         .doc(userCurrent!.uid)
//         .update({'WatchHistory': FieldValue.arrayUnion(healthDataStrings)});
//   }

//   void _showEditDiseaseDialog(String oldDisease) {
//     final TextEditingController _editController =
//         TextEditingController(text: oldDisease);

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Edit Disease'),
//           content: CustomTextFormField(
//             prefixIcon: Icon(Icons.coronavirus, color: MyTheme.redColor),
//             label: 'Chronic Disease',
//             controller: _editController,
//             validator: (text) {
//               if (text == null || text.trim().isEmpty) {
//                 return 'Please enter a Chronic Diseases';
//               }
//               return null;
//             },
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 _editDisease(oldDisease, _editController.text);
//                 Navigator.of(context).pop();
//               },
//               child: Text('Save'),
//               style: ElevatedButton.styleFrom(
//                 foregroundColor: MyTheme.whiteColor,
//                 backgroundColor: MyTheme.redColor, // Text color
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyTheme.redColor,
//         title: Text('History', style: TextStyle(color: MyTheme.whiteColor)),
//         centerTitle: true,
//       ),
//       backgroundColor: MyTheme.whiteColor,
//       body: Column(
//         children: [
//           Column(
//             children: [
//               CustomTextFormField(
//                 prefixIcon: Icon(Icons.coronavirus, color: MyTheme.redColor),
//                 label: 'Chronic Disease',
//                 controller: _diseaseController,
//                 validator: (text) {
//                   if (text == null || text.trim().isEmpty) {
//                     return 'Please enter a Chronic Diseases';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 10),
//               ElevatedButton(
//                 onPressed: _addDisease,
//                 child: Text('Add Disease'),
//                 style: ElevatedButton.styleFrom(
//                   foregroundColor: MyTheme.whiteColor,
//                   backgroundColor: MyTheme.redColor, // Text color
//                 ),
//               ),
//             ],
//           ),
//           _diseases.isEmpty
//               ? Text('No diseases added')
//               : Expanded(
//                   child: ListView.builder(
//                     itemCount: _diseases.length,
//                     itemBuilder: (context, index) {
//                       return ListTile(
//                         title: Text(_diseases[index]),
//                         trailing: PopupMenuButton<String>(
//                           onSelected: (String value) {
//                             if (value == 'Edit') {
//                               _showEditDiseaseDialog(_diseases[index]);
//                             } else if (value == 'Delete') {
//                               _deleteDisease(_diseases[index]);
//                             }
//                           },
//                           itemBuilder: (BuildContext context) {
//                             return {'Edit', 'Delete'}.map((String choice) {
//                               return PopupMenuItem<String>(
//                                 value: choice,
//                                 child: Text(choice),
//                               );
//                             }).toList();
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//           Text(
//             'Smart watch data',
//             style: TextStyle(fontSize: 40, color: MyTheme.redColor),
//           ),
//           _isLoading
//               ? Center(child: CircularProgressIndicator())
//               : _healthDataList.isEmpty
//                   ? Center(child: Text('No data available'))
//                   : Expanded(
//                       child: ListView.builder(
//                         itemCount: _healthDataList.length,
//                         itemBuilder: (context, index) {
//                           final data = _healthDataList[index];
//                           return ListTile(
//                             title: Text('${data.typeString}: ${data.value}'),
//                             subtitle: Text('Date: ${data.dateFrom}'),
//                           );
//                         },
//                       ),
//                     ),
//         ],
//       ),
//     );
//   }
// }
