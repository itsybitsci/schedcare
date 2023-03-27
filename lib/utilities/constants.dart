import 'package:flutter/material.dart';
import 'package:schedcare/screens/patient/pages/list_doctors_page.dart';
import 'package:schedcare/screens/patient/pages/schedules_page.dart';
import 'package:schedcare/screens/patient/pages/patient_home_page.dart';

class FirestoreConstants {
  static const String usersCollection = 'users';
  static const String consultationRequestsCollection = 'consultation_requests';
}

class AppConstants {
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

  static const int defaultMeetingDuration = 1;

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
    PatientHomePage(),
    ListDoctorsPage(),
    SchedulesPage(),
  ];
}

//Routes Names
class RouteNames {
  static const String authWrapper = 'authWrapper';
  static const String login = 'login';
  static const String verifyEmail = 'verify_email';
  static const String resetPassword = 'reset_password';
  static const String patientHome = 'patient_home';
  static const String patientRegistration = 'patient_registration';
  static const String doctorHome = 'doctor_home';
  static const String doctorRegistration = 'doctor_registration';
  static const String approval = 'approval';
  static const String patientProfile = 'patient_profile';
  static const String editPatientProfile = 'edit_patient_profile';
  static const String sendConsultationRequest = 'send_consultation_request';
  static const String viewConsultationRequest = 'view_consultation_request';
}

//Route Paths
class RoutePaths {
  static const String authWrapper = '/';
  static const String login = '/login';
  static const String verifyEmail = '/verify_email';
  static const String resetPassword = '/reset_password';
  static const String patientHome = '/patient_home';
  static const String patientRegistration = '/patient_registration';
  static const String doctorHome = '/doctor_home';
  static const String doctorRegistration = '/doctor_registration';
  static const String approval = '/approval';
  static const String patientProfile = '/patient_profile';
  static const String editPatientProfile = '/edit_patient_profile';
  static const String sendConsultationRequest = '/send_consultation_request';
  static const String viewConsultationRequest = '/view_consultation_request';
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
  static const String patientUid = 'patientUid';
  static const String doctorUid = 'doctorUid';
  static const String consultationRequestTitle = 'consultationRequestTitle';
  static const String consultationRequestBody = 'consultationRequestBody';
  static const String status = 'status';
  static const String consultationType = 'consultationType';
  static const String consultationDateTime = 'consultationDateTime';
  static const String meetingId = 'meetingId';
  static const String docId = 'docId';
}
