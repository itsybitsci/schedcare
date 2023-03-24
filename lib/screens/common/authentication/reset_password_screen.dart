import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/firebase_provider.dart';
import 'package:schedcare/providers/generic_fields_provider.dart';

class ResetPasswordScreen extends HookConsumerWidget {
  ResetPasswordScreen({super.key});

  final formKeyResetPassword = GlobalKey<FormState>();

  Future sendPasswordResetEMail(
      FirebaseProvider firebaseNotifier,
      GenericFieldsProvider registrationNotifier,
      ValueNotifier canResendEmail) async {
    if (formKeyResetPassword.currentState!.validate()) {
      formKeyResetPassword.currentState?.save();
      canResendEmail.value = false;

      await firebaseNotifier.sendPasswordResetEmail(registrationNotifier.email);

      await Future.delayed(
        const Duration(seconds: 5),
      ).then((value) => canResendEmail.value = true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseNotifier = ref.watch(firebaseProvider);
    final genericFieldsNotifier = ref.watch(genericFieldsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: formKeyResetPassword,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              genericFieldsNotifier.buildEmail(),
              HookBuilder(
                builder: (_) {
                  final canResendEmail = useState(true);

                  return ElevatedButton(
                    onPressed: canResendEmail.value
                        ? () => sendPasswordResetEMail(firebaseNotifier,
                            genericFieldsNotifier, canResendEmail)
                        : null,
                    child: const Text('Send Password Reset Email'),
                  );
                },
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text('Go back to Login screen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
