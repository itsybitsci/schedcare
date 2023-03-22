import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/firebase_provider.dart';
import 'package:schedcare/providers/registration_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/widgets.dart';

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
              registrationNotifier.buildAge(),
              registrationNotifier.buildSexesDropdown(),
              registrationNotifier.buildEmail(),
              registrationNotifier.buildPhoneNumber(),
              registrationNotifier.buildBirthdate(context),
              registrationNotifier.buildAddress(),
              registrationNotifier.buildClassification(),
              registrationNotifier.buildCivilStatus(),
              registrationNotifier.buildVaccinationStatus(),
              registrationNotifier.buildPassword(),
              registrationNotifier.buildRepeatPassword(),
              ElevatedButton(
                onPressed: () async {
                  if (formKeyRegisterPatient.currentState!.validate()) {
                    formKeyRegisterPatient.currentState?.save();
                    Map<String, dynamic> userData = {
                      ModelFields.email: registrationNotifier.email,
                      ModelFields.role: AppConstants.patient,
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
                      ModelFields.uhsIdNumber: registrationNotifier.uhsIdNumber,
                      ModelFields.vaccinationStatus:
                          registrationNotifier.vaccinationStatus,
                      ModelFields.isApproved: true,
                    };

                    await firebaseNotifier.createUserWithEmailAndPassword(
                        registrationNotifier.email,
                        registrationNotifier.password,
                        userData);

                    if (context.mounted) context.pop();
                  }
                },
                child: firebaseNotifier.getLoading
                    ? loading()
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
