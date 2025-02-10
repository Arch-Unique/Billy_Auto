import 'base_model.dart';

class Customer extends BaseModel {
  String email;
  String phone;
  String fullName;
  String signature;
  String customerType;
  String image;

  Customer({
    super.id = 0,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.signature,
    required this.customerType,
    this.image = "",
    super.createdAt,
    super.updatedAt,
  });

  // Convert Customer object to JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'fullName': fullName,
      'signature': signature,
      'customerType': customerType,
      'image': image,
    };
  }

  @override
  List<dynamic> toTableRows() {
    return [id, fullName, phone, email, customerType, createdAt];
  }

  // Create Customer object from JSON
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      fullName: json['fullName'],
      signature: json['signature'] ?? "",
      image: json['image'] ?? "",
      customerType: json['customerType'] ?? "Individual",
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
