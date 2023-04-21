import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
            SizedBox(height: 150.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300.w),
              child: Text(
                'Your application is still under review by the administrator and pending for approval.',
                style: TextStyle(fontSize: 20.sp),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 300.h),
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
