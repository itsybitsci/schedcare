import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/providers/consultation_request_provider.dart';
import 'package:schedcare/utilities/animations.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/helpers.dart';
import 'package:schedcare/utilities/prompts.dart';

class SendConsultationRequestScreen extends HookConsumerWidget {
  final Doctor doctor;
  SendConsultationRequestScreen({super.key, required this.doctor});
  final GlobalKey<FormState> formKeySendConsultationRequest =
      GlobalKey<FormState>();
  final CollectionReference<Map<String, dynamic>>
      consultationRequestsCollectionReference = FirebaseFirestore.instance
          .collection(FirebaseConstants.consultationRequestsCollection);
  final CollectionReference<Map<String, dynamic>> usersCollectionReference =
      FirebaseFirestore.instance.collection(FirebaseConstants.usersCollection);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);
    final consultationRequestNotifier = ref.watch(consultationRequestProvider);
    final scrollController = useScrollController();
    final Stream<QuerySnapshot<Map<String, dynamic>>>
        consultationRequestsStream = consultationRequestsCollectionReference
            .where(ModelFields.patientId,
                isEqualTo: firebaseServicesNotifier.getCurrentUser!.uid)
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Consultation Request'),
      ),
      resizeToAvoidBottomInset: false,
      body: WillPopScope(
        onWillPop: () async => !firebaseServicesNotifier.getLoading,
        child: Center(
          child: Container(
            height: 580.h,
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
                  height: 80.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          '${doctor.prefix} ${doctor.firstName} ${doctor.lastName} ${doctor.suffix}'
                              .trim(),
                          style: TextStyle(
                              fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      Text('Sex: ${doctor.sex}',
                          style: TextStyle(fontSize: 12.sp)),
                      Text('Specialization: ${doctor.specialization}',
                          style: TextStyle(fontSize: 12.sp)),
                    ],
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
                      child: SingleChildScrollView(
                        child: StreamBuilder(
                          stream: consultationRequestsStream,
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            if (snapshot.hasError) {
                              return lottieError();
                            }

                            if (snapshot.hasData) {
                              List<DateTime> consultationRequestStartTimes =
                                  snapshot.data!.docs
                                      .where((snapshot) =>
                                          snapshot.get(ModelFields.status) !=
                                          AppConstants.rejected)
                                      .map((snapshot) => snapshot
                                          .get(ModelFields.consultationDateTime)
                                          .toDate() as DateTime)
                                      .toList();

                              return StreamBuilder(
                                stream: usersCollectionReference
                                    .doc(firebaseServicesNotifier
                                        .getCurrentUser!.uid)
                                    .snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<
                                            DocumentSnapshot<
                                                Map<String, dynamic>>>
                                        userSnapshot) {
                                  if (snapshot.hasError) {
                                    return lottieError();
                                  }

                                  if (userSnapshot.hasData) {
                                    return Form(
                                      key: formKeySendConsultationRequest,
                                      child: Center(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            Text(
                                              'Consultation Request Body',
                                              style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            consultationRequestNotifier
                                                .buildBody(
                                                    enabled:
                                                        !firebaseServicesNotifier
                                                            .getLoading),
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            consultationRequestNotifier
                                                .buildFilePicker(
                                                    firebaseServicesNotifier),
                                            if (firebaseServicesNotifier
                                                    .getFirebaseStorageService
                                                    .uploadTask !=
                                                null)
                                              consultationRequestNotifier
                                                  .buildUploadProgressIndicator(
                                                      firebaseServicesNotifier),
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            Text(
                                              'Consultation Date',
                                              style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            SizedBox(
                                              height: 70.h,
                                              width: 200.w,
                                              child: consultationRequestNotifier
                                                  .buildDatePicker(context,
                                                      enabled:
                                                          !firebaseServicesNotifier
                                                              .getLoading),
                                            ),
                                            Text(
                                              'Consultation Time',
                                              style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            SizedBox(
                                              height: 70.h,
                                              width: 200.w,
                                              child: consultationRequestNotifier
                                                  .buildTimePicker(context,
                                                      enabled:
                                                          !firebaseServicesNotifier
                                                              .getLoading),
                                            ),
                                            Text(
                                              'Type of Consultation',
                                              style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  maxHeight: 50.h,
                                                  maxWidth: 250.w),
                                              child: consultationRequestNotifier
                                                  .buildConsultationType(
                                                      enabled:
                                                          !firebaseServicesNotifier
                                                              .getLoading),
                                            ),
                                            ElevatedButton(
                                              onPressed: firebaseServicesNotifier
                                                      .getLoading
                                                  ? null
                                                  : () async => await sendConsultationRequest(
                                                          context,
                                                          firebaseServicesNotifier,
                                                          consultationRequestNotifier,
                                                          consultationRequestStartTimes,
                                                          userSnapshot)
                                                      .then((success) => success
                                                          ? context.pop()
                                                          : null),
                                              child: Text('SEND REQUEST',
                                                  style: TextStyle(
                                                      fontSize: 14.sp)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  return lottieLoading(width: 50);
                                },
                              );
                            }
                            return lottieLoading(width: 50);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> sendConsultationRequest(
      BuildContext context,
      FirebaseServicesProvider firebaseServicesNotifier,
      ConsultationRequestProvider consultationRequestNotifier,
      List<DateTime> consultationRequestStartTimes,
      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
          userSnapshot) async {
    if (formKeySendConsultationRequest.currentState!.validate()) {
      formKeySendConsultationRequest.currentState?.save();

      if (isOverlapping(consultationRequestStartTimes,
          consultationRequestNotifier.dateTime)) {
        showToast(Prompts.overlappingSchedule);
        return false;
      }

      DocumentReference consultationRequestRef = FirebaseFirestore.instance
          .collection(FirebaseConstants.consultationRequestsCollection)
          .doc();
      String consultationRequestId = consultationRequestRef.id;
      Map<String, dynamic> consultationRequest = {
        ModelFields.id: consultationRequestId,
        ModelFields.patientId: firebaseServicesNotifier.getCurrentUser!.uid,
        ModelFields.doctorId: doctor.id,
        ModelFields.consultationRequestPatientTitle:
            'Consultation with ${'${doctor.prefix} ${doctor.firstName} ${doctor.lastName} ${doctor.suffix}'.trim()}',
        ModelFields.consultationRequestDoctorTitle:
            'Consultation with ${userSnapshot.data!.get(ModelFields.firstName)} ${userSnapshot.data!.get(ModelFields.lastName)} ${userSnapshot.data!.get(ModelFields.suffix)}'
                .trim(),
        ModelFields.consultationRequestBody:
            consultationRequestNotifier.consultationRequestBody,
        ModelFields.status: AppConstants.pending,
        ModelFields.consultationType:
            consultationRequestNotifier.consultationType,
        ModelFields.consultationDateTime: consultationRequestNotifier.dateTime,
        ModelFields.modifiedAt: DateTime.now(),
        ModelFields.createdAt: DateTime.now(),
        ModelFields.meetingId: null,
        ModelFields.messages: [],
        ModelFields.patientAttachmentUrl: null,
        ModelFields.doctorAttachmentUrl: null,
        ModelFields.isPatientSoftDeleted: false,
        ModelFields.isDoctorSoftDeleted: false,
      };

      await firebaseServicesNotifier
          .sendConsultationRequest(
              consultationRequest,
              FirebaseConstants.consultationRequestsCollection,
              consultationRequestId)
          .then(
        (success) async {
          if (consultationRequestNotifier.pickedFile != null) {
            await uploadAttachment(firebaseServicesNotifier,
                consultationRequestNotifier, consultationRequestId);
          }

          await sendNotification(firebaseServicesNotifier);

          showToast('Successfully sent consultation request');
        },
      );
      return true;
    }
    return false;
  }

  Future uploadAttachment(
      FirebaseServicesProvider firebaseServicesNotifier,
      ConsultationRequestProvider consultationRequestNotifier,
      String consultationRequestId) async {
    await firebaseServicesNotifier.uploadFile(
        File(consultationRequestNotifier.pickedFile!.path!),
        consultationRequestId,
        AppConstants.patient,
        consultationRequestNotifier.pickedFile!.name);
  }

  Future sendNotification(
      FirebaseServicesProvider firebaseServicesNotifier) async {
    await firebaseServicesNotifier.getFirebaseFirestoreService
        .getDocument(FirebaseConstants.usersCollection,
            firebaseServicesNotifier.getCurrentUser!.uid)
        .then(
      (userSnapshot) async {
        DocumentReference appNotificationRef = FirebaseFirestore.instance
            .collection(FirebaseConstants.notificationsCollection)
            .doc();
        String appNotificationId = appNotificationRef.id;
        String notificationTitle = 'New Consultation Request';
        String notificationBody =
            'New consultation request received from ${userSnapshot.get(ModelFields.firstName)} ${userSnapshot.get(ModelFields.lastName)}';

        Map<String, dynamic> appNotification = {
          ModelFields.id: appNotificationId,
          ModelFields.patientId: firebaseServicesNotifier.getCurrentUser!.uid,
          ModelFields.doctorId: doctor.id,
          ModelFields.title: notificationTitle,
          ModelFields.body: notificationBody,
          ModelFields.sentAt: DateTime.now(),
          ModelFields.sender: AppConstants.patient,
          ModelFields.isRead: false,
        };

        await firebaseServicesNotifier.getFirebaseFirestoreService.setDocument(
            appNotification,
            FirebaseConstants.notificationsCollection,
            appNotificationId);

        await firebaseServicesNotifier.getFirebaseFirestoreService
            .getDocument(FirebaseConstants.userTokensCollection, doctor.id)
            .then(
          (DocumentSnapshot<Map<String, dynamic>> userTokenSnapshot) {
            List tokens = userTokenSnapshot.get(ModelFields.deviceTokens);

            for (String token in tokens) {
              firebaseServicesNotifier.getFirebaseCloudMessagingService
                  .sendPushNotification(
                      notificationTitle, notificationBody, token);
            }
          },
        );
      },
    );
  }
}
