import 'base_model.dart';

class Customer extends BaseModel {
  String email;
  String phone;
  String fullName;
  String signature;
  String customerType;

  Customer({
    super.id = 0,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.signature,
    required this.customerType,
    
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
      'customerType': customerType
    };
  }

     @override
  bool validate() {
    return fullName.isNotEmpty && customerType.isNotEmpty;
  }

  @override
  List<dynamic> toTableRows() {
    return [id, fullName, phone, email, customerType, createdAtRaw];
  }

  // Create Customer object from JSON
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      email: json['email'],
      phone: json['phone'],
      fullName: json['fullName'],
      signature: json['signature'] ?? "",
      
      customerType: json['customerType'] ?? "Individual",
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
    );
  }
}
