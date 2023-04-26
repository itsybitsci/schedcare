import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/providers/generic_fields_provider.dart';
import 'package:schedcare/utilities/animations.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/prompts.dart';
import 'package:schedcare/utilities/widgets.dart';

class DoctorProfileScreen extends HookConsumerWidget {
  DoctorProfileScreen({Key? key}) : super(key: key);
  final GlobalKey<FormState> formKeyUpdateDoctorPassword =
      GlobalKey<FormState>();
  final GlobalKey<FormState> formKeyUpdateDoctorEmail = GlobalKey<FormState>();
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
                      'Doctor Profile',
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
                        if (snapshot.hasError) {
                          return lottieError();
                        }

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
                                        ? '${data.get(ModelFields.prefix)} ${data.get(ModelFields.firstName)} ${data.get(ModelFields.middleName)} ${data.get(ModelFields.lastName)} ${data.get(ModelFields.suffix)}'
                                            .trim()
                                        : '${data.get(ModelFields.prefix)} ${data.get(ModelFields.firstName)} ${data.get(ModelFields.lastName)} ${data.get(ModelFields.suffix)}'
                                            .trim(),
                                    style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 12.h),
                                Text('Email: ${data.get(ModelFields.email)}',
                                    style: TextStyle(fontSize: 13.sp)),
                                SizedBox(height: 3.h),
                                Text('Sex: ${data.get(ModelFields.sex)}',
                                    style: TextStyle(fontSize: 13.sp)),
                                SizedBox(height: 3.h),
                                Text(
                                    'Specialization: ${data.get(ModelFields.specialization)}',
                                    style: TextStyle(fontSize: 13.sp)),
                                SizedBox(height: 30.h),
                                buildChangePasswordButton(
                                    context,
                                    firebaseServicesNotifier,
                                    genericFieldsNotifier,
                                    formKeyUpdateDoctorPassword),
                                buildChangeEmailButton(
                                    context,
                                    firebaseServicesNotifier,
                                    genericFieldsNotifier,
                                    formKeyUpdateDoctorEmail),
                                ElevatedButton(
                                  onPressed: () => context
                                      .push(RoutePaths.editDoctorProfile),
                                  child: Text(
                                    'Edit Profile',
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
