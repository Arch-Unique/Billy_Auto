import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/models/inner_models/base_model.dart';
import 'package:inventory/tools/extensions.dart';

class Expenses extends BaseModel {
  int expensesTypeId;
  double cost;
  String expensesType,expensesCategoryId;
  RxDouble rawCost=0.0.obs;

  Expenses({
    super.id = 0,
    this.cost = 0,
    this.expensesTypeId = 0,
    super.createdAt,
    super.updatedAt,
    this.expensesType = "",
    this.expensesCategoryId = "OPEX",
  }) {
    rawCost.value = cost;
  }

  // Convert Product object to JSON
  @override
  Map<String, dynamic> toJson() {
    return {'expensesTypeId': expensesTypeId, 'cost': rawCost.value,'expensesCategoryId':expensesCategoryId};
  }

  @override
  List<dynamic> toTableRows() {
    return [id, expensesType,expensesCategoryId, cost.toCurrency(), createdAtRaw];
  }

  @override
  bool validate() {
    return cost != 0 && expensesTypeId != 0 && expensesCategoryId != "";
  }

  // Create Product object from JSON
  factory Expenses.fromJson(Map<String, dynamic> json) {
    return Expenses(
      id: json['id'] ?? 0,
      expensesType: json['expensesType'] ?? "",
      expensesCategoryId: json['expensesCategoryId'] ?? "OPEX",
      expensesTypeId: int.tryParse(json['expensesTypeId'].toString()) ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
      cost: double.tryParse(json['cost'].toString()) ?? 0,
    );
  }
}

class ExpensesType extends BaseModel {
  String name;
  String code,category;

  ExpensesType({
    super.id = 0,
    required this.name,
    required this.code,
    this.category="OPEX",
    super.createdAt,
    super.updatedAt,
  });

  // Convert ExpensesType object to JSON
  @override
  Map<String, dynamic> toJson() {
    return {'name': name,'category':category};
  }

  @override
  List<dynamic> toTableRows() {
    return [id, name, category, createdAtRaw];
  }

  @override
  bool validate() {
    return name.isNotEmpty && category.isNotEmpty;
  }

  // Create ExpensesType object from JSON
  factory ExpensesType.fromJson(Map<String, dynamic> json) {
    return ExpensesType(
      id: json['id'] ?? 0,
      name: json['name'],
      category: json['category'] ?? "OPEX",
      code: json['code'] ?? "",
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
    );
  }
}

class BulkExpenses extends BaseModel {
  DateTime date;
  double totalCost;
  String rawExpenses;
  String rawExpensesId;
  List<String> get expenseTypes => rawExpenses.split(", ");
  List<int> get expenseTypeIds =>
      rawExpensesId.split(", ").map((e) => int.tryParse(e) ?? 0).toList();
  String get dateRaw =>
      DateFormat("dd/MM/yyyy hh:mm:ssa").format(createdAt ?? DateTime.now());

  List<Expenses> expenses = [];
  double get rawTotalCost =>
      expenses.map((e) => e.rawCost.value).fold(0, (a, b) => a + b);

  BulkExpenses({
    required this.date,
    this.totalCost = 0,
    this.rawExpenses = "",
    this.rawExpensesId = "",
    super.id = 0,
  });

  @override
  Map<String, dynamic> toJson() {
    print(expenses.map((e) => e.toJson()).toList());
    return {"data": expenses.map((e) => e.toJson()).toList()};
  }

  @override
  List toTableRows() {
    return [id,DateFormat("dd-MMM-yyyy").format(date), rawExpenses, totalCost.toCurrency()];
  }

  @override
  bool validate() {
    return expenses.isNotEmpty &&
        !expenses.any((test) => test.rawCost.value <= 0 || test.expensesTypeId <= 0);
  }

  factory BulkExpenses.fromJson(Map<String, dynamic> json) {
    return BulkExpenses(
      id: json["id"] ?? 0,
        rawExpensesId: json['expensesTypeId'] ?? "",
        rawExpenses: json['expensesTypes'] ?? "",
        totalCost: double.tryParse(json['totalCost'].toString()) ?? 0,
        date: DateTime.parse(json['date']));
  }
}
