import 'package:get/get.dart';

import '../tools/service.dart';
import '../tools/urls.dart';
import 'dependency.dart';

class SplashController extends GetxController {

  Future<void> initializeApp() async {
    await AppDependency.init();
    final controller = Get.find<AppService>();
    if (controller.hasOpenedOnboarding.value) {
      if (controller.isLoggedIn.value) {
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        Get.offAllNamed(AppRoutes.auth);
      }
    }
  }
}
