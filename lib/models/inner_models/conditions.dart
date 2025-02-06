class BillyConditions {
  int id;
  String name, conditionsCategory;
  int conditionsCategoryId;
  DateTime? createdAt;
  DateTime? updatedAt;

  BillyConditions({
    this.id = 0,
    required this.name,
    required this.conditionsCategoryId,
    this.conditionsCategory="",
    this.createdAt,
    this.updatedAt,
  });

  // Convert BillyConditions object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'conditionsCategoryId': conditionsCategoryId,
    };
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

class BillyConditionCategory {
  int id;
  String name;
  DateTime? createdAt;
  DateTime? updatedAt;

  BillyConditionCategory({
    this.id = 0,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  // Convert BillyConditionCategory object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
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
