import 'dart:io';
import 'dart:typed_data';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/models/inner_models/base_model.dart';
import 'package:inventory/models/table_repo.dart';
import 'package:inventory/tools/demo.dart';
import 'package:inventory/tools/enums.dart';
import 'package:inventory/tools/functions.dart';
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

  RxList<CStep> allServicesItems = <CStep>[].obs;
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
  RxList<Customer> allCustomer = <Customer>[].obs;
  RxList<CustomerCar> allCustomerCar = <CustomerCar>[].obs;
  RxList<User> allServiceAdvisor = <User>[].obs;
  RxList<User> allTechnicians = <User>[].obs;
  RxList<Order> allOrders = <Order>[].obs;
  RxList<String> userRoles = <String>[].obs;
  RxList<String> customerTypes = <String>[].obs;
  RxList<String> inventoryStatus = <String>[].obs;
  RxList<String> inventoryTransactionTypes = <String>[].obs;

  //TABLE
  Rx<TableModelDataSource> tmds = TableModelDataSource([], []).obs;
  Rx<PaginatorController> paginatorController = PaginatorController().obs;
  Rx<BaseModel> currentBaseModel = User().obs;
  Rx<Order> currentOrder = Order(customerId: 0).obs;

  //PROFILE
  RxBool editOn = false.obs;
  Type currentType = User;

  final appRepo = Get.find<AppRepo>();

  initApp() async {
    userRoles.value = ["admin", "user", "technician", "service-advisor"];
    customerTypes.value = ["Individual", "Corporate"];
    inventoryStatus.value = ["Inbound", "Outbound", "Transfer"];
    inventoryTransactionTypes.value = ["a", "b"];
    allBillyServices.value = await _getAll<BillyServices>();
    allBillyConditionCategories.value = await _getAll<BillyConditionCategory>();
    allBillyConditions.value = await _getAll<BillyConditions>();
    allProductCategory.value = await _getAll<ProductCategory>();
    allProductType.value = await _getAll<ProductType>();
    allCarMakes.value = await _getAll<CarMake>();
    allCarModels.value = await _getAll<CarModels>();
    allCustomer.value = await _getAll<Customer>();
    allCustomerCar.value = await _getAll<CustomerCar>();
    allOrders.value = await _getAll<Order>();
    
    allTechnicians.value = await _getAll<User>(fm: [
      FilterModel("", "role", 0, tec: TextEditingController(text: userRoles[2]))
    ]);
    allServiceAdvisor.value = await _getAll<User>(fm: [
      FilterModel("", "role", 0, tec: TextEditingController(text: userRoles[3]))
    ]);
    updateOrderWithInfo();

    totalConditionsHeaders =
        allBillyConditionCategories.map((element) => element.name).toList();

    condItem = allBillyConditions.fold<Map<String, int>>({}, (map, condition) {
      map[condition.conditionsCategory] =
          (map[condition.conditionsCategory] ?? 0) + 1;
      return map;
    });

    totalConditionsExpanded.value =
        totalConditionsHeaders.map((e) => true).toList();
    allServicesItems.value =
        allBillyServices.map((e) => CStep(e.id, e.id, e.name)).toList();

    int k = 0;
    for (var j = 0; j < condItem.length; j++) {
      List<CStep> allStepItem = [];
      final vc = allBillyConditions
          .where((p0) => p0.conditionsCategory == totalConditionsHeaders[j])
          .map((e) => e.name)
          .toList();
      for (var i = 0; i < condItem[totalConditionsHeaders[j]]!; i++) {
        allStepItem.add(CStep(22 + k + i + 1, k, vc[i]));
        k++;
      }
      allSteps.addAll(allStepItem);
      inspectionNo[totalConditionsHeaders[j]] = allStepItem;
    }
  }

  Future<List<T>> _getAll<T>({List<FilterModel> fm = const []}) async {
    final g = (await appRepo.getAll<T>(limit: 10000, fm: fm)).data;
    return g;
  }

  Future<void> saveFile(Uint8List document, String name) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File('${dir.path}/$name.png');

    await file.writeAsBytes(document);
    Ui.showInfo('Saved exported Image at: ${file.path}');
  }

  createOrderForm() {
    Customer customer;
    CustomerCar car;
    if ((int.tryParse(tecs[5].text) ?? 0) == 0) {
      customer = Customer(
          email: tecs[1].text,
          phone: tecs[2].text,
          fullName: tecs[0].text,
          signature: "",
          customerType: tecs[3].text,
          id: int.tryParse(tecs[5].text) ?? currentOrder.value.customerId);
    } else {
      customer = allCustomer
          .firstWhere((element) => element.id == int.tryParse(tecs[5].text));
    }

    if ((int.tryParse(tecs[10].text) ?? 0) == 0) {
      car = CustomerCar(
          makeId: int.tryParse(tecs[6].text) ?? 0,
          make: int.tryParse(tecs[6].text) == null ||
                  int.tryParse(tecs[6].text) == 0
              ? "None"
              : allCarMakes
                  .firstWhere(
                      (element) => element.id == int.parse(tecs[6].text))
                  .make,
          model: int.tryParse(tecs[7].text) == null ||
                  int.tryParse(tecs[7].text) == 0
              ? "None"
              : allCarModels
                  .firstWhere(
                      (element) => element.id == int.parse(tecs[7].text))
                  .model,
          modelId: int.tryParse(tecs[7].text) ?? 0,
          desc: "",
          id: int.tryParse(tecs[10].text) ?? currentOrder.value.carId,
          year: tecs[8].text,
          licenseNo: tecs[9].text,
          customerId: customer.id);
      car.desc = car.descRaw;
    } else {
      car = allCustomerCar
          .firstWhere((element) => element.id == int.tryParse(tecs[10].text));
    }

    Order order = Order(
        customerId: customer.id,
        carId: car.id,
        customerConcerns: tecs[11].text,
        mileageOnReception: int.tryParse(tecs[12].text) ?? 0,
        fuelLevel: tecs[13].text,
        bodyCheck: tecs[14].text,
        observations: tecs[15].text,
        servicesPerformed: allServicesItems
            .where((p0) => p0.isChecked)
            .map((element) => element.rawId)
            .toList(),
        technicianId: int.tryParse(tecs[17].text) ?? 0,
        serviceAdvisorId: int.tryParse(tecs[16].text) ?? 0,
        conditions:
            allSteps.map((element) => element.isChecked ? 1 : 0).toList(),
        lostSales: tecs[18].text);

    order.serviceAdvisor = allServiceAdvisor
        .firstWhereOrNull((p0) => p0.id == order.serviceAdvisorId)
        ?.fullName;
    order.technician = allTechnicians
        .firstWhereOrNull((p0) => p0.id == order.technicianId)
        ?.fullName;

    order.customerCar = car;
    order.customerDetails = customer;
    order.allServices = allBillyServices
        .where((p0) => order.servicesPerformed.contains(p0.id))
        .toList();
    currentOrder.value = order;
  }

  updateOrderWithInfo() {
    for (var i = 0; i < allOrders.length; i++) {
      final element = allOrders[i];
      element.customerDetails = allCustomer.firstWhere((e) => e.id == element.customerId);
      if (element.carId > 0) {
        element.customerCar = allCustomerCar.firstWhere((e) => e.id == element.carId);
      }
      element.serviceAdvisor = allServiceAdvisor.firstWhere((e) => e.id == element.serviceAdvisorId).fullName;
      element.technician = allTechnicians.firstWhere((e) => e.id == element.technicianId).fullName;
      element.allServices = allBillyServices
          .where((p0) => element.servicesPerformed.contains(p0.id))
          .toList();
    }
  }

  Future<bool> submitServiceOrder() async {
    try {
      if (!(currentOrder.value.customerDetails?.validate() ?? false)) {
        throw "Customer Details incomplete";
      }
      if (!(currentOrder.value.customerCar?.validate() ?? false)) {
        throw "Car Details incomplete";
      }
      if (currentOrder.value.customerId == 0) {
        if (userSig.value.isNotEmpty) {
          final imgPath = await UtilFunctions.saveToTempFile(userSig.value);
          currentOrder.value.customerDetails?.signature =
              await appRepo.uploadPhoto(imgPath.path) ?? "";
        }
        final customer =
            await appRepo.create<Customer>(currentOrder.value.customerDetails!);
        currentOrder.value.customerId = customer;
        currentOrder.value.customerCar?.customerId = customer;
      }
      if (currentOrder.value.carId == 0) {
        final car =
            await appRepo.create<CustomerCar>(currentOrder.value.customerCar!);
        currentOrder.value.carId = car;
      }
      if (!currentOrder.value.validate()) {
        throw "Order Details incomplete";
      }
      await appRepo.create<Order>(currentOrder.value);
      return true;
    } catch (e) {
      Ui.showError(e.toString());
      return false;
    } finally {
      await initApp();
    }
  }

  Future<bool> loginUser(String username, String password) async {
    try {
      await appRepo.login(username, password);
      return true;
    } catch (e) {
      Ui.showError(e.toString());
      return false;
    }
  }

  updateUser(String path) async {
    try {
      if (path.isNotEmpty) {
        final s = await appRepo.uploadPhoto(path);
        appRepo.appService.currentUser.value.signature = s ?? "";
      }

      await appRepo.patch<User>(appRepo.appService.currentUser.value);
      await appRepo.appService.refreshUser();
      Ui.showInfo("Updated successfully");
    } catch (e) {
      print(e);
      Ui.showError(e.toString());
    }
  }

  //EXPLORER
  setCurrentTypeTable<T extends BaseModel>() {
    currentHeaders.value = AllTables.tablesData[T]!.headers;
    currentType = T;
    if (!currentHeaders.contains("actions")) {
      currentHeaders.add("actions");
    }
    currentFilters.value = AllTables.tablesData[T]!.fm;
    currentBaseModel = AllTables.tablesData[T]!.bm.obs;
    currentFilters.refresh();
    currentHeaders.refresh();

    tmds.value = TableModelDataSource<T>(currentHeaders, currentFilters);
  }

  saveNewRecord(Map<String, dynamic> json) async {
    BaseModel mp = appRepo.factories[currentBaseModel.value.runtimeType]!(json);
    try {
      if (currentBaseModel.value.validate()) {
        await appRepo.create(mp);
        Ui.showInfo("Successfully Created A New Record");
      }
    } catch (e) {
      print(e);
      Ui.showError(e.toString());
    } finally {
      await initApp();
    }
  }

  editExisitingRecord(Map<String, dynamic> json) async {
    BaseModel mp = appRepo.factories[currentBaseModel.value.runtimeType]!(json);
    try {
      if (currentBaseModel.value.validate()) {
        await appRepo.patch(mp);
        Ui.showInfo("Successfully Created A New Record");
      }
    } catch (e) {
      print(e);
      Ui.showError(e.toString());
    } finally {
      await initApp();
    }
  }
}
