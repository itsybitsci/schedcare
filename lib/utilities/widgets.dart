import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:schedcare/plugins/videosdk_plugin/utils/videosdk_colors.dart';
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

Widget loading({Color color = Colors.white}) => Center(
      child: CircularProgressIndicator(color: color),
    );

Widget shimmerListTile() => Shimmer.fromColors(
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
            ),
          ),
        ),
      ),
    );

Widget conversationHistoryChatWidget(String currentUserRole, String senderRole,
        String senderName, String message, DateTime timestamp) =>
    Align(
      alignment: currentUserRole == senderRole
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: message));
          showToast("Message has been copied");
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.blue,
          ),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentUserRole == senderRole ? "You" : senderName,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: VideoSdkColorConstants.black200,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    DateFormat('hh:mm a').format(timestamp.toLocal()),
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
