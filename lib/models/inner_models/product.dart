import 'package:inventory/models/inner_models/base_model.dart';

class Product extends BaseModel{
  
  String name;
  double cost;
  double sellingPrice;
  int productCategoryId;
  String code;
  String image;
  
  
  int productTypeId,supplierId;
  String productCategory, productType;

  Product({
    super.id = 0,
    required this.name,
    required this.cost,
    required this.sellingPrice,
    required this.productCategoryId,
    required this.supplierId,
    this.productCategory="",
    this.code="",
    this.image="",
    super.createdAt,
    super.updatedAt,
    required this.productTypeId,
    this.productType="",
  });

  // Convert Product object to JSON
  @override
Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cost': cost,
      'sellingPrice': sellingPrice,
      'productCategoryId': productCategoryId,
      'code': code,
      'image': image,
      'supplierId': supplierId,
      'productTypeId': productTypeId,
    };
  }

      @override
List<dynamic> toTableRows(){
    return [id,name,code,cost,sellingPrice,productType,productCategory,createdAt];
  }

  @override
  bool validate() {
    return name.isNotEmpty && productCategoryId != 0 && productTypeId != 0 ;
  }

  // Create Product object from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'],
      cost: json['cost'],
      sellingPrice: json['sellingPrice'],
      productCategoryId: json['productCategoryId'],
      productCategory: json['productCategory'] ?? "",
      code: json['code'] ?? "",
      image: json['image'] ?? "",
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
      productTypeId: json['productTypeId'],
      supplierId: json['supplierId'],
      productType: json['productType'] ?? "",
    );
  }
}

class ProductType extends BaseModel{
  
  String name;
  String code;
  String image, productCategory;
  
  
  int productCategoryId;

  ProductType({
    super.id = 0,
    required this.name,
    required this.code,
    required this.image,
    super.createdAt,
    super.updatedAt,
    required this.productCategoryId,
    this.productCategory="",
  });

  // Convert ProductType object to JSON
  @override
Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'image': image,
      'productCategoryId': productCategoryId,
    };
  }

  @override
  bool validate() {
    return name.isNotEmpty && productCategoryId != 0;
  }

      @override
List<dynamic> toTableRows(){
    return [id,name,code,productCategory,createdAt];
  }

  // Create ProductType object from JSON
  factory ProductType.fromJson(Map<String, dynamic> json) {
    return ProductType(
      id: json['id'] ?? 0,
      name: json['name'],
      code: json['code'] ?? "",
      image: json['image'] ?? "",
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
      productCategoryId: json['productCategoryId'],
      productCategory: json['productCategory'] ?? "",
    );
  }
}

class ProductCategory extends BaseModel{
  
  String name;
  String code;
  String image;
  
  

  ProductCategory({
    super.id = 0,
    required this.name,
    required this.code,
    required this.image,
    super.createdAt,
    super.updatedAt,
  });

  // Convert ProductCategory object to JSON
  @override
Map<String, dynamic> toJson() {
    return {'name': name, 'code': code, 'image': image};
  }

      @override
List<dynamic> toTableRows(){
    return [id,name,code,createdAt];
  }

  @override
  bool validate() {
    return name.isNotEmpty;
  }

  // Create ProductCategory object from JSON
  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] ?? 0,
      name: json['name'],
      code: json['code'] ?? "",
      image: json['image'] ?? "",
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
    );
  }
}
