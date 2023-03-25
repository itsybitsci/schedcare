import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  final CollectionReference<Map<String, dynamic>>
      consultationRequestsCollectionReference = FirebaseFirestore.instance
          .collection(FirestoreConstants.consultationRequestsCollection);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseNotifier = ref.watch(firebaseProvider);
    final consultationRequestsQuery = consultationRequestsCollectionReference
        .where(ModelFields.patientUid,
            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .withConverter(
          fromFirestore: (snapshot, _) =>
              ConsultationRequest.fromSnapshot(snapshot),
          toFirestore: (consultationRequest, _) => consultationRequest.toMap(),
        );

    return FirestoreQueryBuilder<ConsultationRequest>(
      query: consultationRequestsQuery,
      pageSize: 10,
      builder: (context, consultationRequestSnapshot, _) {
        if (consultationRequestSnapshot.hasError) {
          return const Text(Prompts.errorDueToWeakInternet);
        }

        if (consultationRequestSnapshot.hasData) {
          return consultationRequestSnapshot.docs.isEmpty
              ? const Center(
                  child: Text(Prompts.noSentConsultationRequests),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    consultationRequestSnapshot.fetchMore();
                  },
                  child: ListView.builder(
                    itemCount: consultationRequestSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      if (consultationRequestSnapshot.hasMore &&
                          index + 1 ==
                              consultationRequestSnapshot.docs.length) {
                        consultationRequestSnapshot.fetchMore();
                      }

                      final ConsultationRequest consultationRequest =
                          consultationRequestSnapshot.docs[index].data();

                      return FutureBuilder(
                        future: firebaseNotifier.getFirestoreService
                            .getUserData(consultationRequest.doctorUid),
                        builder: (BuildContext context,
                            AsyncSnapshot<
                                    DocumentSnapshot<Map<String, dynamic>>>
                                doctorSnapshot) {
                          if (doctorSnapshot.hasData) {
                            Doctor doctor =
                                Doctor.fromSnapshot(doctorSnapshot.data!);
                            return ListTile(
                              onTap: () {
                                context.push(
                                  RoutePaths.viewConsultationRequest,
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
                              trailing: Text(
                                consultationRequest.status,
                                style: TextStyle(fontSize: 10.sp),
                              ),
                              subtitle: Center(
                                child: Text(
                                    DateFormat('MMMM d, y').format(
                                        consultationRequest
                                            .consultationDateTime),
                                    style: TextStyle(fontSize: 12.sp)),
                              ),
                            );
                          }

                          if (doctorSnapshot.hasError) {
                            return const Center(
                              child: Text(Prompts.errorDueToWeakInternet),
                            );
                          }

                          return shimmerListTile();
                        },
                      );
                    },
                  ),
                );
        }

        return loading(color: Colors.blue);
      },
    );
  }
}
