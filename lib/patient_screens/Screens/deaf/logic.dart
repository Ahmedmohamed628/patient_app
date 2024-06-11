import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:patient/patient_screens/Screens/deaf/deaf.dart';
import 'package:tflite_v2/tflite_v2.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String answer = "";
  CameraController? cameraController;
  CameraImage? cameraImage;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  initCamera() {
    cameraController = CameraController(
      cameras![0],
      ResolutionPreset.medium,
    );

    cameraController!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      cameraController!.startImageStream((image) {
        if (cameraImage == null) {
          cameraImage = image;
          applyModelOnImages();
        }
      });
    });
  }

  applyModelOnImages() async {
    if (cameraImage != null) {
      var predictions = await Tflite.runModelOnFrame(
        bytesList: cameraImage!.planes.map((plane) => plane.bytes).toList(),
        imageHeight: cameraImage!.height,
        imageWidth: cameraImage!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults:
            10, // Ensure this matches the output tensor shape of [1, 35]
        threshold: 0.1,
        asynch: true,
      );

      // print(predictions); // Print predictions for debugging

      setState(() {
        answer = predictions?.map((prediction) {
              return "${prediction['label']} ${(prediction['confidence'] as double).toStringAsFixed(3)}";
            }).join('\n') ??
            '';
        cameraImage = null;
      });
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(cameraController!),
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
