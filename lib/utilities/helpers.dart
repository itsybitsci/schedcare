import 'package:fluttertoast/fluttertoast.dart';
import 'package:schedcare/utilities/constants.dart';

Future<bool?> showToast(String message) async {
  return await Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.SNACKBAR,
  );
}

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
