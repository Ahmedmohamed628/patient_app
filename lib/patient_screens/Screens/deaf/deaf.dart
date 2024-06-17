import 'package:flutter/material.dart';
import 'package:patient/patient_screens/Screens/deaf/logic.dart';
import 'package:patient/theme/theme.dart';
import 'package:tflite_v2/tflite_v2.dart';

class DeafScreenPatient extends StatelessWidget {
  static const String routeName = 'deaf-screen-hospital';

  @override
  Widget build(BuildContext context) {
    return FirstScreen();
  }
}

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> loadModel() async {
    Tflite.close();

    try {
      await Tflite.loadModel(
        model: "assets/detect.tflite",
        labels: "assets/labels.txt",
      );
      print("Model loaded successfully.");
    } catch (e) {
      print("Failed to load model: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.white,
      appBar: AppBar(
        backgroundColor: MyTheme.redColor,
        title: Text(
          'Sign Language',
          style: TextStyle(color: MyTheme.whiteColor),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.32,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Image.asset("assets/images/sign_lang.png"),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton(
                  onPressed: () async {
                    await loadModel();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Home(),
                      ),
                    );
                  },
                  child: Text('Start Detecting'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: MyTheme.whiteColor,
                    backgroundColor: MyTheme.redColor, // Text color
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
