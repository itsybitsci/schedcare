import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedcare/utilities/constants.dart';

class AppNotification {
  final String id;
  final String patientId;
  final String doctorId;
  final String title;
  final String body;
  final DateTime sentAt;
  final String sender;
  final bool isRead;

  AppNotification(
      {required this.id,
      required this.patientId,
      required this.doctorId,
      required this.title,
      required this.body,
      required this.sentAt,
      required this.sender,
      required this.isRead});

  factory AppNotification.fromSnapshot(DocumentSnapshot snapshot) {
    return AppNotification(
      id: snapshot.get(ModelFields.id),
      patientId: snapshot.get(ModelFields.patientId),
      doctorId: snapshot.get(ModelFields.doctorId),
      title: snapshot.get(ModelFields.title),
      body: snapshot.get(ModelFields.body),
      sentAt: snapshot.get(ModelFields.sentAt).toDate(),
      sender: snapshot.get(ModelFields.sender),
      isRead: snapshot.get(ModelFields.isRead),
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
      ModelFields.sender: sender,
      ModelFields.isRead: isRead,
    };
  }
}
