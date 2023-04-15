import 'package:fluttertoast/fluttertoast.dart';
import 'package:schedcare/models/consultation_request_model.dart';
import 'package:schedcare/utilities/constants.dart';

Future<bool?> showToast(String message) async => await Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.SNACKBAR,
    );

bool isOverlapping(List<DateTime> consultationRequestStartTimes,
        DateTime compareDatetime) =>
    consultationRequestStartTimes.any(
      (datetime) =>
          datetime.isBefore(
            compareDatetime.add(
              const Duration(hours: AppConstants.defaultMeetingDuration),
            ),
          ) &&
          compareDatetime.isBefore(
            datetime.add(
              const Duration(hours: AppConstants.defaultMeetingDuration),
            ),
          ),
    );

bool checkIfLapsed(ConsultationRequest consultationRequest) =>
    consultationRequest.status == AppConstants.pending &&
    DateTime.now().isAfter(consultationRequest.consultationDateTime);

bool isWithinSchedule(DateTime dateTime) {
  return DateTime.now()
          .isAfter(dateTime.subtract(const Duration(minutes: 5))) &&
      DateTime.now().isBefore(dateTime
          .add(const Duration(hours: AppConstants.defaultMeetingDuration)));
}

String getFileNameFromUrl(String url) {
  RegExp regExp = RegExp(r'.+(\\/|%2F)(.+)\?.+');
  var matches = regExp.allMatches(url);
  var match = matches.elementAt(0);
  return Uri.decodeFull(match.group(2)!);
}
