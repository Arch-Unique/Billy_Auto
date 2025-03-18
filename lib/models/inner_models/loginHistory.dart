import 'package:intl/intl.dart';
import 'package:inventory/models/inner_models/base_model.dart';

class LoginHistory extends BaseModel{
  int userId;
  String username,device;
  DateTime? loggedOutDate;

  LoginHistory({
    super.id = 0,
  this.userId=0,
    this.username="",
    this.device="",
    this.loggedOutDate,
    super.createdAt,
    super.updatedAt,
  });

  String get loggedOutAtRaw => loggedOutDate == null ? "" : DateFormat("dd/MM/yyyy hh:mm:ssa").format(loggedOutDate!);

  // Convert LoginHistory object to JSON
  @override
Map<String, dynamic> toJson() {
    return {
      "userId":userId,
      "device":device,
    };
  }

      @override
List<dynamic> toTableRows(){
    return [id,username,device,createdAtRaw,loggedOutAtRaw];
  }

        @override
List<dynamic> toExcelRows(){
    return [id,username,device,createdAtRaw,loggedOutAtRaw];
  }

  @override
  bool validate() {
    return userId != 0;
  }

  // Create LoginHistory object from JSON
  factory LoginHistory.fromJson(Map<String, dynamic> json) {
    return LoginHistory(
      id: json['id'] ?? 0,
      username: json['username'] ?? "",
      userId: json['userId'] ?? 0,
      device: json['device'] ?? "mobile",
      loggedOutDate: DateTime.tryParse(json['loggedOutAt'] ?? ""),
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
    );
  }
}

class UserAttendance extends BaseModel{
  int userId;
  String username,imageIn,imageOut;
  DateTime? loggedOutDate;

  UserAttendance({
    super.id = 0,
  this.userId=0,
    this.username="",
    this.imageIn="",
    this.imageOut="",
    this.loggedOutDate,
    super.createdAt,
    super.updatedAt,
  });

  String get loggedOutAtRaw => loggedOutDate == null ? "" : DateFormat("dd/MM/yyyy hh:mm:ssa").format(loggedOutDate!);
  String get workHours => loggedOutDate == null ? "" : "${loggedOutDate!.difference(createdAt!).inHours}:${loggedOutDate!.difference(createdAt!).inMinutes}";

  // Convert UserAttendance object to JSON
  @override
Map<String, dynamic> toJson() {
    return {
      "userId":userId,
      "imageIn":imageIn,
      "imageOut":imageOut,
    };
  }

      @override
List<dynamic> toTableRows(){
    return [id,username,createdAtRaw,loggedOutAtRaw,workHours];
  }

        @override
List<dynamic> toExcelRows(){
    return [id,username,createdAtRaw,loggedOutAtRaw,workHours];
  }

  @override
  bool validate() {
    return userId != 0;
  }

  // Create UserAttendance object from JSON
  factory UserAttendance.fromJson(Map<String, dynamic> json) {
    return UserAttendance(
      id: json['id'] ?? 0,
      username: json['username'] ?? "",
      userId: int.tryParse((json['userId'] ?? 0).toString()) ?? 0,
      imageIn: json['imageIn'] ?? "",
      imageOut: json['imageOut'] ?? "",
      loggedOutDate: DateTime.tryParse(json['loggedOutAt'] ?? ""),
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
    );
  }
}
