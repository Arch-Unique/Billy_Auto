import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:inventory/tools/service.dart';
import 'package:inventory/views/auth/auth_page.dart';
import 'package:inventory/views/onboarding/splashscreen.dart';

abstract class AppUrls {
  static const String baseURL = 'https://billy.archyuniq.com';
  static const String profile = "/profile";
  static const String storage = "$baseURL/storage/billyautoplussetup.exe";

  static const String user = "/user";
  static const String supplier = "/supplier$profile";
  static const String service = "/service$profile";
  static const String loginHistory = "/loginhistory$profile";
  static const String userAttendance = "/loginhistory/attendance";
  static const String invoice = "/invoice$profile";
  static const String extraOrder = "/invoice/extra";
  static const String product = "/product$profile";
  static const String productType = "/product/type";
  static const String productCategory = "/product/category";
  static const String order = "/order$profile";
  static const String inventory = "/inventory$profile";
  static const String lubeInventory = "/inventory$profile";
  static const String reports = "/inventory/reports";
  static const String customer = "/customer$profile";
  static const String customerCar = "/customer/car";
  static const String expenses = "/expenses$profile";
  static const String expensesTypes = "/expenses/type";
  static const String expensesMetric = "/expenses/metric";
  static const String condition = "/condition$profile";
  static const String appConstants = "/appconstants$profile";
  static const String stations = "/stations$profile";
  static const String locations = "/locations$profile";
  static const String userRoles = "$user/roles$profile";
  static const String conditionCategory = "/condition/category";
  static const String carMake = "/car/makes";
  static const String carModel = "/car/models";
  static const String upload = "/upload";

  //auth repo
  static const String login = "$user/auth/login";
  static const String resetPassword = "$user/auth/reset-password";
  static const String changePassword = "$user/auth/change-password";
  static const String getUser = "$user$profile";
  static const String logout = "$user/auth/logout";
  static const String clockin = "$user/auth/clockin";
  static const String clockout = "$user/auth/clockout";

  //inventory metric
  static const String metrics = "/inventory/metrics";
}

abstract class AppRoutes {
  static const String home = "/";
  static const String dashboard = "/dashboard";
  static const String auth = "/auth";
}

class AppPages {
  static List<GetPage> getPages = [
    GetPage(
        name: AppRoutes.home,
        page: () => SplashScreen(),
        middlewares: [AuthMiddleWare()]),
    GetPage(name: AppRoutes.auth, page: () => AuthPage()),
    GetPage(name: AppRoutes.dashboard, page: () => ChoosePage()),
  ];
}

class AuthMiddleWare extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (GetPlatform.isMobile) {
      FlutterNativeSplash.remove();
      final controller = Get.find<AppService>();
      if (controller.hasOpenedOnboarding.value) {
        if (controller.isLoggedIn.value) {
          return RouteSettings(name: AppRoutes.dashboard);
        } else {
          return const RouteSettings(name: AppRoutes.auth);
        }
      }
      return super.redirect(route);
    }
    return super.redirect(route);
  }
}
