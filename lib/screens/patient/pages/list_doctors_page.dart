import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/utilities/animations.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/prompts.dart';

class ListDoctorsPage extends HookConsumerWidget {
  ListDoctorsPage({super.key});
  final Query<Doctor> doctorsQuery = FirebaseFirestore.instance
      .collection(FirebaseConstants.usersCollection)
      .where(ModelFields.role, isEqualTo: AppConstants.doctor)
      .where(ModelFields.isApproved, isEqualTo: true)
      .withConverter(
        fromFirestore: (snapshot, _) => Doctor.fromSnapshot(snapshot),
        toFirestore: (doctor, _) => doctor.toMap(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();

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
                  'List of Doctors',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Flexible(
              child: Container(
                width: 320.w,
                height: 470.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: Colors.white,
                ),
                child: Scrollbar(
                  controller: scrollController,
                  child: FirestoreQueryBuilder<Doctor>(
                    query: doctorsQuery,
                    builder: (context, snapshot, _) {
                      if (snapshot.hasError) {
                        return lottieError();
                      }

                      if (snapshot.hasData) {
                        return snapshot.docs.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Lottie.asset(
                                        'assets/animations/no-data_lottie.json',
                                        width: 200.w),
                                    Text(
                                      Prompts.noAvailableDoctors,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: snapshot.docs.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == snapshot.docs.length) {
                                    return lottieDiamondLoading();
                                  }

                                  if (snapshot.hasMore &&
                                      index + 1 == snapshot.docs.length) {
                                    snapshot.fetchMore();
                                  }

                                  final Doctor doctor =
                                      snapshot.docs[index].data();

                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5.h, horizontal: 10.w),
                                    child: Material(
                                      type: MaterialType.transparency,
                                      child: ListTile(
                                        tileColor: Colors.grey[200],
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Colors.grey[300]!),
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                        ),
                                        onTap: () {
                                          context.push(
                                              RoutePaths
                                                  .sendConsultationRequest,
                                              extra: doctor);
                                        },
                                        title: Center(
                                          child: Text(
                                              '${doctor.prefix} ${doctor.firstName} ${doctor.lastName} ${doctor.suffix}'
                                                  .trim(),
                                              style:
                                                  TextStyle(fontSize: 12.sp)),
                                        ),
                                        subtitle: Center(
                                          child: Text(
                                              'Specialization: ${doctor.specialization}',
                                              style:
                                                  TextStyle(fontSize: 10.sp)),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                      }

                      return lottieLoading();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
