import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/tools/extensions.dart';
import '../../tools/service.dart';
import 'base_model.dart';

class Inventory extends BaseModel {
  int productId;
  double qty;
  String transactionType;
  String status;
  int supplierId;
  String supplier;
  int productCategoryId;
  String location;
  double cost, sellingPrice;
  int markup;
  // DateTime shelfLife;

  int productTypeId,stationId,locationId;
  String productType, productCategory, product,station;

  Inventory({
    super.id = 0,
    required this.productId,
    this.product = "",
    required this.qty,
    required this.transactionType,
    required this.status,
    this.supplier = "",
    required this.supplierId,
    required this.productCategoryId,
    this.productCategory = "",
    required this.location,
    this.cost = 0,
    this.markup=0,
    this.sellingPrice = 0,
    this.station="",
    this.locationId=0,
    this.stationId=0,
    // required this.shelfLife,
    super.createdAt,
    super.updatedAt,
    required this.productTypeId,
    this.productType = "",
  });

  // Convert Inventory object to JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'qty': qty,
      'transactionType': status,
      'status': status,
      'supplierId': supplierId,
      'productCategoryId': productCategoryId,
      
      'locationId': locationId,
      'cost': cost,
      "markup": markup,
      'sellingPrice': sellingPrice,
      "stationId": Get.find<AppService>().currentStation.value,
      // 'shelfLife': shelfLife.toString(),
      'productTypeId': productTypeId,
    };
  }

  @override
  bool validate() {
    return productId != 0 && status.isNotEmpty && stationId != 0 && locationId != 0;
  }

  @override
  List<dynamic> toTableRows() {
    return [
      id,
      product,
      qty,
      status,
      // transactionType,
      cost.toCurrency(),
      (cost*qty).toCurrency(),
      // productType,
      // productCategory,
      createdAt
    ];
  }

  @override
  List<dynamic> toExcelRows() {
    return [
      id,
      product,
      qty,
      status,
      // transactionType,
      cost.toCurrency(),
      (cost*qty).toCurrency(),
      supplier,
      markup,
      sellingPrice,
      location,
      // productType,
      // productCategory,
      createdAt
    ];
  }

  // Create Inventory object from JSON
  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'] ?? 0,
      productId: int.tryParse(json['productId'].toString()) ?? 0,
      product: json['product'] ?? "",
      qty: double.tryParse(json['qty'].toString()) ?? 0,
      transactionType: json['transactionType'],
      status: json['status'],
      supplierId: int.tryParse(json['supplierId'].toString()) ?? 0,
      supplier: json['supplier'] ?? "",
      productCategoryId:
          int.tryParse(json['productCategoryId'].toString()) ?? 0,
      productCategory: json['productCategory'] ?? "",
      location: json['locationName'] ?? "",
      markup: int.tryParse(json['markup'].toString()) ?? 0,
      cost: double.tryParse(json['cost'].toString()) ?? 0,
      sellingPrice: double.tryParse(json['sellingPrice'].toString()) ?? 0,
      // shelfLife: DateTime.parse(json['shelfLife']),
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
      productTypeId: int.tryParse(json['productTypeId'].toString()) ?? 0,
      productType: json['productType'] ?? "",
      station: json['station'] ?? "",
      stationId: int.tryParse(json['stationId'].toString()) ?? 0,
      locationId: int.tryParse(json['locationId'].toString()) ?? 0,
      
    );
  }
}

class InventoryMetricStockBalances extends UneditableModel {
  final String productName, location;
  final int productId;
  final double quantity;

  InventoryMetricStockBalances(
      {this.location = "",
      this.productId = 0,
      this.productName = "",
      this.quantity = 0});

  factory InventoryMetricStockBalances.fromJson(Map<String, dynamic> json) {
    return InventoryMetricStockBalances(
      location: json["location"] ?? "Store 1",
      productId: json["productId"] ?? 0,
      productName: json["productName"],
      quantity: double.tryParse(json['quantity'].toString()) ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  List toTableRows() {
    return [productName, quantity];
  }

    @override
  List toExcelRows() {
    return [productName, quantity];
  }

  @override
  bool validate() {
    return true;
  }
}

class InventoryMetricProductPrice {
  final String productName;
  final int productId;
  final double cost;

  InventoryMetricProductPrice(
      {this.productId = 0, this.productName = "", this.cost = 0});

  factory InventoryMetricProductPrice.fromJson(Map<String, dynamic> json) {
    return InventoryMetricProductPrice(
      productId: json["productId"] ?? 0,
      productName: json["productName"],
      cost: double.tryParse(json['lastCost'].toString()) ?? 0,
    );
  }
}

class InventoryMetricStockBalancesCost {
  final String productName, location;
  final int productId;
  double inboundQty, soldQty;
  double inboundCost, outboundSales, revenue;

  InventoryMetricStockBalancesCost({
    this.location = "",
    this.productId = 0,
    this.productName = "",
    this.inboundQty = 0,
    this.soldQty = 0,
    this.inboundCost = 0,
    this.outboundSales = 0,
    this.revenue = 0,
  });

  factory InventoryMetricStockBalancesCost.fromJson(Map<String, dynamic> json) {
    return InventoryMetricStockBalancesCost(
      location: json["location"],
      productId: json["productId"] ?? 0,
      productName: json["productName"],
      inboundQty: double.tryParse(json['inboundQty'].toString()) ?? 0,
      soldQty: double.tryParse(json['soldQty'].toString()) ?? 0,
      inboundCost: double.tryParse(json['inboundCost'].toString()) ?? 0,
      outboundSales: double.tryParse(json['outboundSales'].toString()) ?? 0,
      revenue: double.tryParse(json['revenue'].toString()) ?? 0,
    );
  }
}

class InventoryMetricDailyProfit extends UneditableModel {
  final DateTime date;
  final double productProfit,
      serviceProfit,
      laborProfit,
      productCost,
      totalProfit,
      expenses;

  double get sales => serviceProfit + laborProfit + productProfit;
  double get cost => expenses + productCost;
  double get profit => sales - cost;
  String get dateRaw => DateFormat("dd/MM/yyyy").format(date);

  InventoryMetricDailyProfit(
      {required this.date,
      this.productProfit = 0,
      this.serviceProfit = 0,
      this.expenses = 0,
      this.laborProfit = 0,
      this.productCost = 0,
      this.totalProfit = 0});

  factory InventoryMetricDailyProfit.fromJson(Map<String, dynamic> json) {
    return InventoryMetricDailyProfit(
      date: DateTime.parse(json["date"]).add(Duration(hours: 1)),
      productProfit: double.tryParse(json['productProfit'].toString()) ?? 0,
      serviceProfit: double.tryParse(json['serviceProfit'].toString()) ?? 0,
      laborProfit: double.tryParse(json['labor_profit'].toString()) ?? 0,
      productCost: double.tryParse(json['productCost'].toString()) ?? 0,
      totalProfit: double.tryParse(json['totalProfit'].toString()) ?? 0,
      expenses: double.tryParse(json['expenses'].toString()) ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  List toTableRows() {
    return [dateRaw,sales.toCurrency(),expenses.toCurrency(),productCost.toCurrency(),profit.toCurrency()];
  }

    @override
  List toExcelRows() {
    return [dateRaw,sales.toCurrency(),expenses.toCurrency(),productCost.toCurrency(),profit.toCurrency()];
  }

  @override
  bool validate() {
    return true;
  }
}

class InventoryMetricMonthlyProfit extends UneditableModel{
  final DateTime date;
  final double productProfit,
      serviceProfit,
      laborProfit,
      productCost,
      totalProfit,
      expenses;

  double get sales => serviceProfit + laborProfit + productProfit;
  double get cost => expenses + productCost;
  double get profit => sales - cost;
  String get dateRaw => DateFormat("dd/MM/yyyy hh:mm:ssa").format(date);

  InventoryMetricMonthlyProfit(
      {required this.date,
      this.productProfit = 0,
      this.serviceProfit = 0,
      this.expenses = 0,
      this.laborProfit = 0,
      this.productCost = 0,
      this.totalProfit = 0});

  factory InventoryMetricMonthlyProfit.fromJson(Map<String, dynamic> json) {
    return InventoryMetricMonthlyProfit(
      date: DateTime(json["year"], json["month"], 1),
      productProfit: double.tryParse(json['productProfit'].toString()) ?? 0,
      serviceProfit: double.tryParse(json['serviceProfit'].toString()) ?? 0,
      laborProfit: double.tryParse(json['labor_profit'].toString()) ?? 0,
      productCost: double.tryParse(json['productCost'].toString()) ?? 0,
      totalProfit: double.tryParse(json['totalProfit'].toString()) ?? 0,
      expenses: double.tryParse(json['expenses'].toString()) ?? 0,
    );
  }

    @override
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  List toTableRows() {
    return [dateRaw,sales,expenses,productCost,profit];
  }

    @override
  List toExcelRows() {
    return [dateRaw,sales,expenses,productCost,profit];
  }

  @override
  bool validate() {
    return true;
  }
}

class InventoryMetricYearlyProfit extends UneditableModel{
  final DateTime date;
  final double productProfit,
      serviceProfit,
      laborProfit,
      productCost,
      totalProfit,
      expenses;

  double get sales => serviceProfit + laborProfit + productProfit;
  double get cost => expenses + productCost;
  double get profit => sales - cost;
  String get dateRaw => DateFormat("dd/MM/yyyy hh:mm:ssa").format(date);

  InventoryMetricYearlyProfit(
      {required this.date,
      this.productProfit = 0,
      this.serviceProfit = 0,
      this.expenses = 0,
      this.laborProfit = 0,
      this.productCost = 0,
      this.totalProfit = 0});

  factory InventoryMetricYearlyProfit.fromJson(Map<String, dynamic> json) {
    return InventoryMetricYearlyProfit(
      date: DateTime(json["year"]),
      productProfit: double.tryParse(json['productProfit'].toString()) ?? 0,
      serviceProfit: double.tryParse(json['serviceProfit'].toString()) ?? 0,
      laborProfit: double.tryParse(json['labor_profit'].toString()) ?? 0,
      productCost: double.tryParse(json['productCost'].toString()) ?? 0,
      totalProfit: double.tryParse(json['totalProfit'].toString()) ?? 0,
      expenses: double.tryParse(json['expenses'].toString()) ?? 0,
    );
  }

    @override
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  List toTableRows() {
    return [dateRaw,sales,expenses,productCost,profit];
  }

    @override
  List toExcelRows() {
    return [dateRaw,sales,expenses,productCost,profit];
  }

  @override
  bool validate() {
    return true;
  }
}
