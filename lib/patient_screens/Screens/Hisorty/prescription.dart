import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:patient/model/my_user.dart';
import 'package:patient/theme/theme.dart';

class Prescription extends StatefulWidget {
  @override
  _PrescriptionState createState() => _PrescriptionState();
}

class _PrescriptionState extends State<Prescription> {
  List<File> _selectedFiles = []; // List to store selected files
  List<bool> _isPDF = []; // List to store whether each file is a PDF
  List<String> _fileUrls = []; // List to store URLs of files
  final FirebaseStorage _storage =
      FirebaseStorage.instance; // Firebase Storage instance
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance
  final userCurrent = FirebaseAuth.instance.currentUser; // Current user
  bool _isLoading = true; // Flag to indicate if files are being loaded

  @override
  void initState() {
    super.initState();
    _initializeFiles(); // Initialize files on startup
  }

  // Initialize files by fetching URLs from Firestore and downloading them
  Future<void> _initializeFiles() async {
    try {
      log('Initializing files...');
      List<String> fileUrls = await _getUserFiles();
      log('Fetched file URLs: $fileUrls');
      for (String fileUrl in fileUrls) {
        bool isPDF = fileUrl.toLowerCase().contains('.pdf');
        log('_initializeFiles Downloading file from URL: $fileUrl');
        File downloadedFile = await _downloadFile(fileUrl, isPDF);
        log('_initializeFiles Downloaded file: ${downloadedFile.path}');
        setState(() {
          _selectedFiles.add(downloadedFile);
          _isPDF.add(isPDF);
          _fileUrls.add(fileUrl); // Track the file URL
        });
      }
    } catch (e) {
      log('Error initializing files: $e');
    } finally {
      setState(() {
        _isLoading = false; // Set loading to false after initialization
      });
    }
  }

  // Pick a file using FilePicker and upload it to Firebase
  Future<void> _pickFile() async {
    try {
      log('Picking file...');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        File file = File(result.files.single.path!);
        bool isPDF = result.files.single.extension == 'pdf';
        log('Uploading file: ${file.path}');
        String fileUrl = await _uploadFile(file);

        if (fileUrl.isNotEmpty) {
          setState(() {
            _selectedFiles.add(file);
            _isPDF.add(isPDF);
            _fileUrls.add(fileUrl); // Track the file URL
          });

          log('Saving file URL: $fileUrl');
          await _saveFileUrl(fileUrl);
        }
      }
    } catch (e) {
      log('Error picking file: $e');
    }
  }

  // Upload file to Firebase Storage and return the download URL
  Future<String> _uploadFile(File file) async {
    try {
      String fileName =
          'uploads/${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      log('Uploading file with name: $fileName');
      TaskSnapshot snapshot = await _storage.ref(fileName).putFile(file);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      log('File uploaded. Download URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      log('File upload error: $e');
      return '';
    }
  }

  // Save file URL to Firestore under the current user's document
  Future<void> _saveFileUrl(String fileUrl) async {
    try {
      if (fileUrl.isNotEmpty) {
        DocumentReference userDoc =
            _firestore.collection(MyUser.collectionName).doc(userCurrent!.uid);
        log('Updating Firestore with file URL: $fileUrl');
        await userDoc.update({
          'prescription': FieldValue.arrayUnion([fileUrl])
        });
        log('File URL saved to Firestore');
      }
    } catch (e) {
      log('Error saving file URL: $e');
    }
  }

  // Get list of file URLs from Firestore for the current user
  Future<List<String>> _getUserFiles() async {
    try {
      log('Fetching user files from Firestore...');
      DocumentSnapshot userDoc = await _firestore
          .collection(MyUser.collectionName)
          .doc(userCurrent!.uid)
          .get();

      MyUser user =
          MyUser.fromFireStore(userDoc.data() as Map<String, dynamic>);
      log('Fetched user files: ${user.prescription}');
      return user.prescription ?? [];
    } catch (e) {
      log('Error fetching user files: $e');
      return [];
    }
  }

  // Download file from a given URL and save it to a temporary directory
  Future<File> _downloadFile(String url, bool isPDF) async {
    try {
      final directory = await getTemporaryDirectory();
      final filename = path.basename(Uri.parse(url).path);
      final filePath = path.join(directory.path, filename);
      log('Temporary file path: $filePath');

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        log('File downloaded to: $filePath');
        return file;
      } else {
        throw Exception('Failed to download file');
      }
    } catch (e) {
      log('Error downloading file: $e');
      rethrow;
    }
  }

  // Delete a file from both Firebase Storage and Firestore
  Future<void> _deleteFile(int index) async {
    try {
      String fileUrl = _fileUrls[index];
      log('Deleting file URL: $fileUrl');
      DocumentReference userDoc =
          _firestore.collection(MyUser.collectionName).doc(userCurrent!.uid);
      await userDoc.update({
        'prescription': FieldValue.arrayRemove([fileUrl])
      });
      log('File URL removed from Firestore');

      // Remove file from storage
      await _storage.refFromURL(fileUrl).delete();
      log('File removed from Firebase Storage');

      // Remove file from the UI
      setState(() {
        _selectedFiles.removeAt(index);
        _isPDF.removeAt(index);
        _fileUrls.removeAt(index);
      });
    } catch (e) {
      log('Error deleting file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.redColor,
        title: Text('History', style: TextStyle(color: MyTheme.whiteColor)),
        leading: IconButton(
          icon: Icon(LineAwesomeIcons.angle_left, color: MyTheme.whiteColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: _pickFile,
                  child: Text('Add PDF/Image'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: MyTheme.whiteColor,
                    backgroundColor: MyTheme.redColor, // Text color
                  ),
                ),
              ),
              SizedBox(width: 20),
            ],
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _selectedFiles.isEmpty
                    ? Container(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(60.0),
                              child: Text(
                                "No previous prescription added",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            Center(
                              child: Lottie.asset(
                                  'assets/images/prescription3.json'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _selectedFiles.length,
                        itemBuilder: (context, index) {
                          bool isPDF = _isPDF[index];
                          File file = _selectedFiles[index];

                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: isPDF
                                      ? Container(
                                          height: 400,
                                          child: PDFView(
                                            filePath: file.path,
                                            enableSwipe: true,
                                            swipeHorizontal: true,
                                            autoSpacing: false,
                                            pageFling: false,
                                            onRender: (_pages) {
                                              setState(() {});
                                            },
                                            onError: (error) {
                                              log(error.toString());
                                            },
                                            onPageError: (page, error) {
                                              log('$page: ${error.toString()}');
                                            },
                                          ),
                                        )
                                      : Image.file(
                                          file,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Text(
                                              'Failed to load image',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            );
                                          },
                                        ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _deleteFile(index);
                                  },
                                ),
                              ],
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
