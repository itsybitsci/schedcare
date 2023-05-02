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
    final scrollController = useScrollController();

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
                  height: 150.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          '${patient.firstName} ${patient.lastName} ${patient.suffix}'
                              .trim(),
                          style: TextStyle(
                              fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10.h),
                      Text('Age: ${patient.age}',
                          style: TextStyle(fontSize: 12.sp)),
                      Text('Sex: ${patient.sex}',
                          style: TextStyle(fontSize: 12.sp)),
                      Text('Contact Number: ${patient.phoneNumber}',
                          style: TextStyle(fontSize: 12.sp)),
                      Text(
                          'Birthdate: ${DateFormat('yMMMMd').format(patient.birthDate)}',
                          style: TextStyle(fontSize: 12.sp)),
                      Text('Address: ${patient.address}',
                          style: TextStyle(fontSize: 12.sp)),
                      if (patient.uhsIdNumber.isNotEmpty)
                        Text('UHS ID Number: ${patient.uhsIdNumber}',
                            style: TextStyle(fontSize: 12.sp)),
                      if (patient.classification.isNotEmpty)
                        Text('Classification: ${patient.classification}',
                            style: TextStyle(fontSize: 12.sp)),
                      Text('Civil Status: ${patient.civilStatus}',
                          style: TextStyle(fontSize: 12.sp)),
                      Text('Vaccination Status: ${patient.vaccinationStatus}',
                          style: TextStyle(fontSize: 12.sp)),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Flexible(
                  child: Container(
                    width: 320.w,
                    height: 400.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: Colors.white,
                    ),
                    child: Scrollbar(
                      radius: Radius.circular(20.r),
                      controller: scrollController,
                      child: SingleChildScrollView(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                              consultationRequestNotifier.buildBody(
                                  enabled: false),
                              SizedBox(
                                height: 10.h,
                              ),
                              Text(
                                  'Date and Time: ${DateFormat('MMMM d, y - hh:mm a').format(consultationRequest.consultationDateTime)}',
                                  style: TextStyle(fontSize: 12.sp)),
                              SizedBox(
                                height: 10.h,
                              ),
                              Text(
                                  'Consultation Type: ${consultationRequest.consultationType}',
                                  style: TextStyle(fontSize: 12.sp)),
                              SizedBox(
                                height: 10.h,
                              ),
                              if (consultationRequest.patientAttachmentUrl !=
                                  null)
                                buildPatientAttachment(),
                              if (consultationRequest.doctorAttachmentUrl !=
                                  null)
                                buildDoctorAttachment(
                                    context, firebaseServicesNotifier),
                              if (consultationRequest.doctorAttachmentUrl ==
                                      null &&
                                  consultationRequest.status ==
                                      AppConstants.approved &&
                                  DateTime.now().isAfter(
                                      consultationRequest.consultationDateTime))
                                buildDoctorAttachmentUploadIcon(
                                    context,
                                    firebaseServicesNotifier,
                                    consultationRequestNotifier),
                              if (consultationRequest.status ==
                                      AppConstants.pending &&
                                  DateTime.now().isBefore(
                                      consultationRequest.consultationDateTime))
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    buildRejectButton(
                                        context, firebaseServicesNotifier),
                                    SizedBox(
                                      width: 15.w,
                                    ),
                                    buildAcceptButton(
                                        context, firebaseServicesNotifier),
                                  ],
                                ),
                              if (consultationRequest.status ==
                                      AppConstants.approved &&
                                  DateTime.now().isAfter(
                                      consultationRequest.consultationDateTime))
                                ElevatedButton(
                                  onPressed: () => context.push(
                                    RoutePaths.conversationHistory,
                                    extra: ConversationHistoryPayload(
                                        consultationRequestId:
                                            consultationRequest.id,
                                        role: AppConstants.doctor),
                                  ),
                                  child:
                                      const Text('View Conversation History'),
                                ),
                              if (firebaseServicesNotifier
                                      .getFirebaseStorageService.uploadTask !=
                                  null)
                                consultationRequestNotifier
                                    .buildUploadProgressIndicator(
                                        firebaseServicesNotifier),
                            ],
                          ),
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

  Widget buildDoctorAttachment(BuildContext context,
          FirebaseServicesProvider firebaseServicesNotifier) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Doctor Attachment: ', style: TextStyle(fontSize: 12.sp)),
          TextButton(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 100.w),
              child: Text(
                getFileNameFromUrl(consultationRequest.doctorAttachmentUrl!),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            onPressed: () async {
              if (await canLaunchUrl(
                  Uri.parse(consultationRequest.doctorAttachmentUrl!))) {
                await launchUrl(
                    Uri.parse(consultationRequest.doctorAttachmentUrl!),
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
      );

  Widget buildPatientAttachment() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Patient Attachment: ', style: TextStyle(fontSize: 12.sp)),
          TextButton(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 100.w),
              child: Text(
                getFileNameFromUrl(consultationRequest.patientAttachmentUrl!),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            onPressed: () async {
              if (await canLaunchUrl(
                  Uri.parse(consultationRequest.patientAttachmentUrl!))) {
                await launchUrl(
                    Uri.parse(consultationRequest.patientAttachmentUrl!),
                    mode: LaunchMode.externalApplication);
              } else {
                showToast(Prompts.couldNotDownloadFile);
              }
            },
          ),
        ],
      );

  Widget buildDoctorAttachmentUploadIcon(
          BuildContext context,
          FirebaseServicesProvider firebaseServicesNotifier,
          ConsultationRequestProvider consultationRequestNotifier) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          consultationRequestNotifier.buildFilePicker(firebaseServicesNotifier,
              showX: false),
          IconButton(
              onPressed: () async => !firebaseServicesNotifier.getLoading &&
                      consultationRequestNotifier.pickedFile != null
                  ? await firebaseServicesNotifier
                      .uploadFile(
                          File(consultationRequestNotifier.pickedFile!.path!),
                          consultationRequest.id,
                          AppConstants.doctor,
                          consultationRequestNotifier.pickedFile!.name)
                      .then((success) => success ? context.pop() : null)
                  : null,
              icon: const Icon(Icons.upload)),
        ],
      );

  Widget buildRejectButton(BuildContext context,
          FirebaseServicesProvider firebaseServicesNotifier) =>
      ElevatedButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                actionsAlignment: MainAxisAlignment.center,
                title: Text(
                    'Are you sure you want to reject this consultation request?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15.sp)),
                actions: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: firebaseServicesNotifier.getLoading
                        ? null
                        : () async {
                            if (!firebaseServicesNotifier.getLoading) {
                              await firebaseServicesNotifier
                                  .rejectConsultationRequest(
                                      {
                                    ModelFields.status: AppConstants.rejected,
                                    ModelFields.modifiedAt: DateTime.now()
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
                                            FirebaseConstants.usersCollection,
                                            firebaseServicesNotifier
                                                .getCurrentUser!.uid)
                                        .then(
                                      (userSnapshot) {
                                        DocumentReference appNotificationRef =
                                            FirebaseFirestore.instance
                                                .collection(FirebaseConstants
                                                    .notificationsCollection)
                                                .doc();
                                        String appNotificationId =
                                            appNotificationRef.id;
                                        String notificationTitle =
                                            'Consultation Request Rejected';
                                        String notificationBody =
                                            'Consultation request rejected by  ${'${userSnapshot.get(ModelFields.prefix)} ${userSnapshot.get(ModelFields.firstName)} ${userSnapshot.get(ModelFields.lastName)} ${userSnapshot.get(ModelFields.suffix)}'.trim()}';

                                        Map<String, dynamic> appNotification = {
                                          ModelFields.id: appNotificationId,
                                          ModelFields.patientId: patient.id,
                                          ModelFields.doctorId:
                                              firebaseServicesNotifier
                                                  .getCurrentUser!.uid,
                                          ModelFields.title: notificationTitle,
                                          ModelFields.body: notificationBody,
                                          ModelFields.sentAt: DateTime.now(),
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
                                            List tokens = userTokenSnapshot
                                                .get(ModelFields.deviceTokens);

                                            for (String token in tokens) {
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
                    child: Text('Yes', style: TextStyle(fontSize: 12.sp)),
                  ),
                ],
              );
            },
          );
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.red),
        ),
        child: Text('Reject', style: TextStyle(fontSize: 12.sp)),
      );

  Widget buildAcceptButton(BuildContext context,
          FirebaseServicesProvider firebaseServicesNotifier) =>
      ElevatedButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                actionsAlignment: MainAxisAlignment.center,
                title: Text(
                    'Are you sure you want to approve this consultation request?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15.sp)),
                actions: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text('No', style: TextStyle(fontSize: 12.sp)),
                  ),
                  TextButton(
                    onPressed: firebaseServicesNotifier.getLoading
                        ? null
                        : () async {
                            if (!firebaseServicesNotifier.getLoading) {
                              await firebaseServicesNotifier
                                  .approveConsultationRequest(
                                      {
                                    ModelFields.status: AppConstants.approved,
                                    ModelFields.modifiedAt: DateTime.now()
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
                                            FirebaseConstants.usersCollection,
                                            firebaseServicesNotifier
                                                .getCurrentUser!.uid)
                                        .then(
                                      (doctorSnapshot) {
                                        DocumentReference appNotificationRef =
                                            FirebaseFirestore.instance
                                                .collection(FirebaseConstants
                                                    .notificationsCollection)
                                                .doc();
                                        String appNotificationId =
                                            appNotificationRef.id;
                                        String notificationTitle =
                                            'Consultation Request Approved';
                                        String notificationBody =
                                            'Consultation request approved by  ${'${doctorSnapshot.get(ModelFields.prefix)} ${doctorSnapshot.get(ModelFields.firstName)} ${doctorSnapshot.get(ModelFields.lastName)} ${doctorSnapshot.get(ModelFields.suffix)}'.trim()}';

                                        Map<String, dynamic> appNotification = {
                                          ModelFields.id: appNotificationId,
                                          ModelFields.patientId: patient.id,
                                          ModelFields.doctorId:
                                              firebaseServicesNotifier
                                                  .getCurrentUser!.uid,
                                          ModelFields.title: notificationTitle,
                                          ModelFields.body: notificationBody,
                                          ModelFields.sentAt: DateTime.now(),
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
                                            List tokens = userTokenSnapshot
                                                .get(ModelFields.deviceTokens);

                                            for (String token in tokens) {
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
                    child: Text('Yes', style: TextStyle(fontSize: 12.sp)),
                  ),
                ],
              );
            },
          );
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.green)),
        child: Text('Approve', style: TextStyle(fontSize: 12.sp)),
      );
}
