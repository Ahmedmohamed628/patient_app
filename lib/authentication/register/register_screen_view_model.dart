import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:patient/authentication/register/register_navigator.dart';
import 'package:patient/authentication/register/register_screen.dart';
import 'package:patient/patient_screens/homeScreen_patient.dart';
import '../../dialog_utils.dart';
import '../../firebase_utils.dart';
import '../../methods/common_methods.dart';
import '../../model/my_user.dart';

class RegisterScreenViewModel extends ChangeNotifier {
  static User? userSignUp;
  var emailController =
      TextEditingController(text: 'ahmed.mohamed7patient@gmail.com');
  var passwordController = TextEditingController(text: '123456');
  var nameController = TextEditingController(text: 'ahmed');
  var phoneNumber = TextEditingController(text: '01228384694');
  var address = TextEditingController(text: 'alexandria');

  // todo: da le el patient
  // var chronicDiseases = TextEditingController(text: 'corona virus');
  var height = TextEditingController(text: '171');
  var weight = TextEditingController(text: '70');
  var age = TextEditingController(text: '23');
  var gender = TextEditingController(text: 'male');
  var nationalId = TextEditingController(text: '123456789123456');

  CommonMethods cMethods = CommonMethods();
  var formKey = GlobalKey<FormState>();

  //todo: hold data - handle logic
  late RegisterNavigator navigator;
  String? pfpURL;
  //=========================================================================================================
  // Future<void> patientCollection() async {
  //   try {
  //     final databaseReference =
  //         FirebaseDatabase.instance.ref().child('patients');
  //     final snapshot = await databaseReference.once();
  //     final exists = snapshot.snapshot.exists;
  //     if (!exists) {
  //       // Collection might not exist (not guaranteed)
  //       await databaseReference.push().set({});
  //       print(
  //           'Patients collection created successfully.......................................................................................');
  //     }

  //     // Optional: Validate user data before storing (if needed)

  //     final patientMap = {
  //       "userName": FirebaseAuth.instance.currentUser!.displayName,
  //       "userPhone": FirebaseAuth.instance.currentUser!.phoneNumber,
  //       "userID": FirebaseAuth.instance.currentUser!.uid,
  //       "email": FirebaseAuth.instance.currentUser!.email,
  //     };

  //     // Create a unique document for each patient (optional)
  //     final newPatientRef = databaseReference.push();
  //     await newPatientRef.set(patientMap);
  //     print(
  //         'Patient data saved successfully!........................................... (Document ID: ${newPatientRef.key})');
  //   } catch (error) {
  //     print(
  //         'Error creating/saving patient data..............................................: $error');
  //   }
  // }

  //==========================================================================================================
  void register(BuildContext context) async {
    if (formKey.currentState?.validate() == true) {
      //todo: show loading
      navigator.showMyLoading();
      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        //========================================================================================================>>>>>>>>>
        //todo => real time database
        // final databaseReference = FirebaseDatabase.instance.ref().child('patients');
        // final snapshot = await databaseReference.child(FirebaseAuth.instance.currentUser!.uid).once();
        // final userExists = snapshot.snapshot.exists;
        //
        // if (!userExists) {
        //   // User doesn't exist in patients collection, proceed with adding data
        //   await patientCollection();
        // } else {
        //   print('User already exists in the patients collection..........................................................................');
        // }
        //===========================================================================================================>>>>>>>>

        // print(credential.user?.uid ?? '');
        userSignUp = credential.user;
        final currentstatus = userSignUp;
        if (currentstatus != null && RegisterScreen.selectedImage != null) {
          //todo => real time data base
          // DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("Patient").child(credential.user!.uid);
          // Map userDataMap = {
          //   "name": FirebaseAuth.instance.currentUser!.displayName,
          //   "email": FirebaseAuth.instance.currentUser!.email,
          //   "phone": FirebaseAuth.instance.currentUser!.phoneNumber,
          //   "id": FirebaseAuth.instance.currentUser!.uid,
          // };
          // usersRef.set(userDataMap);
          pfpURL = await uplaodPfp(
              file: RegisterScreen.selectedImage!, Uid: currentstatus.uid);
        }

        final databaseReference = FirebaseDatabase.instance
            .ref()
            .child('patients')
            .child(userSignUp!.uid);
        Map patientMap = {
          "userName": nameController.text,
          "userPhone": phoneNumber.text,
          "userID": userSignUp!.uid,
          "email": emailController.text,
        };
        databaseReference.set(patientMap);

        MyUser myUser = MyUser(
          phoneNumber: phoneNumber.text,
          address: address.text,
          id: credential.user?.uid ?? '',
          name: nameController.text,
          email: emailController.text,
          nationalId: nationalId.text,
          // chronicDiseases: chronicDiseases.text,
          height: height.text,
          weight: weight.text,
          age: age.text,
          gender: gender.text,
          pfpURL: pfpURL ?? null,
          createdAt: Timestamp.now(),
          chronicDiseases: null,
          WatchHistory: null, prescription: null,
        );

        // var authProvider = Provider.of<AuthProvider>(context,listen: false);
        // authProvider.updateUser(myUser);

        await FirebaseUtils.addUserToFireStore(myUser);
        //todo: hide loading
        navigator.hideMyLoading();

        //todo: show message
        // navigator.showMessage('Register Successfully');
        DialogUtils.showMessage(context, 'Register Successfully',
            title: 'Sign-Up', posActionName: 'ok', posAction: () {
          Navigator.of(context)
              .pushReplacementNamed(HomeScreenPatient.routeName);
        });
      } on FirebaseAuthException catch (e) {
        // print('this error is unknown ${e.code}');
        if (e.code == 'weak-password') {
          //todo: hide loading
          navigator.hideMyLoading();
          //todo: show message
          navigator.showMessage('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          //todo: hide loading
          navigator.hideMyLoading();
          //todo: show message
          navigator.showMessage('The account already exists for that email.');
        } else if (e.code == 'network-request-failed') {
          //todo: hide loading
          navigator.hideMyLoading();
          //todo: show message
          // navigator.showMessage('Your internet is not available. Check your connection and try again.');
          cMethods.displaySnackBar(
              'Your internet is not available. Check your connection and try again.',
              context);
        }
      } catch (e) {
        //todo: hide loading
        navigator.hideMyLoading();
        //todo: show message
        navigator.showMessage(e.toString());
      }
    }
  }

  Future<String?> uplaodPfp({required File file, required String Uid}) async {
    final firebaseStorage = FirebaseStorage.instance;
    Reference fileRef = firebaseStorage
        .ref('users/pfps')
        .child("${Uid}${p.extension(file.path)}");
    UploadTask task = fileRef.putFile(file);
    return task.then((p0) {
      if (p0.state == TaskState.success) {
        return fileRef.getDownloadURL();
      }
      return null;
    });
  }
}
