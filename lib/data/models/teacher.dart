import 'package:mobile_frontend/data/models/user.dart';

class Teacher{
  final int id;
  final String teacherCode;
  final String? dailyCode;
  final User? user;

  Teacher({
    required this.id,
    required this.teacherCode,
    required this.dailyCode,
    this.user
  });

  factory Teacher.fromJson(Map<String, dynamic> json){
    return Teacher(
      id: json['id'],
      teacherCode: json['teacherCode'],
      dailyCode: json['dailyCode'],
      user: json['userResource'] != null
          ? User.fromJson(json['userResource'])
          : null
    );
  }
}