import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/tools/service.dart';
import 'package:inventory/views/auth/auth_page.dart';
import 'package:inventory/views/onboarding/splashscreen.dart';

abstract class AppUrls {
  static const String baseURL = 'https://billy.archyuniq.com';


  static const String profile = "/profile";

  static const String user = "/user";
  static const String supplier = "/supplier$profile";
  static const String service = "/service$profile";
  static const String product = "/product$profile";
  static const String productType = "/product/type";
  static const String productCategory = "/product/category";
  static const String order = "/order$profile";
  static const String inventory = "/inventory$profile";
  static const String customer = "/customer$profile";
  static const String customerCar = "/customer/car";
  static const String condition = "/condition$profile";
  static const String conditionCategory = "/condition/category";
  static const String carMake = "/car/makes";
  static const String carModel = "/car/models";
  static const String upload = "/upload";

  //auth repo
  static const String login = "$user/auth/login";
  static const String changePassword = "$user/auth/changePassword";
  
  static const String getUser = "$user$profile";


  static const String logout = "$user/auth/logout";
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
}