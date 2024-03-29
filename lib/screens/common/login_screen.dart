import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/utilities/animations.dart';
import 'package:schedcare/utilities/components.dart';
import 'package:schedcare/utilities/constants.dart';

class LoginScreen extends HookConsumerWidget {
  LoginScreen({super.key});

  final GlobalKey<FormState> formKeyLogin = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);
    final TextEditingController emailController = useTextEditingController();
    final TextEditingController passwordController = useTextEditingController();

    emailController.text = '';
    passwordController.text = '';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Background(
        child: Form(
          key: formKeyLogin,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 250.h),
                  child: Image.asset("assets/images/splash.png"),
                ),
                SizedBox(
                  height: 10.h,
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300.w),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      suffixIcon: const Icon(Icons.email),
                      labelText: 'Email Address',
                      hintText: 'Enter email address',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 3.w),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return 'Required';
                      return EmailValidator.validate(value.trim())
                          ? null
                          : 'Invalid format';
                    },
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300.w),
                  child: HookBuilder(
                    builder: (_) {
                      final passwordVisible = useState(false);

                      return TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          labelText: 'Password',
                          hintText: 'Enter password',
                          suffixIcon: IconButton(
                            icon: Icon(passwordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () =>
                                passwordVisible.value = !passwordVisible.value,
                          ),
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 3.w),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        obscureText: !passwordVisible.value,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                firebaseServicesNotifier.getLoggingIn
                    ? lottieLoading(width: 100)
                    : ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 300.w),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKeyLogin.currentState!.validate()) {
                              formKeyLogin.currentState?.save();
                              await firebaseServicesNotifier
                                  .logInWithEmailAndPassword(
                                      emailController.text,
                                      passwordController.text);
                            }
                          },
                          child: Text(
                            'LOGIN',
                            style: TextStyle(fontSize: 15.sp),
                          ),
                        ),
                      ),
                SizedBox(
                  height: 80.h,
                ),
                Text(
                  'Don\'t have an account yet?',
                  style: TextStyle(fontSize: 12.sp),
                ),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12.sp,
                    ),
                    children: [
                      TextSpan(
                        text: 'Register as a patient',
                        style: const TextStyle(
                          color: Colors.blue,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () =>
                              context.push(RoutePaths.patientRegistration),
                      ),
                      const TextSpan(text: ' or '),
                      TextSpan(
                        text: 'Register as a doctor',
                        style: const TextStyle(
                          color: Colors.blue,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap =
                              () => context.push(RoutePaths.doctorRegistration),
                      ),
                      const TextSpan(text: ' now.'),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12.sp,
                    ),
                    children: [
                      const TextSpan(
                          text: 'Forgot your password? Reset password '),
                      TextSpan(
                        text: 'here',
                        style: const TextStyle(
                          color: Colors.blue,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap =
                              () => context.push(RoutePaths.resetPassword),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
