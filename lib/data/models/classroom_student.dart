import 'package:mobile_frontend/data/models/classroom.dart';
import 'package:mobile_frontend/data/models/student.dart';

class ClassroomStudent {
  final int id;
  final Classroom? classroom;
  final Student? student;

  ClassroomStudent({
    required this.id,
    required this.classroom,
    required this.student,
  });

  factory ClassroomStudent.fromJson(Map<String, dynamic> json) {
    return ClassroomStudent(
      id: json['id'] ?? 0,
      classroom: json['classroomResource'] != null
          ? Classroom.fromJson(json['classroomResource'])
          : null,
      student: json['studentResource'] != null
          ? Student.fromJson(json['studentResource'])
          : null,
    );
  }
}
