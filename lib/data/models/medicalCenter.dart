class Medicalcenter{
  late int id;
  late String name;

  Medicalcenter({
    required this.id,
    required this.name
  });

  Medicalcenter.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
  }
}