import 'package:intl/intl.dart';

abstract class BaseModel {
  int id;
  DateTime? createdAt;
  DateTime? updatedAt;

  String get createdAtRaw => DateFormat("dd/MM/yyyy\nhh:mm:ssa").format(createdAt ?? DateTime.now());
  String get updatedAtRaw => DateFormat("dd/MM/yyyy\nhh:mm:ssa").format(updatedAt ?? DateTime.now());

  BaseModel({
    this.id = 0,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson();
  List<dynamic> toTableRows();
  List<dynamic> toExcelRows();
  bool validate();

  factory BaseModel.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }
}

abstract class UneditableModel extends BaseModel {
  
}