// Firestore Constants
class FirestoreConstants {
  static const usersCollection = 'users';
}

//Registration Screen
class RegistrationConstants {
  static const patient = 'Patient';
  static const doctor = 'Doctor';

  static const male = 'Male';
  static const female = 'Female';

  static const notVaccinated = 'Not Vaccinated';
  static const firstDoseOnly = 'First Dose Only';
  static const fullyVaccinated = 'Fully Vaccinated';
  static const withBooster = 'Fully Vaccinated + With Booster';

  static const single = 'Single';
  static const married = 'Married';
  static const divorced = 'Divorced';
  static const separated = 'Separated';
  static const widowed = 'Widowed';

  static const freshman = 'Freshman';
  static const sophomore = 'Sophomore';
  static const junior = 'Junior';
  static const senior = 'Senior';

  static final List<String> sexes = <String>[male, female];

  static final List<String> classifications = <String>[
    freshman,
    sophomore,
    junior,
    senior
  ];

  static final List<String> civilStatuses = <String>[
    single,
    married,
    divorced,
    separated,
    widowed
  ];

  static final List<String> vaccinationStatuses = <String>[
    notVaccinated,
    firstDoseOnly,
    fullyVaccinated,
    withBooster,
  ];
}
