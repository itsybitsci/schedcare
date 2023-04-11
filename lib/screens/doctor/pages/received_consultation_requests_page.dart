import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schedcare/models/consultation_request_model.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/plugins/videosdk_plugin/screens/join_screen.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/helpers.dart';
import 'package:schedcare/utilities/prompts.dart';
import 'package:schedcare/utilities/widgets.dart';

class ReceivedConsultationRequestsPage extends HookConsumerWidget {
  ReceivedConsultationRequestsPage({Key? key}) : super(key: key);
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
            .where(ModelFields.doctorId,
                isEqualTo: firebaseServicesNotifier.getCurrentUser!.uid)
            .orderBy(ModelFields.consultationDateTime)
            .withConverter(
              fromFirestore: (snapshot, _) =>
                  ConsultationRequest.fromSnapshot(snapshot),
              toFirestore: (consultationRequest, _) =>
                  consultationRequest.toMap(),
            );

    return FirestoreQueryBuilder<ConsultationRequest>(
      query: consultationRequestsQuery,
      pageSize: 10,
      builder: (context, consultationRequestCollectionSnapshot, _) {
        if (consultationRequestCollectionSnapshot.hasData) {
          return consultationRequestCollectionSnapshot.docs.isEmpty
              ? const Center(
                  child: Text(Prompts.noReceivedConsultationRequests),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    consultationRequestCollectionSnapshot.fetchMore();
                  },
                  child: ListView.builder(
                    itemCount:
                        consultationRequestCollectionSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      if (consultationRequestCollectionSnapshot.hasMore &&
                          index + 1 ==
                              consultationRequestCollectionSnapshot
                                  .docs.length) {
                        consultationRequestCollectionSnapshot.fetchMore();
                      }

                      final ConsultationRequest consultationRequest =
                          consultationRequestCollectionSnapshot.docs[index]
                              .data();

                      final bool isLapsed = checkIfLapsed(consultationRequest);

                      return StreamBuilder(
                        stream: usersCollectionReference
                            .doc(consultationRequest.patientId)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<
                                    DocumentSnapshot<Map<String, dynamic>>>
                                doctorSnapshot) {
                          if (doctorSnapshot.hasData) {
                            Patient patient =
                                Patient.fromSnapshot(doctorSnapshot.data!);
                            return ListTile(
                              onTap: () => (consultationRequest.status !=
                                          AppConstants.rejected) &&
                                      !isLapsed
                                  ? context.push(
                                      RoutePaths.doctorViewConsultationRequest,
                                      extra:
                                          DoctorViewConsultationRequestObject(
                                              patient: patient,
                                              consultationRequest:
                                                  consultationRequest),
                                    )
                                  : null,
                              title: Center(
                                child: Text(consultationRequest
                                    .consultationRequestDoctorTitle),
                              ),
                              leading: Text(
                                isLapsed
                                    ? AppConstants.lapsed
                                    : consultationRequest.status,
                                style: TextStyle(
                                    fontSize: 10.sp,
                                    color: isLapsed
                                        ? Colors.black54
                                        : consultationRequest.status ==
                                                AppConstants.rejected
                                            ? Colors.red
                                            : consultationRequest.status ==
                                                    AppConstants.approved
                                                ? Colors.green
                                                : Colors.orange),
                              ),
                              trailing: IconButton(
                                icon: consultationRequest.consultationType ==
                                        AppConstants.teleconsultation
                                    ? Icon(
                                        Icons.video_call,
                                        color: consultationRequest.status ==
                                                    AppConstants.approved &&
                                                isWithinSchedule(
                                                    consultationRequest
                                                        .consultationDateTime)
                                            ? Colors.red
                                            : Colors.black54,
                                      )
                                    : Icon(
                                        Icons.person_pin,
                                        color: consultationRequest.status ==
                                                    AppConstants.approved &&
                                                isWithinSchedule(
                                                    consultationRequest
                                                        .consultationDateTime)
                                            ? Colors.red
                                            : Colors.black54,
                                      ),
                                onPressed: () {
                                  if (consultationRequest.status ==
                                          AppConstants.approved &&
                                      isWithinSchedule(consultationRequest
                                          .consultationDateTime)) {
                                    context.push(
                                      RoutePaths.joinScreen,
                                      extra: MeetingPayload(
                                          consultationRequest:
                                              consultationRequest,
                                          role: AppConstants.doctor),
                                    );
                                  } else {
                                    isLapsed
                                        ? showToast(
                                            Prompts.unableToStartLapsedMeeting)
                                        : consultationRequest.status ==
                                                AppConstants.rejected
                                            ? showToast(Prompts
                                                .unableToStartRejectedMeeting)
                                            : consultationRequest.status ==
                                                    AppConstants.pending
                                                ? showToast(Prompts
                                                    .unableToStartPendingMeeting)
                                                : DateTime.now().isAfter(
                                                        consultationRequest
                                                            .consultationDateTime)
                                                    ? showToast(Prompts
                                                        .unableToStartMeetingInThePast)
                                                    : showToast(Prompts
                                                        .unableToStartApprovedMeeting);
                                  }
                                },
                              ),
                              subtitle: Center(
                                child: Text(
                                  "${DateFormat('MMMM d, y  (hh:mm a - ').format(consultationRequest.consultationDateTime)} ${DateFormat(' hh:mm a) ').format(consultationRequest.consultationDateTime.add(
                                    const Duration(
                                        hours: AppConstants
                                            .defaultMeetingDuration),
                                  ))}",
                                  style: TextStyle(fontSize: 12.sp),
                                ),
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

        return loading(color: Colors.blue);
      },
    );
  }
}
