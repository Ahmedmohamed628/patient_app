import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:patient/model/my_user.dart';
import 'package:patient/theme/theme.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class Prescription extends StatefulWidget {
  @override
  _PrescriptionState createState() => _PrescriptionState();
}

class _PrescriptionState extends State<Prescription> {
  List<File> _selectedFiles = [];
  List<bool> _isPDF = [];
  List<String> _fileUrls = []; // Added to track file URLs
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final userCurrent = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _initializeFiles();
  }

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
    }
  }

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

  Future<File> _downloadFile(String url, bool isPDF) async {
    try {
      final directory = await getTemporaryDirectory();
      // Extract filename without query parameters
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
          icon: Icon(Icons.menu),
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
              ElevatedButton(
                onPressed: _pickFile,
                child: Text('Add PDF/Image'),
              ),
              SizedBox(width: 20),
            ],
          ),
          Expanded(
            child: _selectedFiles.isEmpty
                ? Center(child: CircularProgressIndicator())
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
                                          style: TextStyle(color: Colors.red),
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
