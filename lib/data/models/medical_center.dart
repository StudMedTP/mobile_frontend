class MedicalCenter{
  late int id;
  late String name;

  MedicalCenter({
    required this.id,
    required this.name
  });

  MedicalCenter.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
  }
}