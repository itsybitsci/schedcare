import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schedcare/models/consultation_request_model.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/prompts.dart';
import 'package:schedcare/utilities/widgets.dart';

class ReceivedConsultationRequestsPage extends HookConsumerWidget {
  ReceivedConsultationRequestsPage({Key? key}) : super(key: key);
  final CollectionReference<Map<String, dynamic>>
      consultationRequestsCollectionReference = FirebaseFirestore.instance
          .collection(FirestoreConstants.consultationRequestsCollection);
  final CollectionReference<Map<String, dynamic>> usersCollectionReference =
      FirebaseFirestore.instance.collection(FirestoreConstants.usersCollection);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);
    final Query<ConsultationRequest> consultationRequestsQuery =
        consultationRequestsCollectionReference
            .where(ModelFields.doctorId,
                isEqualTo: firebaseServicesNotifier.getCurrentUser!.uid)
            .orderBy(ModelFields.consultationDateTime)
            .withConverter(
              fromFirestore: (snapshot, _) =>
                  ConsultationRequest.fromSnapshot(snapshot),
              toFirestore: (consultationRequest, _) =>
                  consultationRequest.toMap(),
            );

    return FirestoreQueryBuilder<ConsultationRequest>(
      query: consultationRequestsQuery,
      pageSize: 10,
      builder: (context, consultationRequestCollectionSnapshot, _) {
        if (consultationRequestCollectionSnapshot.hasData) {
          return consultationRequestCollectionSnapshot.docs.isEmpty
              ? const Center(
                  child: Text(Prompts.noReceivedConsultationRequests),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    consultationRequestCollectionSnapshot.fetchMore();
                  },
                  child: ListView.builder(
                    itemCount:
                        consultationRequestCollectionSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      if (consultationRequestCollectionSnapshot.hasMore &&
                          index + 1 ==
                              consultationRequestCollectionSnapshot
                                  .docs.length) {
                        consultationRequestCollectionSnapshot.fetchMore();
                      }

                      final ConsultationRequest consultationRequest =
                          consultationRequestCollectionSnapshot.docs[index]
                              .data();

                      return StreamBuilder(
                        stream: usersCollectionReference
                            .doc(consultationRequest.patientId)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<
                                    DocumentSnapshot<Map<String, dynamic>>>
                                doctorSnapshot) {
                          if (doctorSnapshot.hasData) {
                            Patient patient =
                                Patient.fromSnapshot(doctorSnapshot.data!);
                            return ListTile(
                              onTap: () {
                                context.push(
                                  RoutePaths.doctorViewConsultationRequest,
                                  extra: DoctorViewConsultationRequestObject(
                                      patient: patient,
                                      consultationRequest: consultationRequest),
                                );
                              },
                              title: Center(
                                child: Text(consultationRequest
                                    .consultationRequestDoctorTitle),
                              ),
                              trailing: Text(
                                consultationRequest.status,
                                style: TextStyle(fontSize: 10.sp),
                              ),
                              subtitle: Center(
                                child: Text(
                                    DateFormat('MMMM d, y - hh:mm a').format(
                                        consultationRequest
                                            .consultationDateTime),
                                    style: TextStyle(fontSize: 12.sp)),
                              ),
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
