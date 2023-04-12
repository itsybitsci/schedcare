import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/providers/consultation_request_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/helpers.dart';
import 'package:schedcare/utilities/prompts.dart';
import 'package:schedcare/utilities/widgets.dart';

class SendConsultationRequestScreen extends HookConsumerWidget {
  final Doctor doctor;
  SendConsultationRequestScreen({super.key, required this.doctor});
  final GlobalKey<FormState> formKeySendConsultationRequest =
      GlobalKey<FormState>();
  final CollectionReference<Map<String, dynamic>>
      consultationRequestsCollectionReference = FirebaseFirestore.instance
          .collection(FirestoreConstants.consultationRequestsCollection);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);
    final consultationRequestNotifier = ref.watch(consultationRequestProvider);
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
      body: StreamBuilder(
        stream: consultationRequestsStream,
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            final userSnapshotNotifier = ref.watch(userSnapshotProvider(
                firebaseServicesNotifier.getCurrentUser!.uid));

            return userSnapshotNotifier.when(
                data: (DocumentSnapshot<Map<String, dynamic>> data) {
                  List<DateTime> consultationRequestStartTimes = snapshot
                      .data!.docs
                      .where((snapshot) =>
                          snapshot.get(ModelFields.status) !=
                          AppConstants.rejected)
                      .map((snapshot) => snapshot
                          .get(ModelFields.consultationDateTime)
                          .toDate() as DateTime)
                      .toList();

                  return Form(
                    key: formKeySendConsultationRequest,
                    child: SingleChildScrollView(
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 30.h,
                            ),
                            doctor.middleName.isEmpty
                                ? Text('${doctor.firstName} ${doctor.lastName}')
                                : Text(
                                    '${doctor.firstName} ${doctor.middleName} ${doctor.lastName}'),
                            Text('Sex: ${doctor.sex}'),
                            Text('Specialization: ${doctor.specialization}'),
                            SizedBox(
                              height: 30.h,
                            ),
                            consultationRequestNotifier.buildBody(),
                            SizedBox(
                              height: 20.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                consultationRequestNotifier
                                    .buildDatePicker(context),
                                SizedBox(
                                  width: 15.w,
                                ),
                                consultationRequestNotifier
                                    .buildTimePicker(context),
                              ],
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            consultationRequestNotifier.buildConsultationType(),
                            SizedBox(
                              height: 20.h,
                            ),
                            firebaseServicesNotifier.getLoading
                                ? loading(color: Colors.blue)
                                : ElevatedButton(
                                    onPressed: () async {
                                      if (formKeySendConsultationRequest
                                          .currentState!
                                          .validate()) {
                                        formKeySendConsultationRequest
                                            .currentState
                                            ?.save();

                                        if (isOverlapping(
                                            consultationRequestStartTimes,
                                            consultationRequestNotifier
                                                .dateTime)) {
                                          showToast(
                                              Prompts.overlappingSchedule);
                                          return;
                                        }

                                        DocumentReference
                                            consultationRequestRef =
                                            FirebaseFirestore.instance
                                                .collection(FirestoreConstants
                                                    .consultationRequestsCollection)
                                                .doc();
                                        String consultationRequestId =
                                            consultationRequestRef.id;
                                        Map<String, dynamic>
                                            consultationRequest = {
                                          ModelFields.id: consultationRequestId,
                                          ModelFields.patientId:
                                              firebaseServicesNotifier
                                                  .getCurrentUser!.uid,
                                          ModelFields.doctorId: doctor.id,
                                          ModelFields
                                                  .consultationRequestPatientTitle:
                                              'Consultation with ${'${doctor.prefix} ${doctor.firstName} ${doctor.lastName} ${doctor.suffix}'.trim()}',
                                          ModelFields
                                                  .consultationRequestDoctorTitle:
                                              'Consultation with ${data.get(ModelFields.firstName)} ${data.get(ModelFields.lastName)} ${data.get(ModelFields.suffix)}'
                                                  .trim(),
                                          ModelFields.consultationRequestBody:
                                              consultationRequestNotifier
                                                  .consultationRequestBody,
                                          ModelFields.status:
                                              AppConstants.pending,
                                          ModelFields.consultationType:
                                              consultationRequestNotifier
                                                  .consultationType,
                                          ModelFields.consultationDateTime:
                                              consultationRequestNotifier
                                                  .dateTime,
                                          ModelFields.modifiedAt:
                                              DateTime.now(),
                                          ModelFields.createdAt: DateTime.now(),
                                          ModelFields.meetingId: null,
                                          ModelFields.messages: [],
                                        };
                                        await firebaseServicesNotifier
                                            .sendConsultationRequest(
                                                consultationRequest,
                                                FirestoreConstants
                                                    .consultationRequestsCollection,
                                                consultationRequestId)
                                            .then(
                                          (success) {
                                            if (success) {
                                              context.pop();

                                              firebaseServicesNotifier
                                                  .getFirebaseFirestoreService
                                                  .getDocument(
                                                      FirestoreConstants
                                                          .usersCollection,
                                                      firebaseServicesNotifier
                                                          .getCurrentUser!.uid)
                                                  .then(
                                                (userSnapshot) {
                                                  DocumentReference
                                                      appNotificationRef =
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              FirestoreConstants
                                                                  .notificationsCollection)
                                                          .doc();
                                                  String appNotificationId =
                                                      appNotificationRef.id;
                                                  String notificationTitle =
                                                      'New Consultation Request';
                                                  String notificationBody =
                                                      'New consultation request received from ${userSnapshot.get(ModelFields.firstName)} ${userSnapshot.get(ModelFields.lastName)}';

                                                  Map<String, dynamic>
                                                      appNotification = {
                                                    ModelFields.id:
                                                        appNotificationId,
                                                    ModelFields.patientId:
                                                        firebaseServicesNotifier
                                                            .getCurrentUser!
                                                            .uid,
                                                    ModelFields.doctorId:
                                                        doctor.id,
                                                    ModelFields.title:
                                                        notificationTitle,
                                                    ModelFields.body:
                                                        notificationBody,
                                                    ModelFields.sentAt:
                                                        DateTime.now(),
                                                    ModelFields.sender:
                                                        AppConstants.patient,
                                                    ModelFields.isRead: false,
                                                  };

                                                  firebaseServicesNotifier
                                                      .getFirebaseFirestoreService
                                                      .setDocument(
                                                          appNotification,
                                                          FirestoreConstants
                                                              .notificationsCollection,
                                                          appNotificationId);

                                                  firebaseServicesNotifier
                                                      .getFirebaseFirestoreService
                                                      .getDocument(
                                                          FirestoreConstants
                                                              .userTokensCollection,
                                                          doctor.id)
                                                      .then(
                                                    (DocumentSnapshot<
                                                            Map<String,
                                                                dynamic>>
                                                        userTokenSnapshot) {
                                                      List tokens =
                                                          userTokenSnapshot.get(
                                                              ModelFields
                                                                  .deviceTokens);

                                                      for (String token
                                                          in tokens) {
                                                        firebaseServicesNotifier
                                                            .getFirebaseCloudMessagingService
                                                            .sendPushNotification(
                                                                notificationTitle,
                                                                notificationBody,
                                                                token);
                                                      }
                                                    },
                                                  );
                                                },
                                              );
                                            }
                                          },
                                        );
                                      }
                                    },
                                    child: const Text('Send Request'),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                error: (Object error, StackTrace stackTrace) =>
                    loading(color: Colors.blue),
                loading: () => loading(color: Colors.blue));
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(Prompts.errorDueToWeakInternet),
            );
          }

          return loading(color: Colors.blue);
        },
      ),
    );
  }
}
