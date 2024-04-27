import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

import '../authentication/component/custom_text_form_field.dart';
import '../authentication/register/register_screen_view_model.dart';
import '../theme/theme.dart';
import 'homeScreen_patient.dart';

class ScreenPatientRegisteration extends StatelessWidget {
  static const String routeName = 'screen-patient';

  // var formKey = GlobalKey<FormState>();
  RegisterScreenViewModel viewModelRegister = RegisterScreenViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.whiteColor,
      appBar: AppBar(
        backgroundColor: MyTheme.redColor,
        title: Text('Patient', style: TextStyle(color: MyTheme.whiteColor)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: viewModelRegister.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 70),
                  child: Lottie.asset('assets/images/patient_lottie.json')),
              //chronic diseases
              CustomTextFormField(
                label: 'Chronic Diseases',
                controller: viewModelRegister.chronicDiseases,
                // mlhash suffixation icon???????????????????????????
                // ezay a5ly el diseases optional????????????????????????????
                validator: (text) {
                  if (text == null || text.trim().isEmpty) {
                    return 'Please enter a Chronic Diseases';
                  }
                  // valid address???????????????????????????????????????????
                  // if (text.length < 12) {
                  //   return 'Enter a valid address';
                  // }
                  return null;
                },
              ),
              //height
              CustomTextFormField(
                label: 'Height',
                controller: viewModelRegister.height,
                prefixIcon: Icon(Icons.height, color: MyTheme.redColor),
                validator: (text) {
                  if (text == null || text.trim().isEmpty) {
                    return 'Please enter your height';
                  }
                  return null;
                },
              ),
              //weight
              CustomTextFormField(
                label: 'Weight', controller: viewModelRegister.weight,
                // mlhash suffixation icon??????????????????????????
                validator: (text) {
                  if (text == null || text.trim().isEmpty) {
                    return 'Please enter your weight';
                  }
                  return null;
                },
              ),
              //age
              CustomTextFormField(
                label: 'Age', controller: viewModelRegister.age,
                // mlhash suffixation icon??????????????????????????
                validator: (text) {
                  if (text == null || text.trim().isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
              ),
              //gender
              CustomTextFormField(
                label: 'Gender', controller: viewModelRegister.gender,
                // mlhash suffixation icon??????????????????????????
                prefixIcon: Icon(Icons.perm_identity, color: MyTheme.redColor),
                validator: (text) {
                  if (text == null || text.trim().isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
              ),
              //id
              CustomTextFormField(
                label: 'National Id',
                controller: viewModelRegister.nationalId,
                prefixIcon: Icon(Icons.perm_identity, color: MyTheme.redColor),
                validator: (text) {
                  if (text == null || text.trim().isEmpty) {
                    return 'Please enter your national id';
                  }
                  if (text.length < 14) {
                    return 'Enter a valid national id';
                  }
                  return null;
                },
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: ElevatedButton(
                  onPressed: () {
                    // navigate to home screen patient
                    // viewModelRegister.register(context);
                    Navigator.of(context)
                        .pushReplacementNamed(HomeScreenPatient.routeName);
                    authorize();
                  },
                  child: Text('Done',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 17)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: MyTheme.redColor,
                      padding: EdgeInsets.symmetric(vertical: 10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future authorize() async {
  await Permission.activityRecognition.request();
  await Permission.location.request();
}
