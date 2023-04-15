import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schedcare/models/app_notification_model.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/prompts.dart';
import 'package:schedcare/utilities/widgets.dart';

class DoctorNotificationsPage extends HookConsumerWidget {
  DoctorNotificationsPage({Key? key}) : super(key: key);
  final CollectionReference<Map<String, dynamic>>
      appNotificationsCollectionReference = FirebaseFirestore.instance
          .collection(FirebaseConstants.notificationsCollection);
  final CollectionReference<Map<String, dynamic>> usersCollectionReference =
      FirebaseFirestore.instance.collection(FirebaseConstants.usersCollection);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);
    final Query<AppNotification> appNotificationsQuery =
        appNotificationsCollectionReference
            .where(ModelFields.doctorId,
                isEqualTo: firebaseServicesNotifier.getCurrentUser!.uid)
            .where(ModelFields.sender, isEqualTo: AppConstants.patient)
            .orderBy(ModelFields.sentAt, descending: true)
            .withConverter(
              fromFirestore: (snapshot, _) =>
                  AppNotification.fromSnapshot(snapshot),
              toFirestore: (appNotification, _) => appNotification.toMap(),
            );

    return FirestoreQueryBuilder(
      query: appNotificationsQuery,
      builder: (context, appNotificationCollectionSnapshot, _) {
        if (appNotificationCollectionSnapshot.hasData) {
          return appNotificationCollectionSnapshot.docs.isEmpty
              ? const Center(
                  child: Text(Prompts.noNotifications),
                )
              : ListView.builder(
                  itemCount: appNotificationCollectionSnapshot.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (appNotificationCollectionSnapshot.hasMore &&
                        index + 1 ==
                            appNotificationCollectionSnapshot.docs.length) {
                      appNotificationCollectionSnapshot.fetchMore();
                    }

                    final AppNotification appNotification =
                        appNotificationCollectionSnapshot.docs[index].data();

                    return ListTile(
                      tileColor: appNotification.isRead
                          ? Colors.white
                          : Colors.blue[50],
                      onTap: () {
                        firebaseServicesNotifier.getFirebaseFirestoreService
                            .updateDocument(
                                {ModelFields.isRead: true},
                                FirebaseConstants.notificationsCollection,
                                appNotification.id);
                      },
                      title: Center(
                        child: Text(appNotification.body),
                      ),
                      trailing: Text(
                        DateFormat('hh:mm a').format(appNotification.sentAt),
                        style: TextStyle(fontSize: 10.sp),
                      ),
                      subtitle: Center(
                        child: Text(
                            DateFormat('MMMM d, y')
                                .format(appNotification.sentAt),
                            style: TextStyle(fontSize: 12.sp)),
                      ),
                    );
                  },
                );
        }
        return loading(color: Colors.blue);
      },
    );
  }
}
