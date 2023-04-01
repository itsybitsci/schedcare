import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/utilities/constants.dart';

class DoctorProfileScreen extends HookConsumerWidget {
  const DoctorProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
            onPressed: () {
              context.push(RoutePaths.editDoctorProfile);
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Profile Screen'),
      ),
    );
  }
}
