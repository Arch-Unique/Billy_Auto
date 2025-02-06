class User {
  int id;
  String fullName;
  String username;
  String email;
  String signature;
  String role;
  DateTime? createdAt;
  DateTime? updatedAt;

  User({
    this.id=0,
    this.fullName="",
    this.username="",
    this.email="",
    this.signature="",
    this.role="",
    this.createdAt,
    this.updatedAt,
  });

  // Convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'username': username,
      'email': email,
      'signature': signature,
      'role': role
    };
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