import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/models/consultation_request_model.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/providers/firebase_provider.dart';
import 'package:schedcare/providers/send_consultation_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/widgets.dart';

class SendConsultationRequest extends HookConsumerWidget {
  final Doctor doctor;
  SendConsultationRequest({super.key, required this.doctor});

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
                          ConsultationRequest consultationRequest =
                              ConsultationRequest(
                                  patientUid:
                                      firebaseNotifier.getCurrentUser!.uid,
                                  doctorUid: doctor.uid,
                                  body: sendConsultationNotifier.body,
                                  consultationType:
                                      sendConsultationNotifier.consultationType,
                                  consultationDate:
                                      sendConsultationNotifier.dateTime,
                                  status: RegistrationConstants.pending,
                                  createdAt: DateTime.now());
                          await firebaseNotifier
                              .sendConsultationRequest(consultationRequest)
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
