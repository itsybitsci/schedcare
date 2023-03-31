import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/firebase_provider.dart';
import 'package:schedcare/utilities/helpers.dart';
import 'package:schedcare/utilities/widgets.dart';

class DoctorHomeScreen extends HookConsumerWidget {
  const DoctorHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: !firebaseServicesNotifier.getLoading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                    'You\'re in the Home Screen as a Doctor ${firebaseServicesNotifier.getDoctor!.email}'),
                Center(
                  child: ElevatedButton(
                    child: const Text('Logout'),
                    onPressed: () async {
                      showToast('Successfully logged out.');
                      await firebaseServicesNotifier.signOut();
                    },
                  ),
                )
              ],
            )
          : loading(),
    );
  }
}
