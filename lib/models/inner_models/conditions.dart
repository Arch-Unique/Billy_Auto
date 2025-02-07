import 'base_model.dart';

class BillyConditions extends BaseModel{
  
  String name, conditionsCategory;
  int conditionsCategoryId;
  
  

  BillyConditions({
    super.id = 0,
    required this.name,
    required this.conditionsCategoryId,
    this.conditionsCategory="",
    super.createdAt,
    super.updatedAt,
  });

  // Convert BillyConditions object to JSON
  @override
Map<String, dynamic> toJson() {
    return {
      'name': name,
      'conditionsCategoryId': conditionsCategoryId,
    };
  }

    @override
List<dynamic> toTableRows(){
    return [id,name,conditionsCategory,createdAt];
  }

  // Create BillyConditions object from JSON
  factory BillyConditions.fromJson(Map<String, dynamic> json) {
    return BillyConditions(
      id: json['id'],
      name: json['name'],
      conditionsCategoryId: json['conditionsCategoryId'],
      conditionsCategory: json['conditionsCategory'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class BillyConditionCategory extends BaseModel{
  
  String name;
  
  

  BillyConditionCategory({
    super.id = 0,
    required this.name,
    super.createdAt,
    super.updatedAt,
  });

  // Convert BillyConditionCategory object to JSON
  @override
Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

      @override
List<dynamic> toTableRows(){
    return [id,name,createdAt];
  }

  // Create BillyConditionCategory object from JSON
  factory BillyConditionCategory.fromJson(Map<String, dynamic> json) {
    return BillyConditionCategory(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
