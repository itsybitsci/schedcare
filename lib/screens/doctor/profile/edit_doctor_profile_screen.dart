import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/providers/generic_fields_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/widgets.dart';

class EditDoctorProfileScreen extends HookConsumerWidget {
  EditDoctorProfileScreen({Key? key}) : super(key: key);
  final GlobalKey<FormState> formKeyEditDoctorProfile = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);
    final genericFieldsNotifier = ref.watch(genericFieldsProvider);

    useEffect(() {
      Future<void> fetchData() async {
        DocumentSnapshot<Map<String, dynamic>> data = await FirebaseFirestore
            .instance
            .collection(FirestoreConstants.usersCollection)
            .doc(firebaseServicesNotifier.getCurrentUser!.uid)
            .get();
        genericFieldsNotifier.setPrefix = data.get(ModelFields.prefix);
        genericFieldsNotifier.setFirstName = data.get(ModelFields.firstName);
        genericFieldsNotifier.setFirstName = data.get(ModelFields.firstName);
        genericFieldsNotifier.setMiddleName = data.get(ModelFields.middleName);
        genericFieldsNotifier.setLastName = data.get(ModelFields.lastName);
        genericFieldsNotifier.setSuffix = data.get(ModelFields.suffix);
        genericFieldsNotifier.setSexesDropdownValue = data.get(ModelFields.sex);
        genericFieldsNotifier.setSpecialization =
            data.get(ModelFields.specialization);
      }

      fetchData();
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Form(
        key: formKeyEditDoctorProfile,
        child: SingleChildScrollView(
          reverse: true,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              genericFieldsNotifier.buildPrefix(),
              genericFieldsNotifier.buildFirstName(),
              genericFieldsNotifier.buildMiddleName(),
              genericFieldsNotifier.buildLastName(),
              genericFieldsNotifier.buildSuffix(),
              genericFieldsNotifier.buildSexesDropdown(editProfile: true),
              genericFieldsNotifier.buildSpecialization(),
              firebaseServicesNotifier.getLoading
                  ? loading(color: Colors.blue)
                  : ElevatedButton(
                      onPressed: () async {
                        if (formKeyEditDoctorProfile.currentState!.validate()) {
                          formKeyEditDoctorProfile.currentState?.save();
                          Map<String, dynamic> data = {
                            ModelFields.id:
                                firebaseServicesNotifier.getCurrentUser!.uid,
                            ModelFields.prefix: genericFieldsNotifier.prefix,
                            ModelFields.firstName:
                                genericFieldsNotifier.firstName,
                            ModelFields.middleName:
                                genericFieldsNotifier.middleName,
                            ModelFields.lastName:
                                genericFieldsNotifier.lastName,
                            ModelFields.suffix: genericFieldsNotifier.suffix,
                            ModelFields.sex: genericFieldsNotifier.sex,
                            ModelFields.specialization:
                                genericFieldsNotifier.specialization,
                            ModelFields.modifiedAt: DateTime.now(),
                          };

                          await firebaseServicesNotifier
                              .updateUserProfile(
                                  data,
                                  FirestoreConstants.usersCollection,
                                  firebaseServicesNotifier.getCurrentUser!.uid)
                              .then(
                                (success) => success ? context.pop() : null,
                              );
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
