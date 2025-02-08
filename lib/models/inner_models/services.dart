import 'base_model.dart';

class BillyServices extends BaseModel{
  
  String name;
  String image;
  
  

  BillyServices({
    super.id = 0,
    required this.name,
    required this.image,
    super.createdAt,
    super.updatedAt,
  });

  // Convert Services object to JSON
  @override
Map<String, dynamic> toJson() {
    return {'name': name, 'image': image};
  }

      @override
List<dynamic> toTableRows(){
    return [id,name,createdAt];
  }

  // Create Services object from JSON
  factory BillyServices.fromJson(Map<String, dynamic> json) {
    return BillyServices(
      id: json['id'],
      name: json['name'],
      image: json['image'] ?? "",
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
