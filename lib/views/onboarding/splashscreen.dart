import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/controllers/splash_controller.dart';
import 'package:inventory/tools/colors.dart';
import 'package:inventory/tools/service.dart';
import 'package:inventory/views/auth/auth_page.dart';

import '../../controllers/dependency.dart';
import '../../tools/assets.dart';
import '../../tools/urls.dart';
import '../shared.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final controller = Get.put(SplashController());

  @override
  void initState() {
    // TODO: implement initState
    if (GetPlatform.isMobile) {
      Future.delayed(Duration(milliseconds: 300), () {
        Get.offAll(AuthPage());
      });
    } else {
      controller.initializeApp();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // child: LogoWidget(GetPlatform.isMobile ? Ui.width(context)-100 : Ui.width(context)/4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LogoWidget(Ui.width(context) < 500
                ? Ui.width(context) - 100
                : Ui.width(context) / 4),
            CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
