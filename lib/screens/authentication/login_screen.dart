import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/firebase_provider.dart';
import 'package:schedcare/utilities/constants.dart';

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
      body: Form(
        key: formKeyLogin,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: emailController,
              decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.email),
                  labelText: 'Email Address',
                  hintText: 'Enter email address'),
              validator: (value) {
                return value!.isEmpty ? 'Required' : null;
              },
            ),
            HookBuilder(
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
            ElevatedButton.icon(
              onPressed: () async {
                if (formKeyLogin.currentState!.validate()) {
                  formKeyLogin.currentState?.save();
                  await firebaseNotifier.logInWithEmailAndPassword(
                      emailController.text, passwordController.text);
                }
              },
              icon: const Icon(Icons.lock_open),
              label: firebaseNotifier.isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {
                context.push(RoutePaths.patientRegistration);
              },
              child: const Text('Register as Patient'),
            ),
            ElevatedButton(
              onPressed: () {
                context.push(RoutePaths.doctorRegistration);
              },
              child: const Text('Register as Doctor'),
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
    );
  }
}
