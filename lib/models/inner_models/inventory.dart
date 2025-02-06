class Inventory {
  int id;
  int productId;
  int qty;
  String transactionType;
  String status;
  int supplierId;
  String supplier;
  int productCategoryId;
  String location;
  DateTime shelfLife;
  DateTime createdAt;
  DateTime updatedAt;
  int productTypeId;
  String productType,productCategory,product;

  Inventory({
    required this.id,
    required this.productId,
    required this.product,
    required this.qty,
    required this.transactionType,
    required this.status,
    required this.supplier,
    required this.supplierId,
    required this.productCategoryId,
    required this.productCategory,
    required this.location,
    required this.shelfLife,
    required this.createdAt,
    required this.updatedAt,
    required this.productTypeId,
    required this.productType,
  });

  // Convert Inventory object to JSON
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

  // Create Inventory object from JSON
  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'],
      productId: json['productId'],
      product: json['product'],
      qty: json['qty'],
      transactionType: json['transactionType'],
      status: json['status'],
      supplierId: json['supplierId'],
      supplier: json['supplier'],
      productCategoryId: json['productCategoryId'],
      productCategory: json['productCategory'],
      location: json['location'],
      shelfLife: DateTime.parse(json['shelfLife']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      productTypeId: json['productTypeId'],
      productType: json['productType'],
    );
  }
}