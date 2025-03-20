import 'dart:convert';
import 'package:get/get.dart';
import 'package:inventory/models/table_repo.dart';
import '../../tools/service.dart';

import 'base_model.dart';

class User extends BaseModel {
  String fullName;
  String username;
  String email;
  String signature;
  String role, station;
  int roleId, stationId;

  bool get isAdmin => role == "manager" || role == "superadmin";
  bool get isServiceAdvisor => isAdmin || role == "service-advisor";
  int get clockInCode => 100000 + id;

  User({
    super.id = 0,
    this.fullName = "",
    this.username = "",
    this.email = "",
    this.signature = "",
    this.role = "",
    this.station = "",
    this.roleId = 0,
    this.stationId = 0,
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
      'stationId': Get.find<AppService>().currentStation.value,
      'roleId': roleId
    };
  }

  @override
  List<dynamic> toTableRows() {
    return [id, fullName, username, clockInCode, role, createdAtRaw];
  }

  @override
  List<dynamic> toExcelRows() {
    return [id, fullName, username, clockInCode, email, role, createdAtRaw];
  }

  @override
  bool validate() {
    return fullName.isNotEmpty &&
        roleId != 0 &&
        username.isNotEmpty &&
        stationId != 0;
  }

  // Create User object from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      fullName: json['fullName'],
      username: json['username'],
      email: json['email'] ?? "",
      signature: json['signature'] ?? "",
      role: json['roleName'] ?? "",
      roleId: int.tryParse(json['roleId'].toString()) ?? 0,
      station: json['station'] ?? "",
      stationId: int.tryParse(json['stationId'].toString()) ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
    );
  }
}

class UserRole extends BaseModel {
  String name;
  late RxList<List<int>> perms; //[[0,1,0,1]]
  List<List<int>> permsRaw;

  UserRole({
    super.id = 0,
    this.name = "",
    this.permsRaw = const [],
    super.createdAt,
    super.updatedAt,
  }) {
    if (permsRaw.isEmpty) {
      perms = List.generate(AllTables.tablesType.length, (i) {
        return [0, 0, 0, 0];
      }).obs;
      permsRaw = List.from(perms);
    }else{
      perms = List<List<int>>.from(permsRaw).obs;
    }
  }

  // Convert UserRole object to JSON
  @override
  Map<String, dynamic> toJson() {
    final adf = jsonEncode(perms.map((f) => f.join("")).toList());
    return {'name': name, 'rolePermissions': adf};
  }

  @override
  List<dynamic> toTableRows() {
    return [id, name, createdAtRaw];
  }

  @override
  List<dynamic> toExcelRows() {
    return [id, name, createdAtRaw];
  }

  @override
  bool validate() {
    return name.isNotEmpty;
  }

  // Create UserRole object from JSON
  factory UserRole.fromJson(Map<String, dynamic> json) {
    final pm = List.from((json['rolePermissions'].runtimeType == String ? jsonDecode(json['rolePermissions']) : json['rolePermissions']) ?? []).map((e) => e.toString());
   
    return UserRole(
      id: json['id'] ?? 0,
      name: json['name'],
      permsRaw: pm
          .map((e) => e.split("").map((e) => int.tryParse(e) ?? 0).toList())
          .toList(),
      createdAt: DateTime.tryParse(json['createdAt'].toString()),
      updatedAt: DateTime.tryParse(json['updatedAt'].toString()),
    );
  }
}
