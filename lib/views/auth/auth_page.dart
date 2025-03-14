import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory/controllers/app_controller.dart';
import 'package:inventory/repo/app_repo.dart';
import 'package:inventory/tools/assets.dart';
import 'package:inventory/tools/enums.dart';
import 'package:inventory/tools/service.dart';
import 'package:inventory/tools/validators.dart';
import 'package:inventory/views/checklist/checklist2.dart';
import 'package:inventory/views/checklist/history.dart';
import 'package:inventory/views/checklist/shared2.dart';
import 'package:inventory/views/explorer/explorer.dart';
import 'package:inventory/views/shared.dart';

import '../../tools/colors.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final w = Ui.width(context) < 500
        ? Ui.width(context) - 48
        : Ui.isSmallScreen(context)
            ? Ui.isMediumScreen(context)
                ? Ui.width(context) / 1.5
                : Ui.width(context) / 2.5
            : Ui.width(context) / 3.5;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LogoWidget(w / 3),
                Expanded(
                  child: Image.asset(
                    Assets.s5,
                    width: w / 1.2,
                  ),
                ),
                CustomTextField("Username", username),
                CustomTextField(
                  "Password",
                  password,
                  varl: FPL.password,
                ),
                AppButton(
                  onPressed: () async {
                    final msgU = Validators.validate(FPL.text, username.text);
                    final msgP =
                        Validators.validate(FPL.password, password.text);
                    if (msgU == null && msgP == null) {
                      final f = await Get.find<AppController>()
                          .loginUser(username.text, password.text);
                      if (f) {
                        Ui.showInfo("Login Successful. Getting you ready...");
                        await Get.find<AppController>().initApp();
                        Get.offAll(ChoosePage());
                      }
                    } else {
                      Ui.showError(msgU ?? msgP ?? "An error occured");
                    }
                  },
                  text: "Log In",
                ),
                Ui.boxHeight(24),
                AppText.thin("Or"),
                Ui.boxHeight(24),
                AppButton.outline((){
                  Get.to(ClockInOutPage());
                }, "Clock In/Out"),
                Ui.boxHeight(24),
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
  static final pages = ["Service Order", "Order History", "Admin Dashboard"];
  static final assets = [Assets.s1, Assets.s2, Assets.s3];

  @override
  Widget build(BuildContext context) {
    RxBool isPressed = false.obs;
    return Scaffold(
      body: ConnectivityWidget(
        child: BackgroundScaffold(
          hasUser: true,
          hasClockIn: true,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 850),
            child: Column(
              children: [
                Ui.boxWidth(24),
                LogoWidget(120),
                AppText.medium("Dashboard",
                    fontSize: 32,
                    fontFamily: Assets.appFontFamily2,
                    alignment: TextAlign.center,
                    color: AppColors.textColor),
                Ui.boxHeight(8),
                AppText.thin("Choose any section to attend to",
                    fontSize: 15,
                    fontFamily: Assets.appFontFamily1,
                    color: AppColors.lightTextColor),
                Ui.boxHeight(12),
                InkWell(
                    onTap: () async {
                      isPressed.value = true;
                      await Get.find<AppController>().refreshModels();
                      isPressed.value = false;
                      Ui.showInfo("Data Refreshed");
                    },
                    child: CircleAvatar(
                        backgroundColor: AppColors.primaryColor,
                        radius: 24,
                        child: Center(child: Obx(() {
                          return isPressed.value
                              ? CircularProgressIndicator(
                                  color: AppColors.white,
                                )
                              : AppIcon(
                                  Icons.refresh,
                                  color: AppColors.white,
                                );
                        })))),
                Ui.boxHeight(12),
                ...List.generate(
                    Get.find<AppService>().currentUser.value.isServiceAdvisor
                        ? 3
                        : 2,
                    (index) => CurvedContainer(
                          height: 100,
                          width: wideUi(context),
                          radius: 16,
                          onPressed: () {
                            if (index == 0) {
                              Get.to(CheckList2Page());
                            } else if (index == 1) {
                              Get.to(OrderHistoryPage());
                            } else {
                              Get.to(ExplorerPage());
                            }
                          },
                          // color: AppColors.primaryColor,
                          border: Border.all(
                              color: AppColors.primaryColor,
                              strokeAlign: BorderSide.strokeAlignOutside),
                          margin: EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                      height: 100,
                                      width: 100,
                                      color: AppColors.white,
                                      child: Image.asset(
                                        assets[index],
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      )),
                                  Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: [
                                          AppColors.white.withOpacity(0.7),
                                          AppColors.white.withOpacity(0.05)
                                        ],
                                            begin: Alignment.centerRight,
                                            end: Alignment.centerLeft)),
                                  ),
                                ],
                              ),
                              Ui.spacer(),
                              AppText.bold(pages[index],
                                  fontSize: 20, color: AppColors.primaryColor),
                              Ui.spacer(),
                              SizedBox(
                                width: 100,
                              )
                            ],
                          ),
                        )),
                // actionBody("Service Order", "Order History", Assets.s1, Assets.s2,
                //     () {
                //   Get.to(CheckList2Page());
                // }, () {
                //   Get.to(OrderHistoryPage());
                // }),
                // Ui.boxHeight(24),
                // if (!GetPlatform.isMobile)
                //   actionItem("Inventory", Assets.s3, () {
                //     Get.to(ExplorerPage());
                //   }),
                Ui.boxHeight(24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  actionBody(String titleA, String titleB, String assetA, String assetB,
      VoidCallback vba, VoidCallback vbb) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        actionItem(titleA, assetA, vba),
        Ui.boxWidth(32),
        actionItem(titleB, assetB, vbb),
      ],
    );
  }

  actionItem(String title, String asset, VoidCallback vb) {
    double w = Ui.width(Get.context!) < 500 ? 150 : 200;
    double f = w == 200 ? 24 : 18;
    return InkWell(
      onTap: vb,
      child: Container(
        width: w,
        height: w,
        decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.primaryColor),
            borderRadius: BorderRadius.circular(24),
            image:
                DecorationImage(image: AssetImage(asset), fit: BoxFit.cover)),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Positioned(
                bottom: 0,
                child: Container(
                  width: w,
                  height: w / 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(colors: [
                      AppColors.white.withOpacity(0.1),
                      AppColors.white.withOpacity(0.7)
                    ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  ),
                )),
            Positioned(bottom: 6, child: AppText.bold(title, fontSize: f)),
          ],
        ),
      ),
    );
  }
}

class ClockInOutPage extends StatelessWidget {
  const ClockInOutPage({super.key});
  static const List<dynamic> numKeys = [1,2,3,4,5,6,7,8,9,"",0,"x"];
  static const double maxWidth = 500;

  @override
  Widget build(BuildContext context) {
    final tec = TextEditingController();
    RxString img = "".obs;
    return Scaffold(
        body: BackgroundScaffold(
          hasBack: true,
            child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 850),
                child: Column(children: [
                  Ui.boxWidth(24),
                  LogoWidget(120),
                  AppText.medium("Attendance",
                      fontSize: 32,
                      fontFamily: Assets.appFontFamily2,
                      alignment: TextAlign.center,
                      color: AppColors.textColor),
                  Ui.boxHeight(8),
                  AppText.thin("Take your picture and enter your clockin code",
                      fontSize: 15,
                      fontFamily: Assets.appFontFamily1,
                      color: AppColors.lightTextColor),
                  Ui.boxHeight(12),
                  Expanded(child: Obx(
                     () {
                      return CurvedContainer(
                        width: maxWidth,
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                                      img.value = (await picker.pickImage(source: ImageSource.gallery))?.path ?? "";
                        },
                        border: Border.all(color: AppColors.orange),
                        child: img.value.isEmpty ? Center(
                                  child: AppIcon(
                                  Icons.add_a_photo,
                                  color: AppColors.orange,
                                  size: 56,
                                )) : Image.file(
                                  File(img.value),
                                  fit: BoxFit.cover,
                                ),
                      );
                    }
                  )),
                  Ui.boxHeight(12),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: CustomTextField("", tec,readOnly: true,fs: 24,textAlign: TextAlign.center,)),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: List.generate(numKeys.length, (i){
                        return CurvedContainer(
                          onPressed: (){
                            if( i == 11 ){
                              if(tec.text.isEmpty) return;
                              tec.text = tec.text.substring(0,tec.text.length-1);
                              return;
                            }
                            if( i == 9 ){
                              return;
                            }
                            if(tec.text.length < 6){
                              tec.text = tec.text + numKeys[i].toString();
                            }
                            
                          },
                          width: (maxWidth-30)/3,
                          border: Border.all(color: AppColors.lightTextColor),
                          padding: EdgeInsets.all(12),
                          child:  Center(child: AppText.bold(numKeys[i].toString())),
                        );
                      }),
                    ),
                  ),
                  Ui.boxHeight(12),
                  SizedBox(
                    width: maxWidth,
                    child: AppButton.row("Clock In", () async{
                      if(tec.text.length != 6){
                        return Ui.showError("Invalid User Code");
                      }
                      if(img.isEmpty){
                        return Ui.showError("Image cannot be empty");
                      }
                     final f = await Get.find<AppController>().clockIn(tec.text, img.value);
                     if(f){
                      Get.back();
                     }
                    }, "Clock Out", () async{
                      if(tec.text.length != 6){
                        return Ui.showError("Invalid User Code");
                      }
                      final f = await Get.find<AppController>().clockOut(tec.text, img.value);
                       if(f){
                      Get.back();
                     }
                    }),
                  ),
                  Ui.boxHeight(12),
                  

                ]))));
  }
}
