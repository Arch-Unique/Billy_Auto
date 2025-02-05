import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inventory/tools/assets.dart';
import 'package:inventory/views/onboarding/splashscreen.dart';

import 'controllers/dependency.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await AppDependency.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home:SplashScreen(),
      theme: ThemeData(
          fontFamily: Assets.appFontFamily,),
      
    );
  }
}
