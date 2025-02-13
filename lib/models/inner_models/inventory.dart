import 'base_model.dart';

class Inventory extends BaseModel {
  int productId;
  int qty;
  String transactionType;
  String status;
  int supplierId;
  String supplier;
  int productCategoryId;
  String location;
  DateTime shelfLife;

  int productTypeId;
  String productType, productCategory, product;

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
    required this.shelfLife,
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
      'transactionType': transactionType,
      'status': status,
      'supplierId': supplierId,
      'productCategoryId': productCategoryId,
      'location': location,
      'shelfLife': shelfLife.toIso8601String(),
      'productTypeId': productTypeId,
    };
  }

  @override
  bool validate() {
    return productId != 0 && productCategoryId != 0 && qty != 0 && productTypeId != 0 && transactionType.isNotEmpty && status.isNotEmpty && location.isNotEmpty;
  }

  @override
  List<dynamic> toTableRows() {
    return [
      id,
      product,
      qty,
      status,
      transactionType,
      location,
      productType,
      productCategory,
      createdAt
    ];
  }

  // Create Inventory object from JSON
  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'] ?? 0,
      productId: json['productId'],
      product: json['product'] ?? "",
      qty: json['qty'],
      transactionType: json['transactionType'],
      status: json['status'],
      supplierId: json['supplierId'],
      supplier: json['supplier'] ?? "",
      productCategoryId: json['productCategoryId'],
      productCategory: json['productCategory'] ?? "",
      location: json['location'],
      shelfLife: DateTime.parse(json['shelfLife']),
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
      productTypeId: json['productTypeId'],
      productType: json['productType'] ?? "",
    );
  }
}
