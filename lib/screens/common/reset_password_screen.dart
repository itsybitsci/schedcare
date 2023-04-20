import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/providers/generic_fields_provider.dart';
import 'package:schedcare/utilities/components.dart';

class ResetPasswordScreen extends HookConsumerWidget {
  ResetPasswordScreen({super.key});

  final formKeyResetPassword = GlobalKey<FormState>();

  Future sendPasswordResetEMail(
      FirebaseServicesProvider firebaseServicesNotifier,
      GenericFieldsProvider registrationNotifier,
      ValueNotifier canResendEmail) async {
    if (formKeyResetPassword.currentState!.validate()) {
      formKeyResetPassword.currentState?.save();
      canResendEmail.value = false;

      await firebaseServicesNotifier
          .sendPasswordResetEmail(registrationNotifier.email);

      await Future.delayed(
        const Duration(seconds: 5),
      ).then((value) => canResendEmail.value = true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);
    final genericFieldsNotifier = ref.watch(genericFieldsProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Background(
        child: Form(
          key: formKeyResetPassword,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 200.h,
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300.w),
                  child: genericFieldsNotifier.buildEmail(),
                ),
                SizedBox(
                  height: 10.h,
                ),
                HookBuilder(
                  builder: (_) {
                    final canResendEmail = useState(true);

                    return ElevatedButton(
                      onPressed: canResendEmail.value
                          ? () => sendPasswordResetEMail(
                              firebaseServicesNotifier,
                              genericFieldsNotifier,
                              canResendEmail)
                          : null,
                      child: Text(
                        'RESET PASSWORD',
                        style: TextStyle(fontSize: 15.sp),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 250.h,
                ),
                const Text('Already know your password?'),
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
                      const TextSpan(text: ' to go back to the login screen.'),
                    ],
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
