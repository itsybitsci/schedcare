import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/models/user_models.dart';

class SendConsultationRequest extends HookConsumerWidget {
  final Doctor? doctor;
  const SendConsultationRequest({super.key, this.doctor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Consultation Request'),
      ),
      body: Center(
        child: Text(doctor!.firstName),
      ),
    );
  }
}
