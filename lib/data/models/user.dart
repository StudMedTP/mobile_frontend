class User{
  late int id;
  late String firstName;
  late String lastName;

  User({
    required this.id,
    required this.firstName,
    required this.lastName
  });

  User.fromJson(Map<String, dynamic> json){
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
  }
}