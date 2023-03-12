// Firestore Constants
class FirestoreConstants {
  static const String usersCollection = 'users';
}

//Registration Screen
class RegistrationConstants {
  static const String patient = 'Patient';
  static const String doctor = 'Doctor';

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
}

//Routes Names
class RouteNames {
  static const String login = 'login';
  static const String verifyEmail = 'verify_email';
  static const String resetPassword = 'reset_password';
  static const String patientHome = 'patient_home';
  static const String patientRegistration = 'patient_registration';
  static const String doctorHome = 'doctor_home';
  static const String doctorRegistration = 'doctor_registration';
  static const String authWrapper = 'authWrapper';
}

//Route Paths
class RoutePaths {
  static const String login = '/login';
  static const String verifyEmail = '/verify_email';
  static const String resetPassword = '/reset_password';
  static const String patientHome = '/patient_home';
  static const String patientRegistration = '/patient_registration';
  static const String doctorHome = '/doctor_home';
  static const String doctorRegistration = '/doctor_registration';
  static const String authWrapper = '/authWrapper';
}
