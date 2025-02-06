import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:inventory/tools/assets.dart';
import 'package:inventory/tools/enums.dart';
import 'package:inventory/views/checklist/checklist2.dart';
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
                  Get.to(ChoosePage());
                },text: "Log In",),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//ONLY IN DEMO
class ChoosePage extends StatelessWidget {
  const ChoosePage({super.key});
  static final pages = ["Checklist1","Checklist2","Inventory"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(3, (index) => SizedBox(
              width: Ui.width(context)/3,
              child: Ui.padding(
                child: AppButton(onPressed: (){
                  if(index == 0){
                    Get.to(CheckListPage());
                  } else if(index == 1){
                    Get.to(CheckList2Page());
                  }else if(index == 2){
                    Get.to(ExplorerPage());
                  }
                },text: pages[index],),
              ),
            ))
          ],
        ),
      ),
    );
  }
}