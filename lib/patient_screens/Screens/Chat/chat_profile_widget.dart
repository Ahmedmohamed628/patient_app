import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:patient/model/my_user.dart';

class ChatTile extends StatelessWidget {
  final MyHospital user;
  final Function onTap;
  final int unseenCount; // for seen test

  const ChatTile({
    super.key,
    required this.user,
    required this.onTap,
    required this.unseenCount, // for seen test
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTap();
      },
      dense: false,
      //fixed image just for now change it for profile one later
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.pfpURL ?? ''),
      ),
      title: Text(user.hospitalName ?? ""),
      ///////////////////////////////////////test seen
      trailing: unseenCount > 0
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$unseenCount',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(
                  width: 4,
                ),
                Icon(Icons.mark_chat_unread, color: Colors.red),
              ],
            )
          : Icon(Icons.mark_chat_read, color: Colors.green),
      ///////////////////////////test seen
    );
  }
}
