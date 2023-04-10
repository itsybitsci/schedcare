import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/plugins/videosdk_plugin/utils/colors.dart';
import 'package:schedcare/plugins/videosdk_plugin/widgets/common/app_bar/meeting_app_bar.dart';
import 'package:schedcare/plugins/videosdk_plugin/widgets/common/chat/chat_view.dart';
import 'package:schedcare/plugins/videosdk_plugin/widgets/common/joining/participant_limit_reached.dart';
import 'package:schedcare/plugins/videosdk_plugin/widgets/common/joining/wanting_to_join.dart';
import 'package:schedcare/plugins/videosdk_plugin/widgets/common/meeting_controls/meeting_action_bar.dart';
import 'package:schedcare/plugins/videosdk_plugin/widgets/common/participant/participant_list.dart';
import 'package:schedcare/plugins/videosdk_plugin/widgets/one_to_one/one_to_one_meeting_container.dart';
import 'package:schedcare/utilities/helpers.dart';
import 'package:videosdk/videosdk.dart';

// Meeting Screen
class OneToOneMeetingScreen extends ConsumerStatefulWidget {
  final String meetingId, token, displayName;
  final bool micEnabled, camEnabled, chatEnabled;
  const OneToOneMeetingScreen({
    Key? key,
    required this.meetingId,
    required this.token,
    required this.displayName,
    this.micEnabled = true,
    this.camEnabled = true,
    this.chatEnabled = true,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _OneToOneMeetingScreenState();
  }
}

class _OneToOneMeetingScreenState extends ConsumerState<OneToOneMeetingScreen> {
  bool isRecordingOn = false;
  bool showChatSnackbar = true;
  String recordingState = "RECORDING_STOPPED";
  // Meeting
  late Room meeting;
  bool _joined = false;
  bool _moreThan2Participants = false;

  // Streams
  Stream? shareStream;
  Stream? videoStream;
  Stream? audioStream;
  Stream? remoteParticipantShareStream;

  bool fullScreen = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    Room room = VideoSDK.createRoom(
      roomId: widget.meetingId,
      token: widget.token,
      displayName: widget.displayName,
      micEnabled: widget.micEnabled,
      camEnabled: widget.camEnabled,
      maxResolution: 'hd',
      multiStream: false,
      defaultCameraIndex: 1,
      notification: const NotificationInfo(
        title: "Video SDK",
        message: "Video SDK is sharing screen in the meeting",
        icon: "notification_share", // drawable icon name
      ),
    );

    // Register meeting events
    registerMeetingEvents(room);

    // Join meeting
    room.join();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return WillPopScope(
      onWillPop: _onWillPopScope,
      child: _joined
          ? SafeArea(
              child: Scaffold(
                  backgroundColor: ColorConstants.primaryColor,
                  body: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      MeetingAppBar(
                        meeting: meeting,
                        token: widget.token,
                        recordingState: recordingState,
                        isFullScreen: fullScreen,
                      ),
                      Expanded(
                        child: GestureDetector(
                            onDoubleTap: () => {
                                  setState(() {
                                    fullScreen = !fullScreen;
                                  })
                                },
                            child: OneToOneMeetingContainer(meeting: meeting)),
                      ),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: !fullScreen
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        secondChild: const SizedBox.shrink(),
                        firstChild: MeetingActionBar(
                          isMicEnabled: audioStream != null,
                          isCamEnabled: videoStream != null,
                          isScreenShareEnabled: shareStream != null,
                          recordingState: recordingState,
                          // Called when Call End button is pressed
                          onCallEndButtonPressed: () {
                            meeting.end();
                          },

                          onCallLeaveButtonPressed: () {
                            meeting.leave();
                          },
                          // Called when mic button is pressed
                          onMicButtonPressed: () {
                            if (audioStream != null) {
                              meeting.muteMic();
                            } else {
                              meeting.unmuteMic();
                            }
                          },
                          // Called when camera button is pressed
                          onCameraButtonPressed: () {
                            if (videoStream != null) {
                              meeting.disableCam();
                            } else {
                              meeting.enableCam();
                            }
                          },

                          onSwitchMicButtonPressed: (details) async {
                            List<MediaDeviceInfo> outputDevice =
                                meeting.getAudioOutputDevices();
                            double bottomMargin = (70.0 * outputDevice.length);
                            final screenSize = MediaQuery.of(context).size;
                            await showMenu(
                              context: context,
                              color: ColorConstants.black700,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              position: RelativeRect.fromLTRB(
                                screenSize.width - details.globalPosition.dx,
                                details.globalPosition.dy - bottomMargin,
                                details.globalPosition.dx,
                                (bottomMargin),
                              ),
                              items: outputDevice.map((e) {
                                return PopupMenuItem(
                                    value: e, child: Text(e.label));
                              }).toList(),
                              elevation: 8.0,
                            ).then((value) {
                              if (value != null) {
                                meeting.switchAudioDevice(value);
                              }
                            });
                          },

                          onChatButtonPressed: () {
                            setState(() {
                              showChatSnackbar = false;
                            });
                            showModalBottomSheet(
                              context: context,
                              constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height -
                                          statusBarHeight),
                              isScrollControlled: true,
                              builder: (context) => ChatView(
                                  key: const Key("ChatScreen"),
                                  meeting: meeting),
                            ).whenComplete(() => {
                                  setState(() {
                                    showChatSnackbar = true;
                                  })
                                });
                          },

                          // Called when more options button is pressed
                          onMoreOptionSelected: (option) {
                            // Showing more options dialog box
                            if (option == "screenshare") {
                              if (remoteParticipantShareStream == null) {
                                if (shareStream == null) {
                                  meeting.enableScreenShare();
                                } else {
                                  meeting.disableScreenShare();
                                }
                              } else {
                                showToast(
                                  "Someone is already presenting",
                                );
                              }
                            } else if (option == "recording") {
                              if (recordingState == "RECORDING_STOPPING") {
                                showToast("Recording is in stopping state");
                              } else if (recordingState ==
                                  "RECORDING_STARTED") {
                                meeting.stopRecording();
                              } else if (recordingState ==
                                  "RECORDING_STARTING") {
                                showToast("Recording is in starting state");
                              } else {
                                meeting.startRecording();
                              }
                            } else if (option == "participants") {
                              showModalBottomSheet(
                                context: context,
                                // constraints: BoxConstraints(
                                //     maxHeight: MediaQuery.of(context).size.height -
                                //         statusbarHeight),
                                isScrollControlled: false,
                                builder: (context) =>
                                    ParticipantList(meeting: meeting),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  )),
            )
          : _moreThan2Participants
              ? ParticipantLimitReached(
                  meeting: meeting,
                )
              : const WaitingToJoin(),
    );
  }

  void registerMeetingEvents(Room room) {
    // Called when joined in meeting
    room.on(
      Events.roomJoined,
      () {
        if (room.participants.length > 1) {
          setState(() {
            meeting = room;
            _moreThan2Participants = true;
          });
        } else {
          setState(() {
            meeting = room;
            _joined = true;
          });

          subscribeToChatMessages(room);
        }
      },
    );

    // Called when meeting is ended
    room.on(Events.roomLeft, (String? errorMsg) {
      if (errorMsg != null) {
        showToast("Meeting left due to $errorMsg !!");
      }
      context.pop();
    });

    // Called when recording is started
    room.on(Events.recordingStateChanged, (String status) {
      showToast(
          "Meeting recording ${status == "RECORDING_STARTING" ? "is starting" : status == "RECORDING_STARTED" ? "started" : status == "RECORDING_STOPPING" ? "is stopping" : "stopped"}");

      setState(() {
        recordingState = status;
      });
    });

    // Called when stream is enabled
    room.localParticipant.on(Events.streamEnabled, (Stream stream) {
      if (stream.kind == 'video') {
        setState(() {
          videoStream = stream;
        });
      } else if (stream.kind == 'audio') {
        setState(() {
          audioStream = stream;
        });
      } else if (stream.kind == 'share') {
        setState(() {
          shareStream = stream;
        });
      }
    });

    // Called when stream is disabled
    room.localParticipant.on(Events.streamDisabled, (Stream stream) {
      if (stream.kind == 'video' && videoStream?.id == stream.id) {
        setState(() {
          videoStream = null;
        });
      } else if (stream.kind == 'audio' && audioStream?.id == stream.id) {
        setState(() {
          audioStream = null;
        });
      } else if (stream.kind == 'share' && shareStream?.id == stream.id) {
        setState(() {
          shareStream = null;
        });
      }
    });

    // Called when presenter is changed
    room.on(Events.presenterChanged, (activePresenterId) {
      Participant? activePresenterParticipant =
          room.participants[activePresenterId];

      // Get Share Stream
      Stream? stream = activePresenterParticipant?.streams.values
          .singleWhere((e) => e.kind == "share");

      setState(() => remoteParticipantShareStream = stream);
    });

    room.on(
        Events.participantLeft,
        (participant) => {
              if (_moreThan2Participants)
                {
                  if (room.participants.length < 2)
                    {
                      setState(() {
                        _joined = true;
                        _moreThan2Participants = false;
                      }),
                      subscribeToChatMessages(room),
                    }
                }
            });

    room.on(
      Events.error,
      (error) => {showToast("${error['name']}: ${error['message']}")},
    );
  }

  void subscribeToChatMessages(Room meeting) {
    meeting.pubSub.subscribe("CHAT", (message) {
      if (message.senderId != meeting.localParticipant.id) {
        if (mounted) {
          // print("navigator key");
          // print(navigatorKey.currentWidget?.key.toString());
          if (showChatSnackbar) {
            showToast("${message.senderName}: ${message.message}");
          }
        }
      }
    });
  }

  Future<bool> _onWillPopScope() async {
    meeting.end();
    return true;
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
}
