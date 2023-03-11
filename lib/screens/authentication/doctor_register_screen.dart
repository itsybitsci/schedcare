import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/auth_provider.dart';
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
                      'email': registrationNotifier.email,
                      'role': RegistrationConstants.doctor,
                      'firstName': registrationNotifier.firstName,
                      'middleName': registrationNotifier.middleName,
                      'lastName': registrationNotifier.lastName,
                      'suffix': registrationNotifier.suffix,
                      'sex': registrationNotifier.sex,
                      'specialization': registrationNotifier.specialization,
                      'isApproved': false,
                    };

                    await firebaseNotifier.createUserWithEmailAndPassword(
                        registrationNotifier.email,
                        registrationNotifier.password,
                        userData);

                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: firebaseNotifier.isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Register'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
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
