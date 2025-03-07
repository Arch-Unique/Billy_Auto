import 'base_model.dart';

class BillyServices extends BaseModel{
  
  String name;
  String image;
  double cost;
  
  

  BillyServices({
    super.id = 0,
    this.cost = 0,
    required this.name,
    required this.image,
    super.createdAt,
    super.updatedAt,
  });

  // Convert Services object to JSON
  @override
Map<String, dynamic> toJson() {
    return {'name': name, 'image': image,'cost':cost};
  }

      @override
List<dynamic> toTableRows(){
    return [id,name,createdAtRaw];
  }

  @override
  bool validate() {
    return name.isNotEmpty;
  }

  // Create Services object from JSON
  factory BillyServices.fromJson(Map<String, dynamic> json) {
    return BillyServices(
      id: json['id'] ?? 0,
      name: json['name'],
      image: json['image'] ?? "",
      cost: double.tryParse(json['cost'].toString()) ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
    );
  }
}
