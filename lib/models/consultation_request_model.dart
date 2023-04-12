import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ConsultationRequest {
  final String id;
  final String patientId;
  final String doctorId;
  final String consultationRequestPatientTitle;
  final String consultationRequestDoctorTitle;
  final String consultationRequestBody;
  final String status;
  final String consultationType;
  final DateTime consultationDateTime;
  final DateTime modifiedAt;
  final DateTime createdAt;
  final List messages;
  String? meetingId;

  ConsultationRequest(
      {required this.id,
      required this.patientId,
      required this.doctorId,
      required this.consultationRequestPatientTitle,
      required this.consultationRequestDoctorTitle,
      required this.consultationRequestBody,
      required this.status,
      required this.consultationType,
      required this.consultationDateTime,
      required this.modifiedAt,
      required this.createdAt,
      required this.messages,
      this.meetingId});

  factory ConsultationRequest.fromSnapshot(DocumentSnapshot snapshot) {
    return ConsultationRequest(
      id: snapshot.get(ModelFields.id),
      patientId: snapshot.get(ModelFields.patientId),
      doctorId: snapshot.get(ModelFields.doctorId),
      consultationRequestPatientTitle:
          snapshot.get(ModelFields.consultationRequestPatientTitle),
      consultationRequestDoctorTitle:
          snapshot.get(ModelFields.consultationRequestDoctorTitle),
      consultationRequestBody:
          snapshot.get(ModelFields.consultationRequestBody),
      status: snapshot.get(ModelFields.status),
      consultationType: snapshot.get(ModelFields.consultationType),
      consultationDateTime:
          snapshot.get(ModelFields.consultationDateTime).toDate(),
      modifiedAt: snapshot.get(ModelFields.modifiedAt).toDate(),
      createdAt: snapshot.get(ModelFields.createdAt).toDate(),
      messages: snapshot
          .get(ModelFields.messages)
          .map((message) => Message.fromJson(message))
          .toList(),
      meetingId: snapshot.get(ModelFields.meetingId) ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ModelFields.id: id,
      ModelFields.patientId: patientId,
      ModelFields.doctorId: doctorId,
      ModelFields.consultationRequestPatientTitle:
          consultationRequestPatientTitle,
      ModelFields.consultationRequestDoctorTitle:
          consultationRequestDoctorTitle,
      ModelFields.consultationRequestBody: consultationRequestBody,
      ModelFields.status: status,
      ModelFields.consultationType: consultationType,
      ModelFields.consultationDateTime: consultationDateTime,
      ModelFields.modifiedAt: modifiedAt,
      ModelFields.createdAt: createdAt,
      ModelFields.meetingId: meetingId ?? ''
    };
  }

  Meeting toMeeting({String type = AppConstants.patient}) {
    return Meeting(
      eventName: type == AppConstants.patient
          ? consultationRequestPatientTitle
          : consultationRequestDoctorTitle,
      eventBody: consultationRequestBody,
      from: consultationDateTime,
      to: consultationDateTime
          .add(const Duration(hours: AppConstants.defaultMeetingDuration)),
      background: Colors.blue,
    );
  }
}

class PatientViewConsultationRequestObject {
  final Doctor doctor;
  final ConsultationRequest consultationRequest;

  PatientViewConsultationRequestObject(
      {required this.doctor, required this.consultationRequest});
}

class DoctorViewConsultationRequestObject {
  final Patient patient;
  final ConsultationRequest consultationRequest;

  DoctorViewConsultationRequestObject(
      {required this.patient, required this.consultationRequest});
}

class Meeting {
  final String eventName;
  final String eventBody;
  final DateTime from;
  final DateTime to;
  final Color background;

  Meeting({
    required this.eventName,
    required this.eventBody,
    required this.from,
    required this.to,
    required this.background,
  });
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  String getNotes(int index) {
    return appointments![index].eventBody;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }
}

class Message {
  final String message;
  final String senderRole;
  final String senderName;
  final DateTime messageTimeStamp;

  Message(
      {required this.message,
      required this.senderRole,
      required this.senderName,
      required this.messageTimeStamp});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      message: json[ModelFields.message],
      senderRole: json[ModelFields.sender],
      senderName: json[ModelFields.senderName],
      messageTimeStamp: json[ModelFields.messageTimeStamp].toDate(),
    );
  }
}
