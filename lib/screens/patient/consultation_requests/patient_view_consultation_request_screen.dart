import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/models/consultation_request_model.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/providers/consultation_request_provider.dart';
import 'package:schedcare/screens/common/conversation_history_screen.dart';
import 'package:schedcare/utilities/animations.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/helpers.dart';
import 'package:schedcare/utilities/prompts.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientViewConsultationRequestScreen extends HookConsumerWidget {
  final ConsultationRequest consultationRequest;
  final Doctor doctor;
  PatientViewConsultationRequestScreen(
      {super.key, required this.consultationRequest, required this.doctor});
  final GlobalKey<FormState> formKeyEditConsultationRequest =
      GlobalKey<FormState>();
  final CollectionReference<Map<String, dynamic>>
      consultationRequestsCollectionReference = FirebaseFirestore.instance
          .collection(FirebaseConstants.consultationRequestsCollection);

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
    ValueNotifier<bool> isEditing = useState(false);

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
        actions: [
          if (consultationRequest.status == AppConstants.pending &&
              DateTime.now().isBefore(consultationRequest.consultationDateTime))
            isEditing.value
                ? IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Stop Editing',
                    onPressed: () async {
                      if (firebaseServicesNotifier.getLoading) return;
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title:
                                const Text('Discard changes and stop editing?'),
                            actions: [
                              TextButton(
                                onPressed: () => context.pop(),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.popUntil(
                                      context,
                                      ModalRoute.withName(
                                          RouteNames.authWrapper));
                                },
                                child: const Text('Yes'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit Request',
                    onPressed: () {
                      isEditing.value = !isEditing.value;
                    },
                  ),
        ],
      ),
      resizeToAvoidBottomInset: false,
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
                              return Form(
                                key: formKeyEditConsultationRequest,
                                child: SingleChildScrollView(
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
                                          enabled: isEditing.value),
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
                                                enabled: isEditing.value),
                                      ),
                                      SizedBox(
                                        width: 10.w,
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
                                                enabled: isEditing.value),
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
                                      consultationRequestNotifier
                                          .buildConsultationType(
                                              enabled: isEditing.value),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      if (consultationRequest
                                              .patientAttachmentUrl !=
                                          null)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text('Patient Attachment: '),
                                            TextButton(
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    maxWidth: 100.w),
                                                child: Text(
                                                  getFileNameFromUrl(
                                                      consultationRequest
                                                          .patientAttachmentUrl!),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              onPressed: () async {
                                                if (await canLaunchUrl(Uri
                                                    .parse(consultationRequest
                                                        .patientAttachmentUrl!))) {
                                                  await launchUrl(
                                                      Uri.parse(consultationRequest
                                                          .patientAttachmentUrl!),
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                } else {
                                                  showToast(Prompts
                                                      .couldNotDownloadFile);
                                                }
                                              },
                                            ),
                                            if (isEditing.value)
                                              IconButton(
                                                onPressed: !firebaseServicesNotifier
                                                        .getLoading
                                                    ? () async =>
                                                        await firebaseServicesNotifier
                                                            .resetAttachmentUrl(
                                                                consultationRequest
                                                                    .id,
                                                                AppConstants
                                                                    .patient)
                                                            .then((value) =>
                                                                context.pop())
                                                    : null,
                                                icon: const Icon(Icons.close),
                                              ),
                                          ],
                                        ),
                                      if (isEditing.value &&
                                          consultationRequest
                                                  .patientAttachmentUrl ==
                                              null)
                                        consultationRequestNotifier
                                            .buildFilePicker(
                                                firebaseServicesNotifier),
                                      if (consultationRequest
                                                  .doctorAttachmentUrl !=
                                              null &&
                                          !isEditing.value)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text('Doctor Attachment: '),
                                            TextButton(
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    maxWidth: 100.w),
                                                child: Text(
                                                  getFileNameFromUrl(
                                                      consultationRequest
                                                          .doctorAttachmentUrl!),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              onPressed: () async {
                                                if (await canLaunchUrl(Uri
                                                    .parse(consultationRequest
                                                        .doctorAttachmentUrl!))) {
                                                  await launchUrl(
                                                      Uri.parse(consultationRequest
                                                          .doctorAttachmentUrl!),
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                } else {
                                                  showToast(Prompts
                                                      .couldNotDownloadFile);
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      if (consultationRequest.status ==
                                              AppConstants.approved &&
                                          DateTime.now().isAfter(
                                              consultationRequest
                                                  .consultationDateTime))
                                        ElevatedButton(
                                          onPressed: () => context.push(
                                            RoutePaths.conversationHistory,
                                            extra: ConversationHistoryPayload(
                                                consultationRequestId:
                                                    consultationRequest.id,
                                                role: AppConstants.patient),
                                          ),
                                          child: const Text(
                                              'View Conversation History'),
                                        ),
                                      if (consultationRequest.status ==
                                              AppConstants.pending &&
                                          DateTime.now().isBefore(
                                              consultationRequest
                                                  .consultationDateTime))
                                        if (isEditing.value)
                                          ElevatedButton(
                                            onPressed: () async {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Confirm Submission of Edited Request'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            context.pop(),
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          if (formKeyEditConsultationRequest
                                                              .currentState!
                                                              .validate()) {
                                                            formKeyEditConsultationRequest
                                                                .currentState
                                                                ?.save();

                                                            List<DateTime> consultationRequestStartTimes = snapshot
                                                                .data!.docs
                                                                .where((snapshot) =>
                                                                    snapshot.get(ModelFields.status) !=
                                                                    AppConstants
                                                                        .rejected)
                                                                .where((snapshot) =>
                                                                    snapshot.get(ModelFields
                                                                        .id) !=
                                                                    consultationRequest
                                                                        .id)
                                                                .map((snapshot) => snapshot
                                                                    .get(ModelFields
                                                                        .consultationDateTime)
                                                                    .toDate() as DateTime)
                                                                .toList();

                                                            if (isOverlapping(
                                                                consultationRequestStartTimes,
                                                                consultationRequestNotifier
                                                                    .dateTime)) {
                                                              showToast(Prompts
                                                                  .overlappingSchedule);
                                                              context.pop();
                                                              return;
                                                            }

                                                            Map<String, dynamic>
                                                                data = {
                                                              ModelFields
                                                                      .consultationRequestBody:
                                                                  consultationRequestNotifier
                                                                      .consultationRequestBody,
                                                              ModelFields
                                                                      .consultationDateTime:
                                                                  consultationRequestNotifier
                                                                      .dateTime,
                                                              ModelFields
                                                                      .consultationType:
                                                                  consultationRequestNotifier
                                                                      .consultationType,
                                                              ModelFields
                                                                      .modifiedAt:
                                                                  DateTime
                                                                      .now(),
                                                            };
                                                            await firebaseServicesNotifier
                                                                .updateConsultationRequest(
                                                              data,
                                                              FirebaseConstants
                                                                  .consultationRequestsCollection,
                                                              consultationRequest
                                                                  .id,
                                                            )
                                                                .then(
                                                              (success) async {
                                                                if (success) {
                                                                  if (consultationRequestNotifier
                                                                          .pickedFile !=
                                                                      null) {
                                                                    await uploadAttachment(
                                                                        firebaseServicesNotifier,
                                                                        consultationRequestNotifier,
                                                                        consultationRequest
                                                                            .id);
                                                                  }
                                                                  if (context
                                                                      .mounted) {
                                                                    context.go(
                                                                        RoutePaths
                                                                            .authWrapper);
                                                                  }
                                                                }
                                                              },
                                                            );
                                                          } else {
                                                            context.pop();
                                                          }
                                                        },
                                                        child: const Text(
                                                            'Proceed'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: const Text('Edit Request'),
                                          ),
                                      if (firebaseServicesNotifier
                                              .getFirebaseStorageService
                                              .uploadTask !=
                                          null)
                                        consultationRequestNotifier
                                            .buildUploadProgressIndicator(
                                                firebaseServicesNotifier),
                                    ],
                                  ),
                                ),
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
}
