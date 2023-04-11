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
