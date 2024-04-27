import 'package:flutter/material.dart';
import 'package:patient/patient_screens/Screens/Chat/chat_widgets/chat_bubble.dart';

import '../../../theme/theme.dart';

class ChatScreenPatient extends StatelessWidget {
  static const String routeName = 'Chat-screen-patient';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('chat', style: TextStyle(color: MyTheme.whiteColor)),
          centerTitle: true,
          backgroundColor: Color(0xFFa00c0e),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return ChatBubble();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Send text',
                  suffixIcon: Icon(
                    Icons.send,
                    color: MyTheme.mobileChatBoxColor,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        BorderSide(color: MyTheme.mobileChatBoxColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        BorderSide(color: MyTheme.mobileChatBoxColor, width: 2),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
