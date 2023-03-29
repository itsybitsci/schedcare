import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/models/consultation_request_model.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/prompts.dart';
import 'package:schedcare/utilities/widgets.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class SchedulesPage extends HookConsumerWidget {
  SchedulesPage({Key? key}) : super(key: key);
  final CollectionReference<Map<String, dynamic>>
      consultationRequestsCollectionReference = FirebaseFirestore.instance
          .collection(FirestoreConstants.consultationRequestsCollection);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Stream<QuerySnapshot<Map<String, dynamic>>>
        consultationRequestsStream = consultationRequestsCollectionReference
            .where(ModelFields.patientUid,
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            // .where(ModelFields.isApproved, isEqualTo: true)
            .snapshots();

    return StreamBuilder(
      stream: consultationRequestsStream,
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasData) {
          List<Meeting> meetings = snapshot.data!.docs
              .map(
                (data) => ConsultationRequest.fromSnapshot(data).toMeeting(),
              )
              .toList();

          return SfCalendar(
            view: CalendarView.month,
            allowedViews: const [
              CalendarView.day,
              CalendarView.workWeek,
              CalendarView.month,
            ],
            initialDisplayDate: DateTime.now(),
            initialSelectedDate: DateTime.now(),
            monthViewSettings: const MonthViewSettings(showAgenda: true),
            dataSource: MeetingDataSource(meetings),
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
  }
}
