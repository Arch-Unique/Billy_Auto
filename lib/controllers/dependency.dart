import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inventory/controllers/app_controller.dart';

import '../models/winpath.dart';

class AppDependency {
  static init() async {
    // await Get.putAsync(() async {
    //   final appService = AppService();
    //   await appService.init();
    //   return appService;
    // });
    // await Get.putAsync(() async {
    //   final internalcheck = InternalCheckService();
    //   await internalcheck.open();
    //   return internalcheck;
    // });
    // await Get.putAsync(() async {
    //   final internalcheck = ExternalCheckService();
    //   await internalcheck.open();
    //   return internalcheck;
    // });
    // await Get.putAsync(() async {
    //   final actiontable = ActionTableService();
    //   await actiontable.open();
    //   return actiontable;
    // });
    await Get.putAsync(() async {
      final appcontroller = AppController();
      await appcontroller.initApp();
      return appcontroller;
    });
  }
}

class AppService extends GetxService {
  final pref = GetStorage();

  static const String mpHasSetup = "mpHasSetup";

  String winPth = "";

  saveSetup() async {
    await pref.write(mpHasSetup, true);
  }

  init() async {
    winPth =
        (await WinPath.getPath('{FDD39AD0-238F-46AF-ADB4-6C85480369C7}')) ?? "";
    final fwinPth = "$winPth\\calibtracker.db";
   
  }
}
