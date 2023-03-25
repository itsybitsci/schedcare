import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schedcare/providers/firebase_provider.dart';
import 'package:schedcare/providers/generic_fields_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/widgets.dart';

class EditPatientProfileScreen extends HookConsumerWidget {
  EditPatientProfileScreen({Key? key}) : super(key: key);
  final GlobalKey<FormState> formKeyEditPatientProfile = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseNotifier = ref.watch(firebaseProvider);
    final genericFieldsNotifier = ref.watch(genericFieldsProvider);

    Future setData(DocumentSnapshot<Map<String, dynamic>> data) async {
      genericFieldsNotifier.setFirstName = data.get(ModelFields.firstName);
      genericFieldsNotifier.setFirstName = data.get(ModelFields.firstName);
      genericFieldsNotifier.setMiddleName = data.get(ModelFields.middleName);
      genericFieldsNotifier.setLastName = data.get(ModelFields.lastName);
      genericFieldsNotifier.setSuffix = data.get(ModelFields.suffix);
      genericFieldsNotifier.setAge = data.get(ModelFields.age).toString();
      genericFieldsNotifier.setSexesDropdownValue = data.get(ModelFields.sex);
      genericFieldsNotifier.setPhoneNumber = data.get(ModelFields.phoneNumber);
      genericFieldsNotifier.setBirthDate =
          DateFormat('yMMMMd').format(data.get(ModelFields.birthDate).toDate());
      genericFieldsNotifier.setChosenDate =
          data.get(ModelFields.birthDate).toDate();
      genericFieldsNotifier.setAddress = data.get(ModelFields.address);
      genericFieldsNotifier.setUhsIdNumber = data.get(ModelFields.uhsIdNumber);
      genericFieldsNotifier.setClassification =
          data.get(ModelFields.classification);
      genericFieldsNotifier.setCivilStatus = data.get(ModelFields.civilStatus);
      genericFieldsNotifier.setVaccinationStatus =
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
              genericFieldsNotifier.buildFirstName(),
              genericFieldsNotifier.buildMiddleName(),
              genericFieldsNotifier.buildLastName(),
              genericFieldsNotifier.buildSuffix(),
              genericFieldsNotifier.buildAge(),
              genericFieldsNotifier.buildSexesDropdown(editProfile: true),
              genericFieldsNotifier.buildPhoneNumber(),
              genericFieldsNotifier.buildBirthdate(context),
              genericFieldsNotifier.buildAddress(),
              genericFieldsNotifier.buildUhsIdNumber(),
              genericFieldsNotifier.buildClassification(editProfile: true),
              genericFieldsNotifier.buildCivilStatus(editProfile: true),
              genericFieldsNotifier.buildVaccinationStatus(editProfile: true),
              firebaseNotifier.getLoading
                  ? loading(color: Colors.blue)
                  : ElevatedButton(
                      onPressed: () async {
                        if (formKeyEditPatientProfile.currentState!
                            .validate()) {
                          formKeyEditPatientProfile.currentState?.save();
                          Map<String, dynamic> data = {
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
                          };

                          await firebaseNotifier
                              .updateUserProfile(
                                  data,
                                  FirestoreConstants.usersCollection,
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
