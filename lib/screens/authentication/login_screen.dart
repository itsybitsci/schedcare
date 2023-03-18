import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/firebase_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/widgets.dart';

class LoginScreen extends HookConsumerWidget {
  LoginScreen({super.key});

  final GlobalKey<FormState> formKeyLogin = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseNotifier = ref.watch(firebaseProvider);
    final TextEditingController emailController = useTextEditingController();
    final TextEditingController passwordController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      resizeToAvoidBottomInset: false,
      body: Form(
        key: formKeyLogin,
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 80.h,
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 300.w),
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.email),
                    labelText: 'Email Address',
                    hintText: 'Enter email address',
                    border: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    return value!.isEmpty ? 'Required' : null;
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
                              const BorderSide(color: Colors.blue, width: 3),
                          borderRadius: BorderRadius.circular(10),
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
                height: 20.h,
              ),
              firebaseNotifier.getLoading
                  ? loading(color: Colors.blue)
                  : ElevatedButton.icon(
                      onPressed: () async {
                        if (formKeyLogin.currentState!.validate()) {
                          formKeyLogin.currentState?.save();
                          await firebaseNotifier.logInWithEmailAndPassword(
                              emailController.text, passwordController.text);
                        }
                      },
                      icon: const Icon(Icons.lock_open),
                      label: const Text('Login'),
                    ),
              SizedBox(
                height: 10.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.push(RoutePaths.patientRegistration);
                    },
                    child: const Text('Register as Patient'),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 5.w, right: 5.w),
                    child: const Text('or'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.push(RoutePaths.doctorRegistration);
                    },
                    child: const Text('Register as Doctor'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  context.push(RoutePaths.resetPassword);
                },
                child: const Text('Reset password'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
