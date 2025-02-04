import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/tools/enums.dart';

import '../models/step.dart';

class AppController extends GetxController {
  Rx<DashboardModes> currentDashboardMode = DashboardModes.dashboard.obs;
  Rx<ChecklistModes> currentChecklistMode = ChecklistModes.customer.obs;

  // 0 - full name
  // 1 - email
  // 2 - phone
  // 3 - customer type
  // 4 - signature
  // 5 - select user

  // 6 - car make
  // 7 - car model
  // 8 - car year
  // 9 - licence plate no
  // 10 - select car

  // 11 - concern

  // 12 - mileage
  // 13 - fuel level
  // 14 - body check
  // 15 - observations

  // 16 - select service advisor
  // 17 - select technicians
  // 18 - lost sales

  // 19 - urgent
  // 20 - before next visit
  // 21 - during maintenance
  // 22 - delivery hour

  // 22 - 72 - checks 
  List<TextEditingController> tecs =
      List.generate(72, (index) => TextEditingController());
  Rx<Uint8List> userSig = Uint8List(0).obs;
  Rx<Uint8List> advSig = Uint8List(0).obs;
  Rx<Uint8List> techSig = Uint8List(0).obs;
  RxList<CStep> allSteps = <CStep>[].obs;

  List<String> totalConditionsHeaders = ["A","B","C","D","E"];
  RxList<bool> totalConditionsExpanded = <bool>[].obs;
  List<int> totalConditionsItems = [2, 4, 3, 5, 3];
  List<int> totalConditionsItemsZero = [2, 4, 3, 5, 3];

  RxList<String> allServices = ["Tires","Break Pads","Oil Filters"].obs;
  RxList<bool> allServicesItems = <bool>[].obs;

  initApp() async {
    totalConditionsItemsZero.insert(0, 0);
    totalConditionsExpanded.value = totalConditionsHeaders.map((e) => false).toList();
    allServicesItems.value = allServices.map((e) => false).toList();

    for (var j = 0; j < totalConditionsItems.length; j++) {
      for (var i = 0; i < totalConditionsItems[j]; i++) {
        allSteps.add(CStep(22 + totalConditionsItemsZero[j] + i + 1, "Text"));
      }
    }
  }
}
