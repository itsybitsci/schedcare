import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/screens/authentication/verify_email_screen.dart';
import 'package:schedcare/screens/home/doctor_home_screen.dart';
import 'package:schedcare/screens/home/patient_home_screen.dart';
import 'package:schedcare/utilities/firebase_options.dart';
import 'package:schedcare/screens/authentication/doctor_register_screen.dart';
import 'package:schedcare/screens/authentication/login_screen.dart';
import 'package:schedcare/screens/authentication/patient_register_screen.dart';
import 'package:schedcare/screens/authentication/reset_password_screen.dart';
import 'package:schedcare/utilities/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );

  runApp(
    const ProviderScope(
      child: SchedcareApp(),
    ),
  );
}

class SchedcareApp extends StatelessWidget {
  const SchedcareApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SchedCare',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => LoginScreen(),
        '/reset_password': (context) => ResetPasswordScreen(),
        '/verify_email': (context) => const VerifyEmailScreen(),
        '/register_patient': (context) => PatientRegisterScreen(),
        '/patient_home': (context) => const PatientHomeScreen(),
        '/register_doctor': (context) => DoctorRegisterScreen(),
        '/doctor_home': (context) => const DoctorHomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
