import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/prompts.dart';
import 'package:schedcare/utilities/widgets.dart';

class ListDoctorsPage extends HookConsumerWidget {
  ListDoctorsPage({super.key});
  final Stream<QuerySnapshot<Map<String, dynamic>>> userSnapshots =
      FirebaseFirestore.instance
          .collection(FirestoreConstants.usersCollection)
          .snapshots();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HookBuilder(
      builder: (BuildContext context) {
        final doctors = useValueNotifier([]);
        return StreamBuilder(
          stream: userSnapshots,
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasData) {
              doctors.value = snapshot.data!.docs
                  .where((snapshot) =>
                      snapshot[ModelFields.role].toLowerCase() ==
                          AppConstants.doctor.toLowerCase() &&
                      snapshot[ModelFields.isApproved])
                  .map(
                (QueryDocumentSnapshot snapshot) {
                  return Doctor.fromSnapshot(snapshot);
                },
              ).toList();
              return doctors.value.isEmpty
                  ? const Center(
                      child: Text(Prompts.noAvailableDoctors),
                    )
                  : ListView.builder(
                      itemCount: doctors.value.length,
                      itemBuilder: (BuildContext context, int index) {
                        Doctor doctor = doctors.value[index];
                        return ListTile(
                          onTap: () {
                            context.push(RoutePaths.sendConsultationRequest,
                                extra: doctor);
                          },
                          title: Center(
                            child:
                                Text('${doctor.firstName} ${doctor.lastName}'),
                          ),
                          subtitle: Center(
                            child: Text(doctor.role),
                          ),
                        );
                      },
                    );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(Prompts.errorDueToWeakInternet),
              );
            }

            return loading();
          },
        );
      },
    );
  }
}
