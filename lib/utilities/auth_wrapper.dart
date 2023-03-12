import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/firebase_provider.dart';
import 'package:schedcare/screens/authentication/verify_email_screen.dart';
import 'package:schedcare/screens/home/doctor_home_screen.dart';
import 'package:schedcare/screens/authentication/login_screen.dart';
import 'package:schedcare/screens/home/patient_home_screen.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/widgets.dart';

class AuthWrapper extends HookConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseNotifier = ref.watch(firebaseProvider);
    final userStreamNotifier = ref.watch(authStateChangeProvider);

    //Listen for auth changes
    return userStreamNotifier.when(
      data: (User? user) {
        if (user != null) {
          final userSnapshotNotifier =
              ref.watch(userSnapShotProvider(user.uid));

          // Verify user
          if (!user.emailVerified) return const VerifyEmailScreen();

          // Get user snapshot from firestore
          return userSnapshotNotifier.when(
            data: (data) {
              Map<String, dynamic> userData =
                  data.data() as Map<String, dynamic>;
              String role = userData['role'];

              //Redirect based on role
              if (role.toLowerCase() ==
                      RegistrationConstants.patient.toLowerCase() &&
                  !firebaseNotifier.isLoading) {
                return const PatientHomeScreen();
              } else if (role.toLowerCase() ==
                  RegistrationConstants.doctor.toLowerCase()) {
                return const DoctorHomeScreen();
              }
              return materialLoading();
            },
            error: (Object error, StackTrace stackTrace) =>
                materialLoading(toastMessage: 'An error occurred.'),
            loading: () => materialLoading(),
          );
        }
        return LoginScreen();
      },
      error: (Object error, StackTrace stackTrace) =>
          materialLoading(toastMessage: 'An error occurred.'),
      loading: () => materialLoading(),
    );
  }
}
