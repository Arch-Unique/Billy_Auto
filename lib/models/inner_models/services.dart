class BillyServices {
  int id;
  String name;
  String image;
  DateTime? createdAt;
  DateTime? updatedAt;

  BillyServices({
    this.id = 0,
    required this.name,
    required this.image,
    this.createdAt,
    this.updatedAt,
  });

  // Convert Services object to JSON
  Map<String, dynamic> toJson() {
    return {'name': name, 'image': image};
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
