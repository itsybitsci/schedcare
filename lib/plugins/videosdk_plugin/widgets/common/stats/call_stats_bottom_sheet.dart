import 'dart:async';

import 'package:flutter/material.dart';
import 'package:schedcare/plugins/videosdk_plugin/utils/videosdk_colors.dart';
import 'package:videosdk/videosdk.dart';

class CallStatsBottomSheet extends StatefulWidget {
  final Participant participant;
  const CallStatsBottomSheet({Key? key, required this.participant})
      : super(key: key);

  @override
  State<CallStatsBottomSheet> createState() => _CallStatsBottomSheetState();
}

class _CallStatsBottomSheetState extends State<CallStatsBottomSheet> {
  Timer? statsTimer;

  Map<dynamic, dynamic>? audioStats;
  Map<dynamic, dynamic>? videoStats;
  int? score;

  @override
  void initState() {
    statsTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => {updateStats()});
    super.initState();
    updateStats();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: VideoSdkColorConstants.black700,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: score == null
                    ? VideoSdkColorConstants.black700
                    : score! > 7
                        ? VideoSdkColorConstants.green
                        : score! > 4
                            ? VideoSdkColorConstants.yellow
                            : VideoSdkColorConstants.red,
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8.0),
                    bottomRight: Radius.circular(0.0),
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(0.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      children: [
                        Text(
                          " ${widget.participant.displayName} - Quality Metrics : ${score == null ? '-' : score! > 7 ? 'Good' : score! > 4 ? 'Average' : 'Poor'}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.close))
                ],
              ),
            ),
            Table(
              border: TableBorder.all(width: 0.5, color: Colors.white10),
              children: [
                const TableRow(children: [
                  Padding(padding: EdgeInsets.all(4), child: Text("")),
                  Center(
                      child: Padding(
                          padding: EdgeInsets.all(4), child: Text("Audio"))),
                  Center(
                      child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text("Video"),
                  ))
                ]),
                TableRow(children: [
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text("Latency"),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(audioStats?['rtt'] != null
                          ? "${(audioStats?['rtt'] as double).toInt()} ms"
                          : "-"),
                    ),
                  ),
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(videoStats?['rtt'] != null
                        ? "${(videoStats?['rtt'] as double).toInt()} ms"
                        : "-"),
                  ))
                ]),
                TableRow(children: [
                  const Padding(
                      padding: EdgeInsets.all(4), child: Text("Jitter")),
                  Center(
                      child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(audioStats?['jitter'] != null
                              ? "${(audioStats?['jitter']).toString().split('.')[0]} ms"
                              : "-"))),
                  Center(
                      child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(videoStats?['jitter'] != null
                              ? "${(videoStats?['jitter']).toString().split('.')[0]} ms"
                              : "-")))
                ]),
                TableRow(children: [
                  const Padding(
                      padding: EdgeInsets.all(4), child: Text("Packet Loss")),
                  Center(
                      child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(audioStats?['packetsLost'] != null
                              ? "${((audioStats?['packetsLost'] ?? 0.0) / (audioStats?['totalPackets'] ?? 1) as double).toStringAsFixed(2)} %"
                              : "-"))),
                  Center(
                      child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(videoStats?['packetsLost'] != null
                              ? "${((videoStats?['packetsLost'] ?? 0.0) / (videoStats?['totalPackets'] ?? 1) as double).toStringAsFixed(2)} %"
                              : "-")))
                ]),
                TableRow(children: [
                  const Padding(
                      padding: EdgeInsets.all(4), child: Text("Bitrate")),
                  Center(
                      child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(audioStats?['bitrate'] != null
                              ? "${(audioStats?['bitrate']).toString().split('.')[0]} kb/s"
                              : "-"))),
                  Center(
                      child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(videoStats?['bitrate'] != null
                              ? (videoStats?['bitrate']).toStringAsFixed(2) +
                                  " kb/s"
                              : "-")))
                ]),
                TableRow(children: [
                  const Padding(
                      padding: EdgeInsets.all(4), child: Text("Frame Rate")),
                  const Center(
                      child: Padding(
                          padding: EdgeInsets.all(4), child: Text("-"))),
                  Center(
                      child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(videoStats?['size']?['framerate'] != null
                              ? "${videoStats?['size']?['framerate']}"
                              : "-")))
                ]),
                TableRow(children: [
                  const Padding(
                      padding: EdgeInsets.all(4), child: Text("Resolution")),
                  const Center(
                      child: Padding(
                          padding: EdgeInsets.all(4), child: Text("-"))),
                  Center(
                      child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(videoStats?['size']?['width'] != null &&
                                  videoStats?['size']?['height'] != null &&
                                  videoStats?['size']?['height'] != 'null'
                              ? "${videoStats?['size']?['width']}x${videoStats?['size']?['height']}"
                              : "-")))
                ]),
                TableRow(children: [
                  const Padding(
                      padding: EdgeInsets.all(4), child: Text("Codec")),
                  Center(
                      child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(audioStats?['codec'] != null
                              ? (audioStats?['codec']).toString()
                              : "-"))),
                  Center(
                      child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(videoStats?['codec'] != null
                              ? (videoStats?['codec']).toString()
                              : "-")))
                ]),
              ],
            )
          ]),
        )
      ],
    );
  }

  void updateStats() {
    var audioStatScore = widget.participant.getAudioStats();
    var videoStatScore = widget.participant.getVideoStats();
    dynamic vStatsValue;
    videoStatScore?.forEach((stat) {
      if (vStatsValue == null) {
        vStatsValue = stat;
      } else {
        if (stat['size']['width'] != "null" &&
            stat['size']['width'] != null &&
            stat['size']['framerate'] != null) {
          if (stat['size']['width'] > vStatsValue['size']['width']) {
            vStatsValue = stat;
          }
        }
      }
    });
    var stats = {};
    if (audioStatScore != null) {
      if (audioStatScore.isNotEmpty) stats = audioStatScore[0];
    }
    if (vStatsValue != null) {
      stats = vStatsValue;
    }

    double packetLossPercent =
        (stats['packetsLost'] ?? 0.0) / (stats['totalPackets'] ?? 1);
    if (packetLossPercent.isNaN) {
      packetLossPercent = 0;
    }
    double jitter = stats['jitter'] ?? 0;
    double rtt = stats['rtt'] ?? 0;
    double? statScore = stats.isNotEmpty ? 100 : null;
    if (statScore != null) {
      statScore -= packetLossPercent * 50 > 50 ? 50 : packetLossPercent * 50;
      statScore -= ((jitter / 30) * 25 > 25 ? 25 : (jitter / 30) * 25);
      statScore -= ((rtt / 300) * 25 > 25 ? 25 : (rtt / 300) * 25);
    }

    setState(() {
      score = statScore != null ? statScore ~/ 10 : null;
      audioStats = audioStatScore?[0];
      videoStats = vStatsValue;
    });
  }

  @override
  void dispose() {
    if (statsTimer != null) {
      statsTimer?.cancel();
    }
    super.dispose();
  }
}
