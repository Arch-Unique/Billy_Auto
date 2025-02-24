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
  // DateTime shelfLife;

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
      'transactionType': transactionType,
      'status': status,
      'supplierId': supplierId,
      'productCategoryId': productCategoryId,
      'location': location,
      // 'shelfLife': shelfLife.toIso8601String(),
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
      productId: int.tryParse(json['productId'].toString()) ?? 0,
      product: json['product'] ?? "",
      qty: int.tryParse(json['qty'].toString()) ?? 0,
      transactionType: json['transactionType'],
      status: json['status'],
      supplierId: int.tryParse(json['supplierId'].toString()) ?? 0,
      supplier: json['supplier'] ?? "",
      productCategoryId: int.tryParse(json['productCategoryId'].toString()) ?? 0,
      productCategory: json['productCategory'] ?? "",
      location: json['location'],
      // shelfLife: DateTime.parse(json['shelfLife']),
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
      productTypeId: int.tryParse(json['productTypeId'].toString()) ?? 0,
      productType: json['productType'] ?? "",
    );
  }
}
