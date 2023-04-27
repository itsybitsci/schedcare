import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/models/consultation_request_model.dart';
import 'package:schedcare/utilities/animations.dart';
import 'package:schedcare/utilities/components.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/prompts.dart';
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
    final scrollController = useScrollController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appTitle),
      ),
      body: Background(
        child: Center(
          child: Container(
            height: 580.h,
            width: 340.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: ColorConstants.primaryLight,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 320.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      'Conversation History',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.sp),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Flexible(
                  child: Container(
                    width: 320.w,
                    height: 510.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: Colors.white,
                    ),
                    child: Scrollbar(
                      radius: Radius.circular(20.r),
                      controller: scrollController,
                      child: StreamBuilder(
                        stream: consultationRequestsCollectionReference
                            .doc(consultationRequestId)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<
                                    DocumentSnapshot<Map<String, dynamic>>>
                                snapshot) {
                          if (snapshot.hasError) {
                            return lottieError();
                          }

                          if (snapshot.hasData) {
                            final ConsultationRequest consultationRequest =
                                ConsultationRequest.fromSnapshot(
                                    snapshot.data!);

                            if (consultationRequest.messages.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    lottieNoData(),
                                    Text(
                                      Prompts.noMessages,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp),
                                    ),
                                  ],
                                ),
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
                                              (message) =>
                                                  conversationHistoryChatWidget(
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
                          return lottieLoading(width: 50);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
