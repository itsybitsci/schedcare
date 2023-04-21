import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
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

class SentConsultationRequestsPage extends HookConsumerWidget {
  SentConsultationRequestsPage({Key? key}) : super(key: key);
  final CollectionReference<Map<String, dynamic>>
      consultationRequestsCollectionReference = FirebaseFirestore.instance
          .collection(FirebaseConstants.consultationRequestsCollection);
  final CollectionReference<Map<String, dynamic>> usersCollectionReference =
      FirebaseFirestore.instance.collection(FirebaseConstants.usersCollection);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);
    final Query<ConsultationRequest> consultationRequestsQuery =
        consultationRequestsCollectionReference
            .where(ModelFields.patientId,
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
                  child: Text(Prompts.noSentConsultationRequests),
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
                            .doc(consultationRequest.doctorId)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<
                                    DocumentSnapshot<Map<String, dynamic>>>
                                doctorSnapshot) {
                          if (doctorSnapshot.hasData) {
                            Doctor doctor =
                                Doctor.fromSnapshot(doctorSnapshot.data!);

                            return StreamBuilder(
                              stream: consultationRequestsCollectionReference
                                  .doc(consultationRequest.id)
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<
                                          DocumentSnapshot<
                                              Map<String, dynamic>>>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  String? meetingId =
                                      snapshot.data!.get(ModelFields.meetingId);
                                  return ListTile(
                                    onTap: () => context.push(
                                      RoutePaths.patientViewConsultationRequest,
                                      extra:
                                          PatientViewConsultationRequestObject(
                                              doctor: doctor,
                                              consultationRequest:
                                                  consultationRequest),
                                    ),
                                    title: Center(
                                      child: Text(
                                        consultationRequest
                                            .consultationRequestPatientTitle,
                                        style: TextStyle(fontSize: 12.sp),
                                      ),
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
                                                  : consultationRequest
                                                              .status ==
                                                          AppConstants.approved
                                                      ? Colors.green
                                                      : Colors.orange),
                                    ),
                                    trailing: consultationRequest
                                                .consultationType ==
                                            AppConstants.teleconsultation
                                        ? IconButton(
                                            icon: consultationRequest
                                                        .consultationType ==
                                                    AppConstants
                                                        .teleconsultation
                                                ? Icon(
                                                    Icons.video_call,
                                                    color: meetingId != null
                                                        ? Colors.red
                                                        : Colors.black54,
                                                  )
                                                : Icon(
                                                    Icons.person_pin,
                                                    color: meetingId != null
                                                        ? Colors.red
                                                        : Colors.black54,
                                                  ),
                                            onPressed: () {
                                              if (meetingId != null) {
                                                context.push(
                                                  RoutePaths.joinScreen,
                                                  extra: MeetingPayload(
                                                    meetingId: meetingId,
                                                    consultationRequest:
                                                        consultationRequest,
                                                    role: AppConstants.patient,
                                                  ),
                                                );
                                              } else {
                                                if (consultationRequest
                                                        .status !=
                                                    AppConstants.approved) {
                                                  showToast(Prompts
                                                      .meetingUnavailable);
                                                } else {
                                                  showToast(Prompts
                                                      .waitForDoctorToStartMeeting);
                                                }
                                              }
                                            },
                                          )
                                        : null,
                                    subtitle: Center(
                                      child: Text(
                                        "${DateFormat('MMMM d, y  (hh:mm a - ').format(consultationRequest.consultationDateTime)} ${DateFormat(' hh:mm a) ').format(consultationRequest.consultationDateTime.add(
                                          const Duration(
                                              hours: AppConstants
                                                  .defaultMeetingDuration),
                                        ))}",
                                        style: TextStyle(fontSize: 10.sp),
                                      ),
                                    ),
                                  );
                                }
                                return shimmerListTile();
                              },
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
