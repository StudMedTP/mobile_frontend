import 'package:mobile_frontend/data/models/user.dart';

class Teacher{
  late int id;
  late String teacherCode;
  late String? dailyCode;
  late User user;

  Teacher({
    required this.id,
    required this.teacherCode,
    required this.dailyCode,
    required this.user
  });

  Teacher.fromJson(Map<String, dynamic> json){
    id = json['id'];
    teacherCode = json['teacherCode'];
    dailyCode = json['dailyCode'];
    if (json['userResource'] != null) {
      user = User.fromJson(json['userResource']);
    }
  }
}