class Customer {
  int id;
  String email;
  String phone;
  String fullName;
  String signature;
  String customerType;
  DateTime? createdAt;
  DateTime? updatedAt;

  Customer({
    this.id = 0,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.signature,
    required this.customerType,
    this.createdAt,
    this.updatedAt,
  });

  // Convert Customer object to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'fullName': fullName,
      'signature': signature,
      'customerType': customerType,
    };
  }

  // Create Customer object from JSON
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      fullName: json['fullName'],
      signature: json['signature'] ?? "",
      customerType: json['customerType'] ?? "Individual",
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
