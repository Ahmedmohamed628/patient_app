import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:patient/authentication/register/register_navigator.dart';
import 'package:patient/patient_screens/homeScreen_patient.dart';

import '../../dialog_utils.dart';
import '../../firebase_utils.dart';
import '../../methods/common_methods.dart';
import '../../model/my_user.dart';

class RegisterScreenViewModel extends ChangeNotifier {
  var emailController = TextEditingController(text: 'ahmed.mohamed7@gmail.com');
  var passwordController = TextEditingController(text: '123456');
  var nameController = TextEditingController(text: 'ahmed');
  var phoneNumber = TextEditingController(text: '01228384694');
  var address = TextEditingController(text: 'alexandria');

  // todo: da le el patient
  var chronicDiseases = TextEditingController();
  var height = TextEditingController();
  var weight = TextEditingController();
  var age = TextEditingController();
  var gender = TextEditingController();
  var nationalId = TextEditingController();

  CommonMethods cMethods = CommonMethods();
  var formKey = GlobalKey<FormState>();

  //todo: hold data - handle logic
  late RegisterNavigator navigator;

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
        // print(credential.user?.uid ?? '');
        MyUser myUser = MyUser(
            phoneNumber: phoneNumber.text,
            address: address.text,
            id: credential.user?.uid ?? '',
            name: nameController.text,
            email: emailController.text,
            nationalId: nationalId.text,
            chronicDiseases: chronicDiseases.text,
            height: height.text,
            weight: weight.text,
            age: age.text,
            gender: gender.text);
        // var authProvider = Provider.of<AuthProvider>(context,listen: false);
        // authProvider.updateUser(myUser);

        //todo: lw 3ayz a3ml patient
        // Patient patient = Patient(
        //     nationalId: nationalId.text,
        //     id: credential.user?.uid??'',
        //     phoneNumber:phoneNumber.text,
        //     address: address.text,
        //     email: emailController.text,
        //     name: nameController.text,
        //     chronicDiseases: chronicDiseases.text,
        //     height: height.text,
        //     weight: weight.text,
        //     age: age.text,
        //     gender: gender.text);
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
}
