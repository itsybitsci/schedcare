import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ConsultationRequest {
  final String id;
  final String patientId;
  final String doctorId;
  final String consultationRequestTitle;
  final String consultationRequestBody;
  final String status;
  final String consultationType;
  final DateTime consultationDateTime;
  final DateTime modifiedAt;
  final DateTime createdAt;
  String? meetingId;

  ConsultationRequest(
      {required this.id,
      required this.patientId,
      required this.doctorId,
      required this.consultationRequestTitle,
      required this.consultationRequestBody,
      required this.status,
      required this.consultationType,
      required this.consultationDateTime,
      required this.modifiedAt,
      required this.createdAt,
      this.meetingId});

  factory ConsultationRequest.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return ConsultationRequest(
      id: data[ModelFields.id],
      patientId: data[ModelFields.patientId],
      doctorId: data[ModelFields.doctorId],
      consultationRequestTitle: data[ModelFields.consultationRequestTitle],
      consultationRequestBody: data[ModelFields.consultationRequestBody],
      status: data[ModelFields.status],
      consultationType: data[ModelFields.consultationType],
      consultationDateTime: data[ModelFields.consultationDateTime].toDate(),
      modifiedAt: data[ModelFields.modifiedAt].toDate(),
      createdAt: data[ModelFields.createdAt].toDate(),
      meetingId: data[ModelFields.meetingId] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ModelFields.id: id,
      ModelFields.patientId: patientId,
      ModelFields.doctorId: doctorId,
      ModelFields.consultationRequestTitle: consultationRequestTitle,
      ModelFields.consultationRequestBody: consultationRequestBody,
      ModelFields.status: status,
      ModelFields.consultationType: consultationType,
      ModelFields.consultationDateTime: consultationDateTime,
      ModelFields.modifiedAt: modifiedAt,
      ModelFields.createdAt: createdAt,
      ModelFields.meetingId: meetingId ?? ''
    };
  }

  Meeting toMeeting() {
    return Meeting(
      eventName: consultationRequestTitle,
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
