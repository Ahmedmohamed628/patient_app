import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:patient/authentication/login/login_screen_view_model.dart';
import 'package:patient/model/chat_model.dart';
import 'package:patient/model/message_model.dart';
import 'package:patient/model/my_user.dart';
import 'package:patient/patient_screens/Screens/Chat/chat_profile_widget.dart';
import 'package:patient/patient_screens/Screens/Chat/private_chat.dart';

import '../../../theme/theme.dart';

class ChatScreenPatient extends StatelessWidget {
  static const String routeName = 'Chat-screen-patient';

  @override
  Widget build(BuildContext context) {
    // return FutureBuilder<QuerySnapshot>(
    //   future: messages.get(),
    return Scaffold(
      appBar: AppBar(
          title: Text("Chat", style: TextStyle(color: MyTheme.whiteColor)),
          centerTitle: true,
          backgroundColor: MyTheme.redColor),
      body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/chat_list2.jpg'),
              fit: BoxFit.cover, // Adjust as needed (cover, contain, etc.)
            ),
          ),
          child: _chatList()),
    );
  }
}

Widget _chatList() {
  var snapshots = FirebaseFirestore.instance
      .collection("Hospitals")
      .withConverter(
          fromFirestore: (snapshot, options) =>
              MyHospital.fromFireStore(snapshot.data()!),
          toFirestore: (user, options) => user.toFireStore())
      .snapshots();
  return StreamBuilder(
    stream: snapshots,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(child: Text("no data"));
      }
      if (snapshot.hasData && snapshot.data != null) {
        final users = snapshot.data!.docs;
        final userCurrent = FirebaseAuth.instance.currentUser;
        return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, Index) {
              MyHospital user = users[Index].data();
              return ChatTile(
                  user: user,
                  onTap: () async {
                    final chatExists =
                        await checkChatExists(userCurrent!.uid, user.id!);
                    print(chatExists);
                    if (!chatExists) {
                      await createNewChat(userCurrent.uid, user.id!);
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return PrivateChat(
                            chatuser: user,
                          );
                        },
                      ),
                    );
                    //02:56 -- 41 00
                  });
            });
      }
      return Center(child: CircularProgressIndicator());
    },
  );
}

Future<bool> checkChatExists(String uid1, String uid2) async {
  var snapshots = FirebaseFirestore.instance
      .collection(Chat.collectionName)
      .withConverter(
          fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
          toFirestore: (chat, _) => chat.toJson());

  String chatID = generateChatID(uid1: uid1, uid2: uid2);
  final result = await snapshots?.doc(chatID).get();
  if (result != null) {
    return result.exists;
  }
  return false;
}

String generateChatID({required String uid1, required String uid2}) {
  List uids = [uid1, uid2];
  uids.sort();
  String chatID = uids.fold("", (id, uid) => "$id$uid");
  return chatID;
}

Future<void> createNewChat(String uid1, String uid2) async {
  String chatID = generateChatID(uid1: uid1, uid2: uid2);
  var snapshots = FirebaseFirestore.instance
      .collection(Chat.collectionName)
      .withConverter(
          fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
          toFirestore: (chat, _) => chat.toJson());
  final docRef = snapshots.doc(chatID);
  final chat = Chat(id: chatID, participants: [uid1, uid2], messages: []);
  await docRef.set(chat);
}

Future<void> sendChaMessage(String uid1, String uid2, Message message) async {
  String chatID = generateChatID(uid1: uid1, uid2: uid2);
  var snapshots = FirebaseFirestore.instance
      .collection(Chat.collectionName)
      .withConverter(
          fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
          toFirestore: (chat, _) => chat.toJson());
  final docRef = snapshots.doc(chatID);
  await docRef.update(
    {
      "messages": FieldValue.arrayUnion(
        [
          message.toJson(),
        ],
      ),
    },
  );
}

Stream getChatData(String uid1, String uid2) {
  String chatID = generateChatID(uid1: uid1, uid2: uid2);
  var snapshots = FirebaseFirestore.instance
      .collection(Chat.collectionName)
      .withConverter(
          fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
          toFirestore: (chat, _) => chat.toJson());
  return snapshots.doc(chatID).snapshots();
}
