import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schedcare/models/app_notification_model.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/utilities/animations.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/prompts.dart';

class PatientNotificationsPage extends HookConsumerWidget {
  PatientNotificationsPage({Key? key}) : super(key: key);
  final CollectionReference<Map<String, dynamic>>
      appNotificationsCollectionReference = FirebaseFirestore.instance
          .collection(FirebaseConstants.notificationsCollection);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);
    final scrollController = useScrollController();

    final Query<AppNotification> appNotificationsQuery =
        appNotificationsCollectionReference
            .where(ModelFields.patientId,
                isEqualTo: firebaseServicesNotifier.getCurrentUser!.uid)
            .where(ModelFields.sender, isEqualTo: AppConstants.doctor)
            .orderBy(ModelFields.sentAt, descending: true)
            .withConverter(
              fromFirestore: (snapshot, _) =>
                  AppNotification.fromSnapshot(snapshot),
              toFirestore: (appNotification, _) => appNotification.toMap(),
            );

    return Center(
      child: Container(
        height: 540.h,
        width: 340.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: ColorConstants.primaryLight,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 320.w,
              height: 40.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: Colors.white,
              ),
              child: Center(
                child: Text(
                  'Notifications',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Flexible(
              child: Container(
                width: 320.w,
                height: 470.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: Colors.white,
                ),
                child: Scrollbar(
                  radius: Radius.circular(20.r),
                  controller: scrollController,
                  child: FirestoreQueryBuilder(
                    query: appNotificationsQuery,
                    builder: (context, appNotificationCollectionSnapshot, _) {
                      if (appNotificationCollectionSnapshot.hasError) {
                        return lottieError();
                      }

                      if (appNotificationCollectionSnapshot.hasData) {
                        return appNotificationCollectionSnapshot.docs.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    lottieNoNotifications(),
                                    Text(
                                      Prompts.noNotifications,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: appNotificationCollectionSnapshot
                                        .docs.length +
                                    1,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index ==
                                      appNotificationCollectionSnapshot
                                          .docs.length) {
                                    return lottieDiamondLoading();
                                  }

                                  if (appNotificationCollectionSnapshot
                                          .hasMore &&
                                      index + 1 ==
                                          appNotificationCollectionSnapshot
                                              .docs.length) {
                                    appNotificationCollectionSnapshot
                                        .fetchMore();
                                  }

                                  final AppNotification appNotification =
                                      appNotificationCollectionSnapshot
                                          .docs[index]
                                          .data();

                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5.h, horizontal: 10.w),
                                    child: Material(
                                      type: MaterialType.transparency,
                                      child: ListTile(
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Colors.grey[300]!),
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                        ),
                                        tileColor: appNotification.isRead
                                            ? Colors.grey[200]
                                            : Colors.blue[50],
                                        onTap: appNotification.isRead
                                            ? null
                                            : () async => firebaseServicesNotifier
                                                .getFirebaseFirestoreService
                                                .updateDocument(
                                                    {ModelFields.isRead: true},
                                                    FirebaseConstants
                                                        .notificationsCollection,
                                                    appNotification.id),
                                        onLongPress: () async =>
                                            await showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(
                                              'Delete Notification?',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 15.sp),
                                            ),
                                            actionsAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            actions: [
                                              TextButton(
                                                onPressed: () => context.pop(),
                                                child: Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                      fontSize: 10.sp),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  await firebaseServicesNotifier
                                                      .getFirebaseFirestoreService
                                                      .deleteDocument(
                                                          FirebaseConstants
                                                              .notificationsCollection,
                                                          appNotification.id)
                                                      .then((value) =>
                                                          context.pop());
                                                },
                                                child: Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                      fontSize: 10.sp),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        title: Center(
                                          child: Text(
                                            appNotification.body,
                                            style: TextStyle(fontSize: 12.sp),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        trailing: Text(
                                          DateFormat('hh:mm a')
                                              .format(appNotification.sentAt),
                                          style: TextStyle(fontSize: 10.sp),
                                        ),
                                        subtitle: Center(
                                          child: Text(
                                              DateFormat('MMMM d, y').format(
                                                  appNotification.sentAt),
                                              style:
                                                  TextStyle(fontSize: 10.sp)),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                      }
                      return lottieLoading(width: 50);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
