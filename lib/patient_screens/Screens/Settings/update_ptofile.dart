// import 'dart:html';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:patient/authentication/component/custom_text_form_field.dart';
import 'package:patient/model/my_user.dart';

import '../../../methods/common_methods.dart';
import '../../../theme/theme.dart';

///////////////////////////// //////////////////////

class ProfilePage extends StatefulWidget {
  static const String routeName = 'update-profile-screen';
  static File? selectedImage;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  CommonMethods cMethods = CommonMethods();
  final _formKey = GlobalKey<FormState>();
  MyUser? _user;
  final userId = FirebaseAuth.instance.currentUser!.uid;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _chronicDiseasesController =
      TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    MyUser? fetchedUser = await fetchUserFromFirestore(userId);
    setState(() {
      _user = fetchedUser;
      _nameController.text = _user!.name ?? '';
      _emailController.text = _user!.email ?? '';
      _phoneNumberController.text = _user!.phoneNumber ?? '';
      _addressController.text = _user!.address ?? '';
      _nationalIdController.text = _user!.nationalId ?? '';
      _chronicDiseasesController.text = _user!.chronicDiseases ?? '';
      _heightController.text = _user!.height ?? '';
      _weightController.text = _user!.weight ?? '';
      _ageController.text = _user!.age ?? '';
      _genderController.text = _user!.gender ?? '';
    });
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Update user object with new values
      if (_user != null) {
        _user!.name = _nameController.text;
        _user!.email = _emailController.text;
        _user!.phoneNumber = _phoneNumberController.text;
        // _user!.address = _addressController.text;
        _user!.nationalId = _nationalIdController.text;
        _user!.chronicDiseases = _chronicDiseasesController.text;
        _user!.height = _heightController.text;
        _user!.weight = _weightController.text;
        _user!.age = _ageController.text;
        _user!.gender = _genderController.text;

        try {
          if (ProfilePage.selectedImage != null) {
            String? imageUrl = await _uploadImage(ProfilePage.selectedImage!);
            if (imageUrl != null) {
              _user!.pfpURL = imageUrl;
            }
          }
          await updateUserInFirestore(_user!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User data updated successfully')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update user data')),
          );
        }
      }
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      // Create a unique file name based on userId and timestamp
      String fileName =
          'profile_pictures/$userId/${DateTime.now().millisecondsSinceEpoch}${p.extension(imageFile.path)}';
      // Reference to the Firebase Storage location
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      // Upload the image file
      UploadTask uploadTask = storageRef.putFile(imageFile);
      // Wait for the upload to complete
      TaskSnapshot taskSnapshot = await uploadTask;
      // Get the download URL
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _changePassword() async {
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFormField(
                label: 'Current Password',
                controller: currentPasswordController,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              CustomTextFormField(
                label: 'New Password',
                controller: newPasswordController,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your new password';
                  }
                  return null;
                },
              ),
              CustomTextFormField(
                label: 'Confirm New Password',
                controller: confirmPasswordController,
                isPassword: true,
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (currentPasswordController.text.isNotEmpty &&
                    newPasswordController.text.isNotEmpty &&
                    newPasswordController.text ==
                        confirmPasswordController.text) {
                  try {
                    User user = FirebaseAuth.instance.currentUser!;
                    String email = user.email!;
                    AuthCredential credential = EmailAuthProvider.credential(
                        email: email, password: currentPasswordController.text);

                    await user.reauthenticateWithCredential(credential);
                    await user.updatePassword(newPasswordController.text);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password changed successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error changing password: $e')),
                    );
                  }
                }
              },
              child: Text('Change Password'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(LineAwesomeIcons.angle_left)),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.save),
        //     onPressed: _saveForm,
        //   ),
        // ],
      ),
      body: _user == null
          ? Center(child: CircularProgressIndicator(color: MyTheme.redColor))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        File? file = await _pickImage();
                        if (file != null) {
                          setState(() {
                            ProfilePage.selectedImage = file;
                          });
                        }
                      },
                      child: CircleAvatar(
                        radius: MediaQuery.of(context).size.width * 0.2,
                        child: Stack(
                          children: [
                            ClipOval(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: MediaQuery.of(context).size.width * 0.4,
                                child: ProfilePage.selectedImage != null
                                    ? Image.file(ProfilePage.selectedImage!,
                                        fit: BoxFit.cover)
                                    : _user!.pfpURL != null
                                        ? Image.network(_user!.pfpURL!,
                                            fit: BoxFit.cover)
                                        : Image.asset('assets/images/user.jpg',
                                            fit: BoxFit.cover),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.04,
                                width: MediaQuery.of(context).size.width * 0.08,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: MyTheme.redColor),
                                child: Icon(LineAwesomeIcons.alternate_pencil,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    CustomTextFormField(
                      label: 'Name',
                      controller: _nameController,
                      validator: (text) {
                        if (text == null || text.trim().isEmpty) {
                          return 'Please Enter User Name';
                        }
                        return null;
                      },
                    ),
                    // CustomTextFormField(
                    //   label: 'Email',
                    //   controller: _emailController,
                    //   keyboardType: TextInputType.emailAddress,
                    //   validator: (text) {
                    //     if (text == null || text.trim().isEmpty) {
                    //       return 'Please Enter An Email';
                    //     }
                    //     bool emailValid = RegExp(
                    //             r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    //         .hasMatch(text);
                    //     if (!emailValid) {
                    //       return 'Please Enter Valid Email';
                    //     }
                    //     return null;
                    //   },
                    // ),
                    CustomTextFormField(
                      label: 'Phone Number',
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
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
                    CustomTextFormField(
                      label: 'Address',
                      controller: _addressController,
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
                    CustomTextFormField(
                      label: 'National ID',
                      controller: _nationalIdController,
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
                    CustomTextFormField(
                      label: 'Chronic Diseases',
                      controller: _chronicDiseasesController,
                      validator: (text) {
                        if (text == null || text.trim().isEmpty) {
                          return 'Please enter a Chronic Diseases';
                        }
                        return null;
                      },
                    ),
                    CustomTextFormField(
                      label: 'Height',
                      controller: _heightController,
                      validator: (text) {
                        if (text == null || text.trim().isEmpty) {
                          return 'Please enter your Height';
                        }
                        return null;
                      },
                    ),
                    CustomTextFormField(
                      label: 'Weight',
                      controller: _weightController,
                      validator: (text) {
                        if (text == null || text.trim().isEmpty) {
                          return 'Please enter your Weight';
                        }
                        return null;
                      },
                    ),
                    CustomTextFormField(
                      label: 'Age',
                      controller: _ageController,
                      validator: (text) {
                        if (text == null || text.trim().isEmpty) {
                          return 'Please enter your Age';
                        }
                        return null;
                      },
                    ),
                    CustomTextFormField(
                      label: 'Gender',
                      controller: _genderController,
                      validator: (text) {
                        if (text == null || text.trim().isEmpty) {
                          return 'Please enter your Gender';
                        }
                        return null;
                      },
                    ),
                    //change password
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 3),
                      child: ElevatedButton(
                        onPressed: _changePassword,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.change_circle,
                                color: MyTheme.whiteColor,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.02,
                              ),
                              Text('Change Password',
                                  style: TextStyle(
                                      color: MyTheme.whiteColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                            ]),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: MyTheme.messageColor,
                            padding: EdgeInsets.symmetric(vertical: 10)),
                        // Text('Change Password'),
                      ),
                    ),
                    //confirm changes
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 3),
                      child: ElevatedButton(
                        onPressed: () {
                          _saveForm();
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.02,
                              ),
                              Text('Confirm changes',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                            ]),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: MyTheme.redColor,
                            padding: EdgeInsets.symmetric(vertical: 10)),
                      ),
                    ),
                    //delete
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                    //   child: ElevatedButton(
                    //     onPressed: () {
                    //       // delete the account
                    //       DialogUtils.showMessage(context,
                    //         'Are you sure to delete this account?.',
                    //         title: 'Delete account',
                    //         barrierDismissible: false,
                    //         posActionName: 'yes',
                    //         posAction: () {
                    //
                    //           cMethods.displaySnackBar('Email has been deleted successfully.', context);
                    //         },
                    //         negActionName: 'no',
                    //         negAction: () {},
                    //       );
                    //     },
                    //     child: Row(
                    //         mainAxisAlignment:
                    //         MainAxisAlignment.center,
                    //         children: [
                    //           Icon(Icons.delete_forever),
                    //           SizedBox(width: MediaQuery.of(context).size.width *0.02,),
                    //           Text('Delete this account',
                    //               style: TextStyle(
                    //                   color: Colors.white,
                    //                   fontWeight: FontWeight.w600,
                    //                   fontSize: 15)),
                    //         ]),
                    //     style: ElevatedButton.styleFrom(
                    //         backgroundColor: MyTheme.searchBarColor,
                    //         padding:
                    //         EdgeInsets.symmetric(vertical: 10)),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
    );
  }

  // Widget _buildTextFormField({
  //   required String? initialValue,
  //   required String label,
  //   TextInputType keyboardType = TextInputType.text,
  //   required FormFieldSetter<String?> onSaved,
  // }) {
  //   return TextFormField(
  //     initialValue: initialValue,
  //     decoration: InputDecoration(labelText: label),
  //     keyboardType: keyboardType,
  //     validator: (value) {
  //       if (value == null || value.isEmpty) {
  //         return 'Please enter $label';
  //       }
  //       return null;
  //     },
  //     onSaved: onSaved,
  //   );
  // }

  Future<void> updateUserInFirestore(MyUser user) async {
    try {
      DocumentReference userRef = FirebaseFirestore.instance
          .collection(MyUser.collectionName)
          .doc(user.id);

      await userRef.update(user.toFireStore());
      print('User data updated successfully');
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  Future<MyUser?> fetchUserFromFirestore(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection(MyUser.collectionName)
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return MyUser.fromFireStore(userDoc.data() as Map<String, dynamic>);
      } else {
        print('User not found');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  Future<File?> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: await showDialog(
        context: this.context,
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
}



///////////////////////////working 1////////////////

////////////////////////test2/////////////////////////////

// class UpdateProfileScreen extends StatefulWidget {
//   static const String routeName = 'update-profile-screen';

//   @override
//   State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
// }

// class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
//   // RegisterScreenViewModel viewModelRegister = RegisterScreenViewModel();

//   final userCurrent = FirebaseAuth.instance.currentUser;
//   MyUser? userdata;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _fetchUserData();
//   }

//   Future<void> _fetchUserData() async {
//     userdata = await getUserDetails(userCurrent!.uid);
//     setState(() {}); // Update the state after fetching the data
//   }


//   @override
//   Widget build(BuildContext context) {
//     // return FutureBuilder<QuerySnapshot>(
//     //   future: messages.get(),
//     return Scaffold(
//       appBar: AppBar(
//           title: Text("profile", style: TextStyle(color: MyTheme.whiteColor)),
//           centerTitle: true,
//           backgroundColor: MyTheme.redColor),
//       body: Container(
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage('assets/images/chat_list2.jpg'),
//               fit: BoxFit.cover, // Adjust as needed (cover, contain, etc.)
//             ),
//           ),
//           child: profilebody()),
//     );
//   }

//   Widget profilebody() {
//     return Container(
//       child: TextButton(
//           onPressed: () {
//             log(userdata!.address.toString());
//             log(userdata!.age.toString());
//             log(userdata!.chronicDiseases.toString());
//             log(userdata!.email.toString());
//             log(userdata!.gender.toString());
//             log(userdata!.height.toString());
//             log(userdata!.name.toString());
//             log(userdata!.nationalId.toString());
//             log(userdata!.pfpURL.toString());
//             log(userdata!.phoneNumber.toString());
//             log(userdata!.weight.toString());
//           },
//           child: Text("data test ")),
//     );
//   }

//   Future<MyUser?> getUserDetails(String id) async {
//     var usersnapshot = await FirebaseFirestore.instance
//         .collection(MyUser.collectionName)
//         .withConverter(
//             fromFirestore: (snapshot, options) =>
//                 MyUser.fromFireStore(snapshot.data()!),
//             toFirestore: (user, options) => user.toFireStore())
//         .where("id", isEqualTo: id)
//         .get();
//     log(usersnapshot.toString());

//     // Correctly map each document snapshot to a MyUser object
//     var userdata = usersnapshot.docs
//         .map((doc) => MyUser.fromFireStore(doc.data().toFireStore()));

//     return userdata.single;
//   }

// Future<MyUser?> fetchUserFromFirestore(String userId) async {
//   try {
//     // Reference to the specific user document in the Firestore collection
//     DocumentSnapshot userDoc = await FirebaseFirestore.instance
//         .collection(MyUser.collectionName)
//         .doc(userId)
//         .get();

//     if (userDoc.exists) {
//       // Convert the document data to a MyUser object
//       return MyUser.fromFireStore(userDoc.data() as Map<String, dynamic>);
//     } else {
//       print('User not found');
//       return null;
//     }
//   } catch (e) {
//     print('Error fetching user data: $e');
//     return null;
//   }
// }

// Future<void> updateUserInFirestore(MyUser user) async {
//   try {
//     // Reference to the specific user document in the Firestore collection
//     DocumentReference userRef = FirebaseFirestore.instance
//         .collection(MyUser.collectionName)
//         .doc(user.id);

//     // Convert the user object to a map and update the Firestore document
//     await userRef.update(user.toFireStore());
//     print('User data updated successfully');
//   } catch (e) {
//     print('Error updating user data: $e');
//   }
// }}

////////////////////////test2/////////////////////////////
///
///
///
///////////////////////////test3/////////////////////////////not working
///deleted
////////////////////////test3//////////////////////////////
///
///
//////////////////////////////test4//////////////////////////////not working
//////deleted
////////////////////////test4//////////////////////////////
///
///
///
//////////////////////////////test5//////////////////////////////not working
//////deleted
////////////////////////test5//////////////////////////////
///
///
//////////////////////////////test6//////////////////////////////not working
//////deleted

////////////////////////test6//////////////////////////////


  // Future<List<MyUser?>> getUserDetails(String id) async {
  //   var usersnapshot = await FirebaseFirestore.instance
  //       .collection(MyUser.collectionName)
  //       .withConverter(
  //           fromFirestore: (snapshot, options) =>
  //               MyUser.fromFireStore(snapshot.data()!),
  //           toFirestore: (user, options) => user.toFireStore())
  //       .where("id", isEqualTo: id)
  //       .get();
  //   log(usersnapshot.toString());

  //   // var userdata =
  //   //     usersnapshot.docs.map((doc) => MyUser.fromFireStore(doc.data()));
  // var userdata = usersnapshot.docs.map((doc) => MyUser.fromFireStore(doc.data())).toList();

  //   // final userdata = usersnapshot.docs
  //   //     .map((doc) => MyUser.fromFireStore(doc.data() as Map<String, dynamic>));
  //   log(userdata.toString());
  // return userdata.isNotEmpty? userdata : [];
  // }
// }

  // var snapshots = FirebaseFirestore.instance
  //     .collection(MyUser.collectionName)
  //     .withConverter(
  //         fromFirestore: (snapshot, options) =>
  //             MyUser.fromFireStore(snapshot.data()!),
  //         toFirestore: (user, options) => user.toFireStore())
  //     .where("id", isEqualTo: currentUser!.id).get();

  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: MyTheme.whiteColor,
  //     appBar: AppBar(
  //       backgroundColor: MyTheme.redColor,
  //       title:
  //           Text('Edit Profile', style: TextStyle(color: MyTheme.whiteColor)),
  //       centerTitle: true,
  //       leading: IconButton(
  //           onPressed: () {
  //             Navigator.of(context).pop(ProfileScreen.routeName);
  //           },
  //           icon: Icon(LineAwesomeIcons.angle_left, color: MyTheme.whiteColor)),
  //     ),
  //     body: SingleChildScrollView(
  //       child: Container(
  //         padding: const EdgeInsets.all(20),
  //         child: StreamBuilder(
  //           stream: snapshots,
  //           // stream: FirebaseFirestore.instance
  //           //     .collection(MyUser.collectionName)
  //           //     .doc(currentUser.email)
  //           //     .snapshots(),
  //           builder: (context, snapshot) as{
  //             // if (snapshot.connectionState == ConnectionState.done) {
  //             if (snapshot.hasData && snapshot.data != null) {

  //               log("connectionState");

  //               final userData = snapshot.docs;
  //               // log(userData.toString());
  //               return Column(children: [
  //                 Stack(children: [
  //                   SizedBox(
  //                     width: MediaQuery.of(context).size.width * 0.3,
  //                     height: MediaQuery.of(context).size.height * 0.15,
  //                     child: GestureDetector(
  //                       onTap: () async {
  //                         File? file = await _pickImage();
  //                         if (file != null) {
  //                           setState(() {
  //                             UpdateProfileScreen.selectedImage = file;
  //                           });
  //                         }
  //                       },
  //                       child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(100),
  //                         child: UpdateProfileScreen.selectedImage != null
  //                             ? Image.file(UpdateProfileScreen.selectedImage!,
  //                                 fit: BoxFit.cover)
  //                             : Image.asset('assets/images/user.jpg',
  //                                 fit: BoxFit.cover),
  //                         // Image(image: AssetImage('assets/images/user.jpg'),
  //                       ),
  //                     ),
  //                   ),
  //                   Positioned(
  //                     bottom: 0,
  //                     right: 0,
  //                     child: Container(
  //                       height: MediaQuery.of(context).size.height * 0.04,
  //                       width: MediaQuery.of(context).size.width * 0.08,
  //                       decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.circular(100),
  //                           color: MyTheme.redColor),
  //                       child: Icon(LineAwesomeIcons.camera,
  //                           color: Colors.white, size: 20),
  //                     ),
  //                   ),
  //                 ]),
  //                 SizedBox(height: MediaQuery.of(context).size.height * 0.02),
  //                 Form(
  //                     key: viewModelRegister.formKey,
  //                     child: Container(
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.stretch,
  //                         children: [
  //                           SizedBox(
  //                               height:
  //                                   MediaQuery.of(context).size.height * 0.01),
  //                           // user name
  //                           CustomTextFormField(
  //                               prefixIcon: Icon(Icons.person_pin_sharp,
  //                                   color: MyTheme.redColor),
  //                               //Icons.drive_file_rename_outline
  //                               label: 'User Name',
  //                               controller: viewModelRegister.nameController,
  //                               validator: (text) {
  //                                 if (text == null || text.trim().isEmpty) {
  //                                   return 'Please Enter User Name';
  //                                 }
  //                                 return null;
  //                               }),
  //                           // email
  //                           CustomTextFormField(
  //                               prefixIcon: Icon(Icons.email_rounded,
  //                                   color: MyTheme.redColor),
  //                               label: 'Email address',
  //                               keyboardType: TextInputType.emailAddress,
  //                               controller: viewModelRegister.emailController,
  //                               validator: (text) {
  //                                 if (text == null || text.trim().isEmpty) {
  //                                   return 'Please Enter An Email';
  //                                 }
  //                                 bool emailValid = RegExp(
  //                                         r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
  //                                     .hasMatch(text);
  //                                 if (!emailValid) {
  //                                   return 'Please Enter Valid Email';
  //                                 }
  //                                 return null;
  //                               }),
  //                           // phone
  //                           CustomTextFormField(
  //                             label: 'Phone number',
  //                             controller: viewModelRegister.phoneNumber,
  //                             prefixIcon:
  //                                 Icon(Icons.phone, color: MyTheme.redColor),
  //                             validator: (text) {
  //                               if (text == null || text.trim().isEmpty) {
  //                                 return 'Please enter a phone number';
  //                               }
  //                               if (text.length < 11) {
  //                                 return 'Enter a valid phone number';
  //                               }
  //                               return null;
  //                             },
  //                           ),
  //                           //address
  //                           CustomTextFormField(
  //                             label: 'Address',
  //                             controller: viewModelRegister.address,
  //                             prefixIcon: Icon(Icons.home_filled,
  //                                 color: MyTheme.redColor),
  //                             validator: (text) {
  //                               if (text == null || text.trim().isEmpty) {
  //                                 return 'Please enter an address';
  //                               }
  //                               // valid address???????????????????????????????????????????
  //                               if (text.length < 4) {
  //                                 return 'Enter a valid address';
  //                               }
  //                               return null;
  //                             },
  //                           ),
  //                           //password
  //                           CustomTextFormField(
  //                             prefixIcon:
  //                                 Icon(Icons.lock, color: MyTheme.redColor),
  //                             label: 'Password',
  //                             keyboardType: TextInputType.number,
  //                             controller: viewModelRegister.passwordController,
  //                             validator: (text) {
  //                               if (text == null || text.trim().isEmpty) {
  //                                 return 'Please Enter a password';
  //                               }
  //                               if (text.length < 6) {
  //                                 return 'Password should be at least 6 characters';
  //                               }
  //                               return null;
  //                             },
  //                             isPassword: true,
  //                           ),
  //                           // chronic diseases
  //                           CustomTextFormField(
  //                             prefixIcon: Icon(Icons.coronavirus,
  //                                 color: MyTheme.redColor),
  //                             //lock_outline_sharp
  //                             label: 'Chronic Disease',
  //                             controller: viewModelRegister.chronicDiseases,
  //                             validator: (text) {
  //                               if (text == null || text.trim().isEmpty) {
  //                                 return 'Please enter a Chronic Diseases';
  //                               }
  //                               return null;
  //                             },
  //                           ),
  //                           //height
  //                           CustomTextFormField(
  //                             prefixIcon:
  //                                 Icon(Icons.height, color: MyTheme.redColor),
  //                             //lock_outline_sharp
  //                             label: 'Height',
  //                             controller: viewModelRegister.height,
  //                             validator: (text) {
  //                               if (text == null || text.trim().isEmpty) {
  //                                 return 'Please enter your height';
  //                               }
  //                               return null;
  //                             },
  //                           ),
  //                           // weight
  //                           CustomTextFormField(
  //                             prefixIcon: Icon(LineAwesomeIcons.weight,
  //                                 color: MyTheme.redColor),
  //                             label: 'Weight',
  //                             controller: viewModelRegister.weight,
  //                             validator: (text) {
  //                               if (text == null || text.trim().isEmpty) {
  //                                 return 'Please enter your weight';
  //                               }
  //                               return null;
  //                             },
  //                           ),
  //                           //age
  //                           CustomTextFormField(
  //                             label: 'Age',
  //                             controller: viewModelRegister.age,
  //                             validator: (text) {
  //                               if (text == null || text.trim().isEmpty) {
  //                                 return 'Please enter your age';
  //                               }
  //                               return null;
  //                             },
  //                           ),
  //                           //gender
  //                           CustomTextFormField(
  //                             label: 'Gender',
  //                             controller: viewModelRegister.gender,
  //                             prefixIcon: Icon(Icons.perm_identity,
  //                                 color: MyTheme.redColor),
  //                             validator: (text) {
  //                               if (text == null || text.trim().isEmpty) {
  //                                 return 'Please enter your gender';
  //                               }
  //                               return null;
  //                             },
  //                           ),
  //                           //id
  //                           CustomTextFormField(
  //                             label: 'National Id',
  //                             controller: viewModelRegister.nationalId,
  //                             prefixIcon: Icon(
  //                                 LineAwesomeIcons.identification_card,
  //                                 color: MyTheme.redColor),
  //                             validator: (text) {
  //                               if (text == null || text.trim().isEmpty) {
  //                                 return 'Please enter your national id';
  //                               }
  //                               if (text.length < 14) {
  //                                 return 'Enter a valid national id';
  //                               }
  //                               return null;
  //                             },
  //                           ),

  //                           // button of registration
  //                           Padding(
  //                             padding: const EdgeInsets.symmetric(
  //                                 horizontal: 20, vertical: 10),
  //                             child: ElevatedButton(
  //                               onPressed: () {},
  //                               child: Row(
  //                                   mainAxisAlignment: MainAxisAlignment.center,
  //                                   children: [
  //                                     Icon(Icons.check_circle,
  //                                         color: Colors.white),
  //                                     SizedBox(
  //                                       width:
  //                                           MediaQuery.of(context).size.width *
  //                                               0.02,
  //                                     ),
  //                                     Text('Confirm changes',
  //                                         style: TextStyle(
  //                                             color: Colors.white,
  //                                             fontWeight: FontWeight.w600,
  //                                             fontSize: 15)),
  //                                   ]),
  //                               style: ElevatedButton.styleFrom(
  //                                   backgroundColor: MyTheme.redColor,
  //                                   padding:
  //                                       EdgeInsets.symmetric(vertical: 10)),
  //                             ),
  //                           ),
  //                           Padding(
  //                             padding: const EdgeInsets.symmetric(
  //                                 horizontal: 20, vertical: 10),
  //                             child: ElevatedButton(
  //                               onPressed: () {},
  //                               child: Row(
  //                                   mainAxisAlignment: MainAxisAlignment.center,
  //                                   children: [
  //                                     Icon(Icons.delete_forever),
  //                                     SizedBox(
  //                                       width:
  //                                           MediaQuery.of(context).size.width *
  //                                               0.02,
  //                                     ),
  //                                     Text('Delete this account',
  //                                         style: TextStyle(
  //                                             color: Colors.white,
  //                                             fontWeight: FontWeight.w600,
  //                                             fontSize: 15)),
  //                                   ]),
  //                               style: ElevatedButton.styleFrom(
  //                                   backgroundColor: MyTheme.searchBarColor,
  //                                   padding:
  //                                       EdgeInsets.symmetric(vertical: 10)),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     )),
  //               ]);
  //             } else if (snapshot.hasError) {
  //               return Center(child: Text(snapshot.error.toString()));
  //             } else {
  //               return Center(child: Text('Something went wrong'));
  //             }
  //             // } else {
  //             //   return Center(
  //             //       child: CircularProgressIndicator(color: MyTheme.redColor));
  //             // }
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Future<File?> _pickImage() async {
  //   final ImagePicker picker = ImagePicker();
  //   final XFile? pickedFile = await picker.pickImage(
  //     source: await showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return SimpleDialog(
  //           title: Text('Select Image'),
  //           children: <Widget>[
  //             SimpleDialogOption(
  //               child: Column(
  //                 children: [Icon(Icons.image), Text('Gallery')],
  //               ),
  //               onPressed: () => Navigator.pop(context, ImageSource.gallery),
  //             ),
  //             SimpleDialogOption(
  //               child: Column(
  //                 children: [Icon(Icons.camera_alt), Text('Camera')],
  //               ),
  //               onPressed: () => Navigator.pop(context, ImageSource.camera),
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  //   if (pickedFile != null) {
  //     return File(pickedFile.path);
  //   }
  //   return null;
  // }
// class _ChatScreenPatientState extends State<ChatScreenPatient> {
//   @override
//   Widget build(BuildContext context) {
//     // return FutureBuilder<QuerySnapshot>(
//     //   future: messages.get(),
//     return Scaffold(
//       appBar: AppBar(
//           title: Text("Chat", style: TextStyle(color: MyTheme.whiteColor)),
//           centerTitle: true,
//           backgroundColor: MyTheme.redColor),
//       body: Container(
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage('assets/images/chat_list2.jpg'),
//               fit: BoxFit.cover, // Adjust as needed (cover, contain, etc.)
//             ),
//           ),
//           child: _chatList()),
//     );
//   }
// }

// Widget _chatList() {
//   var snapshots = FirebaseFirestore.instance
//       .collection("Hospitals")
//       .withConverter(
//           fromFirestore: (snapshot, options) =>
//               MyHospital.fromFireStore(snapshot.data()!),
//           toFirestore: (user, options) => user.toFireStore())
//       .snapshots();
//   return StreamBuilder(
//     stream: snapshots,
//     builder: (context, snapshot) {
//       if (snapshot.hasError) {
//         return Center(child: Text("no data"));
//       }
//       if (snapshot.hasData && snapshot.data != null) {
//         final users = snapshot.data!.docs;
//         final userCurrent = FirebaseAuth.instance.currentUser;
//         return ListView.builder(
//             itemCount: users.length,
//             itemBuilder: (context, Index) {
//               MyHospital user = users[Index].data();
//               return ChatTile(
//                   user: user,
//                   onTap: () async {
//                     final chatExists =
//                         await checkChatExists(userCurrent!.uid, user.id!);
//                     print(chatExists);
//                     if (!chatExists) {
//                       await createNewChat(userCurrent.uid, user.id!);
//                     }
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (context) {
//                           return PrivateChat(
//                             chatuser: user,
//                           );
//                         },
//                       ),
//                     );
//                     //02:56 -- 41 00
//                   });
//             });
//       }
//       return Center(child: CircularProgressIndicator());
//     },
//   );
// }

// var snapshots = FirebaseFirestore.instance
//     .collection(MyUser.collectionName)
//     .withConverter(
//         fromFirestore: (snapshot, options) =>
//             MyUser.fromFireStore(snapshot.data()!),
//         toFirestore: (user, options) => user.toFireStore())
//     .where("id", isEqualTo: currentUser!.id)
//     .get();
