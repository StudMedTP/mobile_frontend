import 'package:mobile_frontend/data/models/medical_center.dart';
import 'package:mobile_frontend/data/models/teacher.dart';

class Classroom {
  final int id;
  final String name;
  final int medicalCenterId;
  final int teacherId;
  final MedicalCenter? medicalCenter;
  final Teacher? teacher;

  Classroom({
    required this.id,
    required this.name,
    required this.medicalCenterId,
    required this.teacherId,
    this.medicalCenter,
    this.teacher,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      medicalCenterId: json['medicalCenterId'] ?? 0,
      teacherId: json['teacherId'] ?? 0,
      medicalCenter: json['medicalCenterResource'] != null
          ? MedicalCenter.fromJson(json['medicalCenterResource'])
          : null,
      teacher: json['teacherResource'] != null
          ? Teacher.fromJson(json['teacherResource'])
          : null,
    );
  }
}
