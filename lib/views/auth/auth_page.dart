import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:inventory/tools/assets.dart';
import 'package:inventory/tools/enums.dart';
import 'package:inventory/views/explorer/explorer.dart';
import 'package:inventory/views/shared.dart';

import '../checklist/checklist.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    
    // final w = GetPlatform.isMobile ? Ui.width(context)-48 : Ui.isSmallScreen(context) ? Ui.width(context)/3 : Ui.width(context)/4;
    final w = Ui.width(context) < 500 ? Ui.width(context)-48 : Ui.isSmallScreen(context) ? Ui.isMediumScreen(context) ? Ui.width(context)/1.5 : Ui.width(context)/2.5 : Ui.width(context)/3.5;
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width:  w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LogoWidget(w/2),
                Ui.boxWidth(24),
                CustomTextField("Username", TextEditingController()),
                CustomTextField("Password", TextEditingController(),varl: FPL.password,),
                Ui.boxWidth(24),
                AppButton(onPressed: (){
                  Get.to(ExplorerPage());
                },text: "Log In",),
              ],
            ),
          ),
        ),
      ),
    );
  }
}