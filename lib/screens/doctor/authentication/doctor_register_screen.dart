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

class DoctorRegisterScreen extends HookConsumerWidget {
  DoctorRegisterScreen({super.key});

  final GlobalKey<FormState> formKeyRegisterDoctor = GlobalKey<FormState>();

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
              key: formKeyRegisterDoctor,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    lottieRegister(),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300.w),
                      child: genericFieldsNotifier.buildPrefix(),
                    ),
                    SizedBox(height: 10.h),
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
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300.w),
                      child: genericFieldsNotifier.buildSexesDropdown(),
                    ),
                    SizedBox(height: 10.h),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300.w),
                      child: genericFieldsNotifier.buildEmail(),
                    ),
                    SizedBox(height: 10.h),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300.w),
                      child: genericFieldsNotifier.buildSpecialization(),
                    ),
                    SizedBox(height: 10.h),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300.w),
                      child: genericFieldsNotifier.buildPassword(),
                    ),
                    SizedBox(height: 10.h),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300.w),
                      child: genericFieldsNotifier.buildRepeatPassword(),
                    ),
                    SizedBox(height: 10.h),
                    firebaseServicesNotifier.getLoading
                        ? lottieLoading(width: 100)
                        : ElevatedButton(
                            onPressed: () async {
                              if (formKeyRegisterDoctor.currentState!
                                  .validate()) {
                                formKeyRegisterDoctor.currentState?.save();
                                Map<String, dynamic> data = {
                                  ModelFields.id: firebaseServicesNotifier
                                      .getCurrentUser!.uid,
                                  ModelFields.email:
                                      genericFieldsNotifier.email,
                                  ModelFields.role: AppConstants.doctor,
                                  ModelFields.prefix:
                                      genericFieldsNotifier.prefix,
                                  ModelFields.firstName:
                                      genericFieldsNotifier.firstName,
                                  ModelFields.middleName:
                                      genericFieldsNotifier.middleName,
                                  ModelFields.lastName:
                                      genericFieldsNotifier.lastName,
                                  ModelFields.suffix:
                                      genericFieldsNotifier.suffix,
                                  ModelFields.sex: genericFieldsNotifier.sex,
                                  ModelFields.specialization:
                                      genericFieldsNotifier.specialization,
                                  ModelFields.isApproved: false,
                                };

                                await firebaseServicesNotifier
                                    .createUserWithEmailAndPassword(
                                        genericFieldsNotifier.email.removEmoji,
                                        genericFieldsNotifier.password,
                                        data);

                                if (context.mounted) context.pop();
                              }
                            },
                            child: Text('REGISTER AS A DOCTOR',
                                style: TextStyle(fontSize: 15.sp)),
                          ),
                    SizedBox(height: 10.h),
                    const Text('Already have an account?'),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black,
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
