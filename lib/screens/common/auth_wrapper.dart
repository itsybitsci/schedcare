import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:schedcare/utilities/helpers.dart';

class AuthWrapper extends HookConsumerWidget {
  AuthWrapper({super.key});
  final Stream<User?> userStream = FirebaseAuth.instance.authStateChanges();
  final CollectionReference<Map<String, dynamic>> usersCollectionReference =
      FirebaseFirestore.instance.collection(FirebaseConstants.usersCollection);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);

    return StreamBuilder(
      stream: userStream,
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.hasData) {
          User user = snapshot.data!;

          // Verify user
          if (!user.emailVerified) return const VerifyEmailScreen();

          return StreamBuilder(
            stream: usersCollectionReference
                .doc(firebaseServicesNotifier.getCurrentUser!.uid)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    userSnapshot) {
              if (userSnapshot.hasData) {
                String role = userSnapshot.data!.get(ModelFields.role);

                // Check if user is admin approved
                if (!userSnapshot.data!.get(ModelFields.isApproved)) {
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
              }

              if (userSnapshot.hasError) {
                showToast(userSnapshot.error.toString());
                return const LoadingScreen();
              }

              return const LoadingScreen();
            },
          );
        }
        return LoginScreen();
      },
    );
  }
}
