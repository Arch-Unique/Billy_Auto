import 'dart:convert';

import 'package:get/get.dart';
import 'package:inventory/tools/extensions.dart';

import '../models/inner_models/barrel.dart';
import '../models/table_repo.dart';
import '../tools/demo.dart';
import '../tools/service.dart';
import '../tools/urls.dart';

typedef FromJsonFactory<T> = T Function(Map<String, dynamic>);

class JsonParser {
  static TotalResponse<T> parseList<T>(
      dynamic response, FromJsonFactory<dynamic> fromJson) {
    if (!(response.statusCode! as int).isSuccess()) {
      return TotalResponse<T>(0, <T>[]);
    }
    final data = response.data["data"]["data"] as List<dynamic>;
    final tt = response.data["data"]["total"] ?? 0;
    List<T> dt = <T>[];
    if (data.isNotEmpty){
      
    dt = data
        .map((item) => fromJson(item as Map<String, dynamic>) as T)
        .toList();
    }
    return TotalResponse<T>(tt, dt);
  }

  static T? parse<T>(dynamic response, FromJsonFactory<dynamic> fromJson) {
    if (!(response.statusCode! as int).isSuccess()) {
      return null;
    }
    return fromJson(response.data["data"] as Map<String, dynamic>) as T;
  }
}

class TotalResponse<T> {
  final int total;
  final List<T> data;

TotalResponse(this.total,this.data);
}

class AppRepo extends GetxController {
  final apiService = Get.find<DioApiService>();
  final prefService = Get.find<MyPrefService>();
  final appService = Get.find<AppService>();

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
    BillyConditions: BillyConditions.fromJson,
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

  TotalResponse<T> getListOf<T>(dynamic res) {
    return JsonParser.parseList<T>(res, factories[T]!);
  }

  T? getOf<T>(dynamic res) {
    return JsonParser.parse<T>(res, factories[T]!);
  }

  Future<int> create<T>(Map<String, dynamic> data) async {
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

  Future<TotalResponse<T>> getAll<T>(
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
      'filter': ffm.isEmpty ? null : jsonEncode(ffm), // Convert filter to JSON string
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

  login(String username, String password) async {
    final res = await apiService.post(AppUrls.login,
        data: {"username": username, "password": password});
    if (res.statusCode!.isSuccess()) {
      await appService.loginUser(res.data["data"]["jwt"]);
    } else {
      throw res.data["error"];
    }
  }

  // sendDemoToBackend() async {
  //   //Do For Cars
  //   final carMakes = cars.keys.toList();
  //   for (var i = 0; i < carMakes.length; i++) {
  //     await create<CarMake>(CarMake(make: carMakes[i]).toJson()).then((v) async{
  //       for (var j = 0; j < cars[carMakes[i]]!.length; j++) {
  //         await create<CarModels>(
  //                 CarModels(makeId: v, model: cars[carMakes[i]]![j]).toJson())
  //             .then((vi) {
  //           print("done car$i $vi");
  //         }).catchError((e) {});
  //       }
  //     }).catchError((e) {});
  //   }

  //   //Do For Products
  //   final prodCat = autoParts.keys.toList();
  //   for (var i = 0; i < prodCat.length; i++) {
  //     await create<ProductCategory>(
  //             ProductCategory(name: prodCat[i], code: "", image: "").toJson())
  //         .then((v) async{
  //       for (var j = 0; j < autoParts[prodCat[i]]!.length; j++) {
  //         await create<ProductType>(ProductType(
  //                     productCategoryId: v,
  //                     code: "",
  //                     image: "",
  //                     name: autoParts[prodCat[i]]![j])
  //                 .toJson())
  //             .then((vi) {
  //           print("done prod$i $vi");
  //         }).catchError((e) {});
  //       }
  //     }).catchError((e) {});
  //   }

  //   //Do For Coditons
  //   final condCat = vehicleChecklist.keys.toList();
  //   for (var i = 0; i < condCat.length; i++) {
  //     await create<BillyConditionCategory>(
  //             BillyConditionCategory(name: condCat[i]).toJson())
  //         .then((v) async{
  //       for (var j = 0; j < vehicleChecklist[condCat[i]]!.length; j++) {
  //         await create<BillyConditions>(BillyConditions(
  //                     conditionsCategoryId: v,
  //                     name: vehicleChecklist[condCat[i]]![j])
  //                 .toJson())
  //             .then((vi) {
  //           print("done cond$i $vi");
  //         }).catchError((e) {});
  //       }
  //     }).catchError((e) {});

  //     print("done con$i");
  //   }

  //   //Do For Services
  //   for (var i = 0; i < demoServices.length; i++) {
  //     await create<BillyServices>(
  //             BillyServices(name: demoServices[i], image: "").toJson())
  //         .then((v) {})
  //         .catchError((e) {});
  //     print("done ser$i");
  //   }
  // }


}
