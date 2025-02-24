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
    return [id,name,conditionsCategory,createdAtRaw];
  }

    @override
  bool validate() {
    return conditionsCategoryId != 0 && name.isNotEmpty;
  }

  // Create BillyConditions object from JSON
  factory BillyConditions.fromJson(Map<String, dynamic> json) {
    return BillyConditions(
      id: json['id'] ?? 0,
      name: json['name'],
      conditionsCategoryId: int.tryParse(json['conditionsCategoryId'].toString()) ?? 0,
      conditionsCategory: json['conditionsCategory'] ?? "",
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
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
    return [id,name,createdAtRaw];
  }

   @override
  bool validate() {
    return name.isNotEmpty;
  }

  // Create BillyConditionCategory object from JSON
  factory BillyConditionCategory.fromJson(Map<String, dynamic> json) {
    return BillyConditionCategory(
      id: json['id'] ?? 0,
      name: json['name'],
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
    );
  }
}
