import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTheme {
  // all colors we need for the app
  static Color redColor = Color(0xFFa00c0e);
  static Color whiteColor = Color(0xffffffff);
  static Color blackColor = Color(0xff000000);
  static Color grayColor = Color(0xff562929);

  /// colors chat
  static const backgroundColor = Color.fromRGBO(19, 28, 33, 1);
  static const textColor = Color.fromRGBO(241, 241, 242, 1);
  static const appBarColor = Color.fromRGBO(31, 44, 52, 1);
  static const selectTapBarColor = Color.fromRGBO(31, 44, 52, 1);
  static const webAppBarColor = Color.fromRGBO(42, 47, 50, 1);
  static const messageColor = Color.fromRGBO(5, 96, 98, 1);
  static const senderMessageColor = Color.fromRGBO(37, 45, 49, 1);
  static const tabColor = Color.fromRGBO(0, 167, 131, 1);
  static const searchBarColor = Color.fromRGBO(50, 55, 57, 1);
  static const dividerColor = Color.fromRGBO(37, 45, 50, 1);
  static const chatBarMessage = Color.fromRGBO(30, 36, 40, 1);
  static const mobileChatBoxColor = Color.fromRGBO(31, 44, 52, 1);
  // colors for medical reminder
  static const Color bluishColor = Color(0xff4e5ae8);
  static const Color yellowishColor = Color(0xffFFBC76);
  static const Color pinkColor = Color(0xffFF4667);
  static const Color white = Colors.white;
  static const primaryColor = bluishColor;
  static const Color darkGreyColor = Color(0xff121212);
  static const Color darkHeaderColor = Color(0xFF424242);
  static const Color greenColor = Colors.green;

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: whiteColor,
    appBarTheme: AppBarTheme(backgroundColor: redColor, elevation: 0),
    textTheme: TextTheme(
      titleLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: whiteColor),
      titleMedium: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: blackColor),
      titleSmall: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: grayColor),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      showUnselectedLabels: true,
      showSelectedLabels: true,
      selectedItemColor: whiteColor,
      unselectedItemColor: grayColor,
      backgroundColor: redColor,
      elevation: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: redColor,
        shape: StadiumBorder(side: BorderSide(color: whiteColor, width: 4))),
  );

  static final light = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      background: white,
      primary: primaryColor,
    ),
    // appBarTheme: const AppBarTheme(
    //   backgroundColor: white,
    //   elevation: 0,
    //   iconTheme: IconThemeData(
    //     color: Colors.black,
    //   ),
    // ),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      background: darkGreyColor,
      primary: primaryColor,
    ),
    // appBarTheme: const AppBarTheme(
    //   backgroundColor: darkGreyColor,
    //   elevation: 0,
    //   iconTheme: IconThemeData(
    //     color: Colors.white,
    //   ),
    // ),
  );
}

TextStyle get subHeadingStyle {
  return GoogleFonts.lato(
      textStyle: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Get.isDarkMode ? Colors.grey[400] : Colors.grey,
  ));
}

TextStyle get headingStyle {
  return GoogleFonts.lato(
      textStyle: TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Get.isDarkMode ? Colors.white : Colors.black,
  ));
}

TextStyle get titleStyle {
  return GoogleFonts.lato(
      textStyle: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Get.isDarkMode ? Colors.white : Colors.black,
  ));
}

TextStyle get subTitleStyle {
  return GoogleFonts.lato(
      textStyle: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Get.isDarkMode ? Colors.grey[100] : Colors.grey[700],
  ));
}
