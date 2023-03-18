import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/firebase_provider.dart';
import 'package:schedcare/utilities/helpers.dart';
import 'package:schedcare/utilities/widgets.dart';

class DoctorHomeScreen extends HookConsumerWidget {
  const DoctorHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseNotifier = ref.watch(firebaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: !firebaseNotifier.getLoading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                    'You\'re in the Home Screen as a Doctor ${firebaseNotifier.getDoctor!.email}'),
                Center(
                  child: ElevatedButton(
                    child: const Text('Logout'),
                    onPressed: () async {
                      showToast('Successfully logged out.');
                      await firebaseNotifier.signOut();
                    },
                  ),
                )
              ],
            )
          : loading(),
    );
  }
}
