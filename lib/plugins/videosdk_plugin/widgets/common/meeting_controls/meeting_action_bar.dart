import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:schedcare/plugins/videosdk_plugin/utils/colors.dart';
import 'package:schedcare/plugins/videosdk_plugin/utils/spacer.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';

// Meeting ActionBar
class MeetingActionBar extends StatelessWidget {
  // control states
  final bool isMicEnabled, isCamEnabled, isScreenShareEnabled;
  final String recordingState;

  // callback functions
  final void Function() onCallEndButtonPressed,
      onCallLeaveButtonPressed,
      onMicButtonPressed,
      onCameraButtonPressed,
      onChatButtonPressed;

  final void Function(String) onMoreOptionSelected;

  final void Function(TapDownDetails) onSwitchMicButtonPressed;
  const MeetingActionBar({
    Key? key,
    required this.isMicEnabled,
    required this.isCamEnabled,
    required this.isScreenShareEnabled,
    required this.recordingState,
    required this.onCallEndButtonPressed,
    required this.onCallLeaveButtonPressed,
    required this.onMicButtonPressed,
    required this.onSwitchMicButtonPressed,
    required this.onCameraButtonPressed,
    required this.onMoreOptionSelected,
    required this.onChatButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PopupMenuButton(
              position: PopupMenuPosition.under,
              padding: const EdgeInsets.all(0),
              color: ColorConstants.black700,
              icon: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorConstants.red),
                  color: ColorConstants.red,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.call_end,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              offset: const Offset(0, -185),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) => {
                    if (value == "leave")
                      onCallLeaveButtonPressed()
                    else if (value == "end")
                      onCallEndButtonPressed()
                  },
              itemBuilder: (context) => <PopupMenuEntry>[
                    _buildMeetingPoupItem(
                      "leave",
                      "Leave",
                      "Only you will leave the call",
                      SvgPicture.asset("assets/video_sdk/ic_leave.svg"),
                    ),
                    const PopupMenuDivider(),
                    _buildMeetingPoupItem(
                      "end",
                      "End",
                      "End call for all participants",
                      SvgPicture.asset("assets/video_sdk/ic_end.svg"),
                    ),
                  ]),

          // Mic Control
          TouchRippleEffect(
            borderRadius: BorderRadius.circular(12),
            rippleColor:
                isMicEnabled ? ColorConstants.primaryColor : Colors.white,
            onTap: onMicButtonPressed,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ColorConstants.secondaryColor),
                color:
                    isMicEnabled ? ColorConstants.primaryColor : Colors.white,
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(
                    isMicEnabled ? Icons.mic : Icons.mic_off,
                    size: 30,
                    color: isMicEnabled
                        ? Colors.white
                        : ColorConstants.primaryColor,
                  ),
                  GestureDetector(
                      onTapDown: (details) =>
                          {onSwitchMicButtonPressed(details)},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: isMicEnabled
                              ? Colors.white
                              : ColorConstants.primaryColor,
                        ),
                      )),
                ],
              ),
            ),
          ),

          // Camera Control
          TouchRippleEffect(
            borderRadius: BorderRadius.circular(12),
            rippleColor: ColorConstants.primaryColor,
            onTap: onCameraButtonPressed,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ColorConstants.secondaryColor),
                color:
                    isCamEnabled ? ColorConstants.primaryColor : Colors.white,
              ),
              padding: const EdgeInsets.all(10),
              child: SvgPicture.asset(
                isCamEnabled
                    ? "assets/video_sdk/ic_video.svg"
                    : "assets/video_sdk/ic_video_off.svg",
                width: 26,
                height: 26,
                colorFilter: ColorFilter.mode(
                    isCamEnabled ? Colors.white : ColorConstants.primaryColor,
                    BlendMode.srcIn),
              ),
            ),
          ),

          TouchRippleEffect(
            borderRadius: BorderRadius.circular(12),
            rippleColor: ColorConstants.primaryColor,
            onTap: onChatButtonPressed,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ColorConstants.secondaryColor),
                color: ColorConstants.primaryColor,
              ),
              padding: const EdgeInsets.all(10),
              child: SvgPicture.asset(
                "assets/video_sdk/ic_chat.svg",
                width: 26,
                height: 26,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),

          // More options
          PopupMenuButton(
              position: PopupMenuPosition.under,
              padding: const EdgeInsets.all(0),
              color: ColorConstants.black700,
              icon: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorConstants.secondaryColor),
                  // color: red,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.more_vert,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              offset: const Offset(0, -250),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) => {onMoreOptionSelected(value.toString())},
              itemBuilder: (context) => <PopupMenuEntry>[
                    _buildMeetingPoupItem(
                      "recording",
                      recordingState == "RECORDING_STARTED"
                          ? "Stop Recording"
                          : recordingState == "RECORDING_STARTING"
                              ? "Recording is starting"
                              : "Start Recording",
                      null,
                      SvgPicture.asset("assets/video_sdk/ic_recording.svg"),
                    ),
                    const PopupMenuDivider(),
                    _buildMeetingPoupItem(
                      "screenshare",
                      isScreenShareEnabled
                          ? "Stop Screen Share"
                          : "Start Screen Share",
                      null,
                      SvgPicture.asset("assets/video_sdk/ic_screen_share.svg"),
                    ),
                    const PopupMenuDivider(),
                    _buildMeetingPoupItem(
                      "participants",
                      "Participants",
                      null,
                      SvgPicture.asset("assets/video_sdk/ic_participants.svg"),
                    ),
                  ]),
        ],
      ),
    );
  }

  PopupMenuItem<dynamic> _buildMeetingPoupItem(
      String value, String title, String? description, Widget leadingIcon) {
    return PopupMenuItem(
      value: value,
      padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
      child: Row(children: [
        leadingIcon,
        const HorizontalSpacer(12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
            if (description != null) const VerticalSpacer(4),
            if (description != null)
              Text(
                description,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.black400),
              )
          ],
        )
      ]),
    );
  }
}
