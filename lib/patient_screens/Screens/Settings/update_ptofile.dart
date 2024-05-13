// import 'dart:html';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:patient/model/my_user.dart';
import 'package:patient/patient_screens/Screens/Settings/Settings.dart';

import '../../../authentication/component/custom_text_form_field.dart';
import '../../../authentication/register/register_screen_view_model.dart';
import '../../../theme/theme.dart';

class UpdateProfileScreen extends StatefulWidget {
  static const String routeName = 'update-profile-screen';
  static File? selectedImage;

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  RegisterScreenViewModel viewModelRegister = RegisterScreenViewModel();
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.whiteColor,
      appBar: AppBar(
        backgroundColor: MyTheme.redColor,
        title:
            Text('Edit Profile', style: TextStyle(color: MyTheme.whiteColor)),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(ProfileScreen.routeName);
            },
            icon: Icon(LineAwesomeIcons.angle_left, color: MyTheme.whiteColor)),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection(MyUser.collectionName)
                .doc(currentUser.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return Column(children: [
                    Stack(children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: MediaQuery.of(context).size.height * 0.15,
                        child: GestureDetector(
                          onTap: () async {
                            File? file = await _pickImage();
                            if (file != null) {
                              setState(() {
                                UpdateProfileScreen.selectedImage = file;
                              });
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: UpdateProfileScreen.selectedImage != null
                                ? Image.file(UpdateProfileScreen.selectedImage!,
                                    fit: BoxFit.cover)
                                : Image.asset('assets/images/user.jpg',
                                    fit: BoxFit.cover),
                            // Image(image: AssetImage('assets/images/user.jpg'),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.04,
                          width: MediaQuery.of(context).size.width * 0.08,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: MyTheme.redColor),
                          child: Icon(LineAwesomeIcons.camera,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ]),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Form(
                        key: viewModelRegister.formKey,
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.01),
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
                                prefixIcon:
                                    Icon(Icons.phone, color: MyTheme.redColor),
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
                                prefixIcon: Icon(Icons.home_filled,
                                    color: MyTheme.redColor),
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
                                prefixIcon:
                                    Icon(Icons.lock, color: MyTheme.redColor),
                                label: 'Password',
                                keyboardType: TextInputType.number,
                                controller:
                                    viewModelRegister.passwordController,
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
                                prefixIcon: Icon(Icons.coronavirus,
                                    color: MyTheme.redColor),
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
                                prefixIcon:
                                    Icon(Icons.height, color: MyTheme.redColor),
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
                                prefixIcon: Icon(LineAwesomeIcons.weight,
                                    color: MyTheme.redColor),
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
                                prefixIcon: Icon(Icons.perm_identity,
                                    color: MyTheme.redColor),
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
                                prefixIcon: Icon(
                                    LineAwesomeIcons.identification_card,
                                    color: MyTheme.redColor),
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
                                  onPressed: () {},
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle,
                                            color: Colors.white),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.02,
                                        ),
                                        Text('Confirm changes',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15)),
                                      ]),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: MyTheme.redColor,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.delete_forever),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.02,
                                        ),
                                        Text('Delete this account',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15)),
                                      ]),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: MyTheme.searchBarColor,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10)),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ]);
                } else if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                } else {
                  return Center(child: Text('Something went wrong'));
                }
              } else {
                return Center(
                    child: CircularProgressIndicator(color: MyTheme.redColor));
              }
            },
          ),
        ),
      ),
    );
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

  getUserData() {}

// updateUser(MyUser myUser)async{
//   await
//
// }
}
