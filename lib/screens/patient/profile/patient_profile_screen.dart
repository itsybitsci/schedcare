import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schedcare/providers/firebase_provider.dart';
import 'package:schedcare/providers/generic_fields_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/prompts.dart';
import 'package:schedcare/utilities/widgets.dart';

class PatientProfileScreen extends HookConsumerWidget {
  PatientProfileScreen({super.key});
  final GlobalKey<FormState> formKeyUpdatePassword = GlobalKey<FormState>();
  final Stream<DocumentSnapshot<Map<String, dynamic>>> userSnapshots =
      FirebaseFirestore.instance
          .collection(FirestoreConstants.usersCollection)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseNotifier = ref.watch(firebaseProvider);
    final genericFieldsNotifier = ref.watch(genericFieldsProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Profile',
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
                  (data.get(ModelFields.middleName)).toString().isNotEmpty
                      ? Text(
                          '${data.get(ModelFields.firstName)} ${data.get(ModelFields.middleName)} ${data.get(ModelFields.lastName)} ${data.get(ModelFields.suffix)}')
                      : Text(
                          '${data.get(ModelFields.firstName)} ${data.get(ModelFields.lastName)} ${data.get(ModelFields.suffix)}'),
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
                  firebaseNotifier.getLoading
                      ? loading(color: Colors.blue)
                      : ElevatedButton(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Change Password'),
                                  content: StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setState) {
                                      genericFieldsNotifier
                                          .clearPasswordFields();

                                      return ConstrainedBox(
                                        constraints:
                                            BoxConstraints(maxHeight: 200.h),
                                        child: Form(
                                          key: formKeyUpdatePassword,
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
                                        if (formKeyUpdatePassword.currentState!
                                            .validate()) {
                                          formKeyUpdatePassword.currentState
                                              ?.save();
                                          context.pop();
                                          await firebaseNotifier.updatePassword(
                                              genericFieldsNotifier.password);
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
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(Prompts.errorDueToWeakInternet),
            );
          }

          return loading();
        },
      ),
    );
  }
}
