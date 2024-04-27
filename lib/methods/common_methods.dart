import 'package:flutter/material.dart';

class CommonMethods extends ChangeNotifier {
  displaySnackBar(String message, BuildContext context) {
    var snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
