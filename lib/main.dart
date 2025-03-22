import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_single_instance/flutter_single_instance.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inventory/tools/assets.dart';
import 'package:inventory/tools/colors.dart';

import 'controllers/dependency.dart';
import 'tools/urls.dart';
// import 'views/test.dart';

void main() async {
  final wd = WidgetsFlutterBinding.ensureInitialized();
  if (GetPlatform.isDesktop) {
    await windowManager.ensureInitialized();
    final isRunning = await FlutterSingleInstance().isFirstInstance();

    if (!isRunning) {
      print("App is already running");

      final err = await FlutterSingleInstance().focus();

      if (err != null) {
        print("Error focusing running instance: $err");
      }

      exit(0);
    }
  }

  await GetStorage.init();
  if (GetPlatform.isMobile) {
    FlutterNativeSplash.preserve(widgetsBinding: wd);
    await AppDependency.init();
  }

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
