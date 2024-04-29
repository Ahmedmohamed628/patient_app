import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:patient/model/my_user.dart';

class ChatTile extends StatelessWidget {
  final MyHospital user;
  final Function onTap;
  const ChatTile({
    super.key,
    required this.user,
    required this.onTap,
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
        backgroundImage: NetworkImage(
            "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.pinterest.com%2Fpin%2F35-no-profile-pictures-for-tiktok-default-collection--746260600768706252%2F&psig=AOvVaw3m79rAdC4RZt__KRJ1CF2Z&ust=1714428510641000&source=images&cd=vfe&opi=89978449&ved=0CBIQjRxqFwoTCLjBs4T25YUDFQAAAAAdAAAAABAE"),
      ),
      title: Text(user.hospitalName!),
    );
  }
}
