import 'package:inventory/models/inner_models/base_model.dart';

class CarMake extends BaseModel{
  String make;

  CarMake({
    super.id = 0,
    required this.make,
    super.createdAt,
    super.updatedAt,
  });

  // Convert CarMake object to JSON
  @override
Map<String, dynamic> toJson() {
    return {
      'make': make,
    };
  }

  @override
List<dynamic> toTableRows(){
    return [id,make,createdAt];
  }

  // Create CarMake object from JSON
  factory CarMake.fromJson(Map<String, dynamic> json) {
    return CarMake(
      id: json['id'] ?? 0,
      make: json['make'],
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
    );
  }
  
  @override
  bool validate() {
    return make.isNotEmpty;
  }
}

class CarModels extends BaseModel {
  
  int makeId;
  String model, make;
  
  

  CarModels({
    super.id = 0,
    required this.makeId,
    required this.model,
    this.make="",
    super.createdAt,
    super.updatedAt,
  });

  // Convert CarModels object to JSON
  @override
Map<String, dynamic> toJson() {
    return {'makeId': makeId, 'model': model};
  }

    @override
List<dynamic> toTableRows(){
    return [id,make,model,createdAt];
  }

  @override
  bool validate() {
    return makeId != 0 && model.isNotEmpty;
  }

  // Create CarModels object from JSON
  factory CarModels.fromJson(Map<String, dynamic> json) {
    return CarModels(
      id: json['id'] ?? 0,
      makeId: json['makeId'],
      make: json['make'],
      model: json['model'],
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
    );
  }
}
