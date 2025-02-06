class Supplier {
  int id;
  String fullName;
  String email;
  String phone;
  String address;
  String code;
  DateTime? createdAt;
  DateTime? updatedAt;

  Supplier({
    this.id = 0,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.code,
    this.createdAt,
    this.updatedAt,
  });

  // Convert Supplier object to JSON
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'code': code
    };
  }

  // Create Supplier object from JSON
  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
      address: json['address'] ?? "",
      code: json['code'] ?? "",
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
