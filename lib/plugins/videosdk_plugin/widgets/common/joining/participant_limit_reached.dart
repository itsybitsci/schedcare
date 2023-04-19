import 'package:flutter/material.dart';
import 'package:schedcare/plugins/videosdk_plugin/utils/videosdk_colors.dart';
import 'package:schedcare/plugins/videosdk_plugin/utils/spacer.dart';
import 'package:videosdk/videosdk.dart';

class ParticipantLimitReached extends StatelessWidget {
  final Room meeting;
  const ParticipantLimitReached({Key? key, required this.meeting})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VideoSdkColorConstants.primaryColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "OOPS!!",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700),
            ),
            const VerticalSpacer(20),
            const Text(
              "Maximun 2 participants can join this meeting",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
            const VerticalSpacer(10),
            const Text(
              "Please try again later",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
            const VerticalSpacer(20),
            MaterialButton(
              onPressed: () {
                meeting.leave();
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: VideoSdkColorConstants.purple,
              child: const Text("Ok", style: TextStyle(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}
