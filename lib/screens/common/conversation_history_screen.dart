import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/models/consultation_request_model.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/widgets.dart';

class ConversationHistoryScreen extends HookConsumerWidget {
  final String consultationRequestId;
  final String role;
  ConversationHistoryScreen(
      {super.key, required this.consultationRequestId, required this.role});
  final CollectionReference<Map<String, dynamic>>
      consultationRequestsCollectionReference = FirebaseFirestore.instance
          .collection(FirebaseConstants.consultationRequestsCollection);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conversation History"),
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: consultationRequestsCollectionReference
              .doc(consultationRequestId)
              .snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasData) {
              final ConsultationRequest consultationRequest =
                  ConsultationRequest.fromSnapshot(snapshot.data!);

              if (consultationRequest.messages.isEmpty) {
                return const Center(
                  child: Text("No messages"),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: consultationRequest.messages
                              .map(
                                (message) => conversationHistoryChatWidget(
                                    role,
                                    message.senderRole,
                                    message.senderName,
                                    message.message,
                                    message.messageTimeStamp),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return loading(color: Colors.blue);
          },
        ),
      ),
    );
  }
}

class ConversationHistoryPayload {
  final String consultationRequestId;
  final String role;

  ConversationHistoryPayload(
      {required this.consultationRequestId, required this.role});
}
