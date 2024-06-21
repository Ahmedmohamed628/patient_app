import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { Text, Image }

class Message {
  String? senderID;
  String? content;
  MessageType? messageType;
  Timestamp? sentAt;
  bool? seen; //test seen

  Message({
    required this.senderID,
    required this.content,
    required this.messageType,
    required this.sentAt,
    this.seen = false, // Default to false test seen
  });

  Message.fromJson(Map<String, dynamic> json) {
    senderID = json['senderID'];
    content = json['content'];
    sentAt = json['sentAt'];
    messageType = MessageType.values.byName(json['messageType']);
    seen =
        json['seen'] ?? false; // Default to false if not present for old chats
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['senderID'] = senderID;
    data['content'] = content;
    data['sentAt'] = sentAt;
    data['messageType'] = messageType!.name;
    data['seen'] = seen; // test seen

    return data;
  }
}
  // MyUser.fromFireStore(Map<String, dynamic> data)
  //     : this(
  //         id: data['id'],
  //         phoneNumber: data['phoneNumber'],
  //         address: data['address'],
  //         hospitalName: data['HospitalName'],
  //         email: data['email'],
  //         doctorId: data['doctorId'],
  //         doctorName: data['doctorName'],
  //         gender: data['gender'],
  //         status: data['status'],
  //       );

  // Map<String, dynamic> toFireStore() {
  //   return {
  //     'id': id,
  //     'phoneNumber': phoneNumber,
  //     'address': address,
  //     'hospitalName': hospitalName,
  //     'email': email,
  //     'doctorId': doctorId,
  //     'doctorName': doctorName,
  //     'gender': gender,
  //     'status': status,
  //   };