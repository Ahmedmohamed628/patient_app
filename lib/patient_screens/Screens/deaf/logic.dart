import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:patient/main.dart';
import 'package:patient/theme/theme.dart';
import 'package:tflite_v2/tflite_v2.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String answer = "";
  CameraController? cameraController;
  CameraImage? cameraImage;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  // Initialize the camera
  Future<void> initCamera() async {
    cameraController = CameraController(
      cameras![0], // Use the first camera from the list of available cameras
      ResolutionPreset.medium, // Set the camera resolution
    );

    try {
      await cameraController!.initialize(); // Initialize the camera controller
      if (!mounted) return; // Ensure the widget is still mounted
      setState(() {}); // Update the state to reflect the initialization
      cameraController!.startImageStream((image) {
        if (!isProcessing) {
          isProcessing =
              true; // Set the flag to indicate that processing is ongoing
          cameraImage = image; // Set the current frame to the camera image
          applyModelOnImages(); // Apply the model on the current frame
        }
      });
    } catch (e) {
      print("Failed to initialize camera: $e");
    }
  }

  // Apply the model on the camera images
  Future<void> applyModelOnImages() async {
    if (cameraImage != null) {
      try {
        var predictions = await Tflite.runModelOnFrame(
          bytesList: cameraImage!.planes.map((plane) => plane.bytes).toList(),
          imageHeight: cameraImage!.height,
          imageWidth: cameraImage!.width,
          imageMean: 127.5,
          imageStd: 127.5,
          rotation: 90,
          numResults: 10,
          threshold: 0.1,
          asynch: true,
        );

        if (predictions != null) {
          setState(() {
            answer = predictions.map((prediction) {
              return "${prediction['label']} ${(prediction['confidence'] as double).toStringAsFixed(3)}";
            }).join('\n');
          });
        } else {
          print("No predictions returned from the model.");
        }
      } catch (e) {
        print("Failed to run model on frame: $e");
      } finally {
        isProcessing =
            false; // Reset the flag to indicate that processing is done
      }
    } else {
      print("Camera image is null.");
    }
  }

  @override
  void dispose() {
    if (cameraController != null || cameraController!.value.isInitialized) {
      cameraController!.stopImageStream(); // Stop the image stream
      cameraController!.dispose(); // Dispose of the camera controller
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: Center(
          child:
              CircularProgressIndicator(), // Show a loading indicator while the camera is initializing
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.redColor,
        centerTitle: true,
        title: Text(
          'Sign Language',
          style: TextStyle(color: MyTheme.whiteColor),
        ),
        leading: IconButton(
          icon: Icon(LineAwesomeIcons.angle_left, color: MyTheme.whiteColor),
          onPressed: () {
            Tflite.close(); // Ensure Tflite is closed properly
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child:
                CameraPreview(cameraController!), // Display the camera preview
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: EdgeInsets.all(10),
              child: Text(
                answer,
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
