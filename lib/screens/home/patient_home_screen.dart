import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/pages/list_doctors_page.dart';
import 'package:schedcare/pages/notifications_page.dart';
import 'package:schedcare/pages/patient_home_page.dart';
import 'package:schedcare/pages/patient_profile_page.dart';
import 'package:schedcare/providers/firebase_provider.dart';

List<Widget> patientPages = const [
  PatientHomePage(),
  ListDoctorsPage(),
  NotificationsPage(),
  PatientProfilePage(),
];

class PatientHomeScreen extends HookConsumerWidget {
  const PatientHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseNotifier = ref.watch(firebaseProvider);
    final index = useState(0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SchedCare'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await firebaseNotifier.signOut();
            },
          ),
        ],
      ),
      body: !firebaseNotifier.getLoading
          ? patientPages[index.value]
          : const Center(
              child: CircularProgressIndicator(),
            ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.blue.shade100,
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        child: NavigationBar(
          height: 60,
          backgroundColor: const Color(0xFFF1F5FB),
          animationDuration: const Duration(milliseconds: 500),
          selectedIndex: index.value,
          onDestinationSelected: (selectedIndex) {
            index.value = selectedIndex;
          },
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.local_hospital_outlined),
                selectedIcon: Icon(Icons.local_hospital),
                label: 'Doctors'),
            NavigationDestination(
                icon: Icon(Icons.notification_add_outlined),
                selectedIcon: Icon(Icons.notification_add),
                label: 'Notifications'),
            NavigationDestination(
                icon: Icon(Icons.person_2_outlined),
                selectedIcon: Icon(Icons.person_2),
                label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
