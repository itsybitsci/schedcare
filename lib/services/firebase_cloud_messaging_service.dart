import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/helpers.dart';

class FirebaseCloudMessagingService {
  final _firebaseCloudMessagingInstance = FirebaseMessaging.instance;

  Future<String?> getDeviceToken() async {
    try {
      return await _firebaseCloudMessagingInstance.getToken();
    } on FirebaseException catch (e) {
      showToast(e.code);
      throw Exception(e.code);
    }
  }

  Future<void> sendPushNotification(
      String title, String body, String token) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=${AppConstants.fcmKey}'
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
              'android_channel_id': AppConstants.channelId,
            },
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': body,
              'title': title,
            },
            'priority': 'high',
            'to': token,
          },
        ),
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
