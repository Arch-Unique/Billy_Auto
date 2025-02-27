import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inventory/tools/assets.dart';
import 'package:inventory/tools/colors.dart';
import 'package:inventory/views/onboarding/splashscreen.dart';

import 'controllers/dependency.dart';
import 'tools/urls.dart';

void main() async {
  final wd = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: wd);
  await GetStorage.init();
  await AppDependency.init();
  if (GetPlatform.isIOS) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: AppColors.transparent));
  } else if (GetPlatform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark
        .copyWith(statusBarColor: AppColors.transparent));
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: AppRoutes.home,
      title: 'Billy Auto Plus',
      color: AppColors.primaryColor,
      getPages: AppPages.getPages,
      theme: ThemeData(
          fontFamily: Assets.appFontFamily,
          appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.dark
                  .copyWith(statusBarColor: AppColors.transparent))),
    );
  }
}
