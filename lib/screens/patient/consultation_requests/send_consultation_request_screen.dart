import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/providers/firebase_provider.dart';
import 'package:schedcare/providers/send_consultation_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/widgets.dart';

class SendConsultationRequestScreen extends HookConsumerWidget {
  final Doctor doctor;
  SendConsultationRequestScreen({super.key, required this.doctor});

  final GlobalKey<FormState> formKeySendConsultationRequest =
      GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseNotifier = ref.watch(firebaseProvider);
    final sendConsultationNotifier = ref.watch(sendConsultationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Consultation Request'),
      ),
      resizeToAvoidBottomInset: false,
      body: Form(
        key: formKeySendConsultationRequest,
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
              sendConsultationNotifier.buildBody(),
              SizedBox(
                height: 20.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  sendConsultationNotifier.buildDatePicker(context),
                  SizedBox(
                    width: 15.w,
                  ),
                  sendConsultationNotifier.buildTimePicker(context),
                ],
              ),
              SizedBox(
                height: 10.h,
              ),
              sendConsultationNotifier.buildConsultationType(),
              SizedBox(
                height: 20.h,
              ),
              firebaseNotifier.getLoading
                  ? loading(color: Colors.blue)
                  : ElevatedButton(
                      onPressed: () async {
                        if (formKeySendConsultationRequest.currentState!
                            .validate()) {
                          formKeySendConsultationRequest.currentState?.save();
                          DocumentReference docRef = FirebaseFirestore.instance
                              .collection(FirestoreConstants
                                  .consultationRequestsCollection)
                              .doc();
                          String docId = docRef.id;
                          Map<String, dynamic> data = {
                            ModelFields.docId: docId,
                            ModelFields.patientUid:
                                firebaseNotifier.getCurrentUser!.uid,
                            ModelFields.doctorUid: doctor.uid,
                            ModelFields.consultationRequestBody:
                                sendConsultationNotifier
                                    .consultationRequestBody,
                            ModelFields.consultationType:
                                sendConsultationNotifier.consultationType,
                            ModelFields.consultationDateTime:
                                sendConsultationNotifier.dateTime,
                            ModelFields.status: AppConstants.pending,
                            ModelFields.createdAt: DateTime.now()
                          };
                          await firebaseNotifier
                              .sendConsultationRequest(
                                  data,
                                  FirestoreConstants
                                      .consultationRequestsCollection,
                                  docId)
                              .then(
                            (success) {
                              if (success) {
                                context.pop();
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
  }
}
