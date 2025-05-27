import 'package:flutter/material.dart';
import 'package:inventory/models/inner_models/base_model.dart';
import 'package:inventory/models/inner_models/reports.dart';
import 'package:inventory/tools/extensions.dart';

import 'inner_models/barrel.dart';

class TableModel {
  List<String> headers;
  List<String> excelHeaders;
  List<FilterModel> fm;
  BaseModel bm;

  TableModel(this.headers, this.fm, this.bm, {this.excelHeaders = const []});
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
    dtr = dtr ?? DateTimeRange(start: DateTime(2025), end: DateTime.now());
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
  static List<Type> tablesType = [
    Reports,User,Supplier,BillyServices,CarMake,CarModels,BillyConditionCategory,BillyConditions,Customer,CustomerCar,ProductCategory,ProductType,Product,
    Inventory,Order,LoginHistory,UserAttendance,Invoice,ExpensesType,Expenses,BulkExpenses,InventoryMetricStockBalances,InventoryMetricDailyProfit,AppConstants,
    Locations,UserRole,Stations,LubeInventory
  ];
  static Map<Type, TableModel> tablesData = {
    Reports: TableModel([], [], Reports()),
    User: TableModel([
      "id",
      "fullName",
      "username",
      "clockinCode",
      "role",
      "createdAt"
    ], [
      FilterModel("Role", "roleId", 0),
      FilterModel("Date", "createdAt", 1),
    ], User(),excelHeaders: [
      "id",
      "fullName",
      "username",
      "clockinCode",
      "email",
      "role",
      "createdAt"
    ]),
    Supplier: TableModel([
      "id",
      "fullName",
      "email",
      "phone",
      "products",
      "createdAt"
    ], [
      FilterModel("Date", "createdAt", 1),
    ], Supplier(fullName: "", email: "", phone: "", address: "", products: "")),
    BillyServices: TableModel([
      "id",
      "name",
      "createdAt"
    ], [
      FilterModel("Date", "createdAt", 1),
    ], BillyServices(name: "", image: "")),
    CarMake: TableModel([
      "id",
      "make",
      "createdAt"
    ], [
      FilterModel("Date", "createdAt", 1),
    ], CarMake(make: "")),
    CarModels: TableModel([
      "id",
      "model",
      "make",
      "createdAt"
    ], [
      FilterModel("Car Brand", "makeId", 0),
      FilterModel("Date", "createdAt", 1),
    ], CarModels(makeId: 0, model: "")),
    BillyConditionCategory: TableModel([
      "id",
      "name",
      "createdAt"
    ], [
      FilterModel("Date", "createdAt", 1),
    ], BillyConditionCategory(name: "")),
    BillyConditions: TableModel([
      "id",
      "name",
      "category",
      "createdAt"
    ], [
      FilterModel("Conditions Category", "conditionsCategoryId", 0),
      FilterModel("Date", "createdAt", 1),
    ], BillyConditions(name: "", conditionsCategoryId: 0)),
    Customer: TableModel(
        [
          "id",
          "fullName",
          "phone",
          "email",
          "createdAt"
        ],
        [
          FilterModel("Customer Type", "customerType", 0),
          FilterModel("Date", "createdAt", 1),
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
          FilterModel("Date", "createdAt", 1),
        ],
        CustomerCar(
            makeId: 0, modelId: 0, year: "", licenseNo: "", customerId: 0)),
    ProductCategory: TableModel([
      "id",
      "name",
      "createdAt"
    ], [
      FilterModel("Date", "createdAt", 1),
    ], ProductCategory(name: "", code: "", image: "")),
    ProductType: TableModel([
      "id",
      "name",
      "category",
      "createdAt"
    ], [
      FilterModel("Product Category", "productCategoryId", 0),
      FilterModel("Date", "createdAt", 1),
    ], ProductType(name: "", code: "", image: "", productCategoryId: 0)),
    Product: TableModel(
        ["id", "name", "type", "sellingPrice", "createdAt"],
        [
          FilterModel("Product Type", "productTypeId", 0),
          FilterModel("Product Category", "productCategoryId", 0),
          FilterModel("Date", "createdAt", 1),
        ],
        Product(
          name: "",
          productCategoryId: 0,
          productTypeId: 0,
        ),
        excelHeaders: [
          "id",
          "name",
          "type",
          "cost",
          "markup",
          "sellingPrice",
          "createdAt"
        ]),
    Inventory: TableModel(
        [
          "id",
          "product",
          "qty",
          "status",
          "unit cost",
          "total cost",
          // "product Type",
          // "product Category",
          "createdAt"
        ],
        [
          FilterModel("Product", "productId", 0),
          // FilterModel("Status", "status", 0),
          FilterModel("Transaction Type", "transactionType", 0),
          FilterModel("Product Type", "productTypeId", 0),
          FilterModel("Product Category", "productCategoryId", 0),
          FilterModel("Date", "createdAt", 1),
        ],
        Inventory(
            productId: 0,
            qty: 0,
            transactionType: "",
            status: "",
            supplierId: 0,
            productCategoryId: 0,
            location: "store 1",
            // shelfLife: DateTime.now(),
            productTypeId: 0),
        excelHeaders: [
          "id",
          "product",
          "qty",
          "status",
          "unit cost",
          "total cost",
          "supplier",
          "markup",
          "unit selling price",
          "location",
          "createdAt"
        ]),



    Order: TableModel(
        ["id", "customer", "car", "status", "createdAt"],
        [
          FilterModel("Customer", "customerId", 0),
          FilterModel("Customer Car", "carId", 0),
          FilterModel("Date", "createdAt", 1),
        ],
        Order(customerId: 0),
        excelHeaders: [
          "id",
          "customer",
          "car",
          "mileageOnReception",
          "fuelLevel",
          "customerConcerns",
          "observations",
          "lostSales",
          "technician",
          "serviceAdvisor",
          "status",
          "createdAt"
        ]),
    LoginHistory: TableModel(
      ["id", "username", "device", "loggedIn", "loggedOut"],
      [
        FilterModel("User", "userId", 0),
        FilterModel("Device", "device", 0),
        FilterModel("Date", "createdAt", 1),
      ],
      LoginHistory(),
    ),
    UserAttendance: TableModel(
      ["id", "username", "clockedIn", "clockedOut","workHours (hh:mm)"],
      [
        FilterModel("User", "userId", 0),
        FilterModel("Date", "createdAt", 1),
      ],
      UserAttendance(),
    ),
    Invoice: TableModel(
      ["id", "order", "labourCost", "totalCost", "createdAt"],
      [
        FilterModel("Date", "createdAt", 1),
      ],
      Invoice(productsUsed: [], servicesUsed: []),
    ),
    ExpensesType: TableModel(
      ["id", "name", "category", "createdAt"],
      [
        FilterModel("Date", "createdAt", 1),
      ],
      ExpensesType(name: "", code: ""),
    ),
    Expenses: TableModel(
      ["id", "expensesType", "expensesCategory", "cost", "createdAt"],
      [
        FilterModel("Date", "createdAt", 1),
        FilterModel("Expenses Type", "expensesTypeId", 0),
        FilterModel("Expenses Category", "expensesCategoryId", 0),
      ],
      Expenses(),
    ),
    BulkExpenses: TableModel(
      [
        "id",
        "date",
        "expenses",
        "totalCost",
      ],
      [
        FilterModel("Date", "createdAt", 1),
        FilterModel("Expenses", "expensesTypeId", 0),
      ],
      BulkExpenses(date: DateTime.now()),
    ),
    InventoryMetricStockBalances:
        TableModel(["product", "quantity"], [], InventoryMetricStockBalances()),
    InventoryMetricDailyProfit: TableModel(
        ["date", "revenue", "expenses", "productCost", "profit"],
        [],
        InventoryMetricDailyProfit(date: DateTime.now())),
    AppConstants: TableModel(["product"], [], AppConstants()),
    Locations: TableModel([
      "id","name","station","createdAt"
    ], [FilterModel("Station", "stationId", 0),FilterModel("Date", "createdAt", 1),], Locations()),
    UserRole: TableModel([
      "id","name","createdAt"
    ], [FilterModel("Date", "createdAt", 1),], UserRole()),
    Stations: TableModel([
      "id","name","address","email","phone","createdAt"
    ], [FilterModel("Date", "createdAt", 1),], Stations())
  ,LubeInventory: TableModel(
        [
          "id",
          "product",
          "qty",
          "status",
          "unit cost",
          "total cost",
          // "product Type",
          // "product Category",
          "createdAt"
        ],
        [
          FilterModel("Transaction Type", "transactionType", 0),
          FilterModel("Date", "createdAt", 1),
        ],
        LubeInventory(
            productId: 0,
            qty: 0,
            transactionType: "",
            status: "",
            supplierId: 0,
            productCategoryId: 0,
            location: "store 1",
            // shelfLife: DateTime.now(),
            productTypeId: 0),
        excelHeaders: [
          "id",
          "product",
          "qty",
          "status",
          "unit cost",
          "total cost",
          "supplier",
          "markup",
          "unit selling price",
          "location",
          "createdAt"
        ]),
  };
  
}
