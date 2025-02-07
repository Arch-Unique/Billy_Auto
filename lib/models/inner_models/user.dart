class User {
  
  String fullName;
  String username;
  String email;
  String signature;
  String role;
  
  

  User({
    this.id=0,
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
    return [id,fullName,username,email,role,createdAt];
  }

  // Create User object from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'],
      username: json['username'],
      email: json['email'] ?? "",
      signature: json['signature'] ?? "",
      role: json['role'] ?? "user", //admin,technician,customer-support,service-advisor,user
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}