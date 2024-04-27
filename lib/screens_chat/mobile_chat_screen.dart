import 'package:flutter/material.dart';

import '../info.dart';
import '../theme/theme.dart';
import '../widgets_chats/chat_list.dart';

class MobileChatScreen extends StatelessWidget {
  const MobileChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.redColor,
        title: Text(
          info[0]['name'].toString(),
          style: TextStyle(color: MyTheme.whiteColor),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.video_call, color: Colors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call, color: Colors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          const Expanded(
            child: ChatList(),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.07,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: MyTheme.dividerColor),
              ),
              color: MyTheme.chatBarMessage,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.emoji_emotions_outlined,
                    color: Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.attach_file,
                    color: Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.grey,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 5,
                      right: 2,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: MyTheme.searchBarColor,
                        hintText: 'Type a message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        contentPadding: const EdgeInsets.only(left: 20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.mic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // TextField(
          //   decoration: InputDecoration(
          //     filled: true,
          //     fillColor: MyTheme.mobileChatBoxColor,
          //     prefixIcon: const Padding(
          //       padding: EdgeInsets.symmetric(horizontal: 20.0),
          //       child: Icon(Icons.emoji_emotions, color: Colors.grey,),
          //     ),
          //     suffixIcon: Padding(
          //       padding: const EdgeInsets.symmetric(horizontal: 20.0),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.end,
          //         children:  [
          //           Icon(Icons.camera_alt, color: Colors.grey,),
          //           Icon(Icons.attach_file, color: Colors.grey,),
          //           Icon(Icons.money, color: Colors.grey,),
          //
          //         ],
          //       ),
          //     ),
          //     hintText: 'Type a message!',
          //     hintStyle: TextStyle(color: Colors.white),
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(30.0),
          //       borderSide: const BorderSide(
          //         width: 0,
          //         style: BorderStyle.none,
          //       ),
          //     ),
          //     contentPadding: const EdgeInsets.all(10),
          //   ),
          // ),
        ],
      ),
    );
  }
}
