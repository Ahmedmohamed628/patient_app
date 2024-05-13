import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'model/my_user.dart';

class FirebaseUtils {
  static CollectionReference<MyUser> getUsersCollection() {
    return FirebaseFirestore.instance
        .collection(MyUser.collectionName)
        .withConverter<MyUser>(
            fromFirestore: (snapshot, options) =>
                MyUser.fromFireStore(snapshot.data()!),
            toFirestore: (user, options) => user.toFireStore());
  }

  static Future<void> addUserToFireStore(MyUser myUser) {
    return getUsersCollection().doc(myUser.id).set(myUser);
  }

  static Future<MyUser?> readUserFromFireStore(String uId) async {
    var docSnapshot = await getUsersCollection().doc(uId).get();
    return docSnapshot.data();
  }

  // todo : mn el video>>>>>>>>>>>>>>>>>>
  // fetch users details:
  // Future<MyUser> getUserDetails(String email) async{
  //   final snapshot = await FirebaseFirestore.instance.collection(MyUser.collectionName).where('Email', isEqualTo: email).get();
  //   final userData = snapshot.docs.map((e) => MyUser.fromSnapshot(e)).single;
  //   return userData;
  //
  //
  // }

  static Future<void> updateUserRecords(MyUser myUser) async {
    await FirebaseFirestore.instance
        .collection(MyUser.collectionName)
        .doc(myUser.id)
        .update(myUser.toFireStore());
  }

  // todo: da goz2 el patient
  // static CollectionReference<Patient> getUsersCollectionPatient() {
  //   return FirebaseFirestore.instance
  //       .collection(Patient.collectionName)
  //       .withConverter<Patient>(
  //           fromFirestore: (snapshot, options) =>
  //               Patient.fromFireStore(snapshot.data()!),
  //           toFirestore: (user, options) => user.toFireStore());
  // }

// static Future<void> addUserToFireStorePatient(Patient patient){
//   return getUsersCollection().doc(patient.id).set(patient);
// }
//
// static Future<Patient?> readUserFromFireStorePatient(String uId)async{
//   var docSnapshot = await getUsersCollection().doc(uId).get();
//   return docSnapshot.data();
// }
}
