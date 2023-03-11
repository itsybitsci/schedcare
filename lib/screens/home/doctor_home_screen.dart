import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/auth_provider.dart';

class DoctorHomeScreen extends HookConsumerWidget {
  const DoctorHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.watch(firebaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text('You\'re in the Home Screen as a Doctor'),
          Center(
            child: ElevatedButton(
              child: const Text('Logout'),
              onPressed: () async {
                await authNotifier.signOut();
              },
            ),
          )
        ],
      ),
    );
  }
}
