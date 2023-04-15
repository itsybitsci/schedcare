import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/providers/generic_fields_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/prompts.dart';
import 'package:schedcare/utilities/widgets.dart';

class PatientProfileScreen extends HookConsumerWidget {
  PatientProfileScreen({super.key});
  final GlobalKey<FormState> formKeyUpdatePatientPassword =
      GlobalKey<FormState>();
  final GlobalKey<FormState> formKeyUpdatePatientEmail = GlobalKey<FormState>();
  final Stream<DocumentSnapshot<Map<String, dynamic>>> userSnapshots =
      FirebaseFirestore.instance
          .collection(FirebaseConstants.usersCollection)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);
    final genericFieldsNotifier = ref.watch(genericFieldsProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
            onPressed: () {
              context.push(RoutePaths.editPatientProfile);
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: userSnapshots,
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            DocumentSnapshot<Map<String, dynamic>> data = snapshot.data!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.get(ModelFields.middleName).toString().isNotEmpty
                        ? '${data.get(ModelFields.firstName)} ${data.get(ModelFields.middleName)} ${data.get(ModelFields.lastName)} ${data.get(ModelFields.suffix)}'
                            .trim()
                        : '${data.get(ModelFields.firstName)} ${data.get(ModelFields.lastName)} ${data.get(ModelFields.suffix)}'
                            .trim(),
                  ),
                  Text('Email: ${data.get(ModelFields.email)}'),
                  Text('Age: ${data.get(ModelFields.age)}'),
                  Text('Sex: ${data.get(ModelFields.sex)}'),
                  Text('Contact Number: ${data.get(ModelFields.phoneNumber)}'),
                  Text(
                      'Birthdate: ${DateFormat('yMMMMd').format(data.get(ModelFields.birthDate).toDate())}'),
                  Text('Address: ${data.get(ModelFields.address)}'),
                  if ((data.get(ModelFields.uhsIdNumber)).toString().isNotEmpty)
                    Text('UHS ID Number: ${data.get(ModelFields.uhsIdNumber)}'),
                  if ((data.get(ModelFields.classification))
                      .toString()
                      .isNotEmpty)
                    Text(
                        'Classification: ${data.get(ModelFields.classification)}'),
                  Text('Civil Status: ${data.get(ModelFields.civilStatus)}'),
                  Text(
                      'Vaccination Status: ${data.get(ModelFields.vaccinationStatus)}'),
                  firebaseServicesNotifier.getLoading
                      ? loading(color: Colors.blue)
                      : ElevatedButton(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) {
                                genericFieldsNotifier.clearPasswordFields();
                                return AlertDialog(
                                  title: const Text('Enter New Password'),
                                  content: StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setState) {
                                      return ConstrainedBox(
                                        constraints:
                                            BoxConstraints(maxHeight: 200.h),
                                        child: Form(
                                          key: formKeyUpdatePatientPassword,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              genericFieldsNotifier
                                                  .buildPassword(setState),
                                              genericFieldsNotifier
                                                  .buildRepeatPassword(
                                                      setState),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => context.pop(),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        if (formKeyUpdatePatientPassword
                                            .currentState!
                                            .validate()) {
                                          formKeyUpdatePatientPassword
                                              .currentState
                                              ?.save();
                                          context.pop();
                                          await firebaseServicesNotifier
                                              .updatePassword(
                                                  genericFieldsNotifier
                                                      .password);
                                        }
                                      },
                                      child: const Text('Update Password'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text('Change Password'),
                        ),
                  firebaseServicesNotifier.getLoading
                      ? loading(color: Colors.blue)
                      : ElevatedButton(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) {
                                genericFieldsNotifier.clearEmailField();
                                return AlertDialog(
                                  title: const Text('Enter New Email Address'),
                                  content: ConstrainedBox(
                                    constraints:
                                        BoxConstraints(maxHeight: 200.h),
                                    child: Form(
                                      key: formKeyUpdatePatientEmail,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          genericFieldsNotifier.buildEmail(),
                                        ],
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => context.pop(),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        if (formKeyUpdatePatientEmail
                                            .currentState!
                                            .validate()) {
                                          formKeyUpdatePatientEmail.currentState
                                              ?.save();
                                          context.pop();
                                          await firebaseServicesNotifier
                                              .updateEmail(
                                                  firebaseServicesNotifier
                                                      .getCurrentUser!,
                                                  genericFieldsNotifier.email)
                                              .then(
                                            (success) async {
                                              if (success) {
                                                await firebaseServicesNotifier
                                                    .getFirebaseFirestoreService
                                                    .updateDocument(
                                                        {
                                                      ModelFields.email:
                                                          genericFieldsNotifier
                                                              .email,
                                                      ModelFields.modifiedAt:
                                                          DateTime.now()
                                                    },
                                                        FirebaseConstants
                                                            .usersCollection,
                                                        firebaseServicesNotifier
                                                            .getCurrentUser!
                                                            .uid);
                                              }
                                            },
                                          );
                                        }
                                      },
                                      child: const Text('Confirm'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text('Change Email Address'),
                        )
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(Prompts.errorDueToWeakInternet),
            );
          }

          return loading(color: Colors.blue);
        },
      ),
    );
  }
}
