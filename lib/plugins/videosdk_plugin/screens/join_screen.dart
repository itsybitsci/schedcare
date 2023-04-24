import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/models/consultation_request_model.dart';
import 'package:schedcare/plugins/videosdk_plugin/screens/one_to_one_meeting.dart';
import 'package:schedcare/plugins/videosdk_plugin/utils/api.dart';
import 'package:schedcare/plugins/videosdk_plugin/utils/videosdk_colors.dart';
import 'package:schedcare/plugins/videosdk_plugin/utils/spacer.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/helpers.dart';
import 'package:schedcare/utilities/widgets.dart';

class JoinScreen extends ConsumerStatefulWidget {
  final ConsultationRequest consultationRequest;
  final String role;
  final String? meetingId;
  const JoinScreen(
      {super.key,
      required this.consultationRequest,
      required this.role,
      this.meetingId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _JoinScreenState();
  }
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
  final CollectionReference<Map<String, dynamic>> usersCollectionReference =
      FirebaseFirestore.instance.collection(FirebaseConstants.usersCollection);

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

    if (widget.role == AppConstants.patient) {
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

  void _onClickMeetingJoin(FirebaseServicesProvider firebaseServicesNotifier,
      String? meetingId, String callType, String displayName) async {
    cameraController?.dispose();
    cameraController = null;
    if (displayName.toString().isEmpty) {
      displayName = "Guest";
    }
    if (isCreateMeetingSelected!) {
      createAndJoinMeeting(firebaseServicesNotifier, callType, displayName);
    } else {
      joinMeeting(firebaseServicesNotifier, callType, displayName, meetingId);
    }
  }

  Future<void> createAndJoinMeeting(
      FirebaseServicesProvider firebaseServicesNotifier,
      callType,
      displayName) async {
    try {
      var meetingID = await createMeeting(AppConstants.videoSdkToken);
      await firebaseServicesNotifier
          .setMeetingId(widget.consultationRequest.id, meetingID)
          .then(
        (success) {
          if (success) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OneToOneMeetingScreen(
                  consultationRequest: widget.consultationRequest,
                  token: AppConstants.videoSdkToken,
                  meetingId: meetingID,
                  role: widget.role,
                  displayName: displayName,
                  micEnabled: isMicOn,
                  camEnabled: isCameraOn,
                ),
              ),
            );
          }
        },
      );
    } catch (error) {
      showToast(error.toString());
    }
  }

  Future<void> joinMeeting(FirebaseServicesProvider firebaseServicesNotifier,
      String callType, String displayName, String? meetingId) async {
    if (meetingId == null) {
      showToast('Please enter Valid Meeting ID');
      return;
    }
    var validMeeting =
        await validateMeeting(AppConstants.videoSdkToken, meetingId);
    if (validMeeting && context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OneToOneMeetingScreen(
            consultationRequest: widget.consultationRequest,
            token: AppConstants.videoSdkToken,
            meetingId: meetingId,
            role: widget.role,
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
    final firebaseServicesNotifier = ref.watch(firebaseServicesProvider);

    return Theme(
      data: ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme().copyWith(
          color: VideoSdkColorConstants.secondaryColor,
        ),
        primaryColor: VideoSdkColorConstants.primaryColor,
        colorScheme: ColorScheme.fromSwatch(
            backgroundColor: VideoSdkColorConstants.secondaryColor),
      ),
      child: Scaffold(
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
                                                        VideoSdkColorConstants
                                                            .black800,
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
                                                : VideoSdkColorConstants.red,
                                            shape: const CircleBorder(),
                                            padding: const EdgeInsets.all(12),
                                          ),
                                          child: Icon(
                                              isMicOn
                                                  ? Icons.mic
                                                  : Icons.mic_off,
                                              color: isMicOn
                                                  ? VideoSdkColorConstants.grey
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
                                                : VideoSdkColorConstants.red,
                                            padding: const EdgeInsets.all(12),
                                          ),
                                          child: Icon(
                                            isCameraOn
                                                ? Icons.videocam
                                                : Icons.videocam_off,
                                            color: isCameraOn
                                                ? VideoSdkColorConstants.grey
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
                        FutureBuilder(
                          future: usersCollectionReference
                              .doc(firebaseServicesNotifier.getCurrentUser!.uid)
                              .get(),
                          builder: (BuildContext context,
                              AsyncSnapshot<
                                      DocumentSnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            if (snapshot.hasData) {
                              DocumentSnapshot data = snapshot.data!;
                              String displayName = widget.role ==
                                      AppConstants.patient
                                  ? '${data.get(ModelFields.firstName)} ${data.get(ModelFields.lastName)} ${data.get(ModelFields.suffix)}'
                                      .trim()
                                  : '${data.get(ModelFields.prefix)} ${data.get(ModelFields.firstName)} ${data.get(ModelFields.lastName)} ${data.get(ModelFields.suffix)}'
                                      .trim();
                              return Padding(
                                padding: const EdgeInsets.all(36.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Container(
                                    //   decoration: BoxDecoration(
                                    //       borderRadius:
                                    //           BorderRadius.circular(12),
                                    //       color: ColorConstants.black750),
                                    //   child: TextField(
                                    //     textAlign: TextAlign.center,
                                    //     style: const TextStyle(
                                    //       fontWeight: FontWeight.w500,
                                    //     ),
                                    //     onChanged: ((value) =>
                                    //         displayName = value),
                                    //     decoration: const InputDecoration(
                                    //         hintText: "Enter display name",
                                    //         hintStyle: TextStyle(
                                    //           color: ColorConstants.textGray,
                                    //         ),
                                    //         border: InputBorder.none),
                                    //   ),
                                    // ),
                                    const VerticalSpacer(16),
                                    MaterialButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      color: VideoSdkColorConstants.purple,
                                      child: Text(
                                          widget.role == AppConstants.patient
                                              ? "Join Meeting"
                                              : 'Create Meeting',
                                          style: const TextStyle(fontSize: 16)),
                                      onPressed: () {
                                        if (displayName.trim().isEmpty) {
                                          showToast('Please enter name');
                                          return;
                                        }

                                        _onClickMeetingJoin(
                                            firebaseServicesNotifier,
                                            widget.meetingId,
                                            "ONE_TO_ONE",
                                            displayName.trim());
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }
                            return loading(
                                color: VideoSdkColorConstants.black400);
                          },
                        ),
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
  final ConsultationRequest consultationRequest;
  final String role;
  final String? meetingId;

  MeetingPayload({
    required this.consultationRequest,
    required this.role,
    this.meetingId,
  });
}
