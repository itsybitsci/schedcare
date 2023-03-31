import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedcare/utilities/constants.dart';

class AppNotification {
  final String id;
  final String patientId;
  final String doctorId;
  final String title;
  final String body;
  final DateTime sentAt;
  final bool isRead;

  AppNotification(
      {required this.id,
      required this.patientId,
      required this.doctorId,
      required this.title,
      required this.body,
      required this.sentAt,
      required this.isRead});

  factory AppNotification.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return AppNotification(
      id: data[ModelFields.id],
      patientId: data[ModelFields.patientId],
      doctorId: data[ModelFields.doctorId],
      title: data[ModelFields.title],
      body: data[ModelFields.body],
      sentAt: data[ModelFields.sentAt].toDate(),
      isRead: data[ModelFields.isRead],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ModelFields.id: id,
      ModelFields.patientId: patientId,
      ModelFields.doctorId: doctorId,
      ModelFields.title: title,
      ModelFields.body: body,
      ModelFields.sentAt: sentAt,
      ModelFields.isRead: isRead,
    };
  }
}
