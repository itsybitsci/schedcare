import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/edit_profile_provider.dart';
import 'package:schedcare/providers/firebase_provider.dart';
import 'package:schedcare/utilities/constants.dart';

class PatientProfilePage extends HookConsumerWidget {
  PatientProfilePage({Key? key}) : super(key: key);
  final GlobalKey<FormState> formKeyEditPatientProfile = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseNotifier = ref.watch(firebaseProvider);
    final editProfileNotifier = ref.watch(editProfileProvider);

    useEffect(
      () {
        Future.microtask(
          () async {
            DocumentSnapshot<Map<String, dynamic>> data =
                await FirebaseFirestore.instance
                    .collection(FirestoreConstants.usersCollection)
                    .doc(firebaseNotifier.getCurrentUser!.uid)
                    .get();
            editProfileNotifier.setFirstName = data.get(ModelFields.firstName);
            editProfileNotifier.setFirstName = data.get(ModelFields.firstName);
            editProfileNotifier.setMiddleName =
                data.get(ModelFields.middleName);
            editProfileNotifier.setLastName = data.get(ModelFields.lastName);
            editProfileNotifier.setSuffix = data.get(ModelFields.suffix);
            editProfileNotifier.setAge = data.get(ModelFields.age).toString();
            editProfileNotifier.setSexesDropdownValue =
                data.get(ModelFields.sex);
            editProfileNotifier.setPhoneNumber =
                data.get(ModelFields.phoneNumber);
            editProfileNotifier.setBirthDate = data.get(ModelFields.birthDate);
            editProfileNotifier.setAddress = data.get(ModelFields.address);
            editProfileNotifier.setUhsIdNumber =
                data.get(ModelFields.uhsIdNumber);
            editProfileNotifier.setClassification =
                data.get(ModelFields.classification);
            editProfileNotifier.setCivilStatus =
                data.get(ModelFields.civilStatus);
            editProfileNotifier.setVaccinationStatus =
                data.get(ModelFields.vaccinationStatus);
          },
        );
        return null;
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Form(
        key: formKeyEditPatientProfile,
        child: SingleChildScrollView(
          reverse: true,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              editProfileNotifier.buildFirstName(),
              editProfileNotifier.buildMiddleName(),
              editProfileNotifier.buildLastName(),
              editProfileNotifier.buildSuffix(),
              editProfileNotifier.buildAge(),
              editProfileNotifier.buildSexesDropdown(),
              editProfileNotifier.buildPhoneNumber(),
              editProfileNotifier.buildBirthdate(context),
              editProfileNotifier.buildAddress(),
              editProfileNotifier.buildUhsIdNumber(),
              editProfileNotifier.buildClassification(),
              editProfileNotifier.buildCivilStatus(),
              editProfileNotifier.buildVaccinationStatus(),
              ElevatedButton(
                onPressed: () async {
                  if (formKeyEditPatientProfile.currentState!.validate()) {
                    formKeyEditPatientProfile.currentState?.save();
                    Map<String, dynamic> userData = {
                      ModelFields.firstName: editProfileNotifier.firstName,
                      ModelFields.middleName: editProfileNotifier.middleName,
                      ModelFields.lastName: editProfileNotifier.lastName,
                      ModelFields.suffix: editProfileNotifier.suffix,
                      ModelFields.age: editProfileNotifier.age,
                      ModelFields.birthDate: editProfileNotifier.birthdate,
                      ModelFields.sex: editProfileNotifier.sex,
                      ModelFields.phoneNumber: editProfileNotifier.phoneNumber,
                      ModelFields.address: editProfileNotifier.address,
                      ModelFields.civilStatus: editProfileNotifier.civilStatus,
                      ModelFields.classification:
                          editProfileNotifier.classification,
                      ModelFields.uhsIdNumber: editProfileNotifier.uhsIdNumber,
                      ModelFields.vaccinationStatus:
                          editProfileNotifier.vaccinationStatus,
                    };

                    await firebaseNotifier
                        .updateUser(
                            userData, firebaseNotifier.getCurrentUser!.uid)
                        .then((success) => success ? context.pop() : null);
                  }
                },
                child: firebaseNotifier.getLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Save Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
