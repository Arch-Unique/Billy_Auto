import 'dart:convert';

import 'package:get/get.dart';
import 'package:inventory/tools/extensions.dart';

import '../models/inner_models/barrel.dart';
import '../models/table_repo.dart';
import '../tools/service.dart';
import '../tools/urls.dart';

typedef FromJsonFactory<T> = T Function(Map<String, dynamic>);

class JsonParser {
  static List<T> parseList<T>(
      dynamic response, FromJsonFactory<dynamic> fromJson) {
    if (!(response.statusCode! as int).isSuccess()) {
      return <T>[];
    }
    final data = response.data["data"] as List<dynamic>;
    if (data.isEmpty) return <T>[];
    return data
        .map((item) => fromJson(item as Map<String, dynamic>) as T)
        .toList();
  }

  static T? parse<T>(dynamic response, FromJsonFactory<dynamic> fromJson) {
    if (!(response.statusCode! as int).isSuccess()) {
      return null;
    }
    return fromJson(response.data["data"] as Map<String, dynamic>) as T;
  }
}

class AppRepo extends GetxController {
  final apiService = Get.find<DioApiService>();
  final prefService = Get.find<MyPrefService>();

  final Map<Type, FromJsonFactory> factories = {
    User: User.fromJson,
    CarMake: CarMake.fromJson,
    CarModels: CarModels.fromJson,
    Customer: Customer.fromJson,
    CustomerCar: CustomerCar.fromJson,
    Supplier: Supplier.fromJson,
    Order: Order.fromJson,
    Inventory: Inventory.fromJson,
    Product: Product.fromJson,
    ProductType: ProductType.fromJson,
    ProductCategory: ProductCategory.fromJson,
    BillyConditions: ProductCategory.fromJson,
    BillyConditionCategory: BillyConditionCategory.fromJson,
    BillyServices: BillyServices.fromJson
  };

  final Map<Type, String> urls = {
    User: AppUrls.user,
    CarMake: AppUrls.carMake,
    CarModels: AppUrls.carModel,
    Customer: AppUrls.customer,
    CustomerCar: AppUrls.customerCar,
    Supplier: AppUrls.supplier,
    Order: AppUrls.order,
    Inventory: AppUrls.inventory,
    Product: AppUrls.product,
    ProductType: AppUrls.productType,
    ProductCategory: AppUrls.productCategory,
    BillyConditions: AppUrls.condition,
    BillyConditionCategory: AppUrls.conditionCategory,
    BillyServices: AppUrls.service
  };

  List<T> getListOf<T>(dynamic res) {
    return JsonParser.parseList<T>(res, factories[T]!);
  }

  T? getOf<T>(dynamic res) {
    return JsonParser.parse<T>(res, factories[T]!);
  }

  Future<String> create<T>(Map<String, dynamic> data) async {
    final res = await apiService.post(urls[T]!, data: data);
    if (!res.statusCode!.isSuccess()) {
      throw res.data["error"];
    }
    return res.data["data"];
  }

  Future<String> patch<T>(String id, Map<String, dynamic> data) async {
    final res = await apiService.patch("${urls[T]!}/$id", data: data);
    if (!res.statusCode!.isSuccess()) {
      throw res.data["error"];
    }
    return res.data["data"];
  }

  Future<T?> getOne<T>(String id) async {
    final res = await apiService.get("${urls[T]!}/$id");
    return getOf<T>(res);
  }

  Future<List<T>> getAll<T>(
      {List<FilterModel> fm = const [],
      int page = 1,
      int limit = 10,
      String query = ""}) async {
    Map<String, String> ffm = {};
    for (var i = 0; i < fm.length; i++) {
      final sfm = fm[i];
      if (sfm.tec != null && sfm.tec!.text.isNotEmpty) {
        ffm[sfm.tableTitle] = sfm.tec!.text;
      }
    }
    // Construct query parameters as an object
    Map<String, dynamic> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      'q': query,
      'filter': jsonEncode(ffm), // Convert filter to JSON string
    };

    // Remove null or empty values
    queryParams
        .removeWhere((key, value) => value == null || value.toString().isEmpty);

    // Convert query parameters to URL-encoded string
    String queryString = Uri(queryParameters: queryParams).query;

    // Construct full URL
    final url = '${urls[T]!}?$queryString';

    final res = await apiService.get(url);
    return getListOf<T>(res);
  }

  Future<String> delete<T>(String id) async {
    final res = await apiService.patch("${urls[T]!}/$id");
    if (!res.statusCode!.isSuccess()) {
      throw res.data["error"];
    }
    return res.data["data"];
  }
}
