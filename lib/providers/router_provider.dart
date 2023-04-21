import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/models/consultation_request_model.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/plugins/videosdk_plugin/screens/join_screen.dart';
import 'package:schedcare/screens/common/approval_screen.dart';
import 'package:schedcare/screens/common/auth_wrapper.dart';
import 'package:schedcare/screens/common/conversation_history_screen.dart';
import 'package:schedcare/screens/common/login_screen.dart';
import 'package:schedcare/screens/common/reset_password_screen.dart';
import 'package:schedcare/screens/common/verify_email_screen.dart';
import 'package:schedcare/screens/doctor/authentication/doctor_register_screen.dart';
import 'package:schedcare/screens/doctor/consultation_requests/doctor_view_consultation_requests_screen.dart';
import 'package:schedcare/screens/doctor/home/doctor_home_screen.dart';
import 'package:schedcare/screens/doctor/profile/doctor_profile_screen.dart';
import 'package:schedcare/screens/doctor/profile/edit_doctor_profile_screen.dart';
import 'package:schedcare/screens/patient/authentication/patient_register_screen.dart';
import 'package:schedcare/screens/patient/consultation_requests/send_consultation_request_screen.dart';
import 'package:schedcare/screens/patient/consultation_requests/patient_view_consultation_request_screen.dart';
import 'package:schedcare/screens/patient/home/patient_home_screen.dart';
import 'package:schedcare/screens/patient/profile/edit_patient_profile_screen.dart';
import 'package:schedcare/screens/patient/profile/patient_profile_screen.dart';
import 'package:schedcare/utilities/constants.dart';

final routerProvider = Provider<GoRouter>(
  (ProviderRef<GoRouter> ref) {
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
          name: RouteNames.approval,
          path: RoutePaths.approval,
          builder: (context, state) => ApprovalScreen(),
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
          name: RouteNames.patientRegistration,
          path: RoutePaths.patientRegistration,
          builder: (context, state) => PatientRegisterScreen(),
        ),
        GoRoute(
          name: RouteNames.patientHome,
          path: RoutePaths.patientHome,
          builder: (context, state) => PatientHomeScreen(),
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
            return SendConsultationRequestScreen(
              doctor: doctor,
            );
          },
        ),
        GoRoute(
          name: RouteNames.patientViewConsultationRequest,
          path: RoutePaths.patientViewConsultationRequest,
          builder: (context, state) {
            PatientViewConsultationRequestObject
                patientViewConsultationRequestObject =
                state.extra! as PatientViewConsultationRequestObject;

            return PatientViewConsultationRequestScreen(
              consultationRequest:
                  patientViewConsultationRequestObject.consultationRequest,
              doctor: patientViewConsultationRequestObject.doctor,
            );
          },
        ),
        GoRoute(
          name: RouteNames.doctorRegistration,
          path: RoutePaths.doctorRegistration,
          builder: (context, state) => DoctorRegisterScreen(),
        ),
        GoRoute(
          name: RouteNames.doctorHome,
          path: RoutePaths.doctorHome,
          builder: (context, state) => DoctorHomeScreen(),
        ),
        GoRoute(
          name: RouteNames.doctorProfile,
          path: RoutePaths.doctorProfile,
          builder: (context, state) => DoctorProfileScreen(),
        ),
        GoRoute(
          name: RouteNames.editDoctorProfile,
          path: RoutePaths.editDoctorProfile,
          builder: (context, state) => EditDoctorProfileScreen(),
        ),
        GoRoute(
          name: RouteNames.doctorViewConsultationRequest,
          path: RoutePaths.doctorViewConsultationRequest,
          builder: (context, state) {
            DoctorViewConsultationRequestObject
                doctorViewConsultationRequestObject =
                state.extra! as DoctorViewConsultationRequestObject;

            return DoctorViewConsultationRequestScreen(
              consultationRequest:
                  doctorViewConsultationRequestObject.consultationRequest,
              patient: doctorViewConsultationRequestObject.patient,
            );
          },
        ),
        GoRoute(
          name: RouteNames.joinScreen,
          path: RoutePaths.joinScreen,
          builder: (context, state) {
            MeetingPayload meetingPayload = state.extra! as MeetingPayload;

            return JoinScreen(
              consultationRequest: meetingPayload.consultationRequest,
              role: meetingPayload.role,
              meetingId: meetingPayload.meetingId,
            );
          },
        ),
        GoRoute(
          name: RouteNames.conversationHistory,
          path: RoutePaths.conversationHistory,
          builder: (context, state) {
            ConversationHistoryPayload conversationHistoryPayload =
                state.extra! as ConversationHistoryPayload;

            return ConversationHistoryScreen(
              consultationRequestId:
                  conversationHistoryPayload.consultationRequestId,
              role: conversationHistoryPayload.role,
            );
          },
        ),
      ];
}
