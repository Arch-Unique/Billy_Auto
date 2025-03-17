import 'package:inventory/models/inner_models/base_model.dart';

class Supplier extends BaseModel{
  
  String fullName;
  String email;
  String phone;
  String address;
  String products;
  
  

  Supplier({
    super.id = 0,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.products,
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
      'products': products
    };
  }

      @override
List<dynamic> toTableRows(){
    return [id,fullName,email,phone,products,createdAtRaw];
  }

        @override
List<dynamic> toExcelRows(){
    return [id,fullName,email,phone,products,createdAtRaw];
  }

  @override
  bool validate() {
    return fullName.isNotEmpty;
  }

  // Create Supplier object from JSON
  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] ?? 0,
      fullName: json['fullName'],
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
      address: json['address'] ?? "",
      products: json['products'] ?? "",
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
    );
  }
}
