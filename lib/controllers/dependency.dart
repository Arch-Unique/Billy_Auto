import 'package:get/get.dart';
import 'package:inventory/controllers/app_controller.dart';
import 'package:inventory/repo/app_repo.dart';
import '../tools/service.dart';

class AppDependency {
  static init() async {
    Get.put(MyPrefService());
    Get.put(DioApiService());
    await Get.putAsync(() async {
      final appService = AppService();
      await appService.initUserConfig();
      return appService;
    });
    Get.put(AppRepo());
    await Get.putAsync(() async {
      final appcontroller = AppController();
      await appcontroller.initApp();
      return appcontroller;
    });
  }
}

