import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/providers/generic_fields_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/prompts.dart';
import 'package:schedcare/utilities/widgets.dart';

class DoctorProfileScreen extends HookConsumerWidget {
  DoctorProfileScreen({Key? key}) : super(key: key);
  final GlobalKey<FormState> formKeyUpdateDoctorPassword =
      GlobalKey<FormState>();
  final Stream<DocumentSnapshot<Map<String, dynamic>>> userSnapshots =
      FirebaseFirestore.instance
          .collection(FirestoreConstants.usersCollection)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);
    final genericFieldsNotifier = ref.watch(genericFieldsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
            onPressed: () {
              context.push(RoutePaths.editDoctorProfile);
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
                        ? '${data.get(ModelFields.prefix)} ${data.get(ModelFields.firstName)} ${data.get(ModelFields.middleName)} ${data.get(ModelFields.lastName)} ${data.get(ModelFields.suffix)}'
                            .trim()
                        : '${data.get(ModelFields.prefix)} ${data.get(ModelFields.firstName)} ${data.get(ModelFields.lastName)} ${data.get(ModelFields.suffix)}'
                            .trim(),
                  ),
                  Text('Sex: ${data.get(ModelFields.sex)}'),
                  Text(
                      'Specialization: ${data.get(ModelFields.specialization)}'),
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
                                          key: formKeyUpdateDoctorPassword,
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
                                        if (formKeyUpdateDoctorPassword
                                            .currentState!
                                            .validate()) {
                                          formKeyUpdateDoctorPassword
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
