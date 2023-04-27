import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/utilities/components.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/widgets.dart';

class PatientHomeScreen extends HookConsumerWidget {
  PatientHomeScreen({Key? key}) : super(key: key);
  final CollectionReference<Map<String, dynamic>>
      appNotificationsCollectionReference = FirebaseFirestore.instance
          .collection(FirebaseConstants.notificationsCollection);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);
    final Stream<QuerySnapshot<Map<String, dynamic>>> appNotificationsStream =
        appNotificationsCollectionReference
            .where(ModelFields.patientId,
                isEqualTo: firebaseServicesNotifier.getCurrentUser!.uid)
            .where(ModelFields.sender, isEqualTo: AppConstants.doctor)
            .where(ModelFields.isRead, isEqualTo: false)
            .snapshots();
    final index = useState(0);

    useEffect(() {
      firebaseServicesNotifier.getAndSaveDeviceToken();

      flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );

      FirebaseMessaging.onMessage.listen(
        (RemoteMessage message) async {
          AndroidNotificationDetails androidPlatformChannelSpecifics =
              const AndroidNotificationDetails(
            AppConstants.channelId,
            AppConstants.channelId,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            showWhen: false,
          );
          NotificationDetails platformChannelSpecifics =
              NotificationDetails(android: androidPlatformChannelSpecifics);
          await FlutterLocalNotificationsPlugin().show(
            0,
            message.notification!.title,
            message.notification!.body,
            platformChannelSpecifics,
          );
        },
      );

      return null;
    }, []);

    return firebaseServicesNotifier.getLoggingIn
        ? const LoadingScreen()
        : Scaffold(
            appBar: AppBar(
              title: const Text(AppConstants.appTitle),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person),
                  tooltip: 'Profile',
                  onPressed: () {
                    context.push(RoutePaths.patientProfile);
                  },
                ),
                logoutButton(
                  context: context,
                  onPressedNo: () => context.pop(),
                  onPressedYes: () async {
                    context.pop();
                    await firebaseServicesNotifier.signOut();
                  },
                ),
              ],
            ),
            body: Background(child: AppConstants.patientPages[index.value]),
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
                            final List<
                                    QueryDocumentSnapshot<Map<String, dynamic>>>
                                appNotifications = snapshot.data!.docs;

                            return appNotifications.isEmpty
                                ? const Icon(
                                    Icons.notifications_active_outlined)
                                : Badge(
                                    label: Text('${appNotifications.length}'),
                                    child: const Icon(
                                        Icons.notifications_active_outlined),
                                  );
                          }
                          return const Icon(
                              Icons.notifications_active_outlined);
                        },
                      ),
                      selectedIcon: StreamBuilder(
                        stream: appNotificationsStream,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                snapshot) {
                          if (snapshot.hasData) {
                            final List<
                                    QueryDocumentSnapshot<Map<String, dynamic>>>
                                appNotifications = snapshot.data!.docs;

                            return appNotifications.isEmpty
                                ? const Icon(Icons.notifications_active)
                                : Badge(
                                    label: Text('${appNotifications.length}'),
                                    child:
                                        const Icon(Icons.notifications_active),
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
