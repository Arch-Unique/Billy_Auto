import 'dart:convert';

import 'package:get/get.dart';
import 'package:inventory/tools/extensions.dart';

import '../models/inner_models/barrel.dart';
import '../models/inner_models/base_model.dart';
import '../models/table_repo.dart';
import '../tools/demo.dart';
import '../tools/service.dart';
import '../tools/urls.dart';
import 'package:dio/dio.dart' as dio;

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
    if (data.isNotEmpty) {
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

  TotalResponse(this.total, this.data);
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
    LubeInventory: LubeInventory.fromJson,
    Product: Product.fromJson,
    ProductType: ProductType.fromJson,
    ProductCategory: ProductCategory.fromJson,
    BillyConditions: BillyConditions.fromJson,
    BillyConditionCategory: BillyConditionCategory.fromJson,
    BillyServices: BillyServices.fromJson,
    LoginHistory: LoginHistory.fromJson,
    UserAttendance: UserAttendance.fromJson,
    Expenses: Expenses.fromJson,
    ExpensesType: ExpensesType.fromJson,
    BulkExpenses: BulkExpenses.fromJson,
    Invoice: Invoice.fromJson,
    AppConstants: AppConstants.fromJson,
    Locations: Locations.fromJson,
    Stations: Stations.fromJson,
    UserRole: UserRole.fromJson,
    InventoryMetricStockBalances: InventoryMetricStockBalances.fromJson,
    InventoryMetricStockBalancesCost: InventoryMetricStockBalancesCost.fromJson,
    InventoryMetricDailyProfit: InventoryMetricDailyProfit.fromJson,
    InventoryMetricMonthlyProfit: InventoryMetricMonthlyProfit.fromJson,
    InventoryMetricYearlyProfit: InventoryMetricYearlyProfit.fromJson,
    InventoryMetricProductPrice: InventoryMetricProductPrice.fromJson,
  };

  final Map<Type, String> urls = {
    User: AppUrls.getUser,
    CarMake: AppUrls.carMake,
    CarModels: AppUrls.carModel,
    Customer: AppUrls.customer,
    CustomerCar: AppUrls.customerCar,
    Supplier: AppUrls.supplier,
    Order: AppUrls.order,
    Inventory: AppUrls.inventory,
    LubeInventory: AppUrls.lubeInventory,
    Product: AppUrls.product,
    ProductType: AppUrls.productType,
    ProductCategory: AppUrls.productCategory,
    BillyConditions: AppUrls.condition,
    BillyConditionCategory: AppUrls.conditionCategory,
    BillyServices: AppUrls.service,
    LoginHistory: AppUrls.loginHistory,
    UserAttendance: AppUrls.userAttendance,
    Expenses: AppUrls.expenses,
    ExpensesType: AppUrls.expensesTypes,
    BulkExpenses: AppUrls.expensesMetric,
    Invoice: AppUrls.invoice,
    AppConstants: AppUrls.appConstants,
    Locations: AppUrls.locations,
    Stations: AppUrls.stations,
    UserRole: AppUrls.userRoles,
    InventoryMetricStockBalances: "${AppUrls.metrics}/1",
    InventoryMetricStockBalancesCost: "${AppUrls.metrics}/2",
    InventoryMetricDailyProfit: "${AppUrls.metrics}/3",
    InventoryMetricMonthlyProfit: "${AppUrls.metrics}/4",
    InventoryMetricYearlyProfit: "${AppUrls.metrics}/5",
    InventoryMetricProductPrice: "${AppUrls.metrics}/6"
  };

  TotalResponse<T> getListOf<T>(dynamic res) {
    return JsonParser.parseList<T>(res, factories[T]!);
  }

  T? getOf<T>(dynamic res) {
    return JsonParser.parse<T>(res, factories[T]!);
  }

  Future<int> create<T extends BaseModel>(T data,{String? url}) async {
    final res = await apiService.post("${url ?? urls[data.runtimeType]!}/add",
        data: data.toJson());
    if (!res.statusCode!.isSuccess()) {
      throw res.data["error"];
    }
    return res.data["data"];
  }

  Future<String> patch<T extends BaseModel>(T data) async {
    final res = await apiService.patch("${urls[data.runtimeType]!}/${data.id}",
        data: data.toJson());
        print(data.toJson());
    if (!res.statusCode!.isSuccess()) {
      throw res.data["error"];
    }
    return res.data["data"];
  }

  Future<T?> getOne<T>(String id) async {
    final res =
        await apiService.post("${urls[T]!}/get/$id", data: {"filter": {}});
    return getOf<T>(res);
  }

  Future<TotalResponse<T>> getAll<T>(
      {List<FilterModel> fm = const [],
      int page = 1,
      int limit = 10,
      String date = "",
      String? rurl,
      String query = ""}) async {
    Map<String, String> ffm = {};
    for (var i = 0; i < fm.length; i++) {
      final sfm = fm[i];
      if (sfm.tec != null && sfm.tec!.text.isNotEmpty) {
        if(sfm.tableTitle == "createdAt"){
          ffm["from"] = (sfm.dtr?.start ?? DateTime(2025)).toSQLDate();
          ffm["to"] = (sfm.dtr?.end ?? DateTime.now()).toSQLDate();
        }else{
          ffm[sfm.tableTitle] = sfm.tec!.text;
        }
      }
    }
    if(T == LubeInventory){
      ffm["productTypeId"] = "201";
    }
    // Construct query parameters as an object
    Map<String, dynamic> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      'q': query,
      'date': date,
    };

    // Remove null or empty values
    queryParams
        .removeWhere((key, value) => value == null || value.toString().isEmpty);

    // Convert query parameters to URL-encoded string
    String queryString = Uri(queryParameters: queryParams).query;

    // Construct full URL
    final url = '${rurl ?? urls[T]!}/get?$queryString';

    final res = await apiService.post(url, data: {"filter": ffm});
    return getListOf<T>(res);
  }

  Future<String> delete<T>(String id) async {
    final res = await apiService.delete("${urls[T]!}/$id");
    if (!res.statusCode!.isSuccess()) {
      throw res.data["error"];
    }
    return res.data["data"];
  }

  login(String username, String password) async {
    final res = await apiService.post(AppUrls.login, data: {
      "username": username,
      "password": password,
      "device": GetPlatform.isMobile ? "mobile" : "pc"
    });
    if (res.statusCode!.isSuccess()) {
      await appService.loginUser(res.data["data"]["jwt"]);
    } else {
      throw res.data["error"];
    }
  }

  Future<bool> clockin(String code, String image) async {
    final img = await uploadPhoto(image);
    final res = await apiService.post(AppUrls.clockin, data: {
      "id": code,
      "imageIn": img,
    });
    if (res.statusCode!.isSuccess()) {
      return true;
    } else {
      throw res.data["error"];
    }
  }

    Future<bool> clockout(String code, String image) async {
    final img = await uploadPhoto(image);
    final res = await apiService.post(AppUrls.clockout, data: {
      "id": code,
      "imageOut": img,
    });
    if (res.statusCode!.isSuccess()) {
      return true;
    } else {
      throw res.data["error"];
    }
  }

  syncExpenses(Map<String, dynamic> json, String dt) async {
    final res = await apiService.post("${AppUrls.expensesMetric}/add/$dt",
        data: json["data"]);
    if (res.statusCode!.isSuccess()) {
      return;
      // await appService.loginUser(res.data["data"]["jwt"]);
    } else {
      throw res.data["error"];
    }
  }

  resetPassword(String username, String password) async {
    final res = await apiService.post(AppUrls.resetPassword,
        data: {"username": username, "password": password});
    if (res.statusCode!.isSuccess()) {
      // await appService.loginUser(res.data["data"]["jwt"]);
    } else {
      throw res.data["error"];
    }
  }

  Future<TotalResponse> getReport(int a,String dateA, String dateb) async {
final res = await apiService.get("${AppUrls.reports}/$a/$dateA/$dateb");
if (res.statusCode!.isSuccess()) {
      return TotalResponse(res.data["data"]["total"], res.data["data"]["data"]);
    } else {
      return TotalResponse(0, []);
    }
  }

  changePassword(String password, String npassword) async {
    final res = await apiService.post(
        "${AppUrls.changePassword}/${appService.currentUser.value.id}",
        data: {"password": password, "npassword": npassword});
    if (res.statusCode!.isSuccess()) {
      // await appService.loginUser(res.data["data"]["jwt"]);
    } else {
      throw res.data["error"];
    }
  }

  Future<String?> uploadPhoto(String? imagePath) async {
    if (imagePath == null) return null;
    if (imagePath.isEmpty) return null;
    final res = await apiService.post(AppUrls.upload,
        data: dio.FormData.fromMap({
          'file': await dio.MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split('/').last,
          ),
        }));

    if (res.statusCode!.isSuccess()) {
      return res.data["data"];
    }
    return null;
  }

  Future<List<T>> getAllMetricData<T>() async {
    final res = await apiService.get(urls[T]!);
    return (getListOf<T>(res)).data;
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
