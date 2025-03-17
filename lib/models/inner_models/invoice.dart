import 'dart:convert';

import 'package:get/get.dart';
import 'package:inventory/models/inner_models/base_model.dart';
import 'package:inventory/repo/app_repo.dart';
import 'package:inventory/tools/extensions.dart';

class Invoice extends BaseModel {
  int orderId;
  double labourCost, totalCost;
  List<InvoiceItem> servicesUsed;
  List<InvoiceItem> productsUsed;
  DateTime? orderCreatedAt;

  String get title => "ORD-${orderId.toString().padLeft(4, "0")}";

  Invoice(
      {this.orderId = 0,
      this.labourCost = 0,
      this.totalCost = 0,
      this.productsUsed = const [],
      this.servicesUsed = const [],
      super.id = 0,
      super.createdAt,
      super.updatedAt}){
        orderCreatedAt = super.createdAt;
      }

  double get rawTotalCost =>
      labourCost +
      servicesUsed.map((e) => e.totalPrice).fold(0, (a, b) => a + b) +
      productsUsed.map((e) => e.totalPrice).fold(0, (a, b) => a + b);

  @override
  Map<String, dynamic> toJson() {
    final mp = {
      "orderId": orderId,
      "labourCost": labourCost,
      "totalCost": totalCost,
      "servicesUsed": jsonEncode(servicesUsed.map((e) => e.toJson()).toList()),
      "productUsed": jsonEncode(productsUsed.map((e) => e.toJson()).toList()),
    };
    if (orderCreatedAt != null) {
      mp["createdAt"] = orderCreatedAt!.toSQLDate();
    }
    return mp;
  }

  Map<String, dynamic> toRawJson() {
    return {
      "orderId": orderId,
      "labourCost": labourCost,
      "totalCost": totalCost,
      "servicesUsed": servicesUsed,
      "productUsed": productsUsed,
      "createdAt": orderCreatedAt?.toSQLDate() ?? ""
    };
  }

  @override
  List toTableRows() {
    return [
      id,
      title,
      labourCost.toCurrency(),
      totalCost.toCurrency(),
      createdAt
    ];
  }

    @override
  List toExcelRows() {
    return [
      id,
      title,
      labourCost.toCurrency(),
      totalCost.toCurrency(),
      createdAt
    ];
  }

  @override
  bool validate() {
    return orderId != 0 && !containsNull();
  }

  removeNullItems() {
    servicesUsed.removeWhere((test) =>
        test.rawId.value == 0 ||
        test.rawQty.value <= 0 ||
        test.rawUnitPrice.value <= 0);
    productsUsed.removeWhere((test) =>
        test.rawId.value == 0 ||
        test.rawQty.value <= 0 ||
        test.rawUnitPrice.value <= 0);
  }

  bool containsNull() {
    final a = servicesUsed.any((test) =>
        test.rawId.value == 0 ||
        test.rawQty.value <= 0 ||
        test.rawUnitPrice.value <= 0);
    final b = productsUsed.any((test) =>
        test.rawId.value == 0 ||
        test.rawQty.value <= 0 ||
        test.rawUnitPrice.value <= 0);
    return a || b;
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json["id"] ?? 0,
      orderId: json["orderId"] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? ""),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? ""),
      labourCost: double.parse((json['labourCost'] ?? 0).toString()),
      totalCost: double.parse((json['totalCost'] ?? 0).toString()),
      servicesUsed: json['servicesUsed'] != null
          ? List<InvoiceItem>.from((json['servicesUsed'] as List).map((x) =>
              x.runtimeType == InvoiceItem ? x : InvoiceItem.fromJson(x)))
          : [],
      productsUsed: json['productUsed'] != null
          ? List<InvoiceItem>.from((json['productUsed'] as List).map((x) =>
              x.runtimeType == InvoiceItem ? x : InvoiceItem.fromJson(x)))
          : [],
    );
  }
}

class InvoiceItem {
  int id, qty;
  double unitPrice;

  RxInt rawId = 0.obs, rawQty = 1.obs;
  RxDouble rawUnitPrice = 0.0.obs;

  double get totalPrice => rawQty.value * rawUnitPrice.value;

  InvoiceItem({this.id = 0, this.qty = 1, this.unitPrice = 0}) {
    rawId.value = id;
    rawQty.value = qty;
    rawUnitPrice.value = unitPrice;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": rawId.value,
      "qty": rawQty.value,
      "unitPrice": rawUnitPrice.value
    };
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: int.parse((json['id'] ?? 0).toString()),
      qty: int.parse((json['qty'] ?? 1).toString()),
      unitPrice: double.parse((json['unitPrice'] ?? 0).toString()),
    );
  }
}
