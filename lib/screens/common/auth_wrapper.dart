import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/screens/common/approval_screen.dart';
import 'package:schedcare/screens/common/login_screen.dart';
import 'package:schedcare/screens/common/verify_email_screen.dart';
import 'package:schedcare/screens/doctor/home/doctor_home_screen.dart';
import 'package:schedcare/screens/patient/home/patient_home_screen.dart';
import 'package:schedcare/utilities/components.dart';
import 'package:schedcare/utilities/constants.dart';

class AuthWrapper extends HookConsumerWidget {
  AuthWrapper({super.key});
  final Stream<User?> userStream = FirebaseAuth.instance.authStateChanges();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
      stream: userStream,
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.hasData) {
          User user = snapshot.data!;
          final userSnapshotNotifier =
              ref.watch(userSnapshotProvider(user.uid));

          // Verify user
          if (!user.emailVerified) return const VerifyEmailScreen();

          // Get user snapshot from firestore
          return userSnapshotNotifier.when(
            data: (data) {
              String role = data.get(ModelFields.role);

              // Check if user is admin approved
              if (!data.get(ModelFields.isApproved)) {
                return ApprovalScreen();
              }

              //Redirect based on role
              if (role.toLowerCase() == AppConstants.patient.toLowerCase()) {
                return PatientHomeScreen();
              } else if (role.toLowerCase() ==
                  AppConstants.doctor.toLowerCase()) {
                return DoctorHomeScreen();
              }
              return const LoadingScreen();
            },
            error: (Object error, StackTrace stackTrace) =>
                const LoadingScreen(),
            loading: () => const LoadingScreen(),
          );
        }
        return LoginScreen();
      },
    );
  }
}
