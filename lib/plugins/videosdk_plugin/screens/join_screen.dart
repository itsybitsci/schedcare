import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/plugins/videosdk_plugin/screens/one_to_one_meeting.dart';
import 'package:schedcare/plugins/videosdk_plugin/utils/api.dart';
import 'package:schedcare/plugins/videosdk_plugin/utils/colors.dart';
import 'package:schedcare/plugins/videosdk_plugin/widgets/common/joining_details/joining_details.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/helpers.dart';

class JoinScreen extends ConsumerStatefulWidget {
  final Patient patient;
  const JoinScreen({super.key, required this.patient});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _JoinScreenState();
  }
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
  String _token = "";

  // Control Status
  bool isMicOn = false;
  bool isCameraOn = false;

  bool? isJoinMeetingSelected;
  bool? isCreateMeetingSelected;

  // Camera Controller
  CameraController? cameraController;

  @override
  void initState() {
    super.initState();
    initCameraPreview();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      const token = AppConstants.videoSdkToken;
      setState(() => _token = token);
    });

    if (widget.patient.role.toLowerCase() == AppConstants.patient) {
      isJoinMeetingSelected = true;
      isCreateMeetingSelected = false;
    } else {
      isJoinMeetingSelected = true;
      isCreateMeetingSelected = true;
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void initCameraPreview() {
    // Get available cameras
    availableCameras().then((availableCameras) {
      // stores selected camera id
      int selectedCameraId = availableCameras.length > 1 ? 1 : 0;

      cameraController = CameraController(
        availableCameras[selectedCameraId],
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      log("Starting Camera");
      cameraController!.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    }).catchError((err) {
      log("Error: $err");
    });
  }

  void _onClickMeetingJoin(meetingId, callType, displayName) async {
    cameraController?.dispose();
    cameraController = null;
    if (displayName.toString().isEmpty) {
      displayName = "Guest";
    }
    if (isCreateMeetingSelected!) {
      createAndJoinMeeting(callType, displayName);
    } else {
      joinMeeting(callType, displayName, meetingId);
    }
  }

  Future<void> createAndJoinMeeting(callType, displayName) async {
    try {
      var meetingID = await createMeeting(_token);
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OneToOneMeetingScreen(
              token: _token,
              meetingId: meetingID,
              displayName: displayName,
              micEnabled: isMicOn,
              camEnabled: isCameraOn,
            ),
          ),
        );
      }
    } catch (error) {
      showToast(error.toString());
    }
  }

  Future<void> joinMeeting(callType, displayName, meetingId) async {
    if (meetingId.isEmpty) {
      showToast('Please enter Valid Meeting ID');
      return;
    }
    var validMeeting = await validateMeeting(_token, meetingId);
    if (validMeeting && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OneToOneMeetingScreen(
            token: _token,
            meetingId: meetingId,
            displayName: displayName,
            micEnabled: isMicOn,
            camEnabled: isCameraOn,
          ),
        ),
      );
    } else {
      showToast('Invalid Meeting ID');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme().copyWith(
          color: ColorConstants.secondaryColor,
        ),
        primaryColor: ColorConstants.primaryColor,
        colorScheme: ColorScheme.fromSwatch(
            backgroundColor: ColorConstants.secondaryColor),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Teleconsultation'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.pop();
            },
          ),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder:
                (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: viewportConstraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Camera Preview
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 100, horizontal: 36),
                          child: SizedBox(
                            height: 300,
                            width: 200,
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                (cameraController == null) && isCameraOn
                                    ? !(cameraController?.value.isInitialized ??
                                            false)
                                        ? Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          )
                                    : AspectRatio(
                                        aspectRatio: 1 / 1.55,
                                        child: isCameraOn
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: CameraPreview(
                                                  cameraController!,
                                                ))
                                            : Container(
                                                decoration: BoxDecoration(
                                                    color:
                                                        ColorConstants.black800,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                                child: const Center(
                                                  child: Text(
                                                    "Camera is turned off",
                                                  ),
                                                ),
                                              ),
                                      ),
                                Positioned(
                                  bottom: 16,

                                  // Meeting ActionBar
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Mic Action Button
                                        ElevatedButton(
                                          onPressed: () => setState(
                                            () => isMicOn = !isMicOn,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.black,
                                            backgroundColor: isMicOn
                                                ? Colors.white
                                                : ColorConstants.red,
                                            shape: const CircleBorder(),
                                            padding: const EdgeInsets.all(12),
                                          ),
                                          child: Icon(
                                              isMicOn
                                                  ? Icons.mic
                                                  : Icons.mic_off,
                                              color: isMicOn
                                                  ? ColorConstants.grey
                                                  : Colors.white),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            if (isCameraOn) {
                                              cameraController?.dispose();
                                              cameraController = null;
                                            } else {
                                              initCameraPreview();
                                              // cameraController?.resumePreview();
                                            }
                                            setState(
                                                () => isCameraOn = !isCameraOn);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: const CircleBorder(),
                                            backgroundColor: isCameraOn
                                                ? Colors.white
                                                : ColorConstants.red,
                                            padding: const EdgeInsets.all(12),
                                          ),
                                          child: Icon(
                                            isCameraOn
                                                ? Icons.videocam
                                                : Icons.videocam_off,
                                            color: isCameraOn
                                                ? ColorConstants.grey
                                                : Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(36.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (isJoinMeetingSelected != null &&
                                  isCreateMeetingSelected != null)
                                JoiningDetails(
                                  isCreateMeeting: isCreateMeetingSelected!,
                                  onClickMeetingJoin:
                                      (meetingId, callType, displayName) =>
                                          _onClickMeetingJoin(
                                              meetingId, callType, displayName),
                                ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class MeetingPayload {
  final String token;
  final String meetingId;
  final String displayName;
  final String micEnabled;
  final String camEnabled;

  MeetingPayload({
    required this.token,
    required this.meetingId,
    required this.displayName,
    required this.micEnabled,
    required this.camEnabled,
  });
}
