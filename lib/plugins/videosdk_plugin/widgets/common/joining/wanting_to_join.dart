import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:schedcare/plugins/videosdk_plugin/utils/videosdk_colors.dart';
import 'package:schedcare/plugins/videosdk_plugin/utils/spacer.dart';
import 'package:schedcare/utilities/constants.dart';

class WaitingToJoin extends StatelessWidget {
  final String role;
  const WaitingToJoin({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: VideoSdkColorConstants.primaryColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset("assets/video_sdk/joining_lottie.json", width: 100),
              const VerticalSpacer(20),
              Text(
                  role != AppConstants.patient
                      ? "Creating a Room"
                      : 'Joining Room',
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
