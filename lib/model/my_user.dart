import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  static const String collectionName = 'patients';
  String? id;
  String? email;
  String? name;
  String? phoneNumber;
  String? address;
  String? nationalId;
  List<String>? chronicDiseases;
  List<String>? WatchHistory;
  String? height;
  String? weight;
  String? age;
  String? gender;
  String? pfpURL;
  Timestamp? createdAt;
  List<String>? prescription;

  MyUser({
    required this.id,
    required this.phoneNumber,
    required this.address,
    required this.name,
    required this.email,
    required this.nationalId,
    required this.chronicDiseases,
    required this.WatchHistory,
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    required this.pfpURL,
    required this.createdAt,
    required this.prescription,
  });

  MyUser.fromFireStore(Map<String, dynamic> data)
      : this(
          id: data['id'],
          phoneNumber: data['phoneNumber'],
          address: data['address'],
          email: data['email'],
          name: data['name'],
          nationalId: data['nationalId'],
          chronicDiseases: List<String>.from(data['chronicDiseases'] ?? []),
          WatchHistory: List<String>.from(data['WatchHistory'] ?? []),
          height: data['height'],
          weight: data['weight'],
          age: data['age'],
          gender: data['gender'],
          pfpURL: data['pfpURL'],
          createdAt: data['createdAt'],
          prescription: List<String>.from(data['prescription'] ?? []),
        );

  Map<String, dynamic> toFireStore() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'address': address,
      'name': name,
      'email': email,
      'nationalId': nationalId,
      'chronicDiseases': chronicDiseases ?? [],
      'WatchHistory': WatchHistory ?? [],
      'height': height,
      'weight': weight,
      'age': age,
      'gender': gender,
      'pfpURL': pfpURL,
      'createdAt': createdAt,
      'prescription': prescription ?? [],
    };
  }
}

class MyHospital {
  static const String collectionName = 'Hospitals';
  String? id;
  String? email;
  String? hospitalName;
  String? phoneNumber;
  String? address;
  String? doctorId;
  String? doctorName;
  String? gender;
  bool? status;
  String? pfpURL;
  Timestamp? createdAt;

  MyHospital(
      {required this.id,
      required this.phoneNumber,
      required this.address,
      required this.hospitalName,
      required this.email,
      required this.doctorId,
      required this.doctorName,
      required this.gender,
      required this.status,
      required this.pfpURL,
      required this.createdAt});

  MyHospital.fromFireStore(Map<String, dynamic> data)
      : this(
          id: data['id'],
          phoneNumber: data['phoneNumber'],
          address: data['address'],
          hospitalName: data['hospitalName'],
          email: data['email'],
          doctorId: data['doctorId'],
          doctorName: data['doctorName'],
          gender: data['gender'],
          status: data['status'],
          pfpURL: data['pfpURL'],
          createdAt: data['createdAt'],
        );

  Map<String, dynamic> toFireStore() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'address': address,
      'hospitalName': hospitalName,
      'email': email,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'gender': gender,
      'status': status,
      'pfpURL': pfpURL,
      'createdAt': createdAt,
    };
  }
}









// class Patient {
//   static const String collectionName = 'patient';
//   String? nationalId;
//   String? id;
//   String? chronicDiseases;
//   String? height;
//   String? weight;
//   String? age;
//   String? gender;

//   Patient(
//       {required this.nationalId,
//       required this.id,
//       required this.chronicDiseases,
//       required this.height,
//       required this.weight,
//       required this.age,
//       required this.gender});

//   Patient.fromFireStore(Map<String, dynamic> data)
//       : this(
//             nationalId: data['nationalId'],
//             id: data['id'],
//             chronicDiseases: data['chronicDiseases'],
//             height: data['height'],
//             weight: data['weight'],
//             age: data['age'],
//             gender: data['gender']);

//   Map<String, dynamic> toFireStore() {
//     return {
//       'nationalId': nationalId,
//       'id': id,
//       'chronicDiseases': chronicDiseases,
//       'height': height,
//       'weight': weight,
//       'age': age,
//       'gender': gender
//     };
//   }
// }

// class Observer {
//   static const String collectionName = 'observer';
//   String? nationalId;
//   String? id;
//   String? email;
//   String? name;
//   String? age;
//   String? gender;

//   Observer(
//       {required this.nationalId,
//       required this.id,
//       required this.email,
//       required this.name,
//       required this.age,
//       required this.gender});

//   Observer.fromFireStore(Map<String, dynamic> data)
//       : this(
//             nationalId: data['nationalId'],
//             id: data['id'],
//             email: data['email'],
//             name: data['name'],
//             age: data['age'],
//             gender: data['gender']);

//   Map<String, dynamic> toFireStore() {
//     return {
//       'nationalId': nationalId,
//       'id': id,
//       'name': name,
//       'email': email,
//       'age': age,
//       'gender': gender
//     };
//   }
// }

// class Hospital {
//   static const String collectionName = 'Hospital';
//   String? doctorId;
//   String? id;
//   String? email;
//   String? doctorName;
//   String? gender;

//   Hospital(
//       {required this.doctorId,
//       required this.id,
//       required this.email,
//       required this.doctorName,
//       required this.gender});

//   Hospital.fromFireStore(Map<String, dynamic> data)
//       : this(
//             doctorId: data['doctorId'],
//             id: data['id'],
//             email: data['email'],
//             doctorName: data['doctorName'],
//             gender: data['gender']);

//   Map<String, dynamic> toFireStore() {
//     return {
//       'doctorId': doctorId,
//       'id': id,
//       'doctorName': doctorName,
//       'email': email,
//       'gender': gender
//     };
//   }
// }
