import 'package:mobile_frontend/data/models/medicalCenter.dart';
import 'package:mobile_frontend/data/models/student.dart';

class Attendance{
  late int id;
  late int studentId;
  late int medicalCenterId;
  late Student student;
  late Medicalcenter medicalcenter;
  late String status;

  Attendance({
    required this.id,
    required this.studentId,
    required this.medicalCenterId,
    required this.student,
    required this.medicalcenter,
    required this.status
  });

  Attendance.fromJson(Map<String, dynamic> json){
    id = json['id'];
    studentId = json['studentId'];
    medicalCenterId = json['medicalCenterId'];
    if (json['studentResource'] != null) {
      student = Student.fromJson(json['studentResource']);
    }
    if (json['medicalCenterResource'] != null) {
      medicalcenter = Medicalcenter.fromJson(json['medicalCenterResource']);
    }
    status = json['status'];
  }
}