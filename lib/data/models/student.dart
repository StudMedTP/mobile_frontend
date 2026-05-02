import 'package:mobile_frontend/data/models/user.dart';

class Student{
  late int id;
  late String studentCode;
  late User user;

  Student({
    required this.id,
    required this.studentCode,
    required this.user
  });

  Student.fromJson(Map<String, dynamic> json){
    id = json['id'];
    print(json['id']);
    studentCode = json['studentCode'];
    print(json['studentCode']);
    if (json['userResource'] != null) {
      print("Huh?");
      user = User.fromJson(json['userResource']);
    }
  }
}