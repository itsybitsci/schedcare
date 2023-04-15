import 'dart:async';
import 'package:flutter/material.dart';
import 'package:schedcare/plugins/videosdk_plugin/utils/colors.dart';
import 'package:schedcare/plugins/videosdk_plugin/widgets/common/stats/call_stats_bottom_sheet.dart';
import 'package:videosdk/videosdk.dart';

class CallStats extends StatefulWidget {
  final Participant participant;

  const CallStats({Key? key, required this.participant}) : super(key: key);

  @override
  State<CallStats> createState() => _CallStatsState();
}

class _CallStatsState extends State<CallStats> {
  Timer? statsTimer;
  bool showFullStats = false;
  int? score;
  PersistentBottomSheetController? bottomSheetController;

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
    return Container(
      child: score != null && !showFullStats
          ? GestureDetector(
              onTap: () {
                setState(() {
                  showFullStats = !showFullStats;
                });
                bottomSheetController = showBottomSheet(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    context: context,
                    builder: (_) {
                      return CallStatsBottomSheet(
                          participant: widget.participant);
                    });
                bottomSheetController?.closed.then((value) {
                  setState(() {
                    showFullStats = !showFullStats;
                  });
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: score! > 7
                      ? ColorConstants.green
                      : score! > 4
                          ? ColorConstants.yellow
                          : ColorConstants.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.network_cell,
                  size: 17,
                ),
              ),
            )
          : null,
    );
  }

  void updateStats() {
    if (widget.participant.streams.isEmpty) {
      bottomSheetController?.close();
    }
    var audioStats = widget.participant.getAudioStats();
    var videoStats = widget.participant.getVideoStats();
    dynamic vStats;
    videoStats?.forEach((stat) {
      if (vStats == null) {
        vStats = stat;
      } else {
        if (stat['size']['width'] != "null" && stat['size']['width'] != null) {
          if (stat['size']['width'] > vStats['size']['width']) {
            vStats = stat;
          }
        }
      }
    });
    var stats = {};
    if (audioStats != null) {
      if (audioStats.isNotEmpty) stats = audioStats[0];
    }
    if (vStats != null) {
      stats = vStats;
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
    });
  }

  @override
  void dispose() {
    if (statsTimer != null) {
      statsTimer?.cancel();
    }
    if (widget.participant.streams.isEmpty) {
      bottomSheetController?.close();
    }
    super.dispose();
  }
}
