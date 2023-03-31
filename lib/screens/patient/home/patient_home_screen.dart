import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/firebase_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/widgets.dart';

class PatientHomeScreen extends HookConsumerWidget {
  PatientHomeScreen({Key? key}) : super(key: key);
  final CollectionReference<Map<String, dynamic>>
      appNotificationsCollectionReference = FirebaseFirestore.instance
          .collection(FirestoreConstants.notificationsCollection);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);
    final Stream<QuerySnapshot<Map<String, dynamic>>> appNotificationsStream =
        appNotificationsCollectionReference
            .where(ModelFields.patientId,
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .where(ModelFields.isRead, isEqualTo: false)
            .snapshots();
    final pageController = usePageController();
    final index = useState(0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SchedCare'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              context.push(RoutePaths.patientProfile);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Confirm signing out?'),
                    actions: [
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () async {
                          context.pop();
                          await firebaseServicesNotifier.signOut();
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: !firebaseServicesNotifier.getLoading
          ? PageView(
              controller: pageController,
              onPageChanged: (selectedIndex) {
                index.value = selectedIndex;
              },
              children: AppConstants.patientPages)
          : loading(color: Colors.blue),
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
            pageController.animateToPage(
              selectedIndex,
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
            );
          },
          destinations: [
            const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home'),
            const NavigationDestination(
                icon: Icon(Icons.local_hospital_outlined),
                selectedIcon: Icon(Icons.local_hospital),
                label: 'Doctors'),
            const NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: 'Schedule'),
            NavigationDestination(
                icon: StreamBuilder(
                  stream: appNotificationsStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot) {
                    if (snapshot.hasData) {
                      final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                          appNotifications = snapshot.data!.docs;

                      return appNotifications.isEmpty
                          ? const Icon(Icons.notifications_active_outlined)
                          : Badge(
                              label: Text('${appNotifications.length}'),
                              child: const Icon(
                                  Icons.notifications_active_outlined),
                            );
                    }
                    return const Icon(Icons.notifications_active_outlined);
                  },
                ),
                selectedIcon: StreamBuilder(
                  stream: appNotificationsStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot) {
                    if (snapshot.hasData) {
                      final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                          appNotifications = snapshot.data!.docs;

                      return appNotifications.isEmpty
                          ? const Icon(Icons.notifications_active)
                          : Badge(
                              label: Text('${appNotifications.length}'),
                              child: const Icon(Icons.notifications_active),
                            );
                    }
                    return const Icon(Icons.notifications_active);
                  },
                ),
                label: 'Notifications'),
          ],
        ),
      ),
    );
  }
}
