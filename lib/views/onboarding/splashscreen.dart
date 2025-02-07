import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/views/auth/auth_page.dart';

import '../../tools/assets.dart';
import '../shared.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2),(){
      Get.offAll(AuthPage());
    });
    return  Scaffold(
      body: Center(
        // child: LogoWidget(GetPlatform.isMobile ? Ui.width(context)-100 : Ui.width(context)/4),
        child: LogoWidget(Ui.width(context) < 500 ? Ui.width(context)-100 : Ui.width(context)/4),
      ),
    );
  }
}

