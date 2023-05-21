import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remove_emoji/remove_emoji.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/providers/generic_fields_provider.dart';
import 'package:schedcare/utilities/animations.dart';
import 'package:schedcare/utilities/components.dart';
import 'package:schedcare/utilities/constants.dart';

class PatientRegisterScreen extends HookConsumerWidget {
  PatientRegisterScreen({super.key});

  final GlobalKey<FormState> formKeyRegisterPatient = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);
    final genericFieldsNotifier = ref.watch(genericFieldsProvider);
    final scrollController = useScrollController();

    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => !firebaseServicesNotifier.getLoading,
        child: Scrollbar(
          controller: scrollController,
          child: Background(
            child: Form(
              key: formKeyRegisterPatient,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    lottieRegister(),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300.w),
                      child: genericFieldsNotifier.buildFirstName(),
                    ),
                    SizedBox(height: 10.h),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300.w),
                      child: genericFieldsNotifier.buildMiddleName(),
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
                          constraints: BoxConstraints(maxWidth: 130.w),
                          child: genericFieldsNotifier.buildAge(),
                        ),
                        SizedBox(width: 10.w),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 160.w),
                          child: genericFieldsNotifier.buildSexesDropdown(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300.w),
                      child: genericFieldsNotifier.buildEmail(),
                    ),
                    SizedBox(height: 10.h),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300.w),
                      child: genericFieldsNotifier.buildPhoneNumber(),
                    ),
                    SizedBox(height: 10.h),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300.w),
                      child: genericFieldsNotifier.buildBirthdate(context),
                    ),
                    SizedBox(height: 10.h),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300.w),
                      child: genericFieldsNotifier.buildAddress(),
                    ),
                    SizedBox(height: 10.h),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300.w),
                      child: genericFieldsNotifier.buildClassification(),
                    ),
                    SizedBox(height: 10.h),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300.w),
                      child: genericFieldsNotifier.buildCivilStatus(),
                    ),
                    SizedBox(height: 10.h),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300.w),
                      child: genericFieldsNotifier.buildUhsIdNumber(),
                    ),
                    SizedBox(height: 10.h),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300.w),
                      child: genericFieldsNotifier.buildVaccinationStatus(),
                    ),
                    SizedBox(height: 10.h),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300.w),
                      child: genericFieldsNotifier.buildPassword(),
                    ),
                    SizedBox(height: 10.h),
                    ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 300.w),
                        child: genericFieldsNotifier.buildRepeatPassword()),
                    SizedBox(height: 10.h),
                    firebaseServicesNotifier.getLoading
                        ? lottieLoading(width: 100)
                        : ElevatedButton(
                            onPressed: () async {
                              if (formKeyRegisterPatient.currentState!
                                  .validate()) {
                                formKeyRegisterPatient.currentState?.save();
                                Map<String, dynamic> data = {
                                  ModelFields.email:
                                      genericFieldsNotifier.email,
                                  ModelFields.role: AppConstants.patient,
                                  ModelFields.firstName:
                                      genericFieldsNotifier.firstName,
                                  ModelFields.middleName:
                                      genericFieldsNotifier.middleName,
                                  ModelFields.lastName:
                                      genericFieldsNotifier.lastName,
                                  ModelFields.suffix:
                                      genericFieldsNotifier.suffix,
                                  ModelFields.age: genericFieldsNotifier.age,
                                  ModelFields.birthDate:
                                      genericFieldsNotifier.birthdate,
                                  ModelFields.sex: genericFieldsNotifier.sex,
                                  ModelFields.phoneNumber:
                                      genericFieldsNotifier.phoneNumber,
                                  ModelFields.address:
                                      genericFieldsNotifier.address,
                                  ModelFields.civilStatus:
                                      genericFieldsNotifier.civilStatus,
                                  ModelFields.classification:
                                      genericFieldsNotifier.classification,
                                  ModelFields.uhsIdNumber:
                                      genericFieldsNotifier.uhsIdNumber,
                                  ModelFields.vaccinationStatus:
                                      genericFieldsNotifier.vaccinationStatus,
                                  ModelFields.isApproved: true,
                                  ModelFields.isEmailVerified: false,
                                };

                                await firebaseServicesNotifier
                                    .createUserWithEmailAndPassword(
                                        genericFieldsNotifier.email.removEmoji,
                                        genericFieldsNotifier.password,
                                        data);

                                if (context.mounted) context.pop();
                              }
                            },
                            child: Text('REGISTER AS A PATIENT',
                                style: TextStyle(fontSize: 15.sp)),
                          ),
                    SizedBox(height: 10.h),
                    Text(
                      'Already have an account?',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12.sp,
                        ),
                        children: [
                          const TextSpan(text: 'Click '),
                          TextSpan(
                            text: 'here',
                            style: const TextStyle(
                              color: Colors.blue,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => context.pop(),
                          ),
                          const TextSpan(
                              text: ' to go back to the login screen.'),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
