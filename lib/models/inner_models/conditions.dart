class BillyConditions {
  int id;
  String name,conditionsCategory;
  int conditionsCategoryId;

  BillyConditions({
    required this.id,
    required this.name,
    required this.conditionsCategoryId,
    required this.conditionsCategory,
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
    );
  }
}

class BillyConditionCategory {
  int id;
  String name;

  BillyConditionCategory({
    required this.id,
    required this.name,
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
    );
  }
}