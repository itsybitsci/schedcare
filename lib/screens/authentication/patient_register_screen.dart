import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/firebase_provider.dart';
import 'package:schedcare/providers/registration_provider.dart';
import 'package:schedcare/utilities/constants.dart';

class PatientRegisterScreen extends HookConsumerWidget {
  PatientRegisterScreen({super.key});
  final GlobalKey<FormState> formKeyRegisterPatient = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseNotifier = ref.watch(firebaseProvider);
    final registrationNotifier = ref.watch(registrationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Patient'),
        automaticallyImplyLeading: false,
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
                      ModelFields.email: registrationNotifier.email,
                      ModelFields.role: RegistrationConstants.patient,
                      ModelFields.firstName: registrationNotifier.firstName,
                      ModelFields.middleName: registrationNotifier.middleName,
                      ModelFields.lastName: registrationNotifier.lastName,
                      ModelFields.suffix: registrationNotifier.suffix,
                      ModelFields.age: registrationNotifier.age,
                      ModelFields.birthDate: registrationNotifier.birthdate,
                      ModelFields.sex: registrationNotifier.sex,
                      ModelFields.phoneNumber: registrationNotifier.phoneNumber,
                      ModelFields.address: registrationNotifier.address,
                      ModelFields.civilStatus: registrationNotifier.civilStatus,
                      ModelFields.classification:
                          registrationNotifier.classification,
                      ModelFields.uhsIdNumber: registrationNotifier.uhsId,
                      ModelFields.vaccinationStatus:
                          registrationNotifier.vaccinationStatus,
                      ModelFields.isApproved: true,
                    };

                    await firebaseNotifier.createUserWithEmailAndPassword(
                        registrationNotifier.email,
                        registrationNotifier.password,
                        userData);

                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: firebaseNotifier.getLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Register'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.pop();
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
