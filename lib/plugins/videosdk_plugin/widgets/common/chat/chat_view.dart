import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/plugins/videosdk_plugin/utils/videosdk_colors.dart';
import 'package:schedcare/plugins/videosdk_plugin/widgets/common/chat/chat_widget.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:videosdk/videosdk.dart';

// ChatScreen
class ChatView extends ConsumerStatefulWidget {
  final Room meeting;
  final String consultationRequestId;
  final String role;
  final String displayName;

  const ChatView(
      {super.key,
      required this.meeting,
      required this.role,
      required this.displayName,
      required this.consultationRequestId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ChatViewState();
  }
}

class _ChatViewState extends ConsumerState<ChatView> {
  // MessageTextController
  final msgTextController = TextEditingController();

  // PubSubMessages
  PubSubMessages? messages;

  @override
  void initState() {
    super.initState();

    // Subscribing 'CHAT' Topic
    widget.meeting.pubSub
        .subscribe("CHAT", messageHandler)
        .then((value) => setState((() => messages = value)));
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);

    return Scaffold(
      backgroundColor: VideoSdkColorConstants.secondaryColor,
      appBar: AppBar(
        flexibleSpace: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    "Chat",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: VideoSdkColorConstants.black200),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: VideoSdkColorConstants.black200,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: VideoSdkColorConstants.secondaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: messages == null
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        reverse: true,
                        child: Column(
                          children: messages!.messages
                              .map(
                                (e) => ChatWidget(
                                  message: e,
                                  isLocalParticipant: e.senderId ==
                                      widget.meeting.localParticipant.id,
                                ),
                              )
                              .toList(),
                        ),
                      ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: VideoSdkColorConstants.black600),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: VideoSdkColorConstants.black200,
                        ),
                        controller: msgTextController,
                        onChanged: (value) => setState(() {
                          msgTextController.text;
                        }),
                        decoration: const InputDecoration(
                            hintText: "Write your message",
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: VideoSdkColorConstants.black400,
                            )),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (msgTextController.text.trim().isNotEmpty) {
                          widget.meeting.pubSub
                              .publish(
                                "CHAT",
                                msgTextController.text,
                                const PubSubPublishOptions(persist: true),
                              )
                              .then(
                                (value) => msgTextController.clear(),
                              );
                          firebaseServicesNotifier.getFirebaseFirestoreService
                              .updateDocument({
                            ModelFields.messages: FieldValue.arrayUnion([
                              {
                                ModelFields.message:
                                    msgTextController.text.trim(),
                                ModelFields.sender: widget.role,
                                ModelFields.senderName: widget.displayName,
                                ModelFields.messageTimeStamp: DateTime.now(),
                              }
                            ])
                          }, FirebaseConstants.consultationRequestsCollection,
                                  widget.consultationRequestId);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        width: 45,
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: msgTextController.text.trim().isEmpty
                                ? null
                                : Colors.blue,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(
                          Icons.send,
                          color: VideoSdkColorConstants.black200,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void messageHandler(PubSubMessage message) {
    setState(() => messages!.messages.add(message));
  }

  @override
  void dispose() {
    widget.meeting.pubSub.unsubscribe("CHAT", messageHandler);
    super.dispose();
  }
}
