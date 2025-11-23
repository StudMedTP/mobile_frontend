class Student{
  late int id;
  late String studentCode;
  late int teacherId;

  Student({
    required this.id,
    required this.studentCode,
    required this.teacherId
  });

  Student.fromJson(Map<String, dynamic> json){
    id = json['id'];
    studentCode = json['studentCode'];
    teacherId = json['teacherId'];
  }
}