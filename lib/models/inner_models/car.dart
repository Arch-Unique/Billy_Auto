class CarMake {
  int id;
  String make;
  DateTime createdAt;
  DateTime updatedAt;

  CarMake({
    required this.id,
    required this.make,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert CarMake object to JSON
  Map<String, dynamic> toJson() {
    return {
      'make': make,
    };
  }

  // Create CarMake object from JSON
  factory CarMake.fromJson(Map<String, dynamic> json) {
    return CarMake(
      id: json['id'],
      make: json['make'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class CarModels {
  int id;
  int makeId;
  String model,make;
  DateTime createdAt;
  DateTime updatedAt;

  CarModels({
    required this.id,
    required this.makeId,
    required this.model,
    required this.make,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert CarModels object to JSON
  Map<String, dynamic> toJson() {
    return {
      'makeId': makeId,
      'model': model
    };
  }

  // Create CarModels object from JSON
  factory CarModels.fromJson(Map<String, dynamic> json) {
    return CarModels(
      id: json['id'],
      makeId: json['makeId'],
      make: json['make'],
      model: json['model'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}