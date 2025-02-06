class Product {
  int id;
  String name;
  double cost;
  double sellingPrice;
  int productCategoryId;
  String code;
  String image;
  DateTime? createdAt;
  DateTime? updatedAt;
  int productTypeId;
  String productCategory, productType;

  Product({
    this.id = 0,
    required this.name,
    required this.cost,
    required this.sellingPrice,
    required this.productCategoryId,
    this.productCategory="",
    this.code="",
    this.image="",
    this.createdAt,
    this.updatedAt,
    required this.productTypeId,
    this.productType="",
  });

  // Convert Product object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cost': cost,
      'sellingPrice': sellingPrice,
      'productCategoryId': productCategoryId,
      'code': code,
      'image': image,
      'productTypeId': productTypeId,
    };
  }

  // Create Product object from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      cost: json['cost'],
      sellingPrice: json['sellingPrice'],
      productCategoryId: json['productCategoryId'],
      productCategory: json['productCategory'],
      code: json['code'] ?? "",
      image: json['image'] ?? "",
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      productTypeId: json['productTypeId'],
      productType: json['productType'],
    );
  }
}

class ProductType {
  int id;
  String name;
  String code;
  String image, productCategory;
  DateTime? createdAt;
  DateTime? updatedAt;
  int productCategoryId;

  ProductType({
    this.id = 0,
    required this.name,
    required this.code,
    required this.image,
    this.createdAt,
    this.updatedAt,
    required this.productCategoryId,
    this.productCategory="",
  });

  // Convert ProductType object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'image': image,
      'productCategoryId': productCategoryId,
    };
  }

  // Create ProductType object from JSON
  factory ProductType.fromJson(Map<String, dynamic> json) {
    return ProductType(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      image: json['image'] ?? "",
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      productCategoryId: json['productCategoryId'],
      productCategory: json['productCategory'],
    );
  }
}

class ProductCategory {
  int id;
  String name;
  String code;
  String image;
  DateTime? createdAt;
  DateTime? updatedAt;

  ProductCategory({
    this.id = 0,
    required this.name,
    required this.code,
    required this.image,
    this.createdAt,
    this.updatedAt,
  });

  // Convert ProductCategory object to JSON
  Map<String, dynamic> toJson() {
    return {'name': name, 'code': code, 'image': image};
  }

  // Create ProductCategory object from JSON
  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      image: json['image'] ?? "",
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
