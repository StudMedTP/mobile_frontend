class User{
  late int id;
  late String firstName;
  late String lastName;
  late String email;
  late String role;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role
  });

  User.fromJson(Map<String, dynamic> json){
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    role = json['role'];
  }
}