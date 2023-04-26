import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/models/consultation_request_model.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/utilities/animations.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/prompts.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class DoctorSchedulesPage extends HookConsumerWidget {
  DoctorSchedulesPage({Key? key}) : super(key: key);
  final CollectionReference<Map<String, dynamic>>
      consultationRequestsCollectionReference = FirebaseFirestore.instance
          .collection(FirebaseConstants.consultationRequestsCollection);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);
    final Stream<QuerySnapshot<Map<String, dynamic>>>
        consultationRequestsStream = consultationRequestsCollectionReference
            .where(ModelFields.doctorId,
                isEqualTo: firebaseServicesNotifier.getCurrentUser!.uid)
            .where(ModelFields.status, isEqualTo: AppConstants.approved)
            .snapshots();

    return Center(
      child: Container(
        height: 540.h,
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
                  'Schedule',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              width: 320.w,
              height: 470.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: Colors.white,
              ),
              child: StreamBuilder(
                stream: consultationRequestsStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.hasError) {
                    return lottieError();
                  }

                  if (snapshot.hasData) {
                    List<Meeting> meetings = snapshot.data!.docs
                        .map(
                          (data) => ConsultationRequest.fromSnapshot(data)
                              .toMeeting(type: AppConstants.doctor),
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
                      monthViewSettings:
                          const MonthViewSettings(showAgenda: true),
                      dataSource: MeetingDataSource(meetings),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(Prompts.errorDueToWeakInternet),
                    );
                  }

                  return lottieLoading(width: 50);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
