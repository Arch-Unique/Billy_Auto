import 'package:intl/intl.dart';

abstract class BaseModel {
  int id;
  DateTime? createdAt;
  DateTime? updatedAt;

  String get createdAtRaw => DateFormat("dd/MM/yyyy hh:mm:ss").format(createdAt ?? DateTime.now());

  BaseModel({
    this.id = 0,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson();
  List<dynamic> toTableRows();
  bool validate();

  factory BaseModel.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }
}
