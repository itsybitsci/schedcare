import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/auth_provider.dart';
import 'package:schedcare/screens/authentication/verify_email_screen.dart';
import 'package:schedcare/screens/home/doctor_home_screen.dart';
import 'package:schedcare/screens/authentication/login_screen.dart';
import 'package:schedcare/screens/home/patient_home_screen.dart';
import 'package:schedcare/utilities/constants.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.watch(firebaseProvider);

    return StreamBuilder(
      stream: authNotifier.userStream,
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.hasData) {
          User user = snapshot.data!;
          if (!user.emailVerified) return const VerifyEmailScreen();

          return StreamBuilder(
            stream: authNotifier.fireStoreService.getUserSnapshots(user),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic> userData =
                    snapshot.data!.data() as Map<String, dynamic>;
                String role = userData['role'];

                if (role.toLowerCase() ==
                    RegistrationConstants.patient.toLowerCase()) {
                  return const PatientHomeScreen();
                } else if (role.toLowerCase() ==
                    RegistrationConstants.doctor.toLowerCase()) {
                  return const DoctorHomeScreen();
                }
              }
              return const Material(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          );
        }
        return LoginScreen();
      },
    );
  }
}
