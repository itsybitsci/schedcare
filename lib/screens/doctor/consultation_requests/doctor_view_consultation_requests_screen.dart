import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schedcare/models/consultation_request_model.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/providers/consultation_request_provider.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/screens/common/conversation_history_screen.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/helpers.dart';
import 'package:schedcare/utilities/prompts.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorViewConsultationRequestScreen extends HookConsumerWidget {
  final ConsultationRequest consultationRequest;
  final Patient patient;
  const DoctorViewConsultationRequestScreen(
      {super.key, required this.consultationRequest, required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);
    final consultationRequestNotifier = ref.watch(consultationRequestProvider);

    useEffect(() {
      consultationRequestNotifier.setConsultationRequestBody =
          consultationRequest.consultationRequestBody;
      consultationRequestNotifier.setDate =
          consultationRequest.consultationDateTime;
      consultationRequestNotifier.setTime =
          consultationRequest.consultationDateTime;
      consultationRequestNotifier.setConsultationTypeDropdownValue =
          consultationRequest.consultationType;
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation Request'),
      ),
      body: WillPopScope(
        onWillPop: () async {
          return !firebaseServicesNotifier.getLoading;
        },
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${patient.firstName} ${patient.lastName} ${patient.suffix}'
                      .trim(),
                ),
                Text('Age: ${patient.age}'),
                Text('Sex: ${patient.sex}'),
                Text('Contact Number: ${patient.phoneNumber}'),
                Text(
                    'Birthdate: ${DateFormat('yMMMMd').format(patient.birthDate)}'),
                Text('Address: ${patient.address}'),
                if (patient.uhsIdNumber.isNotEmpty)
                  Text('UHS ID Number: ${patient.uhsIdNumber}'),
                if (patient.classification.isNotEmpty)
                  Text('Classification: ${patient.classification}'),
                Text('Civil Status: ${patient.civilStatus}'),
                Text('Vaccination Status: ${patient.vaccinationStatus}'),
                SizedBox(
                  height: 10.h,
                ),
                consultationRequestNotifier.buildBody(enabled: false),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                    'Date and Time: ${DateFormat('MMMM d, y - hh:mm a').format(consultationRequest.consultationDateTime)}'),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                    'Consultation Type: ${consultationRequest.consultationType}'),
                SizedBox(
                  height: 10.h,
                ),
                if (consultationRequest.patientAttachmentUrl != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Patient Attachment: '),
                      TextButton(
                        child: Text(getFileNameFromUrl(
                            consultationRequest.patientAttachmentUrl!)),
                        onPressed: () async {
                          if (await canLaunchUrl(Uri.parse(
                              consultationRequest.patientAttachmentUrl!))) {
                            await launchUrl(
                                Uri.parse(
                                    consultationRequest.patientAttachmentUrl!),
                                mode: LaunchMode.externalApplication);
                          } else {
                            showToast(Prompts.couldNotDownloadFile);
                          }
                        },
                      ),
                    ],
                  ),
                if (consultationRequest.doctorAttachmentUrl != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Doctor Attachment: '),
                      TextButton(
                        child: Text(getFileNameFromUrl(
                            consultationRequest.doctorAttachmentUrl!)),
                        onPressed: () async {
                          if (await canLaunchUrl(Uri.parse(
                              consultationRequest.doctorAttachmentUrl!))) {
                            await launchUrl(
                                Uri.parse(
                                    consultationRequest.doctorAttachmentUrl!),
                                mode: LaunchMode.externalApplication);
                          } else {
                            showToast(Prompts.couldNotDownloadFile);
                          }
                        },
                      ),
                      IconButton(
                        onPressed: !firebaseServicesNotifier.getLoading
                            ? () async => await firebaseServicesNotifier
                                .resetAttachmentUrl(
                                    consultationRequest.id, AppConstants.doctor)
                                .then((value) => context.pop())
                            : null,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                if (consultationRequest.doctorAttachmentUrl == null &&
                    consultationRequest.status == AppConstants.approved &&
                    DateTime.now()
                        .isAfter(consultationRequest.consultationDateTime))
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      consultationRequestNotifier.buildFilePicker(
                          firebaseServicesNotifier,
                          showX: false),
                      IconButton(
                          onPressed: () async => !firebaseServicesNotifier
                                      .getLoading &&
                                  consultationRequestNotifier.pickedFile != null
                              ? await firebaseServicesNotifier
                                  .uploadFile(
                                      File(consultationRequestNotifier
                                          .pickedFile!.path!),
                                      consultationRequest.id,
                                      AppConstants.doctor,
                                      consultationRequestNotifier
                                          .pickedFile!.name)
                                  .then((success) =>
                                      success ? context.pop() : null)
                              : null,
                          icon: const Icon(Icons.upload)),
                    ],
                  ),
                if (consultationRequest.status == AppConstants.pending &&
                    DateTime.now()
                        .isBefore(consultationRequest.consultationDateTime))
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                    'Are you sure you want to reject this consultation request?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => context.pop(),
                                    child: const Text('No'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await firebaseServicesNotifier
                                          .rejectConsultationRequest(
                                              {
                                            ModelFields.status:
                                                AppConstants.rejected,
                                            ModelFields.modifiedAt:
                                                DateTime.now()
                                          },
                                              FirebaseConstants
                                                  .consultationRequestsCollection,
                                              consultationRequest.id).then(
                                        (success) {
                                          if (success) {
                                            context.go(RoutePaths.authWrapper);

                                            firebaseServicesNotifier
                                                .getFirebaseFirestoreService
                                                .getDocument(
                                                    FirebaseConstants
                                                        .usersCollection,
                                                    firebaseServicesNotifier
                                                        .getCurrentUser!.uid)
                                                .then(
                                              (userSnapshot) {
                                                DocumentReference
                                                    appNotificationRef =
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            FirebaseConstants
                                                                .notificationsCollection)
                                                        .doc();
                                                String appNotificationId =
                                                    appNotificationRef.id;
                                                String notificationTitle =
                                                    'Consultation Request Rejected';
                                                String notificationBody =
                                                    'Consultation request rejected by  ${'${userSnapshot.get(ModelFields.prefix)} ${userSnapshot.get(ModelFields.firstName)} ${userSnapshot.get(ModelFields.lastName)} ${userSnapshot.get(ModelFields.suffix)}'.trim()}';

                                                Map<String, dynamic>
                                                    appNotification = {
                                                  ModelFields.id:
                                                      appNotificationId,
                                                  ModelFields.patientId:
                                                      patient.id,
                                                  ModelFields.doctorId:
                                                      firebaseServicesNotifier
                                                          .getCurrentUser!.uid,
                                                  ModelFields.title:
                                                      notificationTitle,
                                                  ModelFields.body:
                                                      notificationBody,
                                                  ModelFields.sentAt:
                                                      DateTime.now(),
                                                  ModelFields.sender:
                                                      AppConstants.doctor,
                                                  ModelFields.isRead: false,
                                                };

                                                firebaseServicesNotifier
                                                    .getFirebaseFirestoreService
                                                    .setDocument(
                                                        appNotification,
                                                        FirebaseConstants
                                                            .notificationsCollection,
                                                        appNotificationId);

                                                firebaseServicesNotifier
                                                    .getFirebaseFirestoreService
                                                    .getDocument(
                                                        FirebaseConstants
                                                            .userTokensCollection,
                                                        patient.id)
                                                    .then(
                                                  (DocumentSnapshot<
                                                          Map<String, dynamic>>
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
                                    },
                                    child: const Text('Yes'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red),
                        ),
                        child: const Text('Reject'),
                      ),
                      SizedBox(
                        width: 15.w,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                    'Are you sure you want to approve this consultation request?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => context.pop(),
                                    child: const Text('No'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await firebaseServicesNotifier
                                          .approveConsultationRequest(
                                              {
                                            ModelFields.status:
                                                AppConstants.approved,
                                            ModelFields.modifiedAt:
                                                DateTime.now()
                                          },
                                              FirebaseConstants
                                                  .consultationRequestsCollection,
                                              consultationRequest.id).then(
                                        (success) async {
                                          if (success) {
                                            context.go(RoutePaths.authWrapper);

                                            firebaseServicesNotifier
                                                .getFirebaseFirestoreService
                                                .getDocument(
                                                    FirebaseConstants
                                                        .usersCollection,
                                                    firebaseServicesNotifier
                                                        .getCurrentUser!.uid)
                                                .then(
                                              (doctorSnapshot) {
                                                DocumentReference
                                                    appNotificationRef =
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            FirebaseConstants
                                                                .notificationsCollection)
                                                        .doc();
                                                String appNotificationId =
                                                    appNotificationRef.id;
                                                String notificationTitle =
                                                    'Consultation Request Approved';
                                                String notificationBody =
                                                    'Consultation request approved by  ${'${doctorSnapshot.get(ModelFields.prefix)} ${doctorSnapshot.get(ModelFields.firstName)} ${doctorSnapshot.get(ModelFields.lastName)} ${doctorSnapshot.get(ModelFields.suffix)}'.trim()}';

                                                Map<String, dynamic>
                                                    appNotification = {
                                                  ModelFields.id:
                                                      appNotificationId,
                                                  ModelFields.patientId:
                                                      patient.id,
                                                  ModelFields.doctorId:
                                                      firebaseServicesNotifier
                                                          .getCurrentUser!.uid,
                                                  ModelFields.title:
                                                      notificationTitle,
                                                  ModelFields.body:
                                                      notificationBody,
                                                  ModelFields.sentAt:
                                                      DateTime.now(),
                                                  ModelFields.sender:
                                                      AppConstants.doctor,
                                                  ModelFields.isRead: false,
                                                };

                                                firebaseServicesNotifier
                                                    .getFirebaseFirestoreService
                                                    .setDocument(
                                                        appNotification,
                                                        FirebaseConstants
                                                            .notificationsCollection,
                                                        appNotificationId);

                                                firebaseServicesNotifier
                                                    .getFirebaseFirestoreService
                                                    .getDocument(
                                                        FirebaseConstants
                                                            .userTokensCollection,
                                                        patient.id)
                                                    .then(
                                                  (DocumentSnapshot<
                                                          Map<String, dynamic>>
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
                                    },
                                    child: const Text('Yes'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.green)),
                        child: const Text('Approve'),
                      ),
                    ],
                  ),
                if (consultationRequest.status == AppConstants.approved &&
                    DateTime.now()
                        .isAfter(consultationRequest.consultationDateTime))
                  ElevatedButton(
                    onPressed: () => context.push(
                      RoutePaths.conversationHistory,
                      extra: ConversationHistoryPayload(
                          consultationRequestId: consultationRequest.id,
                          role: AppConstants.doctor),
                    ),
                    child: const Text('View Conversation History'),
                  ),
                if (firebaseServicesNotifier
                        .getFirebaseStorageService.uploadTask !=
                    null)
                  consultationRequestNotifier
                      .buildUploadProgressIndicator(firebaseServicesNotifier),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
