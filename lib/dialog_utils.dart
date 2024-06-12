import 'package:flutter/material.dart';
import 'package:patient/theme/theme.dart';

class DialogUtils {
  static void showLoading(BuildContext context, String message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Row(
              children: [
                // LoadingAnimationWidget
                CircularProgressIndicator(
                  color: MyTheme.redColor,
                ),
                SizedBox(
                  width: 12,
                ),
                Text(message),
              ],
            ),
          );
        });
  }

  static void hideLoading(BuildContext context) {
    Navigator.pop(context);
  }

  static void showMessage(BuildContext context, String message,
      {String? title,
      String? posActionName,
      VoidCallback? posAction,
      String? negActionName,
      VoidCallback? negAction,
      bool barrierDismissible = true}) {
    List<Widget> actions = [];
    if (posActionName != null) {
      actions.add(
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            posAction?.call();
          },
          child: Text(posActionName,
              style: TextStyle(fontSize: 17, color: Colors.white)),
          style: ElevatedButton.styleFrom(
              backgroundColor: MyTheme.tabColor,
              padding: EdgeInsets.symmetric(vertical: 10)),
        ),
        // TextButton(
        // onPressed: () {
        //   Navigator.pop(context);
        //   posAction?.call();
        // },
        // child: Text(
        //   posActionName,
        //   style: TextStyle(fontSize: 17),
        // )
        // )
      );
    }
    if (negActionName != null) {
      actions.add(ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          negAction?.call();
        },
        child: Text(negActionName,
            style: TextStyle(fontSize: 17, color: Colors.white)),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: EdgeInsets.symmetric(vertical: 10)),
      ));
      // TextButton(
      // onPressed: () {
      //   Navigator.pop(context);
      //   negAction?.call();
      // },
      // child: Text(negActionName, style: TextStyle(fontSize: 17),)));
    }
    showDialog(
        barrierDismissible: barrierDismissible,
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(message),
            title: Text(title ?? 'Title'),
            actions: actions,
          );
        });
  }
}
