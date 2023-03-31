import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/models/consultation_request_model.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/providers/firebase_provider.dart';
import 'package:schedcare/providers/consultation_request_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/widgets.dart';

class ViewConsultationRequestScreen extends HookConsumerWidget {
  final ConsultationRequest consultationRequest;
  final Doctor doctor;
  ViewConsultationRequestScreen(
      {super.key, required this.consultationRequest, required this.doctor});
  final GlobalKey<FormState> formKeyEditConsultationRequest =
      GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);
    final consultationRequestNotifier = ref.watch(consultationRequestProvider);
    ValueNotifier<bool> isEditing = useState(false);

    consultationRequestNotifier.setConsultationRequestBody =
        consultationRequest.consultationRequestBody;
    consultationRequestNotifier.setDate =
        consultationRequest.consultationDateTime;
    consultationRequestNotifier.setTime =
        consultationRequest.consultationDateTime;
    consultationRequestNotifier.setConsultationTypeDropdownValue =
        consultationRequest.consultationType;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation Request'),
        actions: [
          isEditing.value
              ? IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Stop Editing',
                  onPressed: () async {
                    showDialog(
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
      body: Form(
        key: formKeyEditConsultationRequest,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              consultationRequestNotifier.buildBody(enabled: isEditing.value),
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
              firebaseServicesNotifier.getLoading
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
                                          Map<String, dynamic> data = {
                                            ModelFields.consultationRequestBody:
                                                consultationRequestNotifier
                                                    .consultationRequestBody,
                                            ModelFields.consultationDateTime:
                                                consultationRequestNotifier
                                                    .dateTime,
                                            ModelFields.consultationType:
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
                                                consultationRequest.docId,
                                              )
                                              .then((success) => success
                                                  ? context.go(
                                                      RoutePaths.authWrapper)
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
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text(
                                      'Confirm Cancellation of Consultation Request'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => context.pop(),
                                      child: const Text('Keep Request'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        context.go(RoutePaths.authWrapper);
                                        await firebaseServicesNotifier
                                            .deleteDocument(
                                                FirestoreConstants
                                                    .consultationRequestsCollection,
                                                consultationRequest.docId);
                                      },
                                      child: const Text('Delete Request'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text('Cancel Request'),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
