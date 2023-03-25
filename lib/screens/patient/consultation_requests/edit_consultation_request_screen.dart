import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EditConsultationRequestScreen extends HookConsumerWidget {
  final String consultationRequestId;
  EditConsultationRequestScreen(
      {super.key, required this.consultationRequestId});
  final GlobalKey<FormState> formKeyEditConsultationRequest =
      GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Consultation Request'),
      ),
    );
  }
}
