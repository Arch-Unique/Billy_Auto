class Product {
  int id;
  String name;
  double cost;
  double sellingPrice;
  int productCategoryId;
  String code;
  String image;
  DateTime createdAt;
  DateTime updatedAt;
  int productTypeId;
  String productCategory,productType;

  Product({
    required this.id,
    required this.name,
    required this.cost,
    required this.sellingPrice,
    required this.productCategoryId,
    required this.productCategory,
    required this.code,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.productTypeId,
    required this.productType,
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
      code: json['code'],
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
  String image,productCategory;
  DateTime createdAt;
  DateTime updatedAt;
  int productCategoryId;

  ProductType({
    required this.id,
    required this.name,
    required this.code,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.productCategoryId,
    required this.productCategory,
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
  DateTime createdAt;
  DateTime updatedAt;

  ProductCategory({
    required this.id,
    required this.name,
    required this.code,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert ProductCategory object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'image': image
    };
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