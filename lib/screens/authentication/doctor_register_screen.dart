import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/auth_provider.dart';
import 'package:schedcare/providers/registration_provider.dart';
import 'package:schedcare/utilities/constants.dart';

class DoctorRegisterScreen extends ConsumerStatefulWidget {
  const DoctorRegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _DoctorRegisterScreenState();
  }
}

class _DoctorRegisterScreenState extends ConsumerState<DoctorRegisterScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController suffixController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();
  late final List<String> sexes;
  late String sexesDropdownValue;
  late bool passwordVisible;
  late bool repeatPasswordVisible;
  late final GlobalKey<FormState> formKeyRegisterDoctor;

  @override
  void initState() {
    super.initState();
    sexes = <String>[RegistrationConstants.male, RegistrationConstants.female];
    sexesDropdownValue = sexes.first;
    passwordVisible = false;
    repeatPasswordVisible = false;
    formKeyRegisterDoctor = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    suffixController.dispose();
    emailController.dispose();
    passwordController.dispose();
    repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.watch(authProvider);
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
                    };

                    await authNotifier.createUserWithEmailAndPassword(
                        registrationNotifier.email,
                        registrationNotifier.password,
                        userData);

                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: authNotifier.isLoading
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
