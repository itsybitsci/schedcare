import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ReceivedConsultationRequestsPage extends HookConsumerWidget {
  const ReceivedConsultationRequestsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text('Received Consultation Requests Page');
  }
}
