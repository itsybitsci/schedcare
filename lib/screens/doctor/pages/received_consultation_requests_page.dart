import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:schedcare/plugins/videosdk_plugin/screens/join_screen.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/utilities/animations.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/helpers.dart';
import 'package:schedcare/utilities/prompts.dart';
import 'package:schedcare/utilities/widgets.dart';

class ReceivedConsultationRequestsPage extends HookConsumerWidget {
  ReceivedConsultationRequestsPage({Key? key}) : super(key: key);
  final CollectionReference<Map<String, dynamic>>
      consultationRequestsCollectionReference = FirebaseFirestore.instance
          .collection(FirebaseConstants.consultationRequestsCollection);
  final CollectionReference<Map<String, dynamic>> usersCollectionReference =
      FirebaseFirestore.instance.collection(FirebaseConstants.usersCollection);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);
    final scrollController = useScrollController();
    final Query<ConsultationRequest> consultationRequestsQuery =
        consultationRequestsCollectionReference
            .where(ModelFields.doctorId,
                isEqualTo: firebaseServicesNotifier.getCurrentUser!.uid)
            .orderBy(ModelFields.createdAt, descending: true)
            .withConverter(
              fromFirestore: (snapshot, _) =>
                  ConsultationRequest.fromSnapshot(snapshot),
              toFirestore: (consultationRequest, _) =>
                  consultationRequest.toMap(),
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
                  'Received Consultation Requests',
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
                  child: FirestoreQueryBuilder<ConsultationRequest>(
                    query: consultationRequestsQuery,
                    pageSize: 10,
                    builder:
                        (context, consultationRequestCollectionSnapshot, _) {
                      if (consultationRequestCollectionSnapshot.hasError) {
                        return lottieError();
                      }

                      if (consultationRequestCollectionSnapshot.hasData) {
                        return consultationRequestCollectionSnapshot
                                .docs.isEmpty
                            ? const Center(
                                child: Text(
                                    Prompts.noReceivedConsultationRequests),
                              )
                            : ListView.builder(
                                itemCount: consultationRequestCollectionSnapshot
                                        .docs.length +
                                    1,
                                itemBuilder: (context, index) {
                                  if (index ==
                                      consultationRequestCollectionSnapshot
                                          .docs.length) {
                                    return lottieDiamondLoading();
                                  }

                                  if (consultationRequestCollectionSnapshot
                                          .hasMore &&
                                      index + 1 ==
                                          consultationRequestCollectionSnapshot
                                              .docs.length) {
                                    consultationRequestCollectionSnapshot
                                        .fetchMore();
                                  }

                                  final ConsultationRequest
                                      consultationRequest =
                                      consultationRequestCollectionSnapshot
                                          .docs[index]
                                          .data();

                                  final bool isLapsed =
                                      checkIfLapsed(consultationRequest);

                                  return StreamBuilder(
                                    stream: usersCollectionReference
                                        .doc(consultationRequest.patientId)
                                        .snapshots(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<
                                                DocumentSnapshot<
                                                    Map<String, dynamic>>>
                                            patientSnapshot) {
                                      if (patientSnapshot.hasData) {
                                        Patient patient = Patient.fromSnapshot(
                                            patientSnapshot.data!);

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
                                              onTap: () => context.push(
                                                RoutePaths
                                                    .doctorViewConsultationRequest,
                                                extra:
                                                    DoctorViewConsultationRequestObject(
                                                        patient: patient,
                                                        consultationRequest:
                                                            consultationRequest),
                                              ),
                                              title: Text(
                                                  '${patient.firstName} ${patient.lastName}',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 16.sp)),
                                              trailing: buildTrailing(
                                                  consultationRequest),
                                              subtitle: buildSubtitle(
                                                  context,
                                                  firebaseServicesNotifier,
                                                  consultationRequest,
                                                  isLapsed),
                                            ),
                                          ),
                                        );
                                      }

                                      return shimmerListTile();
                                    },
                                  );
                                },
                              );
                      }

                      return lottieLoading();
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

  Widget buildTrailing(ConsultationRequest consultationRequest) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                "${DateFormat('MMMM d, y').format(consultationRequest.createdAt)} ",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 8.sp),
              ),
              Text(
                "${DateFormat('hh:mm a').format(consultationRequest.createdAt)} ",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 8.sp),
              ),
            ],
          ),
        ],
      );

  Widget buildSubtitle(
    BuildContext context,
    FirebaseServicesProvider firebaseServicesNotifier,
    ConsultationRequest consultationRequest,
    bool isLapsed,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5.h),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.black,
              ),
              children: <TextSpan>[
                const TextSpan(
                  text: 'Type of Consultation: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: consultationRequest.consultationType,
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.black,
              ),
              children: <TextSpan>[
                const TextSpan(
                  text: 'Date of Consultation: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: DateFormat('MMMM d, y')
                      .format(consultationRequest.consultationDateTime),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.black,
              ),
              children: <TextSpan>[
                const TextSpan(
                  text: 'Time: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text:
                      '${DateFormat('hh:mm a - ').format(consultationRequest.consultationDateTime)} ${DateFormat(' hh:mm a').format(consultationRequest.consultationDateTime.add(
                    const Duration(hours: AppConstants.defaultMeetingDuration),
                  ))}',
                ),
              ],
            ),
          ),
          SizedBox(height: 5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 80.w,
                height: 25.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: isLapsed
                      ? Colors.grey
                      : consultationRequest.status == AppConstants.rejected
                          ? Colors.red
                          : consultationRequest.status == AppConstants.approved
                              ? Colors.green
                              : Colors.orange,
                ),
                child: Center(
                  child: Text(
                    isLapsed ? AppConstants.lapsed : consultationRequest.status,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10.w,
              ),
              if (consultationRequest.status == AppConstants.approved &&
                  consultationRequest.consultationType ==
                      AppConstants.teleconsultation &&
                  isWithinSchedule(consultationRequest.consultationDateTime))
                Container(
                  width: 100.w,
                  height: 25.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                      child: ElevatedButton(
                    onPressed: () async {
                      context.push(RoutePaths.joinScreen,
                          extra: MeetingPayload(
                              consultationRequest: consultationRequest,
                              role: AppConstants.doctor));
                    },
                    child: Text(
                      'Create Meeting',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                      ),
                    ),
                  )),
                ),
            ],
          ),
        ],
      );
}
