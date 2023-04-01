import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/models/consultation_request_model.dart';
import 'package:schedcare/models/user_models.dart';

class DoctorViewConsultationRequestScreen extends HookConsumerWidget {
  final ConsultationRequest consultationRequest;
  final Patient patient;
  DoctorViewConsultationRequestScreen(
      {super.key, required this.consultationRequest, required this.patient});
  final GlobalKey<FormState> formKeyEditConsultationRequest =
      GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation Request'),
      ),
      body: const Center(
        child: Text('Doctor View Consultation Request Screen'),
      ),
    );
  }
}
