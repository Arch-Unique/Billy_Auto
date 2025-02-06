import 'package:flutter/material.dart';

import 'inner_models/barrel.dart';

class TableModel {
  List<String> headers;
  List<FilterModel> fm;

  TableModel(this.headers, this.fm);
}

class HeaderItem {
  String title;
  void Function()? vb;

  HeaderItem(this.title, {this.vb});
}

class FilterModel {
  /// 0 - string/dropdown
  /// 1 - date/daterange
  int filterType;
  String title, tableTitle;
  List<String>? options;
  DateTimeRange? dtr;
  TextEditingController? tec;
  int? id;

  FilterModel(this.title, this.tableTitle, this.filterType,
      {this.options, this.dtr, this.tec, this.id}) {
    dtr = DateTimeRange(start: DateTime(2000), end: DateTime.now());
    tec = TextEditingController();
    options = [];
    id = 0;
  }
}

class AllTables {
  static Map<Type, TableModel> tablesData = {
    User: TableModel([
      "id",
      "fullName",
      "username",
      "email",
      "role",
      "createdAt"
    ], [
      FilterModel("Role", "role", 0),
      FilterModel("Created At", "createdAt", 1)
    ]),
    Supplier: TableModel(
        ["id", "fullName", "email", "phone", "code", "createdAt"],
        [FilterModel("Created At", "createdAt", 1)]),
    BillyServices: TableModel(["id", "name", "createdAt"],
        [FilterModel("Created At", "createdAt", 1)]),
    CarMake: TableModel(["id", "make", "createdAt"],
        [FilterModel("Created At", "createdAt", 1)]),
    CarModels: TableModel([
      "id",
      "make",
      "model",
      "createdAt"
    ], [
      FilterModel("Car Brand", "makeId", 0),
      FilterModel("Created At", "createdAt", 1)
    ]),
    BillyConditionCategory: TableModel(["id", "name", "createdAt"],
        [FilterModel("Created At", "createdAt", 1)]),
    BillyConditions: TableModel([
      "id",
      "name",
      "conditionsCategory",
      "createdAt"
    ], [
      FilterModel("Conditions Category", "conditionsCategoryId", 0),
      FilterModel("Created At", "createdAt", 1)
    ]),
    Customer: TableModel([
      "id",
      "fullName",
      "phone",
      "email",
      "customerType",
      "createdAt"
    ], [
      FilterModel("Customer Type", "customerType", 0),
      FilterModel("Created At", "createdAt", 1)
    ]),
    CustomerCar: TableModel([
      "id",
      "make",
      "model",
      "year",
      "licenseNo",
      "customer",
      "createdAt"
    ], [
      FilterModel("Car Brand", "makeId", 0),
      FilterModel("Car Model", "modelId", 0),
      FilterModel("Customer", "customerId", 0),
      FilterModel("Created At", "createdAt", 1)
    ]),
    ProductCategory: TableModel(["id", "name", "code", "createdAt"],
        [FilterModel("Created At", "createdAt", 1)]),
    ProductType: TableModel([
      "id",
      "name",
      "code",
      "productCategory",
      "createdAt"
    ], [
      FilterModel("Product Category", "productCategoryId", 0),
      FilterModel("Created At", "createdAt", 1)
    ]),
    Product: TableModel([
      "id",
      "name",
      "code",
      "cost",
      "sellingPrice",
      "productType",
      "productCategory",
      "createdAt"
    ], [
      FilterModel("Product Type", "productTypeId", 0),
      FilterModel("Product Category", "productCategoryId", 0),
      FilterModel("Created At", "createdAt", 1)
    ]),
    Inventory: TableModel([
      "id",
      "product",
      "qty",
      "status",
      "transactionType",
      "location",
      "shelflife",
      "productType",
      "productCategory",
      "createdAt"
    ], [
      FilterModel("Product", "productId", 0),
      FilterModel("Status", "status", 0),
      FilterModel("Transaction Type", "transactionType", 0),
      FilterModel("Product Type", "productTypeId", 0),
      FilterModel("Product Category", "productCategoryId", 0),
      FilterModel("Shelf Life", "shelfLife", 1),
      FilterModel("Created At", "createdAt", 1)
    ]),
    Order: TableModel([
      "id",
      "customer",
      "car",
      "mileageOnReception",
      "fuelLevel",
      "createdAt"
    ], [
      FilterModel("Customer", "customerId", 0),
      FilterModel("Customer Car", "carId", 0),
      FilterModel("Created At", "createdAt", 1)
    ]),
  };
}
