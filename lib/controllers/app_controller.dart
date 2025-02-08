import 'dart:io';
import 'dart:typed_data';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/models/table_repo.dart';
import 'package:inventory/tools/demo.dart';
import 'package:inventory/tools/enums.dart';
import 'package:inventory/views/explorer/admin_page.dart';
import 'package:inventory/views/shared.dart';
import 'package:path_provider/path_provider.dart';

import '../models/inner_models/barrel.dart';
import '../models/step.dart';
import '../repo/app_repo.dart';

class AppController extends GetxController {
  Rx<DashboardModes> currentDashboardMode = DashboardModes.dashboard.obs;
  Rx<ChecklistModes> currentChecklistMode = ChecklistModes.customer.obs;

  /// 0 - full name
  /// 1 - email
  /// 2 - phone
  /// 3 - customer type
  /// 4 - signature
  /// 5 - select user

  /// 6 - car make
  /// 7 - car model
  /// 8 - car year
  /// 9 - licence plate no
  /// 10 - select car

  /// 11 - concern

  /// 12 - mileage
  /// 13 - fuel level
  /// 14 - body check
  /// 15 - observations

  /// 16 - select service advisor
  /// 17 - select technicians
  /// 18 - lost sales

  /// 19 - urgent
  /// 20 - before next visit
  /// 21 - during maintenance
  /// 22 - delivery hour

  /// 22 - 72 - checks
  List<TextEditingController> tecs =
      List.generate(72, (index) => TextEditingController());

  Rx<Uint8List> userSig = Uint8List(0).obs;
  Rx<Uint8List> advSig = Uint8List(0).obs;
  Rx<Uint8List> techSig = Uint8List(0).obs;
  RxList<CStep> allSteps = <CStep>[].obs;

  List<String> totalConditionsHeaders = [];
  RxList<bool> totalConditionsExpanded = <bool>[].obs;
  Map<String, int> condItem = {};

  RxList<bool> allServicesItems = <bool>[].obs;
  RxMap<String, List<CStep>> inspectionNo = <String, List<CStep>>{}.obs;

  //EXPLORER
  RxList<FilterModel> currentFilters = <FilterModel>[].obs;
  RxList<String> currentHeaders = <String>[].obs;

  //MODELS
  RxList<BillyServices> allBillyServices = <BillyServices>[].obs;
  RxList<BillyConditionCategory> allBillyConditionCategories =
      <BillyConditionCategory>[].obs;
  RxList<BillyConditions> allBillyConditions = <BillyConditions>[].obs;
  RxList<ProductCategory> allProductCategory = <ProductCategory>[].obs;
  RxList<ProductType> allProductType = <ProductType>[].obs;
  RxList<CarMake> allCarMakes = <CarMake>[].obs;
  RxList<CarModels> allCarModels = <CarModels>[].obs;

  //TABLE
  Rx<TableModelDataSource> tmds = TableModelDataSource([], []).obs;
  Rx<PaginatorController> paginatorController = PaginatorController().obs;

  final appRepo = Get.find<AppRepo>();

  initApp() async {
    allBillyServices.value =
        (await appRepo.getAll<BillyServices>(limit: 10000)).data;
    allBillyConditionCategories.value =
        (await appRepo.getAll<BillyConditionCategory>(limit: 10000)).data;
    allBillyConditions.value =
        (await appRepo.getAll<BillyConditions>(limit: 10000)).data;
    allProductCategory.value =
        (await appRepo.getAll<ProductCategory>(limit: 10000)).data;
    allProductType.value =
        (await appRepo.getAll<ProductType>(limit: 10000)).data;
    allCarMakes.value = (await appRepo.getAll<CarMake>(limit: 10000)).data;
    allCarModels.value = (await appRepo.getAll<CarModels>(limit: 10000)).data;

    totalConditionsHeaders =
        allBillyConditionCategories.map((element) => element.name).toList();

    condItem = allBillyConditions.fold<Map<String, int>>({}, (map, condition) {
      map[condition.conditionsCategory] =
          (map[condition.conditionsCategory] ?? 0) + 1;
      return map;
    });

    totalConditionsExpanded.value =
        totalConditionsHeaders.map((e) => true).toList();
    allServicesItems.value = allBillyServices.map((e) => false).toList();

    int k = 0;
    for (var j = 0; j < condItem.length; j++) {
      List<CStep> allStepItem = [];
      final vc = allBillyConditions
          .where((p0) => p0.conditionsCategory == totalConditionsHeaders[j])
          .map((e) => e.name)
          .toList();
      for (var i = 0; i < condItem[totalConditionsHeaders[j]]!; i++) {
        allStepItem.add(CStep(22 + k + i + 1, vc[i]));
        k++;
      }
      allSteps.addAll(allStepItem);
      inspectionNo[totalConditionsHeaders[j]] = allStepItem;
    }
  }

  Future<void> saveFile(Uint8List document, String name) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File('${dir.path}/$name.png');

    await file.writeAsBytes(document);
    Ui.showInfo('Saved exported Image at: ${file.path}');
  }

  // createOrderForm() async{
  //   Customer customer = Customer(id: 0, email: tecs[1].text, phone: tecs[2].text, fullName: tecs[0].text, signature: "", customerType: tecs[3].text, createdAt: DateTime.now(), updatedAt: DateTime.now());
  //   CustomerCar car = CustomerCar(id: 0, makeId: makeId, modelId: modelId, desc: tecs[4].text, year: tecs[8].text, licenseNo: tecs[9].text, createdAt: createdAt, updatedAt: updatedAt, customerId: customerId)
  //   Order order = Order(customerId: customerId, createdAt: createdAt, updatedAt: updatedAt)
  // }

  Future<bool> loginUser(String username, String password) async {
    try {
      await appRepo.login(username, password);
      return true;
    } catch (e) {
      Ui.showError(e.toString());
      return false;
    }
  }

  //EXPLORER
  setCurrentTypeTable<T>() {
    currentHeaders.value = AllTables.tablesData[T]!.headers;
    if (!currentHeaders.contains("actions")) {
      currentHeaders.add("actions");
    }
    currentFilters.value = AllTables.tablesData[T]!.fm;
    currentFilters.refresh();
    currentHeaders.refresh();
    // paginatorController.value = PaginatorController();
    // if(paginatorController.value.isAttached){

    // paginatorController.value.goToFirstPage();
    // paginatorController.value = PaginatorController();
    // }
    tmds.value = TableModelDataSource<T>(currentHeaders, currentFilters);
  }
}
