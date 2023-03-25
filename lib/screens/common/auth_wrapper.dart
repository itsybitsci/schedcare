import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/providers/firebase_provider.dart';
import 'package:schedcare/screens/common/approval_screen.dart';
import 'package:schedcare/screens/common/login_screen.dart';
import 'package:schedcare/screens/common/verify_email_screen.dart';
import 'package:schedcare/screens/doctor/home/doctor_home_screen.dart';
import 'package:schedcare/screens/patient/home/patient_home_screen.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/widgets.dart';

class AuthWrapper extends HookConsumerWidget {
  AuthWrapper({super.key});
  final Stream<User?> userStream = FirebaseAuth.instance.authStateChanges();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseNotifier = ref.watch(firebaseProvider);

    return StreamBuilder(
      stream: userStream,
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.hasData) {
          User user = snapshot.data!;
          final userSnapshotNotifier =
              ref.watch(userSnapShotProvider(user.uid));

          // Verify user
          if (!user.emailVerified) return const VerifyEmailScreen();

          // Get user snapshot from firestore
          return userSnapshotNotifier.when(
            data: (data) {
              String role = data.get(ModelFields.role);

              //Redirect based on role
              if (role.toLowerCase() == AppConstants.patient.toLowerCase()) {
                // Persist login
                if (firebaseNotifier.getPatient == null) {
                  Patient patient = Patient.fromSnapshot(data);
                  firebaseNotifier.setPatient = patient;
                }
                return const PatientHomeScreen();
              } else if (role.toLowerCase() ==
                  AppConstants.doctor.toLowerCase()) {
                // Check if doctor is approved
                if (!data.get(ModelFields.isApproved)) {
                  return const ApprovalScreen();
                }
                // Persist login
                if (firebaseNotifier.getDoctor == null) {
                  Doctor doctor = Doctor.fromSnapshot(data);
                  firebaseNotifier.setDoctor = doctor;
                }
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
    );
  }
}
