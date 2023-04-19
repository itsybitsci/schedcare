import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:schedcare/plugins/videosdk_plugin/utils/videosdk_colors.dart';
import 'package:schedcare/plugins/videosdk_plugin/widgets/one_to_one/participant_view.dart';
import 'package:videosdk/videosdk.dart';

class OneToOneMeetingContainer extends StatefulWidget {
  final Room meeting;
  const OneToOneMeetingContainer({Key? key, required this.meeting})
      : super(key: key);

  @override
  State<OneToOneMeetingContainer> createState() =>
      _OneToOneMeetingContainerState();
}

class _OneToOneMeetingContainerState extends State<OneToOneMeetingContainer> {
  Stream? localVideoStream;
  Stream? localShareStream;
  Stream? localAudioStream;
  Stream? remoteAudioStream;
  Stream? remoteVideoStream;
  Stream? remoteShareStream;

  Stream? largeViewStream;
  Stream? smallViewStream;
  Participant? largeParticipant, smallParticipant;
  Participant? localParticipant, remoteParticipant;
  String? activeSpeakerId, presenterId;

  bool isSmallViewLeftAligned = false;

  @override
  void initState() {
    localParticipant = widget.meeting.localParticipant;
    // Setting meeting event listeners
    setMeetingListeners(widget.meeting);

    try {
      remoteParticipant = widget.meeting.participants.isNotEmpty
          ? widget.meeting.participants.entries.first.value
          : null;
      if (remoteParticipant != null) {
        addParticipantListener(remoteParticipant!, true);
      }
    } catch (error) {
      throw Exception(error.toString());
    }
    addParticipantListener(localParticipant!, false);
    super.initState();
    updateView();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: IntrinsicHeight(
        child: Stack(children: [
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: VideoSdkColorConstants.black800,
              ),
              child: ParticipantView(
                avatarBackground: VideoSdkColorConstants.black700,
                stream: largeViewStream,
                isMicOn: remoteParticipant != null
                    ? remoteAudioStream != null
                    : localAudioStream != null,
                onStopScreenSharePressed: () =>
                    widget.meeting.disableScreenShare(),
                participant: remoteParticipant != null
                    ? remoteParticipant!
                    : localParticipant!,
                isLocalScreenShare: localShareStream != null,
                isScreenShare:
                    remoteShareStream != null || localShareStream != null,
                avatarTextSize: 40,
              )),
          if (remoteParticipant != null || localShareStream != null)
            Positioned(
                right: isSmallViewLeftAligned ? null : 8,
                left: isSmallViewLeftAligned ? 8 : null,
                bottom: 8,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    // Note: Sensitivity is integer used when you don't want to mess up vertical drag
                    int sensitivity = 8;
                    if (details.delta.dx > sensitivity) {
                      // Right Swipe
                      setState(() {
                        isSmallViewLeftAligned = false;
                      });
                    } else if (details.delta.dx < -sensitivity) {
                      //Left Swipe
                      setState(() {
                        isSmallViewLeftAligned = true;
                      });
                    }
                  },
                  child: Container(
                      height: 160,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: VideoSdkColorConstants.black600,
                      ),
                      child: ParticipantView(
                        avatarTextSize: 30,
                        avatarBackground: VideoSdkColorConstants.black500,
                        stream: smallViewStream,
                        isMicOn: (localAudioStream != null &&
                                remoteShareStream == null) ||
                            (remoteAudioStream != null &&
                                remoteShareStream != null),
                        onStopScreenSharePressed: () =>
                            widget.meeting.disableScreenShare(),
                        participant: remoteShareStream != null
                            ? remoteParticipant!
                            : localParticipant!,
                        isLocalScreenShare: false,
                        isScreenShare: false,
                      )),
                )),
        ]),
      ),
    );
  }

  void setMeetingListeners(Room meeting) {
    // Called when participant joined meeting
    meeting.on(
      Events.participantJoined,
      (Participant participant) {
        setState(() {
          remoteParticipant = widget.meeting.participants.isNotEmpty
              ? widget.meeting.participants.entries.first.value
              : null;
          updateView();

          if (remoteParticipant != null) {
            addParticipantListener(remoteParticipant!, true);
          }
        });
      },
    );

    // Called when participant left meeting
    meeting.on(
      Events.participantLeft,
      (participantId) {
        if (remoteParticipant?.id == participantId) {
          setState(() {
            remoteParticipant = null;
            remoteShareStream = null;
            remoteVideoStream = null;
            updateView();
          });
        }
        setState(() {
          remoteParticipant = widget.meeting.participants.isNotEmpty
              ? widget.meeting.participants.entries.first.value
              : null;
          if (remoteParticipant != null) {
            addParticipantListener(remoteParticipant!, true);
            updateView();
          }
        });
      },
    );

    meeting.on(Events.presenterChanged, (presenterId) {
      setState(() {
        presenterId = presenterId;
      });
    });

    // Called when speaker is changed
    meeting.on(Events.speakerChanged, (activeSpeakerId) {
      setState(() {
        activeSpeakerId = activeSpeakerId;
      });
    });
  }

  void updateView() {
    Stream? largeViewStreamInput, smallViewStreamInput;
    if (remoteParticipant != null) {
      if (remoteShareStream != null) {
        largeViewStreamInput = remoteShareStream;
      } else if (localShareStream != null) {
        largeViewStreamInput = null;
      } else {
        largeViewStreamInput = remoteVideoStream;
      }
      if (remoteShareStream != null || localShareStream != null) {
        if (remoteVideoStream != null) {
          smallViewStreamInput = remoteVideoStream;
        }
      } else {
        smallViewStreamInput = localVideoStream;
      }
    } else {
      if (localShareStream != null) {
        smallViewStreamInput = localVideoStream;
      } else {
        largeViewStreamInput = localVideoStream;
      }
    }
    setState(() {
      largeViewStream = largeViewStreamInput;
      smallViewStream = smallViewStreamInput;
    });
  }

  void addParticipantListener(Participant participant, bool isRemote) {
    participant.streams.forEach((key, Stream stream) {
      setState(() {
        if (stream.kind == 'video') {
          if (isRemote) {
            remoteVideoStream = stream;
          } else {
            localVideoStream = stream;
          }
        } else if (stream.kind == 'share') {
          if (isRemote) {
            remoteShareStream = stream;
          } else {
            localShareStream = stream;
          }
        } else if (stream.kind == 'audio') {
          if (isRemote) {
            remoteAudioStream = stream;
          } else {
            localAudioStream = stream;
          }
        }
        updateView();
      });
    });
    participant.on(Events.streamEnabled, (Stream stream) {
      setState(() {
        if (stream.kind == "video") {
          if (isRemote) {
            remoteVideoStream = stream;
          } else {
            localVideoStream = stream;
          }
        } else if (stream.kind == "share") {
          if (isRemote) {
            remoteShareStream = stream;
          } else {
            localShareStream = stream;
          }
        } else if (stream.kind == 'audio') {
          if (isRemote) {
            remoteAudioStream = stream;
          } else {
            localAudioStream = stream;
          }
        }
        updateView();
      });
    });

    participant.on(Events.streamDisabled, (Stream stream) {
      setState(() {
        if (stream.kind == "video") {
          if (isRemote) {
            remoteVideoStream = null;
          } else {
            localVideoStream = null;
          }
        } else if (stream.kind == "share") {
          if (isRemote) {
            remoteShareStream = null;
          } else {
            localShareStream = null;
          }
        } else if (stream.kind == 'audio') {
          if (isRemote) {
            remoteAudioStream = null;
          } else {
            localAudioStream = null;
          }
        }
        updateView();
      });
    });
  }
}
