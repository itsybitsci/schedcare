import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/providers/firebase_provider.dart';
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

  bool isOverlapping(List<DateTime> consultationRequestStartTimes,
          DateTime compareDatetime) =>
      consultationRequestStartTimes.any(
        (datetime) =>
            datetime.isBefore(
              compareDatetime.add(
                const Duration(hours: AppConstants.defaultMeetingDuration),
              ),
            ) &&
            compareDatetime.isBefore(
              datetime.add(
                const Duration(hours: AppConstants.defaultMeetingDuration),
              ),
            ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);
    final consultationRequestNotifier = ref.watch(consultationRequestProvider);
    final Stream<QuerySnapshot<Map<String, dynamic>>>
        consultationRequestsStream = consultationRequestsCollectionReference
            .where(ModelFields.patientUid,
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
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
            List<DateTime> consultationRequestStartTimes = snapshot.data!.docs
                .map((e) => e.data()[ModelFields.consultationDateTime].toDate()
                    as DateTime)
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
                          consultationRequestNotifier.buildDatePicker(context),
                          SizedBox(
                            width: 15.w,
                          ),
                          consultationRequestNotifier.buildTimePicker(context),
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
                                if (formKeySendConsultationRequest.currentState!
                                    .validate()) {
                                  formKeySendConsultationRequest.currentState
                                      ?.save();

                                  if (isOverlapping(
                                      consultationRequestStartTimes,
                                      consultationRequestNotifier.dateTime)) {
                                    showToast(
                                        'You already have a consultation request overlapping at this time.');
                                    return;
                                  }

                                  DocumentReference docRef = FirebaseFirestore
                                      .instance
                                      .collection(FirestoreConstants
                                          .consultationRequestsCollection)
                                      .doc();
                                  String docId = docRef.id;
                                  Map<String, dynamic> data = {
                                    ModelFields.docId: docId,
                                    ModelFields.patientUid:
                                        firebaseServicesNotifier
                                            .getCurrentUser!.uid,
                                    ModelFields.doctorUid: doctor.uid,
                                    ModelFields.consultationRequestTitle: doctor
                                            .middleName.isEmpty
                                        ? 'Meeting with ${doctor.prefix} ${doctor.firstName} ${doctor.lastName} ${doctor.suffix}'
                                            .trim()
                                        : 'Meeting with ${doctor.prefix} ${doctor.firstName} ${doctor.middleName} ${doctor.lastName} ${doctor.suffix}'
                                            .trim(),
                                    ModelFields.consultationRequestBody:
                                        consultationRequestNotifier
                                            .consultationRequestBody,
                                    ModelFields.status: AppConstants.pending,
                                    ModelFields.consultationType:
                                        consultationRequestNotifier
                                            .consultationType,
                                    ModelFields.consultationDateTime:
                                        consultationRequestNotifier.dateTime,
                                    ModelFields.modifiedAt: DateTime.now(),
                                    ModelFields.createdAt: DateTime.now()
                                  };
                                  await firebaseServicesNotifier
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
