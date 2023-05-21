import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:schedcare/services/firebase_authentication_service.dart';
import 'package:schedcare/screens/common/auth_wrapper.dart';
import 'package:schedcare/services/firebase_firestore_service.dart';
import 'package:schedcare/utilities/components.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/helpers.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _VerifyEmailScreenState();
  }
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  FirebaseAuthenticationService firebaseAuthenticationService =
      FirebaseAuthenticationService();
  FirebaseFirestoreService firebaseFirestoreService =
      FirebaseFirestoreService();
  late bool isEmailVerified;
  late bool canResendVerificationEmail;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = false;
    canResendVerificationEmail =
        firebaseAuthenticationService.currentUser!.emailVerified;
    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  Future sendVerificationEmail() async {
    final user = firebaseAuthenticationService.currentUser!;

    if (!mounted) return;
    await firebaseAuthenticationService.sendEmailVerification(user);

    setState(() => canResendVerificationEmail = false);

    await Future.delayed(
      const Duration(seconds: 10),
    ).then(
      (value) {
        if (!mounted) return;
        setState(() => canResendVerificationEmail = true);
      },
    );
  }

  Future checkEmailVerified() async {
    await firebaseAuthenticationService.currentUser!.reload();

    if (firebaseAuthenticationService.currentUser!.emailVerified) {
      await firebaseFirestoreService.updateDocument(
          {ModelFields.isEmailVerified: true},
          FirebaseConstants.usersCollection,
          firebaseAuthenticationService.currentUser!.uid);
    }

    setState(() {
      isEmailVerified =
          firebaseAuthenticationService.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (isEmailVerified) {
      showToast('Successfully verified email.');
      return AuthWrapper();
    } else {
      return Scaffold(
        body: Background(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 100.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 300.w),
                child: Text(
                  'A verification email has been sent to your email address.',
                  style: TextStyle(fontSize: 20.sp),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                onPressed:
                    canResendVerificationEmail ? sendVerificationEmail : null,
                icon: const Icon(
                  Icons.email,
                ),
                label: Text(
                  'RESEND EMAIL',
                  style: TextStyle(fontSize: 15.sp),
                ),
              ),
              Lottie.asset('assets/animations/verifying-profile_lottie.json',
                  width: 250.w),
              Text(
                'Already verified?',
                style: TextStyle(fontSize: 13.sp),
              ),
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
                        ..onTap = () async {
                          timer?.cancel();
                          await firebaseAuthenticationService.signOut();
                        },
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
}
