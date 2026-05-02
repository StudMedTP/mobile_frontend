import 'package:mobile_frontend/data/models/classroom_student.dart';

class Grade {
  final int id;
  final int value;
  final String description;
  final ClassroomStudent? classroomStudent;

  Grade({
    required this.id,
    required this.value,
    required this.description,
    required this.classroomStudent,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'] ?? 0,
      value: json['value'] ?? 0,
      description: json['description'] ?? '',
      classroomStudent: json['classroomStudentResource'] != null
          ? ClassroomStudent.fromJson(json['classroomStudentResource'])
          : null,
    );
  }
}
