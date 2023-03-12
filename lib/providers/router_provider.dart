import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/screens/authentication/doctor_register_screen.dart';
import 'package:schedcare/screens/authentication/login_screen.dart';
import 'package:schedcare/screens/authentication/patient_register_screen.dart';
import 'package:schedcare/screens/authentication/reset_password_screen.dart';
import 'package:schedcare/screens/authentication/verify_email_screen.dart';
import 'package:schedcare/screens/home/doctor_home_screen.dart';
import 'package:schedcare/screens/home/patient_home_screen.dart';
import 'package:schedcare/utilities/auth_wrapper.dart';
import 'package:schedcare/utilities/constants.dart';

final routerProvider = Provider<GoRouter>(
  (ref) {
    final router = RouterNotifier();
    return GoRouter(
        initialLocation: RoutePaths.authWrapper, routes: router.routes);
  },
);

class RouterNotifier extends ChangeNotifier {
  RouterNotifier();

  List<GoRoute> get routes => [
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
          name: RouteNames.authWrapper,
          path: RoutePaths.authWrapper,
          builder: (context, state) => const AuthWrapper(),
        ),
      ];
}
