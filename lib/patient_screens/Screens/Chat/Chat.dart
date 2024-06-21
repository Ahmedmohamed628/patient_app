import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:patient/model/chat_model.dart';
import 'package:patient/model/message_model.dart';
import 'package:patient/model/my_user.dart';
import 'package:patient/patient_screens/Screens/Chat/chat_profile_widget.dart';
import 'package:patient/patient_screens/Screens/Chat/private_chat.dart';

import '../../../theme/theme.dart';

class ChatScreenPatient extends StatefulWidget {
  static const String routeName = 'Chat-screen-patient';

  @override
  State<ChatScreenPatient> createState() => _ChatScreenPatientState();
}

class _ChatScreenPatientState extends State<ChatScreenPatient> {
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
/////////////////////////////////////first wroling try not the best
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
//             itemBuilder: (context, index) {
//               MyHospital user = users[index].data();
//               String chatID =
//                   generateChatID(uid1: userCurrent!.uid, uid2: user.id!);
//               var unseenMessageStream = FirebaseFirestore.instance
//                   .collection(Chat.collectionName)
//                   .doc(chatID)
//                   .withConverter<Chat>(
//                     fromFirestore: (snapshot, _) =>
//                         Chat.fromJson(snapshot.data()!),
//                     toFirestore: (chat, _) => chat.toJson(),
//                   )
//                   .snapshots();
//               return StreamBuilder<DocumentSnapshot<Chat>>(
//                   stream: unseenMessageStream,
//                   builder: (context, snapshot) {
//                     return FutureBuilder<int>(
//                       future: getUnseenMessageCount(userCurrent!.uid, user.id!),
//                       builder: (context, countSnapshot) {
//                         int unseenCount = countSnapshot.data ?? 0;

//                         // Log unseenCount for debugging
//                         print(
//                             'Unseen count for ${user.hospitalName}: $unseenCount');

//                         return ChatTile(
//                           user: user,
//                           onTap: () async {
//                             final chatExists = await checkChatExists(
//                                 userCurrent!.uid, user.id!);
//                             if (!chatExists) {
//                               await createNewChat(userCurrent.uid, user.id!);
//                             }
//                             Navigator.of(context).push(
//                               MaterialPageRoute(
//                                 builder: (context) {
//                                   return PrivateChat(
//                                     chatuser: user,
//                                   );
//                                 },
//                               ),
//                             );
//                           },
//                           unseenCount:
//                               unseenCount, // Pass the unseen count here
//                         );
//                       },
//                     );
//                   });
//             });
//       }
//       return Center(child: CircularProgressIndicator());
//     },
//   );
// }
///////////////////////////////////// seen test

//////////////////////////////////////// seen test finally working 100%
Widget _chatList() {
  var snapshots = FirebaseFirestore.instance
      .collection("Hospitals")
      .withConverter(
          fromFirestore: (snapshot, options) =>
              MyHospital.fromFireStore(snapshot.data()!),
          toFirestore: (user, options) => user.toFireStore())
      .where('status', isEqualTo: true) // Filter where 'status' is true
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
        var unseenMessageStream = FirebaseFirestore.instance
            .collection(Chat.collectionName)
            .withConverter<Chat>(
              fromFirestore: (snapshot, _) => Chat.fromJson(snapshot.data()!),
              toFirestore: (chat, _) => chat.toJson(),
            )
            .where('participants', arrayContains: userCurrent!.uid)
            .snapshots();
        return StreamBuilder(
          stream: unseenMessageStream,
          builder: (context, snapshot) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: getChatsWithUnseenCounts(users, userCurrent!.uid),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final chatsWithUnseenCounts = snapshot.data!;

                  return ListView.builder(
                    itemCount: chatsWithUnseenCounts.length,
                    itemBuilder: (context, index) {
                      final chatData = chatsWithUnseenCounts[index];
                      final MyHospital user = chatData['user'];
                      final int unseenCount = chatData['unseenCount'];
                      final String chatID =
                          generateChatID(uid1: userCurrent.uid, uid2: user.id!);

                      return ChatTile(
                        user: user,
                        onTap: () async {
                          final chatExists =
                              await checkChatExists(userCurrent.uid, user.id!);
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
                        },
                        unseenCount: unseenCount,
                      );
                    },
                  );
                }

                return Center(child: CircularProgressIndicator());
              },
            );
          },
        );
      }
      return Center(child: CircularProgressIndicator());
    },
  );
}
//////////////////////////////////////// seen test finally working 100%

////////////seen test logic
Future<List<Map<String, dynamic>>> getChatsWithUnseenCounts(
    List<QueryDocumentSnapshot<MyHospital>> users, String currentUid) async {
  List<Map<String, dynamic>> chats = [];

  for (var userDoc in users) {
    MyHospital user = userDoc.data();
    int unseenCount = await getUnseenMessageCount(currentUid, user.id!);
    chats.add({'user': user, 'unseenCount': unseenCount});
  }

  // Sort chats by unseen message count in descending order
  chats.sort((a, b) => b['unseenCount'].compareTo(a['unseenCount']));
  return chats;
}

Future<int> getUnseenMessageCount(String uid1, String uid2) async {
  try {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    log("Generated Chat ID: $chatID");

    var chatDocRef = FirebaseFirestore.instance
        .collection(Chat.collectionName)
        .doc(chatID)
        .withConverter<Chat>(
          fromFirestore: (snapshot, _) => Chat.fromJson(snapshot.data()!),
          toFirestore: (chat, _) => chat.toJson(),
        );

    var chatSnapshot = await chatDocRef.get();

    if (!chatSnapshot.exists) {
      log("Chat document not found");
      return 0;
    }

    Chat chat = chatSnapshot.data()!;
    int unseenCount = chat.messages!
        .where((message) => message.senderID != uid1 && !message.seen!)
        .length;

    log('Unseen count for chatID $chatID: $unseenCount');

    return unseenCount;
  } catch (e) {
    log("Failed to get unseen message count: $e");
    return 0;
  }
}
////////////seen test logic

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
