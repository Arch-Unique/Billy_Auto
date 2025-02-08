import 'package:inventory/models/inner_models/base_model.dart';

class Supplier extends BaseModel{
  
  String fullName;
  String email;
  String phone;
  String address;
  String code;
  
  

  Supplier({
    super.id = 0,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.code,
    super.createdAt,
    super.updatedAt,
  });

  // Convert Supplier object to JSON
  @override
Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'code': code
    };
  }

      @override
List<dynamic> toTableRows(){
    return [id,fullName,email,phone,code,createdAt];
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
