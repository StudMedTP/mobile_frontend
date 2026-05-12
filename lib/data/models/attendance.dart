import 'package:mobile_frontend/data/models/teacher.dart';
import 'package:mobile_frontend/data/models/student.dart';

class Attendance{
  late int id;
  late int studentId;
  late int teacherId;
  late Student student;
  late Teacher teacher;
  late DateTime createdAt;
  late double? latitude;
  late double? longitude;
  late bool isPartial;

  Attendance({
    required this.id,
    required this.studentId,
    required this.teacherId,
    required this.student,
    required this.teacher,
    required this.createdAt,
    required this.latitude,
    required this.longitude,
    required this.isPartial
  });

  Attendance.fromJson(Map<String, dynamic> json){
    id = json['id'];
    studentId = json['studentId'];
    teacherId = json['teacherId'];
    isPartial = json['isPartial'];
    if (json['studentResource'] != null) {
      student = Student.fromJson(json['studentResource']);
    }
    if (json['teacherResource'] != null) {
      teacher = Teacher.fromJson(json['teacherResource']);
    }
    createdAt = DateTime.parse(json['createdAt']);
    if (json['latitude'] != null) {
      latitude = json['latitude'].toDouble();
    }
    if (json['longitude'] != null) {
      longitude = json['longitude'].toDouble();
    }
  }
}