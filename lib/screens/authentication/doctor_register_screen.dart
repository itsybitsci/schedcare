import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/firebase_provider.dart';
import 'package:schedcare/providers/registration_provider.dart';
import 'package:schedcare/utilities/constants.dart';

class DoctorRegisterScreen extends HookConsumerWidget {
  DoctorRegisterScreen({super.key});
  final GlobalKey<FormState> formKeyRegisterDoctor = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseNotifier = ref.watch(firebaseProvider);
    final registrationNotifier = ref.watch(registrationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Doctor'),
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: formKeyRegisterDoctor,
        child: SingleChildScrollView(
          reverse: true,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              registrationNotifier.buildFirstName(),
              registrationNotifier.buildMiddleName(),
              registrationNotifier.buildLastName(),
              registrationNotifier.buildSuffix(),
              registrationNotifier.buildSexesDropdown(),
              registrationNotifier.buildEmail(),
              registrationNotifier.buildSpecialization(),
              registrationNotifier.buildPassword(),
              registrationNotifier.buildRepeatPassword(),
              ElevatedButton(
                onPressed: () async {
                  if (formKeyRegisterDoctor.currentState!.validate()) {
                    formKeyRegisterDoctor.currentState?.save();
                    Map<String, dynamic> userData = {
                      ModelFields.email: registrationNotifier.email,
                      ModelFields.role: RegistrationConstants.doctor,
                      ModelFields.firstName: registrationNotifier.firstName,
                      ModelFields.middleName: registrationNotifier.middleName,
                      ModelFields.lastName: registrationNotifier.lastName,
                      ModelFields.suffix: registrationNotifier.suffix,
                      ModelFields.sex: registrationNotifier.sex,
                      ModelFields.specialization:
                          registrationNotifier.specialization,
                      ModelFields.isApproved: false,
                    };

                    await firebaseNotifier.createUserWithEmailAndPassword(
                        registrationNotifier.email,
                        registrationNotifier.password,
                        userData);

                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: firebaseNotifier.getLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Register'),
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
