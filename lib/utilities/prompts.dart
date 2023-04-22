import 'package:schedcare/utilities/constants.dart';

class Prompts {
  static const String noAvailableDoctors = 'No available doctor at the moment.';
  static const String noSentConsultationRequests =
      'No sent consultation requests. Kindly check back later.';
  static const String noReceivedConsultationRequests =
      'No received consultation requests. Kindly check back later.';
  static const String noNotifications = 'No notifications at the moment.';
  static const String errorDueToWeakInternet =
      'Error encountered due to weak internet connection. Kindly refresh the page.';
  static const String overlappingSchedule =
      'You already have a consultation request overlapping at this time.';
  static const String confirmSigningOut = 'Are you sure you want to sign out?';
  static const String unableToStartApprovedMeeting =
      'Meeting cannot be started until before 5 minutes of the consultation schedule.';
  static const String unableToStartMeetingInThePast =
      'Meeting cannot be started for consultation requests scheduled in the past.';
  static const String unableToStartRejectedMeeting =
      'Meeting cannot be started for rejected consultation requests.';
  static const String unableToStartPendingMeeting =
      'Meeting cannot be started for pending consultation requests.';
  static const String unableToStartLapsedMeeting =
      'Meeting cannot be started for lapsed consultation requests.';
  static const String waitForDoctorToStartMeeting =
      'Please wait for the doctor to start the meeting.';
  static const String meetingUnavailable =
      'Meetings are not available for not approved consultation requests.';
  static const String maximumFileSize =
      "Maximum file size is ${AppConstants.maximumFileUploadSize}MB.";
  static const String couldNotDownloadFile =
      'Could not download file. Kindly check your internet connection.';
}
