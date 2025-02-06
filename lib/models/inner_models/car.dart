class CarMake {
  int id;
  String make;
  DateTime? createdAt;
  DateTime? updatedAt;

  CarMake({
    this.id = 0,
    required this.make,
    this.createdAt,
    this.updatedAt,
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
  String model, make;
  DateTime? createdAt;
  DateTime? updatedAt;

  CarModels({
    this.id = 0,
    required this.makeId,
    required this.model,
    this.make="",
    this.createdAt,
    this.updatedAt,
  });

  // Convert CarModels object to JSON
  Map<String, dynamic> toJson() {
    return {'makeId': makeId, 'model': model};
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
