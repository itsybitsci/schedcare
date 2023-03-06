import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/auth_provider.dart';

class PatientHomeScreen extends ConsumerWidget {
  const PatientHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: authNotifier.isLoggedIn
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                    'You\'re in the Home Screen as a Patient ${authNotifier.patient!.email}'),
                Center(
                  child: ElevatedButton(
                    child: const Text('Logout'),
                    onPressed: () async {
                      await authNotifier.signOut();
                    },
                  ),
                )
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
