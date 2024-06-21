import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:googleapis/admin/directory_v1.dart';
import 'package:googleapis/androiddeviceprovisioning/v1.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;
import 'package:patient/app_info/app_info.dart';
import 'package:provider/provider.dart';

class PushNotificationService {
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      {
        "type": "service_account",
        "project_id": "emergency-app-da505",
        "private_key_id": "6539944e68ae5acda406f0cfd38371574d191634",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCl1lem7gUe4taF\nXIXHIq2CyzvxI3dI3gS3qW/0rwi30FpTXg9iqfRfLB2Ne2W8TN4fPnHZPC8brtiG\n2VPqN/C949RXWGaZL+DutI9Coie0RNIX6ZEHBTTKJznX4qouNv6dxn1kZjFazTkR\nNC//pj0VsAG0eV2svSuTJMAGuX1RcRl3VO4Yo7dxTtYZNS09byccY4A5dhgXWOfL\n3IfuY117XZbeGSAv67OdYk1ilqzJCtW1UU1BHdUyB2neG0UPVW9T8AtOQl9ddAeL\nkltU5YltMJ1NuHQPVjFYazFWl2bc+iYzOAi8Ybb1mkFdr+C7Ja68/uprgeRbcvoZ\nqfa13bDFAgMBAAECggEASQO2os4AHimkZqImWldHyqLdeN1zGvd5Xz2wB6x666dF\n5ZevsXJ/n9mGB3FRiRbU4y+0o38OhKM2PST5f9FyYsCpEG3g+kgswhxoSN+pGIMG\ndzXEPzGJHQopOwZWhDN9Zgzqz2X5C+/4VL1D9syD74UHMyUOW8wMH+RZ0Xwgk1bB\nLaOJl4TBVgmGNbhxN1jmOSLsKxake37mTEPIv+0vXOnOzHAQkOZ6zoTt4kEc/+Xl\nKF6REyV64CY/U5O+O06VV2WnyqzuQ84TzHGyr+6aqzUYuBPLDNzH2i7LTwMJH0yI\nPPSfDHPh2CdJ4Qat8UDRATH4pM813yJUc+ZnWZgEnwKBgQDajjcnTo3jI/kjRHEq\n6bI2mItr9Yy0m4xmaW67XnG+k22YvXH3UkjW88fAdVhqbEdpAQbYZzIn+aZHs+g8\ndCaNgwDtSHXj8QmTObP/oTzJORHw5lgAPFjFRo93Mb+hGl/8vJGqavHgTldkn3DV\nRalj9+fzolf0BkxGijpH6I7lowKBgQDCP+tFIcz2y1HfW6a6L3xRpqA2madAO8dh\nEQAC2mz50Cd/xNh/UfwHd0m2lYQST5tjhzWv9tNPKVlYDjdUVECZLjFyppKR7OzX\nnt6cIl8ciYZUzts8mlRriIe8KyFP6LqKVWcmdpE1UFy6hUqTB5bF403JQG7I4Tjb\nfdga72ZmdwKBgFXg/Bsd6vMN95+8DRvnqHd7iY1qd1egp5K2aySE//z6wV37UwTz\n+Fs+f4dIlO18jrLcDGyMYFEE8CnMr7zRhzSj/YE/r9NZq4GGcwxHtzL6keovGPU+\nwUMDbuxPSBVt37nX/wUP8OtK3VxUqmmjbeQyTZqWeCkTMHWnay9GWqAxAoGBAI2s\nvvSqBWrOugUVPJI5BgwrYljQUornzrA+DOsH0kmVhumKcXjTG+V6HFo9zJjqVOQP\nfpm7hT0MZGxz2ej4ljDi3w/G68ngqpFM/wGTlBklOMNsJ7yYtw/DAXS9ZEt662rv\nhQ8plRj0Zt1nUA/SjiYAdgBdrS94DNcRfueOSfpbAoGAY9W2bi9VB3k0JRPUya8A\nZz1YkXn+sjaMKbrIMGrwidVrv7T+bRAbqAiMrQpOg3ki30tWK7Bq1vXNiTaJSW5A\nFTSuO9BGty5CRRcWgtj91P4TReWlzgyWe4io8OdtU4QElJ8tGyrcbMmyPuJHkPC4\nZ7AzK/oEVenTnDxmEN/S3Vs=\n-----END PRIVATE KEY-----\n",
        "client_email":
            "ramadona-sendnotification@emergency-app-da505.iam.gserviceaccount.com",
        "client_id": "110503022026692194869",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/ramadona-sendnotification%40emergency-app-da505.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
      }
    };
    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];
    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);
    client.close();
    return credentials.accessToken.data;
  }

  static sendNotificationToSelectedDriver(
    String deviceToken,
    BuildContext context,
    String tripID,
    String userName,
  ) async {
    String dropOffDestinationAddress =
        Provider.of<AppInfo>(context, listen: false)
            .destinationLocation!
            .placeName
            .toString();
    String pickUpAddress = Provider.of<AppInfo>(context, listen: false)
        .pickUpLocation!
        .placeName
        .toString();
    final String serverKey = await getAccessToken();
    String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/emergency-app-da505/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': "New emergency case $userName",
          'body':
              "PickUp Location: $pickUpAddress \nDestination Location: $dropOffDestinationAddress"
        },
        'data': {
          'tripId': tripID,
        }
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey'
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('message sent');
    } else {
      print('not sent');
    }
  }
}








// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import '../app_info/app_info.dart';
//
// class PushNotificationService
// {
//   static sendNotificationToSelectedDriver(String deviceToken, BuildContext context, String tripID) async
//   {
//     String dropOffDestinationAddress = Provider.of<AppInfo>(context, listen: false).destinationLocation!.placeName.toString();
//     String pickUpAddress = Provider.of<AppInfo>(context, listen: false).pickUpLocation!.placeName.toString();
//
//     Map<String, String> headerNotificationMap =
//     {
//       "Content-Type": "application/json",
//       "Authorization": serverKeyFCM,
//     };
//
//     Map titleBodyNotificationMap =
//     {
//       "title": "NET TRIP REQUEST from $userName",
//       "body": "PickUp Location: $pickUpAddress \nDropOff Location: $dropOffDestinationAddress",
//     };
//
//     Map dataMapNotification =
//     {
//       "click_action": "FLUTTER_NOTIFICATION_CLICK",
//       "id": "1",
//       "status": "done",
//       "tripID": tripID,
//     };
//
//     Map bodyNotificationMap =
//     {
//       "notification": titleBodyNotificationMap,
//       "data": dataMapNotification,
//       "priority": "high",
//       "to": deviceToken,
//     };
//
//     await http.post(
//       Uri.parse("https://fcm.googleapis.com/fcm/send"),
//       headers: headerNotificationMap,
//       body: jsonEncode(bodyNotificationMap),
//     );
//   }
// }






//////////////shit code 
/////   static sendNotificationToSelectedDriver(
//     String deviceToken, BuildContext context, String tripID) async {
//     String dropOffDestinationAddress =
//         Provider.of<AppInfo>(context, listen: false)
//             .destinationLocation!
//             .placeName
//             .toString();
//     String pickUpAddress = Provider.of<AppInfo>(context, listen: false)
//         .pickUpLocation!
//         .placeName
//         .toString();
//     final String serverkey = await getAccessToken();
//     String endpointFirebaseCloudMessaging =
//         'https://fcm.googleapis.com/v1/projects/emergency-app-da505/messages:send';
//   }

//   final Map<String, dynamic> messages = {
//     'message': {
//       'token': deviceToken,
//       'notification': {
//         'title': "New emergency case $UserName",
//         'body':
//             "PickUp Location: $pickUpLocation \nDestination Location: $destinationLocation"
//       },
//       'data': {
//         'tripId': tripID,
//       }
//     }
//   };

// final http.Response response = await http.post(
//   Uri.parse(endpointFirebaseCloudMessaging),
//   headers: <String, String>{
//     'Content-Type': 'application/json',
//     'Authorization': 'Bearer $serverkey'
//   },
//   body: jsonEncode(message),
// );

// if (response.statusCode == 200) {
//   print('message sent');
// } else {
//   print('not sent');
// }