class Student{
  late String id;
  late String firstname;
  late String lastname;
  late String email;
  late String password;
  late String role;

  Student({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.password,
    required this.role


  });

  Student.fromJson(Map<String, dynamic> json){
    id = json['_id'];
    firstname = json['firstName'];
    lastname = json['lastName'];
    email = json['email'];
    password = json['password'];
    role = json['role'];
  }
}