import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/auth_provider.dart';
import 'package:schedcare/providers/registration_provider.dart';

class ResetPasswordScreen extends HookConsumerWidget {
  ResetPasswordScreen({super.key});
  final formKeyResetPassword = GlobalKey<FormState>();

  Future sendPasswordResetEMail(
      AuthProvider authNotifier,
      RegistrationProvider registrationNotifier,
      ValueNotifier canResendEmail,
      ValueNotifier emailSent) async {
    if (formKeyResetPassword.currentState!.validate()) {
      formKeyResetPassword.currentState?.save();
      canResendEmail.value = false;

      await authNotifier.authService
          .sendPasswordResetEmail(registrationNotifier.email)
          .then(
        (value) {
          emailSent.value = true;
        },
      );

      await Future.delayed(
        const Duration(seconds: 10),
      ).then(
        (value) {
          emailSent.value = false;
        },
      );

      canResendEmail.value = true;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.watch(authProvider);
    final registrationNotifier = ref.watch(registrationProvider);
    final emailSent = useValueNotifier(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Form(
        key: formKeyResetPassword,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              registrationNotifier.buildEmail(),
              HookBuilder(
                builder: (_) {
                  final canResendEmail = useValueNotifier(true);

                  return ElevatedButton(
                    onPressed: canResendEmail.value
                        ? () => sendPasswordResetEMail(authNotifier,
                            registrationNotifier, canResendEmail, emailSent)
                        : null,
                    child: const Text('Send Password Reset Email'),
                  );
                },
              ),
              const SizedBox(
                height: 10,
              ),
              if (useValueListenable(emailSent))
                const Text('An email has been sent to your email address.'),
            ],
          ),
        ),
      ),
    );
  }
}
