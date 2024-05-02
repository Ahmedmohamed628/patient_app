import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as p;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:patient/authentication/register/register_navigator.dart';
import 'package:patient/authentication/register/register_screen_view_model.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../dialog_utils.dart';
import '../../theme/theme.dart';
import '../component/custom_text_form_field.dart';
import '../login/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = 'register-screen';
  static File? selectedImage;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    implements RegisterNavigator {
  var confirmationPasswordController = TextEditingController(text: '123456');
  RegisterScreenViewModel viewModelRegister = RegisterScreenViewModel();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    viewModelRegister.navigator = this;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyTheme.redColor,
        title: Text('Medical App', style: TextStyle(color: MyTheme.whiteColor)),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 80),
                  child: Lottie.asset('assets/images/patient_lottie.json')),
              // CircleAvatar(
              //   child: Lottie.asset('assets/images/patient_lottie.json'),
              //   radius: 70,
              //   backgroundColor: MyTheme.redColor,
              // ),
            ),
            // Image.asset('assets/images/ambulance_icon.png', alignment: Alignment.topCenter),
            Form(
                key: viewModelRegister.formKey,
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          File? file = await _pickImage();
                          if (file != null) {
                            setState(() {
                              RegisterScreen.selectedImage = file;
                            });
                          }
                        },
                        child: CircleAvatar(
                            radius: MediaQuery.of(context).size.width * 0.2,
                            child: ClipOval(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: MediaQuery.of(context).size.width * 0.4,
                                child: RegisterScreen.selectedImage != null
                                    ? Image.file(RegisterScreen.selectedImage!,
                                        fit: BoxFit.cover)
                                    : Image.asset('assets/images/user.jpg',
                                        fit: BoxFit.cover),
                              ),
                            )
                            // backgroundImage: selectedImage != null
                            //     ? FileImage(selectedImage!)
                            //     : AssetImage('assets/images/user.jpg')
                            //         as ImageProvider,
                            ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      // user name
                      CustomTextFormField(
                          prefixIcon: Icon(Icons.person_pin_sharp,
                              color: MyTheme.redColor),
                          //Icons.drive_file_rename_outline
                          label: 'User Name',
                          controller: viewModelRegister.nameController,
                          validator: (text) {
                            if (text == null || text.trim().isEmpty) {
                              return 'Please Enter User Name';
                            }
                            return null;
                          }),
                      // email
                      CustomTextFormField(
                          prefixIcon: Icon(Icons.email_rounded,
                              color: MyTheme.redColor),
                          label: 'Email address',
                          keyboardType: TextInputType.emailAddress,
                          controller: viewModelRegister.emailController,
                          validator: (text) {
                            if (text == null || text.trim().isEmpty) {
                              return 'Please Enter An Email';
                            }
                            bool emailValid = RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(text);
                            if (!emailValid) {
                              return 'Please Enter Valid Email';
                            }
                            return null;
                          }),
                      // phone
                      CustomTextFormField(
                        label: 'Phone number',
                        controller: viewModelRegister.phoneNumber,
                        prefixIcon: Icon(Icons.phone, color: MyTheme.redColor),
                        validator: (text) {
                          if (text == null || text.trim().isEmpty) {
                            return 'Please enter a phone number';
                          }
                          if (text.length < 11) {
                            return 'Enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      //address
                      CustomTextFormField(
                        label: 'Address',
                        controller: viewModelRegister.address,
                        prefixIcon:
                            Icon(Icons.home_filled, color: MyTheme.redColor),
                        validator: (text) {
                          if (text == null || text.trim().isEmpty) {
                            return 'Please enter an address';
                          }
                          // valid address???????????????????????????????????????????
                          if (text.length < 4) {
                            return 'Enter a valid address';
                          }
                          return null;
                        },
                      ),
                      //password
                      CustomTextFormField(
                        prefixIcon: Icon(Icons.lock, color: MyTheme.redColor),
                        label: 'Password',
                        keyboardType: TextInputType.number,
                        controller: viewModelRegister.passwordController,
                        validator: (text) {
                          if (text == null || text.trim().isEmpty) {
                            return 'Please Enter a password';
                          }
                          if (text.length < 6) {
                            return 'Password should be at least 6 characters';
                          }
                          return null;
                        },
                        isPassword: true,
                      ),
                      // chronic diseases
                      CustomTextFormField(
                        prefixIcon:
                            Icon(Icons.coronavirus, color: MyTheme.redColor),
                        //lock_outline_sharp
                        label: 'Chronic Disease',
                        controller: viewModelRegister.chronicDiseases,
                        validator: (text) {
                          if (text == null || text.trim().isEmpty) {
                            return 'Please enter a Chronic Diseases';
                          }
                          return null;
                        },
                      ),
                      //height
                      CustomTextFormField(
                        prefixIcon: Icon(Icons.height, color: MyTheme.redColor),
                        //lock_outline_sharp
                        label: 'Height',
                        controller: viewModelRegister.height,
                        validator: (text) {
                          if (text == null || text.trim().isEmpty) {
                            return 'Please enter your height';
                          }
                          return null;
                        },
                      ),
                      // weight
                      CustomTextFormField(
                        label: 'Weight',
                        controller: viewModelRegister.weight,
                        validator: (text) {
                          if (text == null || text.trim().isEmpty) {
                            return 'Please enter your weight';
                          }
                          return null;
                        },
                      ),
                      //age
                      CustomTextFormField(
                        label: 'Age',
                        controller: viewModelRegister.age,
                        validator: (text) {
                          if (text == null || text.trim().isEmpty) {
                            return 'Please enter your age';
                          }
                          return null;
                        },
                      ),
                      //gender
                      CustomTextFormField(
                        label: 'Gender',
                        controller: viewModelRegister.gender,
                        prefixIcon:
                            Icon(Icons.perm_identity, color: MyTheme.redColor),
                        validator: (text) {
                          if (text == null || text.trim().isEmpty) {
                            return 'Please enter your gender';
                          }
                          return null;
                        },
                      ),
                      //id
                      CustomTextFormField(
                        label: 'National Id',
                        controller: viewModelRegister.nationalId,
                        prefixIcon:
                            Icon(Icons.perm_identity, color: MyTheme.redColor),
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

                      // button of registration
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            viewModelRegister.register(context);
                            authorize();
                          },
                          child: Text('Register',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: MyTheme.redColor,
                              padding: EdgeInsets.symmetric(vertical: 10)),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already Have An Account',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500)),
                          TextButton(
                            onPressed: () {
                              // navigate to loginScreen
                              Navigator.of(context)
                                  .pushReplacementNamed(LoginScreen.routeName);
                            },
                            child: Text('Login',
                                style: TextStyle(
                                    color: MyTheme.redColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17)),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future authorize() async {
    await Permission.activityRecognition.request();
    await Permission.location.request();
  }

  @override
  void hideMyLoading() {
    // TODO: implement hideMyLoading
    DialogUtils.hideLoading(context);
  }

  @override
  void showMyLoading() {
    // TODO: implement showMyLoading
    DialogUtils.showLoading(context, 'Loading...');
  }

  @override
  void showMessage(String message) {
    // TODO: implement showMessage
    DialogUtils.showMessage(context, message,
        posActionName: 'ok', title: 'Sign-Up', barrierDismissible: false);
  }

  Future<File?> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Select Image'),
            children: <Widget>[
              SimpleDialogOption(
                child: Column(
                  children: [Icon(Icons.image), Text('Gallery')],
                ),
                onPressed: () => Navigator.pop(context, ImageSource.gallery),
              ),
              SimpleDialogOption(
                child: Column(
                  children: [Icon(Icons.camera_alt), Text('Camera')],
                ),
                onPressed: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          );
        },
      ),
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Future<File?> getImageFromGallary() async {
  //   final ImagePicker picker = ImagePicker();

  //   final XFile? file = await picker.pickImage(source: ImageSource.gallery);
  //   if (file != null) {
  //     return File(file.path);
  //   }
  //   return null;
  // }

  // Future<File?> getImageFromCamera() async {
  //   final ImagePicker picker = ImagePicker();

  //   final XFile? file = await picker.pickImage(source: ImageSource.camera);
  //   if (file != null) {
  //     return File(file.path);
  //   }
  //   return null;
  // }
}
