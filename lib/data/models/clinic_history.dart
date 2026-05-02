import 'package:mobile_frontend/data/models/student.dart';

class ClinicHistory {
  final int id;
  final String medicalHistoryNumber;
  final int age;
  final String sex;
  final String mainDiagnosis;
  final String treatment;
  final String analysis;
  final int studentId;
  final Student? student;

  ClinicHistory({
    required this.id,
    required this.medicalHistoryNumber,
    required this.age,
    required this.sex,
    required this.mainDiagnosis,
    required this.treatment,
    required this.analysis,
    required this.studentId,
    this.student,
  });

  factory ClinicHistory.fromJson(Map<String, dynamic> json) {
    return ClinicHistory(
      id: json['id'] ?? 0,
      medicalHistoryNumber: json['medicalHistoryNumber'] ?? '',
      age: json['age'] ?? 0,
      sex: json['sex'] ?? '',
      mainDiagnosis: json['mainDiagnosis'] ?? '',
      treatment: json['treatment'] ?? '',
      analysis: json['analysis'] ?? '',
      studentId: json['studentId'] ?? 0,
      student: json['studentResource'] != null
          ? Student.fromJson(json['studentResource'])
          : null,
    );
  }
}
