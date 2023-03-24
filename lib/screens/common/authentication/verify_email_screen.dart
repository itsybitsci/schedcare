import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/services/auth_service.dart';
import 'package:schedcare/utilities/auth_wrapper.dart';
import 'package:schedcare/utilities/helpers.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _VerifyEmailScreenState();
  }
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  AuthService authService = AuthService();
  late bool isEmailVerified;
  late bool canResendVerificationEmail;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = false;
    canResendVerificationEmail = authService.currentUser!.emailVerified;
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
    final user = authService.currentUser!;

    if (!mounted) return;
    await authService.sendEmailVerification(user);

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
    await authService.currentUser!.reload();

    setState(() {
      isEmailVerified = authService.currentUser!.emailVerified;
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
        appBar: AppBar(
          title: const Text('Verify Email'),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'A verification email has been sent to your email address.',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed:
                    canResendVerificationEmail ? sendVerificationEmail : null,
                icon: const Icon(
                  Icons.email,
                  size: 32,
                ),
                label: const Text(
                  'Resend Email',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              TextButton(
                onPressed: () async {
                  timer?.cancel();
                  await authService.signOut();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
