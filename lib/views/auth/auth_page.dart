import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:inventory/controllers/app_controller.dart';
import 'package:inventory/repo/app_repo.dart';
import 'package:inventory/tools/assets.dart';
import 'package:inventory/tools/enums.dart';
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
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LogoWidget(w / 2),
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
                        Get.offAll(ChoosePage());
                      }
                    }else{
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
    );
  }
}

//ONLY IN DEMO
class ChoosePage extends StatelessWidget {
  const ChoosePage({super.key});
  static final pages = ["Checklist1", "Checklist2", "Inventory"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundScaffold(
        hasUser: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 850),
          child: Column(
            children: [
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
              Ui.boxHeight(24),
              actionBody("Service Order", "Order History", () {
                Get.to(CheckList2Page());
              }, () {
                Get.to(OrderHistoryPage());
              }),
              Ui.boxHeight(24),
              actionBody("Inbound", "Outbound", () {}, () {
                Get.to(ExplorerPage());
                // await Get.find<AppRepo>().sendDemoToBackend();
              }),
              Ui.boxHeight(24),
            ],
          ),
        ),
      ),
    );
  }

  actionBody(String titleA, String titleB, VoidCallback vba, VoidCallback vbb) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        actionItem(titleA, vba),
        Ui.boxWidth(48),
        actionItem(titleB, vbb),
      ],
    );
  }

  actionItem(String title, VoidCallback vb) {
    return CurvedContainer(
      color: AppColors.primaryColorLight,
      radius: 24,
      width: 200,
      height: 200,
      onPressed: vb,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Positioned(bottom: 12, child: AppText.medium(title, fontSize: 16))
        ],
      ),
    );
  }
}
