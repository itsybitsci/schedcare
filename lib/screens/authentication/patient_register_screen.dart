import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/auth_provider.dart';
import 'package:schedcare/providers/registration_provider.dart';
import 'package:schedcare/utilities/constants.dart';

class PatientRegisterScreen extends ConsumerStatefulWidget {
  const PatientRegisterScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _PatientRegisterScreenState();
  }
}

class _PatientRegisterScreenState extends ConsumerState<PatientRegisterScreen> {
  late final GlobalKey<FormState> formKeyRegisterPatient;

  @override
  void initState() {
    super.initState();
    formKeyRegisterPatient = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.watch(authProvider);
    final registrationNotifier = ref.watch(registrationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Patient'),
      ),
      body: Form(
        key: formKeyRegisterPatient,
        child: SingleChildScrollView(
          reverse: true,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              registrationNotifier.buildFirstName(),
              registrationNotifier.buildMiddleName(),
              registrationNotifier.buildLastName(),
              registrationNotifier.buildSuffix(),
              registrationNotifier.buildEmail(),
              registrationNotifier.buildAge(),
              registrationNotifier.buildSexesDropdown(),
              registrationNotifier.buildBirthdate(context),
              registrationNotifier.buildClassification(),
              registrationNotifier.buildCivilStatus(),
              registrationNotifier.buildPhoneNumber(),
              registrationNotifier.buildAddress(),
              registrationNotifier.buildVaccinationStatus(),
              registrationNotifier.buildPassword(),
              registrationNotifier.buildRepeatPassword(),
              ElevatedButton(
                onPressed: () async {
                  if (formKeyRegisterPatient.currentState!.validate()) {
                    formKeyRegisterPatient.currentState?.save();
                    Map<String, dynamic> userData = {
                      'email': registrationNotifier.email,
                      'role': RegistrationConstants.patient,
                      'firstName': registrationNotifier.firstName,
                      'middleName': registrationNotifier.middleName,
                      'lastName': registrationNotifier.lastName,
                      'suffix': registrationNotifier.suffix,
                      'age': registrationNotifier.age,
                      'birthDate': registrationNotifier.birthdate,
                      'sex': registrationNotifier.sex,
                      'phoneNumber': registrationNotifier.phoneNumber,
                      'address': registrationNotifier.address,
                      'civilStatus': registrationNotifier.civilStatus,
                      'classification': registrationNotifier.classification,
                      'uhsIdNumber': registrationNotifier.uhsId,
                      'vaccinationStatus':
                          registrationNotifier.vaccinationStatus
                    };

                    await authNotifier.createUserWithEmailAndPassword(
                        registrationNotifier.email,
                        registrationNotifier.password,
                        userData);

                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: authNotifier.isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Register'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Go back to Login screen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
