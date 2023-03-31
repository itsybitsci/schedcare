import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schedcare/models/consultation_request_model.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/providers/firebase_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/prompts.dart';
import 'package:schedcare/utilities/widgets.dart';

class PatientHomePage extends HookConsumerWidget {
  PatientHomePage({Key? key}) : super(key: key);
  final CollectionReference<Map<String, dynamic>>
      consultationRequestsCollectionReference = FirebaseFirestore.instance
          .collection(FirestoreConstants.consultationRequestsCollection);
  final CollectionReference<Map<String, dynamic>> usersCollectionReference =
      FirebaseFirestore.instance.collection(FirestoreConstants.usersCollection);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);
    final Query<ConsultationRequest> consultationRequestsQuery =
        consultationRequestsCollectionReference
            .where(ModelFields.patientUid,
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .orderBy(ModelFields.consultationDateTime)
            .withConverter(
              fromFirestore: (snapshot, _) =>
                  ConsultationRequest.fromSnapshot(snapshot),
              toFirestore: (consultationRequest, _) =>
                  consultationRequest.toMap(),
            );

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
            'SchedCare',
            'SchedCare',
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

    return FirestoreQueryBuilder<ConsultationRequest>(
      query: consultationRequestsQuery,
      pageSize: 10,
      builder: (context, consultationRequestSnapshot, _) {
        if (consultationRequestSnapshot.hasData) {
          return consultationRequestSnapshot.docs.isEmpty
              ? const Center(
                  child: Text(Prompts.noSentConsultationRequests),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    consultationRequestSnapshot.fetchMore();
                  },
                  child: ListView.builder(
                    itemCount: consultationRequestSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      if (consultationRequestSnapshot.hasMore &&
                          index + 1 ==
                              consultationRequestSnapshot.docs.length) {
                        consultationRequestSnapshot.fetchMore();
                      }

                      final ConsultationRequest consultationRequest =
                          consultationRequestSnapshot.docs[index].data();

                      return StreamBuilder(
                        stream: usersCollectionReference
                            .doc(consultationRequest.doctorUid)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<
                                    DocumentSnapshot<Map<String, dynamic>>>
                                doctorSnapshot) {
                          if (doctorSnapshot.hasData) {
                            Doctor doctor =
                                Doctor.fromSnapshot(doctorSnapshot.data!);
                            return ListTile(
                              onTap: () {
                                context.push(
                                  RoutePaths.viewConsultationRequest,
                                  extra: ViewConsultationRequestObject(
                                      doctor: doctor,
                                      consultationRequest: consultationRequest),
                                );
                              },
                              title: Center(
                                child: Text(consultationRequest
                                    .consultationRequestTitle),
                              ),
                              trailing: Text(
                                consultationRequest.status,
                                style: TextStyle(fontSize: 10.sp),
                              ),
                              subtitle: Center(
                                child: Text(
                                    DateFormat('MMMM d, y - hh:mm a').format(
                                        consultationRequest
                                            .consultationDateTime),
                                    style: TextStyle(fontSize: 12.sp)),
                              ),
                            );
                          }

                          return shimmerListTile();
                        },
                      );
                    },
                  ),
                );
        }

        return shimmerListTile();
      },
    );
  }
}
