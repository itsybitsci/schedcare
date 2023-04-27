import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/providers/generic_fields_provider.dart';
import 'package:schedcare/utilities/animations.dart';
import 'package:schedcare/utilities/components.dart';
import 'package:schedcare/utilities/constants.dart';

class EditPatientProfileScreen extends HookConsumerWidget {
  EditPatientProfileScreen({Key? key}) : super(key: key);
  final GlobalKey<FormState> formKeyEditPatientProfile = GlobalKey<FormState>();

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
        genericFieldsNotifier.setFirstName = data.get(ModelFields.firstName);
        genericFieldsNotifier.setFirstName = data.get(ModelFields.firstName);
        genericFieldsNotifier.setMiddleName = data.get(ModelFields.middleName);
        genericFieldsNotifier.setLastName = data.get(ModelFields.lastName);
        genericFieldsNotifier.setSuffix = data.get(ModelFields.suffix);
        genericFieldsNotifier.setAge = data.get(ModelFields.age).toString();
        genericFieldsNotifier.setSexesDropdownValue = data.get(ModelFields.sex);
        genericFieldsNotifier.setPhoneNumber =
            data.get(ModelFields.phoneNumber);
        genericFieldsNotifier.setBirthDate = DateFormat('yMMMMd')
            .format(data.get(ModelFields.birthDate).toDate());
        genericFieldsNotifier.setChosenDate =
            data.get(ModelFields.birthDate).toDate();
        genericFieldsNotifier.setAddress = data.get(ModelFields.address);
        genericFieldsNotifier.setUhsIdNumber =
            data.get(ModelFields.uhsIdNumber);
        genericFieldsNotifier.setClassification =
            data.get(ModelFields.classification);
        genericFieldsNotifier.setCivilStatus =
            data.get(ModelFields.civilStatus);
        genericFieldsNotifier.setVaccinationStatus =
            data.get(ModelFields.vaccinationStatus);
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
                            key: formKeyEditPatientProfile,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ConstrainedBox(
                                    constraints:
                                        BoxConstraints(maxWidth: 100.w),
                                    child: lottieRegister()),
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ConstrainedBox(
                                      constraints:
                                          BoxConstraints(maxWidth: 130.w),
                                      child: genericFieldsNotifier.buildAge(),
                                    ),
                                    SizedBox(width: 10.w),
                                    ConstrainedBox(
                                      constraints:
                                          BoxConstraints(maxWidth: 160.w),
                                      child: genericFieldsNotifier
                                          .buildSexesDropdown(
                                              editProfile: true),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 300.w),
                                  child:
                                      genericFieldsNotifier.buildPhoneNumber(),
                                ),
                                SizedBox(height: 10.h),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 300.w),
                                  child: genericFieldsNotifier
                                      .buildBirthdate(context),
                                ),
                                SizedBox(height: 10.h),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 300.w),
                                  child: genericFieldsNotifier.buildAddress(),
                                ),
                                SizedBox(height: 10.h),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 300.w),
                                  child:
                                      genericFieldsNotifier.buildUhsIdNumber(),
                                ),
                                SizedBox(height: 10.h),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 300.w),
                                  child: genericFieldsNotifier
                                      .buildClassification(editProfile: true),
                                ),
                                SizedBox(height: 10.h),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 300.w),
                                  child: genericFieldsNotifier.buildCivilStatus(
                                      editProfile: true),
                                ),
                                SizedBox(height: 10.h),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 300.w),
                                  child: genericFieldsNotifier
                                      .buildVaccinationStatus(
                                          editProfile: true),
                                ),
                                SizedBox(height: 10.h),
                                ElevatedButton(
                                  onPressed: firebaseServicesNotifier.getLoading
                                      ? null
                                      : () async {
                                          if (formKeyEditPatientProfile
                                              .currentState!
                                              .validate()) {
                                            formKeyEditPatientProfile
                                                .currentState
                                                ?.save();
                                            Map<String, dynamic> data = {
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
                                              ModelFields.age:
                                                  genericFieldsNotifier.age,
                                              ModelFields.birthDate:
                                                  genericFieldsNotifier
                                                      .birthdate,
                                              ModelFields.sex:
                                                  genericFieldsNotifier.sex,
                                              ModelFields.phoneNumber:
                                                  genericFieldsNotifier
                                                      .phoneNumber,
                                              ModelFields.address:
                                                  genericFieldsNotifier.address,
                                              ModelFields.civilStatus:
                                                  genericFieldsNotifier
                                                      .civilStatus,
                                              ModelFields.classification:
                                                  genericFieldsNotifier
                                                      .classification,
                                              ModelFields.uhsIdNumber:
                                                  genericFieldsNotifier
                                                      .uhsIdNumber,
                                              ModelFields.vaccinationStatus:
                                                  genericFieldsNotifier
                                                      .vaccinationStatus,
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
