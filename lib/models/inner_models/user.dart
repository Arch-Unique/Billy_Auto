import 'base_model.dart';

class User extends BaseModel{
  
  String fullName;
  String username;
  String email;
  String signature;
  String role;
  
  bool get isAdmin => role == "admin";
  bool get isServiceAdvisor => isAdmin || role == "service-advisor";

  User({
    super.id=0,
    this.fullName="",
    this.username="",
    this.email="",
    this.signature="",
    this.role="",
    super.createdAt,
    super.updatedAt,
  });

  // Convert User object to JSON
  @override
Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'username': username,
      'email': email,
      'signature': signature,
      'role': role
    };
  }

      @override
List<dynamic> toTableRows(){
    return [id,fullName,username,email,role,createdAtRaw];
  }

        @override
List<dynamic> toExcelRows(){
    return [id,fullName,username,email,role,createdAtRaw];
  }

  @override
  bool validate() {
    return fullName.isNotEmpty && role.isNotEmpty && username.isNotEmpty;
  }

  // Create User object from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      fullName: json['fullName'],
      username: json['username'],
      email: json['email'] ?? "",
      signature: json['signature'] ?? "",
      role: json['role'] ?? "user", //admin,technician,customer-support,service-advisor,user
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
    );
  }
}