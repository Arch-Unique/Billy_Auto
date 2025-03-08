import 'package:flutter/material.dart';
import 'package:inventory/models/inner_models/base_model.dart';

import 'inner_models/barrel.dart';

class TableModel {
  List<String> headers;
  List<FilterModel> fm;
  BaseModel bm;

  TableModel(this.headers, this.fm, this.bm);
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
  FilterOptionsModel? options;
  DateTimeRange? dtr;
  TextEditingController? tec;
  int? id;

  FilterModel(this.title, this.tableTitle, this.filterType,
      {this.options, this.dtr, this.tec, this.id}) {
    dtr = dtr ?? DateTimeRange(start: DateTime(2000), end: DateTime.now());
    tec = tec ?? TextEditingController();
    options = options ?? FilterOptionsModel(["None"], [0]);
    id = id ?? 0;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "$title ${tec?.text}";
  }
}

class FilterOptionsModel {
  List<String> titles;
  List<dynamic> values;

  FilterOptionsModel(this.titles, this.values) {
  
    // if (!titles.contains("None")) {
    //   titles.insert(0, "None");
    //   values.insert(0, values.isEmpty ? 0: (values[0].runtimeType == int ? 0 : ""));
    // }
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
      
    ], User()),
    Supplier: TableModel(
        ["id", "fullName", "email", "phone", "code", "createdAt"],
        [],
        Supplier(fullName: "", email: "", phone: "", address: "", code: "")),
    BillyServices: TableModel(
        ["id", "name", "createdAt"],
        [],
        BillyServices(name: "", image: "")),
    CarMake: TableModel(["id", "make", "createdAt"],
        [], CarMake(make: "")),
    CarModels: TableModel([
      "id",
      "model",
      "make",
      "createdAt"
    ], [
      FilterModel("Car Brand", "makeId", 0),
      
    ], CarModels(makeId: 0, model: "")),
    BillyConditionCategory: TableModel(
        ["id", "name", "createdAt"],
        [],
        BillyConditionCategory(name: "")),
    BillyConditions: TableModel([
      "id",
      "name",
      "category",
      "createdAt"
    ], [
      FilterModel("Conditions Category", "conditionsCategoryId", 0),
      
    ], BillyConditions(name: "", conditionsCategoryId: 0)),
    Customer: TableModel(
        [
          "id",
          "fullName",
          "phone",
          "email",
          "customerType",
          "createdAt"
        ],
        [
          FilterModel("Customer Type", "customerType", 0),
          
        ],
        Customer(
            email: "",
            phone: "",
            fullName: "",
            signature: "",
            customerType: "")),
    CustomerCar: TableModel(
        [
          "id",
          "make",
          "model",
          "year",
          "licenseNo",
          "customer",
          "createdAt"
        ],
        [
          FilterModel("Car Brand", "makeId", 0),
          FilterModel("Car Model", "modelId", 0),
          FilterModel("Customer", "customerId", 0),
          
        ],
        CustomerCar(
            makeId: 0, modelId: 0, year: "", licenseNo: "", customerId: 0)),
    ProductCategory: TableModel(
        ["id", "name", "code", "createdAt"],
        [],
        ProductCategory(name: "", code: "", image: "")),
    ProductType: TableModel([
      "id",
      "name",
      "code",
      "category",
      "createdAt"
    ], [
      FilterModel("Product Category", "productCategoryId", 0),
      
    ], ProductType(name: "", code: "", image: "", productCategoryId: 0)),
    Product: TableModel(
        [
          "id",
          "name",
          "code",
          "type",
          "category",
          "createdAt"
        ],
        [
          FilterModel("Product Type", "productTypeId", 0),
          FilterModel("Product Category", "productCategoryId", 0),
          
        ],
        Product(
            name: "",
            productCategoryId: 0,
            productTypeId: 0,)),
    Inventory: TableModel(
        [
          "id",
          "product",
          "qty",
          "status",
          "location",
          // "product Type",
          // "product Category",
          "createdAt"
        ],
        [
          FilterModel("Product", "productId", 0),
          FilterModel("Status", "status", 0),
          FilterModel("Transaction Type", "transactionType", 0),
          FilterModel("Product Type", "productTypeId", 0),
          FilterModel("Product Category", "productCategoryId", 0),
          
        ],
        Inventory(
            productId: 0,
            qty: 0,
            transactionType: "",
            status: "",
            supplierId: 0,
            productCategoryId: 0,
            location: "",
            // shelfLife: DateTime.now(),
            productTypeId: 0)),
    Order: TableModel([
      "id",
      "customer",
      "car",
      "status",
      "createdAt"
    ], [
      FilterModel("Customer", "customerId", 0),
      FilterModel("Customer Car", "carId", 0),
      
    ], Order(customerId: 0),),
     LoginHistory: TableModel([
      "id",
      "username",
      "device",
      "loggedIn",
      "loggedOut"
    ], [
      FilterModel("User", "userId", 0),
      FilterModel("Device", "device", 0),
      
    ], LoginHistory(),),
     Invoice: TableModel([
      "id",
      "order",
      "labourCost",
      "totalCost",
      "createdAt"
    ], [
      
    ], Invoice(productsUsed: [], servicesUsed: []),),

    ExpensesType: TableModel([
      "id",
      "name",
      "code",
      "createdAt"
    ], [
      
    ], ExpensesType(name: "",code: ""),),
    Expenses: TableModel([
      "id",
      "expensesType",
      "cost",
      "createdAt"
    ], [
      
      FilterModel("Expenses", "expensesTypeId", 0),
    ], Expenses(),),
    BulkExpenses: TableModel([
      "id",
      "date",
      "expenses",
      "totalCost",
    ], [
      
      FilterModel("Expenses", "expensesTypeId", 0),
    ], BulkExpenses(date: DateTime.now()),),
  };
}
