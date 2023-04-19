import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remove_emoji/remove_emoji.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/providers/generic_fields_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/widgets.dart';

class PatientRegisterScreen extends HookConsumerWidget {
  PatientRegisterScreen({super.key});

  final GlobalKey<FormState> formKeyRegisterPatient = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);
    final genericFieldsNotifier = ref.watch(genericFieldsProvider);

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
              genericFieldsNotifier.buildFirstName(),
              genericFieldsNotifier.buildMiddleName(),
              genericFieldsNotifier.buildLastName(),
              genericFieldsNotifier.buildSuffix(),
              genericFieldsNotifier.buildAge(),
              genericFieldsNotifier.buildSexesDropdown(),
              genericFieldsNotifier.buildEmail(),
              genericFieldsNotifier.buildPhoneNumber(),
              genericFieldsNotifier.buildBirthdate(context),
              genericFieldsNotifier.buildAddress(),
              genericFieldsNotifier.buildClassification(),
              genericFieldsNotifier.buildCivilStatus(),
              genericFieldsNotifier.buildVaccinationStatus(),
              genericFieldsNotifier.buildPassword(),
              genericFieldsNotifier.buildRepeatPassword(),
              firebaseServicesNotifier.getLoading
                  ? loading(color: Colors.blue)
                  : ElevatedButton(
                      onPressed: () async {
                        if (formKeyRegisterPatient.currentState!.validate()) {
                          formKeyRegisterPatient.currentState?.save();
                          Map<String, dynamic> data = {
                            ModelFields.id:
                                firebaseServicesNotifier.getCurrentUser!.uid,
                            ModelFields.email: genericFieldsNotifier.email,
                            ModelFields.role: AppConstants.patient,
                            ModelFields.firstName:
                                genericFieldsNotifier.firstName,
                            ModelFields.middleName:
                                genericFieldsNotifier.middleName,
                            ModelFields.lastName:
                                genericFieldsNotifier.lastName,
                            ModelFields.suffix: genericFieldsNotifier.suffix,
                            ModelFields.age: genericFieldsNotifier.age,
                            ModelFields.birthDate:
                                genericFieldsNotifier.birthdate,
                            ModelFields.sex: genericFieldsNotifier.sex,
                            ModelFields.phoneNumber:
                                genericFieldsNotifier.phoneNumber,
                            ModelFields.address: genericFieldsNotifier.address,
                            ModelFields.civilStatus:
                                genericFieldsNotifier.civilStatus,
                            ModelFields.classification:
                                genericFieldsNotifier.classification,
                            ModelFields.uhsIdNumber:
                                genericFieldsNotifier.uhsIdNumber,
                            ModelFields.vaccinationStatus:
                                genericFieldsNotifier.vaccinationStatus,
                            ModelFields.isApproved: true,
                          };

                          await firebaseServicesNotifier
                              .createUserWithEmailAndPassword(
                                  genericFieldsNotifier.email.removEmoji,
                                  genericFieldsNotifier.password,
                                  data);

                          if (context.mounted) context.pop();
                        }
                      },
                      child: const Text('Register'),
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
