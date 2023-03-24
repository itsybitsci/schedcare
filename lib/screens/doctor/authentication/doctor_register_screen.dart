import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/firebase_provider.dart';
import 'package:schedcare/providers/generic_fields_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/widgets.dart';

class DoctorRegisterScreen extends HookConsumerWidget {
  DoctorRegisterScreen({super.key});

  final GlobalKey<FormState> formKeyRegisterDoctor = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseNotifier = ref.watch(firebaseProvider);
    final genericFieldsNotifier = ref.watch(genericFieldsProvider);

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
              genericFieldsNotifier.buildFirstName(),
              genericFieldsNotifier.buildMiddleName(),
              genericFieldsNotifier.buildLastName(),
              genericFieldsNotifier.buildSuffix(),
              genericFieldsNotifier.buildSexesDropdown(),
              genericFieldsNotifier.buildEmail(),
              genericFieldsNotifier.buildSpecialization(),
              genericFieldsNotifier.buildPassword(),
              genericFieldsNotifier.buildRepeatPassword(),
              ElevatedButton(
                onPressed: () async {
                  if (formKeyRegisterDoctor.currentState!.validate()) {
                    formKeyRegisterDoctor.currentState?.save();
                    Map<String, dynamic> userData = {
                      ModelFields.email: genericFieldsNotifier.email,
                      ModelFields.role: AppConstants.doctor,
                      ModelFields.firstName: genericFieldsNotifier.firstName,
                      ModelFields.middleName: genericFieldsNotifier.middleName,
                      ModelFields.lastName: genericFieldsNotifier.lastName,
                      ModelFields.suffix: genericFieldsNotifier.suffix,
                      ModelFields.sex: genericFieldsNotifier.sex,
                      ModelFields.specialization:
                          genericFieldsNotifier.specialization,
                      ModelFields.isApproved: false,
                    };

                    await firebaseNotifier.createUserWithEmailAndPassword(
                        genericFieldsNotifier.email,
                        genericFieldsNotifier.password,
                        userData);

                    if (context.mounted) context.pop();
                  }
                },
                child: firebaseNotifier.getLoading
                    ? loading()
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
