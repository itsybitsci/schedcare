import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schedcare/models/consultation_request_model.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/providers/firebase_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/prompts.dart';
import 'package:schedcare/utilities/widgets.dart';

class PatientHomePage extends HookConsumerWidget {
  PatientHomePage({Key? key}) : super(key: key);
  final Stream<QuerySnapshot<Map<String, dynamic>>>
      consultationRequestsSnapshots = FirebaseFirestore.instance
          .collection(FirestoreConstants.consultationRequestsCollection)
          .snapshots();
  final patientUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseNotifier = ref.watch(firebaseProvider);

    return HookBuilder(
      builder: (BuildContext context) {
        final consultationRequests = useValueNotifier([]);
        return StreamBuilder(
            stream: consultationRequestsSnapshots,
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.hasData) {
                consultationRequests.value = snapshot.data!.docs
                    .where((snapshot) =>
                        snapshot[ModelFields.patientUid] == patientUid)
                    .map(
                  (QueryDocumentSnapshot snapshot) {
                    return ConsultationRequest.fromSnapshot(snapshot);
                  },
                ).toList();

                consultationRequests.value.sort((a, b) =>
                    a.consultationDateTime.compareTo(b.consultationDateTime));

                return consultationRequests.value.isEmpty
                    ? const Center(
                        child: Text(Prompts.noSentConsultationRequests),
                      )
                    : ListView.builder(
                        itemCount: consultationRequests.value.length,
                        itemBuilder: (BuildContext context, int index) {
                          ConsultationRequest consultationRequest =
                              consultationRequests.value[index];

                          return FutureBuilder(
                            future: firebaseNotifier.getFirestoreService
                                .getUserData(consultationRequest.doctorUid),
                            builder: (BuildContext context,
                                AsyncSnapshot<
                                        DocumentSnapshot<Map<String, dynamic>>>
                                    snapshot) {
                              if (snapshot.hasData) {
                                Doctor doctor =
                                    Doctor.fromSnapshot(snapshot.data!);
                                return ListTile(
                                  onTap: () {
                                    context.push(
                                      RoutePaths.viewSentConsultationRequest,
                                      extra: ViewConsultationRequestObject(
                                          doctor: doctor,
                                          consultationRequestId:
                                              consultationRequest.docId),
                                    );
                                  },
                                  title: Center(
                                    child: doctor.middleName.isEmpty
                                        ? Text(
                                            '${doctor.firstName} ${doctor.lastName}')
                                        : Text(
                                            '${doctor.firstName} ${doctor.middleName} ${doctor.lastName}'),
                                  ),
                                  subtitle: Center(
                                    child: Text(DateFormat('yMMMMd').format(
                                        consultationRequest
                                            .consultationDateTime)),
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
                          );
                        },
                      );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text(Prompts.errorDueToWeakInternet),
                );
              }

              return loading(color: Colors.blue);
            });
      },
    );
  }
}
