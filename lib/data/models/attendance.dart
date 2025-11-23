import 'package:mobile_frontend/data/models/medicalCenter.dart';
import 'package:mobile_frontend/data/models/student.dart';

class Attendance{
  late int id;
  late int studentId;
  late int medicalCenterId;
  late Student student;
  late MedicalCenter medicalcenter;
  late String status;
  late DateTime date;
  late double? latitude;
  late double? longitude;

  Attendance({
    required this.id,
    required this.studentId,
    required this.medicalCenterId,
    required this.student,
    required this.medicalcenter,
    required this.status,
    required this.date,
    required this.latitude,
    required this.longitude
  });

  Attendance.fromJson(Map<String, dynamic> json){
    id = json['id'];
    studentId = json['studentId'];
    medicalCenterId = json['medicalCenterId'];
    if (json['studentResource'] != null) {
      student = Student.fromJson(json['studentResource']);
    }
    if (json['medicalCenterResource'] != null) {
      medicalcenter = MedicalCenter.fromJson(json['medicalCenterResource']);
    }
    status = json['status'];
    date = DateTime.parse(json['date']);
    if (json['latitude'] != null) {
      latitude = json['latitude'].toDouble();
    }
    if (json['longitude'] != null) {
      longitude = json['longitude'].toDouble();
    }
  }
}