import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
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
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Ui.boxWidth(24),
                  LogoWidget(w / 3),
                  Ui.boxWidth(24),
                  Image.asset(
                    Assets.s5,
                    width: w/1.2,
                  ),
                  Ui.boxWidth(24),
                  CustomTextField("Username", username),
                  CustomTextField(
                    "Password",
                    password,
                    varl: FPL.password,
                  ),
                  Ui.boxWidth(24),
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
                ],
              ),
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
                      onTap: () async{
                        isPressed.value = true;
                        await Get.find<AppController>().refreshModels();
                        isPressed.value = false;
                        Ui.showInfo("Data Refreshed");
                      },
                      child: CircleAvatar(
                          backgroundColor: AppColors.primaryColor,
                          radius: 24,
                          child: Center(
                              child: Obx(
                                 () {
                                  return isPressed.value ? CircularProgressIndicator(color: AppColors.white,): AppIcon(
                                                              Icons.refresh,
                                                              color: AppColors.white,
                                                            );
                                }
                              )))),
                Ui.boxHeight(12),
                ...List.generate(
                    !GetPlatform.isMobile || Get.find<AppService>().currentUser.value.username == "dev" ? 3  : 2,
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
