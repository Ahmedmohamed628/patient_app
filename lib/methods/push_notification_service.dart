import 'dart:convert';
import 'dart:developer';

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
      "type": "service_account",
      "project_id": "emergency-app-da505",
      "private_key_id": "3f0ae61d4207d84106bbefb30984d688846ae36c",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDj2b+gRhzf7WRd\nKcnFC3gyMY1gK0a/DJRe98hsJUgpRBazSjqZJAGhf/bjxCIzH9Apyoj7XjKpCmoy\n8BV2ZnJb46C3C2vxO1aEj5FnnJ6O8rUYypXPiqE9bzx9FT+jL3l/MW7PSbsS+zS8\nS+7+MIynNvtaz0763o8D8gI3NzZW0bq9da8SHrvlYPOPa493W94DkEYGNzWld2Uv\n9ao1XLNGDlXVne5reghp9elX1Czw/1bBJtFl63OXVwG+vz5tboBBt1cz4E3LX+Ug\niMlG03wv+ommUaRwnwXHIrtv8oiih2NRgf23Ol+48OHqGWrTlnoZjv1ILsl74gSF\ntAvmMEkjAgMBAAECggEAAKTc4ORB1vgNs0Q+NA0SaiGjH32x9KlIAfEbreC0bnmx\nn+5v4NRUUtnECk8Y6C6NNCsrFEfegtqI2U69zzApRbfy88XCdWCWyoMxPEBNLG0g\nMGBzAeHc7QFK+1/skRas9mb4Ziy4m5s59UxJgwHPydO8dLxq7rJBVwauc0FNU/uN\nidpZX6ciEUUGaAHH8rSnR2zNDQXThTkZVNAGbXvrP6V3zsc4dvx5gGMYLW9bCK5J\n+W4Hdiu/1vSR5xvjQ1S3Rox55zoO+DmUnBCzlMw5FHC4PzzVi1hIT0F1PpcTe985\nMwkzk6GKnR2I1lWm3bM8r8e1h1IYfrjLWroVzBYlFQKBgQD3lWLUoL0uRrepE5CS\nRSQCy2MtkK54G0js917rCsmknW7b6v7Pm4dBAPyJ0aNy6BiCsFJIdtqscKdU5S0G\n/7mKeSPnWR73HtK+COVK/whUlRXKYGNXNIhmCxNPVoLB5qNqI8HOxfm5ucmQwRPm\nVyxwVAIXnBlKtKWRaxULuDnA9wKBgQDrmKKMfjmJvw64T9T4YJtK03P7Q+eI6HS9\niZcypWtkwv85FLwVc3s/1ra3MnBjvr8iN51bdvN2zU0OLLyvFmQaCrRB93ZkDoPM\nmPt3DH+Kv4SqsZJf96PudUxqgzn1bTI8ikzbj3ia9Db/5JRfpuJ6bipMr2nS92RU\nztSi+h/aNQKBgQC0HsNzC6n2g85UPH6eW5zSR6PU34B+suMAOwucFhITJ9IiPrm4\n0l65JP2VSqYOD9rdIWgLfiSi9aZXNg/nGp6ipnU/d2/2uz74sEIYqKgn2PqsbCl5\npSdijcYzny2r4Z6btn3mb9O5kfeZz04p8tvKsOOAx7kCx5/4xp3eE944iwKBgQCr\nl+dEdqcHub1J5vNR2GMi87H03zdjExP7/JvASpVWtWPYuk5nPU4WaBd6hOUw8Pwb\nOvCEbrXS4KLv4QuoZqGQCh3SMh/rrlq2iPIWembmsqk4/c6D0UV35705ksyDAf5l\n88EY5X1NNvRcGqsqo80uqNBsPBLSkldkIaTj81OBxQKBgGHUDexBfAlqP94TSt7b\n2EYjF7aw7h1X1EA9ESlGem3JF5pmLndeZrT1LawYq51Gg/7kkoyc4Kam8ho6EKBo\nzWqmF8oMf97Dz+WaYZQuQlC345yaC9S16KZzaB+04HJ0Bfq/8GXi1Ky4xc8FdaRC\naC2eSrfMKETCuSoBk0mG9Dog\n-----END PRIVATE KEY-----\n",
      "client_email":
          "ramadona-sendnotification@emergency-app-da505.iam.gserviceaccount.com",
      "client_id": "113154250447566946903",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/ramadona-sendnotification%40emergency-app-da505.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
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
      client,
    );

    client.close();
    log('${credentials.accessToken.data}');

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

    //ArgumentError (Invalid argument(s): json must be a Map or a String encoding a Map.)
    final String serverKey = await getAccessToken();
    log(' this is server token : ${serverKey}');
    //ArgumentError (Invalid argument(s): json must be a Map or a String encoding a Map.)
    String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/emergency-app-da505/messages:send';
    log('${deviceToken}');

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': "New emergency case $userName",
          'body':
              "PickUp Location: $pickUpAddress \nDestination Location: $dropOffDestinationAddress"
        },
        'data': {
          'tripID': tripID,
        }
      }
    };
    log('${message}');

    try {
      final http.Response response = await http.post(
        Uri.parse(endpointFirebaseCloudMessaging),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverKey'
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('Message sent successfully');
        print('Response body: ${response.body}');
      } else {
        print('Failed to send message. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending message: $e');
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