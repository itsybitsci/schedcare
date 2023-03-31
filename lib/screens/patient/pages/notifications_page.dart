import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schedcare/models/app_notification_model.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/providers/firebase_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/prompts.dart';
import 'package:schedcare/utilities/widgets.dart';

class NotificationsPage extends HookConsumerWidget {
  NotificationsPage({Key? key}) : super(key: key);
  final CollectionReference<Map<String, dynamic>>
      appNotificationsCollectionReference = FirebaseFirestore.instance
          .collection(FirestoreConstants.notificationsCollection);
  final CollectionReference<Map<String, dynamic>> usersCollectionReference =
      FirebaseFirestore.instance.collection(FirestoreConstants.usersCollection);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);
    final Query<AppNotification> appNotificationsQuery =
        appNotificationsCollectionReference
            .where(ModelFields.patientId,
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .orderBy(ModelFields.sentAt)
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

                    return StreamBuilder(
                      stream: usersCollectionReference
                          .doc(appNotification.doctorId)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                              doctorSnapshot) {
                        if (doctorSnapshot.hasData) {
                          Doctor doctor =
                              Doctor.fromSnapshot(doctorSnapshot.data!);

                          return ListTile(
                            tileColor: appNotification.isRead
                                ? Colors.white
                                : Colors.blue[50],
                            onTap: () {
                              firebaseServicesNotifier
                                  .getFirebaseFirestoreService
                                  .updateDocument({
                                ModelFields.isRead: true
                              }, FirestoreConstants.notificationsCollection,
                                      appNotification.id);
                            },
                            title: Center(
                              child: Text(
                                'Consultation request approved by ${doctor.middleName.isEmpty ? '${doctor.prefix} ${doctor.firstName} ${doctor.lastName} ${doctor.suffix}'.trim() : '${doctor.prefix} ${doctor.firstName} ${doctor.middleName} ${doctor.lastName} ${doctor.suffix}'.trim()}',
                              ),
                            ),
                            trailing: Text(
                              DateFormat('hh:mm a')
                                  .format(appNotification.sentAt),
                              style: TextStyle(fontSize: 10.sp),
                            ),
                            subtitle: Center(
                              child: Text(
                                  DateFormat('MMMM d, y')
                                      .format(appNotification.sentAt),
                                  style: TextStyle(fontSize: 12.sp)),
                            ),
                          );
                        }

                        return shimmerListTile();
                      },
                    );
                  },
                );
        }
        return loading(color: Colors.blue);
      },
    );
  }
}
