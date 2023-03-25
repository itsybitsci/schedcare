import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/prompts.dart';
import 'package:schedcare/utilities/widgets.dart';

class ListDoctorsPage extends HookConsumerWidget {
  ListDoctorsPage({super.key});
  final doctorsQuery = FirebaseFirestore.instance
      .collection(FirestoreConstants.usersCollection)
      .where(ModelFields.role, isEqualTo: AppConstants.doctor)
      .where(ModelFields.isApproved, isEqualTo: true)
      .withConverter(
        fromFirestore: (snapshot, _) => Doctor.fromSnapshot(snapshot),
        toFirestore: (doctor, _) => doctor.toMap(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FirestoreQueryBuilder<Doctor>(
      query: doctorsQuery,
      pageSize: 10,
      builder: (context, snapshot, _) {
        if (snapshot.hasError) {
          return const Text(Prompts.errorDueToWeakInternet);
        }

        if (snapshot.hasData) {
          return snapshot.docs.isEmpty
              ? const Center(
                  child: Text(Prompts.noAvailableDoctors),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    snapshot.fetchMore();
                  },
                  child: ListView.builder(
                    itemCount: snapshot.docs.length,
                    itemBuilder: (context, index) {
                      if (snapshot.hasMore &&
                          index + 1 == snapshot.docs.length) {
                        snapshot.fetchMore();
                      }

                      final Doctor doctor = snapshot.docs[index].data();

                      return ListTile(
                        onTap: () {
                          context.push(RoutePaths.sendConsultationRequest,
                              extra: doctor);
                        },
                        title: Center(
                          child: doctor.middleName.isEmpty
                              ? Text('${doctor.firstName} ${doctor.lastName}')
                              : Text(
                                  '${doctor.firstName} ${doctor.middleName} ${doctor.lastName}'),
                        ),
                        subtitle: Center(
                          child: Text(doctor.role),
                        ),
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
