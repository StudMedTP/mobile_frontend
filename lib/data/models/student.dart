import 'package:mobile_frontend/data/models/user.dart';

class Student{
  late int id;
  late String studentCode;
  late int teacherId;
  late User user;

  Student({
    required this.id,
    required this.studentCode,
    required this.teacherId,
    required this.user
  });

  Student.fromJson(Map<String, dynamic> json){
    id = json['id'];
    studentCode = json['studentCode'];
    teacherId = json['teacherId'];
    if (json['userResource'] != null) {
      user = User.fromJson(json['userResource']);
    }
  }
}