import 'package:flutter/material.dart';
import 'package:schedcare/screens/doctor/pages/doctor_notifications_page.dart';
import 'package:schedcare/screens/doctor/pages/doctor_schedules_page.dart';
import 'package:schedcare/screens/doctor/pages/received_consultation_requests_page.dart';
import 'package:schedcare/screens/patient/pages/list_doctors_page.dart';
import 'package:schedcare/screens/patient/pages/patient_notifications_page.dart';
import 'package:schedcare/screens/patient/pages/patient_schedules_page.dart';
import 'package:schedcare/screens/patient/pages/sent_consultation_requests_page.dart';

class FirebaseConstants {
  static const String usersCollection = 'users';
  static const String consultationRequestsCollection = 'consultation_requests';
  static const String userTokensCollection = 'user_tokens';
  static const String notificationsCollection = 'notifications';
}

class AppConstants {
  static const appTitle = 'SchedCare';
  static const channelId = 'SchedCare';

  static const String fcmKey =
      'AAAAN4HTnQg:APA91bHKKsyn8br_UGidPC-zwuptWNDulQ_Hkx6rf7gwxO-ZPprA1WFbcZuDe8lRIcaYtq9Sd58VoqKdbFwHLKVRNTr3HFPCNDCVN5N_PsqadBpJJlvWEv3va_fzuI47GV-Oed1hJ9Aq';

  static const String videoSdkEndpoint = 'https://api.videosdk.live/v2';

  //Production
  // static const String videoSdkToken =
  //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlrZXkiOiI1MTg4NTAxMS01NGNiLTRlZDgtYWRkYi01MDFmZDVmNTViNjkiLCJwZXJtaXNzaW9ucyI6WyJhbGxvd19qb2luIl0sImlhdCI6MTY4MTA1Mzk1NywiZXhwIjoxODM4ODQxOTU3fQ.LBk-ExQEb9DHabYjF9d7mBiacME6GanWfudNVQzCKWM';

  //Staging
  static const String videoSdkToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlrZXkiOiI0Y2FmNmQ5MC1mMWNlLTRkMTUtYWZmMS1iMzgyZDU3NDM4NzEiLCJwZXJtaXNzaW9ucyI6WyJhbGxvd19qb2luIl0sImlhdCI6MTY4MTE1MjAzOSwiZXhwIjoxODM4OTQwMDM5fQ.1wSCruxqJ1ZRd_S8AqaRCKhB8rCTSHwOjTxQJ6MnPNQ';

  static const String patient = 'Patient';
  static const String doctor = 'Doctor';
  static const String consultationRequest = 'ConsultationRequest';

  static const String male = 'Male';
  static const String female = 'Female';

  static const String notVaccinated = 'Not Vaccinated';
  static const String firstDoseOnly = 'First Dose Only';
  static const String fullyVaccinated = 'Fully Vaccinated';
  static const String withBooster = 'Fully Vaccinated + With Booster';

  static const String single = 'Single';
  static const String married = 'Married';
  static const String divorced = 'Divorced';
  static const String separated = 'Separated';
  static const String widowed = 'Widowed';

  static const String freshman = 'Freshman';
  static const String sophomore = 'Sophomore';
  static const String junior = 'Junior';
  static const String senior = 'Senior';

  static const String teleconsultation = 'Teleconsultation';
  static const String inPersonConsultation = 'In-person Consultation';

  static const String approved = 'Approved';
  static const String rejected = 'Rejected';
  static const String pending = 'Pending';
  static const String lapsed = 'Lapsed';

  static const int defaultMeetingDuration = 1;
  static const int maximumFileUploadSize = 5;
  static const double defaultPadding = 16.0;

  static const List<String> sexes = <String>[male, female];

  static const List<String> classifications = <String>[
    freshman,
    sophomore,
    junior,
    senior
  ];

  static const List<String> civilStatuses = <String>[
    single,
    married,
    divorced,
    separated,
    widowed
  ];

  static const List<String> vaccinationStatuses = <String>[
    notVaccinated,
    firstDoseOnly,
    fullyVaccinated,
    withBooster,
  ];

  static const List<String> consultationTypes = <String>[
    teleconsultation,
    inPersonConsultation
  ];

  static List<Widget> patientPages = <Widget>[
    SentConsultationRequestsPage(),
    ListDoctorsPage(),
    PatientSchedulesPage(),
    PatientNotificationsPage(),
  ];

  static List<Widget> doctorPages = <Widget>[
    ReceivedConsultationRequestsPage(),
    DoctorSchedulesPage(),
    DoctorNotificationsPage(),
  ];
}

//Routes Names
class RouteNames {
  static const String authWrapper = 'auth_wrapper';
  static const String login = 'login';
  static const String approval = 'approval';
  static const String verifyEmail = 'verify_email';
  static const String resetPassword = 'reset_password';

  static const String patientRegistration = 'patient_registration';
  static const String patientHome = 'patient_home';
  static const String patientProfile = 'patient_profile';
  static const String editPatientProfile = 'edit_patient_profile';
  static const String sendConsultationRequest = 'send_consultation_request';
  static const String patientViewConsultationRequest =
      'patient_view_consultation_request';

  static const String doctorRegistration = 'doctor_registration';
  static const String doctorHome = 'doctor_home';
  static const String doctorProfile = 'doctor_profile';
  static const String editDoctorProfile = 'edit_doctor_profile';
  static const String doctorViewConsultationRequest =
      'doctor_view_consultation_request';

  static const String joinScreen = 'join_screen';
  static const String conversationHistory = 'conversation_history';
}

//Route Paths
class RoutePaths {
  static const String authWrapper = '/';
  static const String login = '/login';
  static const String approval = '/approval';
  static const String verifyEmail = '/verify_email';
  static const String resetPassword = '/reset_password';

  static const String patientRegistration = '/patient_registration';
  static const String patientHome = '/patient_home';
  static const String patientProfile = '/patient_profile';
  static const String editPatientProfile = '/edit_patient_profile';
  static const String sendConsultationRequest = '/send_consultation_request';
  static const String patientViewConsultationRequest =
      '/patient_view_consultation_request';

  static const String doctorRegistration = '/doctor_registration';
  static const String doctorHome = '/doctor_home';
  static const String doctorProfile = '/doctor_profile';
  static const String editDoctorProfile = '/edit_doctor_profile';
  static const String doctorViewConsultationRequest =
      '/doctor_view_consultation_request';

  static const String joinScreen = '/join_screen';
  static const String conversationHistory = '/conversation_history';
}

class ModelFields {
  static const String email = 'email';
  static const String role = 'role';
  static const String prefix = 'prefix';
  static const String firstName = 'firstName';
  static const String middleName = 'middleName';
  static const String lastName = 'lastName';
  static const String suffix = 'suffix';
  static const String age = 'age';
  static const String birthDate = 'birthDate';
  static const String sex = 'sex';
  static const String phoneNumber = 'phoneNumber';
  static const String address = 'address';
  static const String civilStatus = 'civilStatus';
  static const String classification = 'classification';
  static const String uhsIdNumber = 'uhsIdNumber';
  static const String vaccinationStatus = 'vaccinationStatus';
  static const String isApproved = 'isApproved';
  static const String specialization = 'specialization';
  static const String lastLogin = 'lastLogin';
  static const String modifiedAt = 'modifiedAt';
  static const String createdAt = 'createdAt';
  static const String patientId = 'patientId';
  static const String doctorId = 'doctorId';
  static const String consultationRequestPatientTitle =
      'consultationRequestPatientTitle';
  static const String consultationRequestDoctorTitle =
      'consultationRequestDoctorTitle';
  static const String consultationRequestBody = 'consultationRequestBody';
  static const String status = 'status';
  static const String consultationType = 'consultationType';
  static const String consultationDateTime = 'consultationDateTime';
  static const String meetingId = 'meetingId';
  static const String patientAttachmentUrl = 'patientAttachmentUrl';
  static const String doctorAttachmentUrl = 'doctorAttachmentUrl';
  static const String id = 'id';
  static const String deviceTokens = 'deviceTokens';
  static const String title = 'title';
  static const String body = 'body';
  static const String sentAt = 'sentAt';
  static const String sender = 'sender';
  static const String isRead = 'isRead';
  static const String messages = 'messages';
  static const String message = 'message';
  static const String messageTimeStamp = 'messageTimeStamp';
  static const String senderName = 'senderName';
  static const String isPatientSoftDeleted = 'isPatientSoftDeleted';
  static const String isDoctorSoftDeleted = 'isDoctorSoftDeleted';
  static const String isEmailVerified = 'isEmailVerified';
}

class FontConstants {
  static const String yesevaOne = 'YesevaOne';
  static const String crimsonPro = 'CrimsonPro';
}

class ColorConstants {
  static const MaterialColor primaryColor = Colors.blue;
  static const MaterialColor primaryLight = Colors.lightBlue;
}
