import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/models/consultation_request_model.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/screens/common/authentication/approval_screen.dart';
import 'package:schedcare/screens/doctor/authentication/doctor_register_screen.dart';
import 'package:schedcare/screens/common/authentication/login_screen.dart';
import 'package:schedcare/screens/patient/authentication/patient_register_screen.dart';
import 'package:schedcare/screens/common/authentication/reset_password_screen.dart';
import 'package:schedcare/screens/common/authentication/verify_email_screen.dart';
import 'package:schedcare/screens/doctor/home/doctor_home_screen.dart';
import 'package:schedcare/screens/patient/consultation_requests/send_consultation_request_screen.dart';
import 'package:schedcare/screens/patient/consultation_requests/view_consultation_request_screen.dart';
import 'package:schedcare/screens/patient/home/patient_home_screen.dart';
import 'package:schedcare/screens/patient/profile/edit_patient_profile_screen.dart';
import 'package:schedcare/screens/patient/profile/patient_profile_screen.dart';
import 'package:schedcare/utilities/auth_wrapper.dart';
import 'package:schedcare/utilities/constants.dart';

final routerProvider = Provider<GoRouter>(
  (ref) {
    final router = RouterNotifier();
    return GoRouter(
      initialLocation: RoutePaths.authWrapper,
      routes: router.routes,
    );
  },
);

class RouterNotifier extends ChangeNotifier {
  List<RouteBase> get routes => [
        GoRoute(
          name: RouteNames.authWrapper,
          path: RoutePaths.authWrapper,
          builder: (context, state) => AuthWrapper(),
        ),
        GoRoute(
          name: RouteNames.login,
          path: RoutePaths.login,
          builder: (context, state) => LoginScreen(),
        ),
        GoRoute(
          name: RouteNames.verifyEmail,
          path: RoutePaths.verifyEmail,
          builder: (context, state) => const VerifyEmailScreen(),
        ),
        GoRoute(
          name: RouteNames.resetPassword,
          path: RoutePaths.resetPassword,
          builder: (context, state) => ResetPasswordScreen(),
        ),
        GoRoute(
          name: RouteNames.patientHome,
          path: RoutePaths.patientHome,
          builder: (context, state) => const PatientHomeScreen(),
        ),
        GoRoute(
          name: RouteNames.patientRegistration,
          path: RoutePaths.patientRegistration,
          builder: (context, state) => PatientRegisterScreen(),
        ),
        GoRoute(
          name: RouteNames.doctorHome,
          path: RoutePaths.doctorHome,
          builder: (context, state) => const DoctorHomeScreen(),
        ),
        GoRoute(
          name: RouteNames.doctorRegistration,
          path: RoutePaths.doctorRegistration,
          builder: (context, state) => DoctorRegisterScreen(),
        ),
        GoRoute(
          name: RouteNames.approval,
          path: RoutePaths.approval,
          builder: (context, state) => const ApprovalScreen(),
        ),
        GoRoute(
          name: RouteNames.patientProfile,
          path: RoutePaths.patientProfile,
          builder: (context, state) => PatientProfileScreen(),
        ),
        GoRoute(
          name: RouteNames.editPatientProfile,
          path: RoutePaths.editPatientProfile,
          builder: (context, state) => EditPatientProfileScreen(),
        ),
        GoRoute(
          name: RouteNames.sendConsultationRequest,
          path: RoutePaths.sendConsultationRequest,
          builder: (context, state) {
            Doctor doctor = state.extra as Doctor;
            return SendConsultationRequest(
              doctor: doctor,
            );
          },
        ),
        GoRoute(
          name: RouteNames.viewConsultationRequest,
          path: RoutePaths.viewConsultationRequest,
          builder: (context, state) {
            ViewConsultationRequestObject viewConsultationRequestObject =
                state.extra! as ViewConsultationRequestObject;
            String consultationRequestId =
                viewConsultationRequestObject.consultationRequestId;
            Doctor doctor = viewConsultationRequestObject.doctor;
            Stream<DocumentSnapshot<Map<String, dynamic>>>
                consultationRequestSnapshots = FirebaseFirestore.instance
                    .collection(
                        FirestoreConstants.consultationRequestsCollection)
                    .doc(consultationRequestId)
                    .snapshots();

            return ViewConsultationRequestScreen(
              consultationRequestId: consultationRequestId,
              doctor: doctor,
              consultationRequestSnapshots: consultationRequestSnapshots,
            );
          },
        ),
      ];
}
