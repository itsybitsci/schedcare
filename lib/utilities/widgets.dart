import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:schedcare/utilities/helpers.dart';
import 'package:shimmer/shimmer.dart';

Widget materialLoading({String toastMessage = ''}) {
  if (toastMessage.isNotEmpty) {
    showToast(toastMessage);
  }
  return const Material(
    child: Center(
      child: CircularProgressIndicator(),
    ),
  );
}

Widget loading({Color color = Colors.white}) {
  return Center(
    child: CircularProgressIndicator(color: color),
  );
}

Widget shimmerListTile() {
  return Shimmer.fromColors(
    baseColor: Colors.grey,
    highlightColor: Colors.white,
    child: ListTile(
      title: Center(
        child: Container(
            height: 20.h,
            width: 280.w,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10.r),
            )),
      ),
      subtitle: Center(
        child: Container(
            height: 10.h,
            width: 100.w,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10.r),
            )),
      ),
    ),
  );
}
