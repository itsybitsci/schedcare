import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/providers/generic_fields_provider.dart';
import 'package:schedcare/utilities/animations.dart';
import 'package:schedcare/utilities/components.dart';
import 'package:schedcare/utilities/constants.dart';

class EditDoctorProfileScreen extends HookConsumerWidget {
  EditDoctorProfileScreen({Key? key}) : super(key: key);
  final GlobalKey<FormState> formKeyEditDoctorProfile = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);
    final genericFieldsNotifier = ref.watch(genericFieldsProvider);
    final scrollController = useScrollController();

    useEffect(() {
      Future<void> fetchData() async {
        DocumentSnapshot<Map<String, dynamic>> data = await FirebaseFirestore
            .instance
            .collection(FirebaseConstants.usersCollection)
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(AppConstants.appTitle),
      ),
      body: WillPopScope(
        onWillPop: () async => !firebaseServicesNotifier.getLoading,
        child: Background(
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
                        'Edit Profile',
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
                      child: Scrollbar(
                        radius: Radius.circular(20.r),
                        controller: scrollController,
                        child: SingleChildScrollView(
                          child: Form(
                            key: formKeyEditDoctorProfile,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ConstrainedBox(
                                    constraints:
                                        BoxConstraints(maxWidth: 100.w),
                                    child: lottieRegister()),
                                ConstrainedBox(
                                    constraints:
                                        BoxConstraints(maxWidth: 300.w),
                                    child: genericFieldsNotifier.buildPrefix()),
                                SizedBox(height: 10.h),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 300.w),
                                  child: genericFieldsNotifier.buildFirstName(),
                                ),
                                SizedBox(height: 10.h),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 300.w),
                                  child:
                                      genericFieldsNotifier.buildMiddleName(),
                                ),
                                SizedBox(height: 10.h),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 300.w),
                                  child: genericFieldsNotifier.buildLastName(),
                                ),
                                SizedBox(height: 10.h),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 300.w),
                                  child: genericFieldsNotifier.buildSuffix(),
                                ),
                                SizedBox(height: 10.h),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 300.w),
                                  child: genericFieldsNotifier
                                      .buildSexesDropdown(editProfile: true),
                                ),
                                SizedBox(height: 10.h),
                                ConstrainedBox(
                                    constraints:
                                        BoxConstraints(maxWidth: 300.w),
                                    child: genericFieldsNotifier
                                        .buildSpecialization()),
                                SizedBox(height: 10.h),
                                ElevatedButton(
                                  onPressed: firebaseServicesNotifier.getLoading
                                      ? null
                                      : () async {
                                          if (formKeyEditDoctorProfile
                                              .currentState!
                                              .validate()) {
                                            formKeyEditDoctorProfile
                                                .currentState
                                                ?.save();
                                            Map<String, dynamic> data = {
                                              ModelFields.id:
                                                  firebaseServicesNotifier
                                                      .getCurrentUser!.uid,
                                              ModelFields.prefix:
                                                  genericFieldsNotifier.prefix,
                                              ModelFields.firstName:
                                                  genericFieldsNotifier
                                                      .firstName,
                                              ModelFields.middleName:
                                                  genericFieldsNotifier
                                                      .middleName,
                                              ModelFields.lastName:
                                                  genericFieldsNotifier
                                                      .lastName,
                                              ModelFields.suffix:
                                                  genericFieldsNotifier.suffix,
                                              ModelFields.sex:
                                                  genericFieldsNotifier.sex,
                                              ModelFields.specialization:
                                                  genericFieldsNotifier
                                                      .specialization,
                                              ModelFields.modifiedAt:
                                                  DateTime.now(),
                                            };

                                            await firebaseServicesNotifier
                                                .updateUserProfile(
                                                    data,
                                                    FirebaseConstants
                                                        .usersCollection,
                                                    firebaseServicesNotifier
                                                        .getCurrentUser!.uid)
                                                .then(
                                                  (success) => success
                                                      ? context.pop()
                                                      : null,
                                                );
                                          }
                                        },
                                  child: Text(
                                    'Save Details',
                                    style: TextStyle(fontSize: 15.sp),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
