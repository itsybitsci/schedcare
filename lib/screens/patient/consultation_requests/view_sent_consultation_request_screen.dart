import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/providers/firebase_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/prompts.dart';
import 'package:schedcare/utilities/widgets.dart';

class ViewSentConsultationRequestScreen extends HookConsumerWidget {
  final String consultationRequestId;
  final Doctor doctor;
  final Stream<DocumentSnapshot<Map<String, dynamic>>>
      consultationRequestSnapshots;

  const ViewSentConsultationRequestScreen(
      {super.key,
      required this.consultationRequestId,
      required this.doctor,
      required this.consultationRequestSnapshots});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseNotifier = ref.watch(firebaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation Request'),
      ),
      resizeToAvoidBottomInset: false,
      body: StreamBuilder(
        stream: consultationRequestSnapshots,
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            DocumentSnapshot<Map<String, dynamic>> data = snapshot.data!;
            return Center(
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
                  Container(
                    height: 350.h,
                    width: 300.w,
                    decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5))),
                    child: SingleChildScrollView(
                      child: Text(
                          '${data.get(ModelFields.consultationRequestBody)}'),
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          'Date: ${DateFormat('yMMMMd').format(data.get(ModelFields.consultationDateTime).toDate())}'),
                      SizedBox(
                        width: 15.w,
                      ),
                      Text(
                          'Time: ${DateFormat('HH:mm a').format(data.get(ModelFields.consultationDateTime).toDate())}'),
                    ],
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Text('Type: ${data.get(ModelFields.consultationType)}'),
                  SizedBox(
                    height: 30.h,
                  ),
                  firebaseNotifier.getLoading
                      ? loading(color: Colors.blue)
                      : ElevatedButton(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text(
                                      'Confirm Cancellation of Consultation Request'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => context.pop(),
                                      child: const Text('Keep Request'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        context.go(RoutePaths.authWrapper);
                                        await firebaseNotifier.deleteDocument(
                                            FirestoreConstants
                                                .consultationRequestsCollection,
                                            consultationRequestId);
                                      },
                                      child: const Text('Cancel Request'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text('Cancel Request'),
                        ),
                ],
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
