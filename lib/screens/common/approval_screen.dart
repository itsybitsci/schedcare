import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';

class ApprovalScreen extends HookConsumerWidget {
  const ApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Under Review'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Your application is still under review and pending for approval.',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await firebaseServicesNotifier.signOut();
              },
              child: const Text('Go back to Login screen'),
            ),
          ],
        ),
      ),
    );
  }
}
