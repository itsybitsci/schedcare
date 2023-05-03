import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:schedcare/services/firebase_authentication_service.dart';
import 'package:schedcare/utilities/components.dart';

class ApprovalScreen extends HookConsumerWidget {
  ApprovalScreen({super.key});
  final FirebaseAuthenticationService firebaseAuthenticationService =
      FirebaseAuthenticationService();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Background(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 100.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300.w),
              child: Text(
                'Your application is still under review by the administrator and pending for approval.',
                style: TextStyle(fontSize: 20.sp),
                textAlign: TextAlign.center,
              ),
            ),
            Lottie.asset('assets/animations/verifying-profile_lottie.json',
                width: 300.w),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13.sp,
                ),
                children: [
                  const TextSpan(text: 'Click '),
                  TextSpan(
                    text: 'here',
                    style: const TextStyle(
                      color: Colors.blue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async =>
                          await firebaseAuthenticationService.signOut(),
                  ),
                  const TextSpan(text: ' to go back to the login screen.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
