import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:schedcare/plugins/videosdk_plugin/utils/colors.dart';
import 'package:schedcare/plugins/videosdk_plugin/utils/spacer.dart';
import 'package:schedcare/plugins/videosdk_plugin/widgets/common/stats/call_stats.dart';
import 'package:videosdk/videosdk.dart';

class ParticipantView extends StatelessWidget {
  final Stream? stream;
  final bool isMicOn;
  final Color? avatarBackground;
  final Participant participant;
  final bool isLocalScreenShare;
  final bool isScreenShare;
  final double avatarTextSize;
  final Function() onStopScreeenSharePressed;
  const ParticipantView(
      {Key? key,
      required this.stream,
      required this.isMicOn,
      required this.avatarBackground,
      required this.participant,
      this.isLocalScreenShare = false,
      this.avatarTextSize = 50,
      required this.isScreenShare,
      required this.onStopScreeenSharePressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        stream != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: RTCVideoView(
                  stream?.renderer as RTCVideoRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              )
            : Center(
                child: !isLocalScreenShare
                    ? Container(
                        padding: EdgeInsets.all(avatarTextSize / 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: avatarBackground,
                        ),
                        child: Text(
                          participant.displayName.characters.first
                              .toUpperCase(),
                          style: TextStyle(fontSize: avatarTextSize),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            SvgPicture.asset(
                              "assets/video_sdk/ic_screen_share.svg",
                              height: 40,
                            ),
                            const VerticalSpacer(20),
                            const Text(
                              "You are presenting to everyone",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            const VerticalSpacer(20),
                            MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 30),
                                color: ColorConstants.purple,
                                onPressed: onStopScreeenSharePressed,
                                child: const Text("Stop Presenting",
                                    style: TextStyle(fontSize: 16)))
                          ])),
        if (!isMicOn)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: ColorConstants.black700,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.mic_off,
                  size: avatarTextSize / 2,
                )),
          ),
        if (isScreenShare)
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: ColorConstants.black700,
              ),
              child: Text(isScreenShare
                  ? "${isLocalScreenShare ? "You" : participant.displayName} is presenting"
                  : participant.displayName),
            ),
          ),
        Positioned(top: 4, left: 4, child: CallStats(participant: participant)),
      ],
    );
  }
}
