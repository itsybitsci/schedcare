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
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/helpers.dart';
import 'package:schedcare/utilities/prompts.dart';
import 'package:schedcare/utilities/widgets.dart';

class PatientViewConsultationRequestScreen extends HookConsumerWidget {
  final ConsultationRequest consultationRequest;
  final Doctor doctor;
  PatientViewConsultationRequestScreen(
      {super.key, required this.consultationRequest, required this.doctor});
  final GlobalKey<FormState> formKeyEditConsultationRequest =
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
          if (consultationRequest.status == AppConstants.pending)
            isEditing.value
                ? IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Stop Editing',
                    onPressed: () async {
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
                                  context.go(RoutePaths.authWrapper);
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
      body: StreamBuilder(
        stream: consultationRequestsStream,
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            return Form(
              key: formKeyEditConsultationRequest,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 30.h,
                    ),
                    Text(
                        '${doctor.prefix} ${doctor.firstName} ${doctor.lastName} ${doctor.suffix}'
                            .trim()),
                    Text('Sex: ${doctor.sex}'),
                    Text('Specialization: ${doctor.specialization}'),
                    SizedBox(
                      height: 30.h,
                    ),
                    consultationRequestNotifier.buildBody(
                        enabled: isEditing.value),
                    SizedBox(
                      height: 20.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        consultationRequestNotifier.buildDatePicker(context,
                            enabled: isEditing.value),
                        SizedBox(
                          width: 15.w,
                        ),
                        consultationRequestNotifier.buildTimePicker(context,
                            enabled: isEditing.value),
                      ],
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    consultationRequestNotifier.buildConsultationType(
                        enabled: isEditing.value),
                    SizedBox(
                      height: 20.h,
                    ),
                    consultationRequest.status != AppConstants.pending
                        ? ElevatedButton(
                            onPressed: () => context.push(
                              RoutePaths.conversationHistory,
                              extra: ConversationHistoryPayload(
                                  consultationRequestId: consultationRequest.id,
                                  role: AppConstants.patient),
                            ),
                            child: const Text('View Conversation History'),
                          )
                        : firebaseServicesNotifier.getLoading
                            ? loading(color: Colors.blue)
                            : isEditing.value
                                ? ElevatedButton(
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Confirm Submission of Edited Request'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => context.pop(),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  if (formKeyEditConsultationRequest
                                                      .currentState!
                                                      .validate()) {
                                                    formKeyEditConsultationRequest
                                                        .currentState
                                                        ?.save();

                                                    List<DateTime>
                                                        consultationRequestStartTimes =
                                                        snapshot.data!.docs
                                                            .where((snapshot) =>
                                                                snapshot.get(
                                                                    ModelFields
                                                                        .status) !=
                                                                AppConstants
                                                                    .rejected)
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

                                                    Map<String, dynamic> data =
                                                        {
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
                                                      ModelFields.modifiedAt:
                                                          DateTime.now(),
                                                    };
                                                    await firebaseServicesNotifier
                                                        .updateConsultationRequest(
                                                          data,
                                                          FirestoreConstants
                                                              .consultationRequestsCollection,
                                                          consultationRequest
                                                              .id,
                                                        )
                                                        .then((success) => success
                                                            ? context.go(
                                                                RoutePaths
                                                                    .authWrapper)
                                                            : null);
                                                  } else {
                                                    context.pop();
                                                  }
                                                },
                                                child: const Text('Proceed'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: const Text('Edit Request'),
                                  )
                                : ElevatedButton(
                                    onPressed: () async {
                                      return showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Confirm Cancellation of Consultation Request'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => context.pop(),
                                                child:
                                                    const Text('Keep Request'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  context.go(
                                                      RoutePaths.authWrapper);
                                                  await firebaseServicesNotifier
                                                      .deleteDocument(
                                                          FirestoreConstants
                                                              .consultationRequestsCollection,
                                                          consultationRequest
                                                              .id);
                                                },
                                                child: const Text(
                                                    'Delete Request'),
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
                                    child: const Text('Cancel Request'),
                                  ),
                  ],
                ),
              ),
            );
          }
          return loading(color: Colors.blue);
        },
      ),
    );
  }
}
