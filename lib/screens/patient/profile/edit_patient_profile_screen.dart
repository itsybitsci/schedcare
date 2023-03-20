import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/firebase_provider.dart';
import 'package:schedcare/providers/registration_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/widgets.dart';

class EditPatientProfileScreen extends HookConsumerWidget {
  EditPatientProfileScreen({Key? key}) : super(key: key);
  final GlobalKey<FormState> formKeyEditPatientProfile = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseNotifier = ref.watch(firebaseProvider);
    final registrationNotifier = ref.watch(registrationProvider);

    Future setData(DocumentSnapshot<Map<String, dynamic>> data) async {
      registrationNotifier.setFirstName = data.get(ModelFields.firstName);
      registrationNotifier.setFirstName = data.get(ModelFields.firstName);
      registrationNotifier.setMiddleName = data.get(ModelFields.middleName);
      registrationNotifier.setLastName = data.get(ModelFields.lastName);
      registrationNotifier.setSuffix = data.get(ModelFields.suffix);
      registrationNotifier.setAge = data.get(ModelFields.age).toString();
      registrationNotifier.setSexesDropdownValue = data.get(ModelFields.sex);
      registrationNotifier.setPhoneNumber = data.get(ModelFields.phoneNumber);
      registrationNotifier.setBirthDate = data.get(ModelFields.birthDate);
      registrationNotifier.setAddress = data.get(ModelFields.address);
      registrationNotifier.setUhsIdNumber = data.get(ModelFields.uhsIdNumber);
      registrationNotifier.setClassification =
          data.get(ModelFields.classification);
      registrationNotifier.setCivilStatus = data.get(ModelFields.civilStatus);
      registrationNotifier.setVaccinationStatus =
          data.get(ModelFields.vaccinationStatus);
    }

    useEffect(
      () {
        Future.microtask(
          () async {
            DocumentSnapshot<Map<String, dynamic>> data =
                await FirebaseFirestore.instance
                    .collection(FirestoreConstants.usersCollection)
                    .doc(firebaseNotifier.getCurrentUser!.uid)
                    .get();
            await setData(data);
          },
        );
        return null;
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Form(
        key: formKeyEditPatientProfile,
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
              registrationNotifier.buildSexesDropdown(editProfile: true),
              registrationNotifier.buildPhoneNumber(),
              registrationNotifier.buildBirthdate(context),
              registrationNotifier.buildAddress(),
              registrationNotifier.buildUhsIdNumber(),
              registrationNotifier.buildClassification(editProfile: true),
              registrationNotifier.buildCivilStatus(editProfile: true),
              registrationNotifier.buildVaccinationStatus(editProfile: true),
              firebaseNotifier.getLoading
                  ? loading(color: Colors.blue)
                  : ElevatedButton(
                      onPressed: () async {
                        if (formKeyEditPatientProfile.currentState!
                            .validate()) {
                          formKeyEditPatientProfile.currentState?.save();
                          Map<String, dynamic> userData = {
                            ModelFields.firstName:
                                registrationNotifier.firstName,
                            ModelFields.middleName:
                                registrationNotifier.middleName,
                            ModelFields.lastName: registrationNotifier.lastName,
                            ModelFields.suffix: registrationNotifier.suffix,
                            ModelFields.age: registrationNotifier.age,
                            ModelFields.birthDate:
                                registrationNotifier.birthdate,
                            ModelFields.sex: registrationNotifier.sex,
                            ModelFields.phoneNumber:
                                registrationNotifier.phoneNumber,
                            ModelFields.address: registrationNotifier.address,
                            ModelFields.civilStatus:
                                registrationNotifier.civilStatus,
                            ModelFields.classification:
                                registrationNotifier.classification,
                            ModelFields.uhsIdNumber:
                                registrationNotifier.uhsIdNumber,
                            ModelFields.vaccinationStatus:
                                registrationNotifier.vaccinationStatus,
                          };

                          await firebaseNotifier
                              .updateUser(userData,
                                  firebaseNotifier.getCurrentUser!.uid)
                              .then(
                                  (success) => success ? context.pop() : null);
                        }
                      },
                      child: const Text('Save Details'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
