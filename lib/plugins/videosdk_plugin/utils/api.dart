import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:schedcare/utilities/constants.dart';

Future<String> createMeeting(String token) async {
  final Uri getMeetingIdUrl =
      Uri.parse('${AppConstants.videoSdkEndpoint}/rooms');
  final http.Response meetingIdResponse =
      await http.post(getMeetingIdUrl, headers: {
    "Authorization": token,
  });

  if (meetingIdResponse.statusCode != 200) {
    throw Exception(json.decode(meetingIdResponse.body)["error"]);
  }
  var meetingID = json.decode(meetingIdResponse.body)['roomId'];
  return meetingID;
}

Future<bool> validateMeeting(String token, String meetingId) async {
  final Uri validateMeetingUrl =
      Uri.parse('${AppConstants.videoSdkEndpoint}/rooms/validate/$meetingId');
  final http.Response validateMeetingResponse =
      await http.get(validateMeetingUrl, headers: {
    "Authorization": token,
  });

  if (validateMeetingResponse.statusCode != 200) {
    throw Exception(json.decode(validateMeetingResponse.body)["error"]);
  }

  return validateMeetingResponse.statusCode == 200;
}

Future<dynamic> fetchSession(String token, String meetingId) async {
  final Uri getMeetingIdUrl =
      Uri.parse('${AppConstants.videoSdkEndpoint}/sessions?roomId=$meetingId');
  final http.Response meetingIdResponse =
      await http.get(getMeetingIdUrl, headers: {
    "Authorization": token,
  });
  List<dynamic> sessions = jsonDecode(meetingIdResponse.body)['data'];
  return sessions.first;
}
