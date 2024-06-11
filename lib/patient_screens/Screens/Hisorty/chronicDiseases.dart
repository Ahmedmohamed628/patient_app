import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:patient/authentication/component/custom_text_form_field.dart';
import 'package:patient/theme/theme.dart';

class ChronicDiseas extends StatefulWidget {
  // final GlobalKey<ScaffoldState> scaffoldKey;
  // const Screen1({Key? key, required this.scaffoldKey}) : super(key: key);

  @override
  State<ChronicDiseas> createState() => _ChronicDiseasState();
}

class _ChronicDiseasState extends State<ChronicDiseas> {
  final TextEditingController _diseaseController = TextEditingController();
  List<String> _diseases = [];
  final userCurrent = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    fetchDiseases();
  }

  Future<void> fetchDiseases() async {
    final doc = await FirebaseFirestore.instance
        .collection('patients')
        .doc(userCurrent!.uid)
        .get();
    if (doc.exists) {
      setState(() {
        _diseases = List<String>.from(doc.data()?['chronicDiseases'] ?? []);
      });
    }
  }

  Future<void> _addDisease() async {
    if (_diseaseController.text.isNotEmpty) {
      final newDisease = _diseaseController.text;

      await FirebaseFirestore.instance
          .collection('patients')
          .doc(userCurrent!.uid)
          .update({
        'chronicDiseases': FieldValue.arrayUnion([newDisease])
      });

      setState(() {
        _diseases.add(newDisease);
        _diseaseController.clear();
      });
    }
  }

  Future<void> _editDisease(String oldDisease, String newDisease) async {
    if (newDisease.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(userCurrent!.uid)
          .update({
        'chronicDiseases': FieldValue.arrayRemove([oldDisease])
      });
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(userCurrent!.uid)
          .update({
        'chronicDiseases': FieldValue.arrayUnion([newDisease])
      });

      setState(() {
        _diseases[_diseases.indexOf(oldDisease)] = newDisease;
      });
    }
  }

  Future<void> _deleteDisease(String disease) async {
    await FirebaseFirestore.instance
        .collection('patients')
        .doc(userCurrent!.uid)
        .update({
      'chronicDiseases': FieldValue.arrayRemove([disease])
    });

    setState(() {
      _diseases.remove(disease);
    });
  }

  void _showEditDiseaseDialog(String oldDisease) {
    final TextEditingController _editController =
        TextEditingController(text: oldDisease);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Disease'),
          content: CustomTextFormField(
            prefixIcon: Icon(Icons.coronavirus, color: MyTheme.redColor),
            label: 'Chronic Disease',
            controller: _editController,
            validator: (text) {
              if (text == null || text.trim().isEmpty) {
                return 'Please enter a Chronic Diseases';
              }
              return null;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _editDisease(oldDisease, _editController.text);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                foregroundColor: MyTheme.whiteColor,
                backgroundColor: MyTheme.redColor, // Text color
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // key: widget.scaffoldKey,
      // appBar: AppBar(
      //   backgroundColor: MyTheme.redColor,
      //   title: Text('History', style: TextStyle(color: MyTheme.whiteColor)),
      //   leading: IconButton(
      //     icon: Icon(Icons.menu),
      //     onPressed: () {
      //       widget.scaffoldKey.currentState?.openDrawer();
      //     },
      //   ),
      //   centerTitle: true,
      // ),
      backgroundColor: MyTheme.whiteColor,
      body: Column(
        children: [
          CustomTextFormField(
            prefixIcon: Icon(Icons.coronavirus, color: MyTheme.redColor),
            label: 'Chronic Disease',
            controller: _diseaseController,
            validator: (text) {
              if (text == null || text.trim().isEmpty) {
                return 'Please enter a Chronic Diseases';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _addDisease,
            child: Text('Add Disease'),
            style: ElevatedButton.styleFrom(
              foregroundColor: MyTheme.whiteColor,
              backgroundColor: MyTheme.redColor, // Text color
            ),
          ),
          _diseases.isEmpty
              ? Text('No diseases added')
              : Expanded(
                  child: ListView.builder(
                    itemCount: _diseases.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_diseases[index]),
                        trailing: PopupMenuButton<String>(
                          onSelected: (String value) {
                            if (value == 'Edit') {
                              _showEditDiseaseDialog(_diseases[index]);
                            } else if (value == 'Delete') {
                              _deleteDisease(_diseases[index]);
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return {'Edit', 'Delete'}.map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(choice),
                              );
                            }).toList();
                          },
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
