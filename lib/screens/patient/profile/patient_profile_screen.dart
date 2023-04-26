import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/providers/generic_fields_provider.dart';
import 'package:schedcare/utilities/animations.dart';
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
        title: const Text(AppConstants.appTitle),
      ),
      body: WillPopScope(
        onWillPop: () async => !firebaseServicesNotifier.getLoading,
        child: Center(
          child: Container(
            height: 580.h,
            width: 340.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: ColorConstants.primaryLight,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 320.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      'Patient Profile',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.sp),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Flexible(
                  child: Container(
                    width: 320.w,
                    height: 510.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: Colors.white,
                    ),
                    child: StreamBuilder(
                      stream: userSnapshots,
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (snapshot.hasData) {
                          DocumentSnapshot<Map<String, dynamic>> data =
                              snapshot.data!;
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                data.get(ModelFields.sex) == AppConstants.male
                                    ? lottieMale()
                                    : lottieFemale(),
                                Text(
                                    data
                                            .get(ModelFields.middleName)
                                            .toString()
                                            .isNotEmpty
                                        ? '${data.get(ModelFields.firstName)} ${data.get(ModelFields.middleName)} ${data.get(ModelFields.lastName)} ${data.get(ModelFields.suffix)}'
                                            .trim()
                                        : '${data.get(ModelFields.firstName)} ${data.get(ModelFields.lastName)} ${data.get(ModelFields.suffix)}'
                                            .trim(),
                                    style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 12.h),
                                Text('Email: ${data.get(ModelFields.email)}',
                                    style: TextStyle(fontSize: 13.sp)),
                                SizedBox(height: 3.h),
                                Text('Age: ${data.get(ModelFields.age)}',
                                    style: TextStyle(fontSize: 13.sp)),
                                SizedBox(height: 3.h),
                                Text('Sex: ${data.get(ModelFields.sex)}',
                                    style: TextStyle(fontSize: 13.sp)),
                                SizedBox(height: 3.h),
                                Text(
                                    'Contact Number: ${data.get(ModelFields.phoneNumber)}',
                                    style: TextStyle(fontSize: 13.sp)),
                                SizedBox(height: 3.h),
                                Text(
                                    'Birthdate: ${DateFormat('yMMMMd').format(data.get(ModelFields.birthDate).toDate())}',
                                    style: TextStyle(fontSize: 13.sp)),
                                SizedBox(height: 3.h),
                                Text(
                                    'Address: ${data.get(ModelFields.address)}',
                                    style: TextStyle(fontSize: 13.sp)),
                                SizedBox(height: 3.h),
                                if ((data.get(ModelFields.uhsIdNumber))
                                    .toString()
                                    .isNotEmpty)
                                  Text(
                                      'UHS ID Number: ${data.get(ModelFields.uhsIdNumber)}',
                                      style: TextStyle(fontSize: 13.sp)),
                                if ((data.get(ModelFields.classification))
                                    .toString()
                                    .isNotEmpty)
                                  Text(
                                      'Classification: ${data.get(ModelFields.classification)}',
                                      style: TextStyle(fontSize: 13.sp)),
                                Text(
                                    'Civil Status: ${data.get(ModelFields.civilStatus)}',
                                    style: TextStyle(fontSize: 13.sp)),
                                Text(
                                    'Vaccination Status: ${data.get(ModelFields.vaccinationStatus)}',
                                    style: TextStyle(fontSize: 13.sp)),
                                SizedBox(height: 10.h),
                                buildChangePasswordButton(
                                    context,
                                    firebaseServicesNotifier,
                                    genericFieldsNotifier),
                                buildChangeEmailButton(
                                    context,
                                    firebaseServicesNotifier,
                                    genericFieldsNotifier),
                                ElevatedButton(
                                    onPressed: () => context
                                        .push(RoutePaths.editPatientProfile),
                                    child: Text(
                                      'Edit Profile',
                                      style: TextStyle(fontSize: 12.sp),
                                    )),
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildChangePasswordButton(
          BuildContext context,
          FirebaseServicesProvider firebaseServicesNotifier,
          GenericFieldsProvider genericFieldsNotifier) =>
      ElevatedButton(
        onPressed: firebaseServicesNotifier.getLoading
            ? null
            : () async => await showDialog(
                  context: context,
                  builder: (context) {
                    genericFieldsNotifier.clearPasswordFields();
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      title: Text(
                        'Enter New Password',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20.sp),
                      ),
                      content: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: 200.h),
                            child: Form(
                              key: formKeyUpdatePatientPassword,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  genericFieldsNotifier.buildPassword(setState),
                                  SizedBox(height: 10.h),
                                  genericFieldsNotifier
                                      .buildRepeatPassword(setState),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      actionsAlignment: MainAxisAlignment.spaceEvenly,
                      actions: [
                        TextButton(
                          onPressed: () => context.pop(),
                          child: Text(
                            'Cancel',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (formKeyUpdatePatientPassword.currentState!
                                .validate()) {
                              formKeyUpdatePatientPassword.currentState?.save();
                              context.pop();
                              await firebaseServicesNotifier.updatePassword(
                                  genericFieldsNotifier.password);
                            }
                          },
                          child: Text(
                            'Update Password',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        child: Text(
          'Change Password',
          style: TextStyle(fontSize: 12.sp),
        ),
      );

  Widget buildChangeEmailButton(
          BuildContext context,
          FirebaseServicesProvider firebaseServicesNotifier,
          GenericFieldsProvider genericFieldsNotifier) =>
      ElevatedButton(
        onPressed: firebaseServicesNotifier.getLoading
            ? null
            : () async => await showDialog(
                  context: context,
                  builder: (context) {
                    genericFieldsNotifier.clearEmailField();
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      title: Text(
                        'Enter New Email Address',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20.sp),
                      ),
                      content: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 160.h),
                        child: Form(
                          key: formKeyUpdatePatientEmail,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              genericFieldsNotifier.buildEmail(),
                            ],
                          ),
                        ),
                      ),
                      actionsAlignment: MainAxisAlignment.spaceEvenly,
                      actions: [
                        TextButton(
                          onPressed: () => context.pop(),
                          child: Text(
                            'Cancel',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (formKeyUpdatePatientEmail.currentState!
                                .validate()) {
                              formKeyUpdatePatientEmail.currentState?.save();
                              context.pop();
                              await firebaseServicesNotifier
                                  .updateEmail(
                                      firebaseServicesNotifier.getCurrentUser!,
                                      genericFieldsNotifier.email)
                                  .then(
                                (success) async {
                                  if (success) {
                                    await firebaseServicesNotifier
                                        .getFirebaseFirestoreService
                                        .updateDocument(
                                            {
                                          ModelFields.email:
                                              genericFieldsNotifier.email,
                                          ModelFields.modifiedAt: DateTime.now()
                                        },
                                            FirebaseConstants.usersCollection,
                                            firebaseServicesNotifier
                                                .getCurrentUser!.uid);
                                  }
                                },
                              );
                            }
                          },
                          child: Text(
                            'Confirm',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        child: Text(
          'Change Email Address',
          style: TextStyle(fontSize: 12.sp),
        ),
      );
}
