import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:inventory/tools/functions.dart';
import 'package:inventory/tools/urls.dart';
import 'package:inventory/views/auth/auth_page.dart';
import 'package:inventory/views/checklist/shared2.dart';
import 'package:inventory/views/shared.dart';

import '../../controllers/app_controller.dart';
import '../../tools/assets.dart';
import '../../tools/colors.dart';
import '../../tools/enums.dart';
import '../../tools/validators.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});
  List<TextEditingController> tecs = [];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppController>();
    Rx<Uint8List> cuserSig = Uint8List(0).obs;
    tecs = [
      TextEditingController(
          text: controller.appRepo.appService.currentUser.value.fullName),
      TextEditingController(
          text: controller.appRepo.appService.currentUser.value.username),
      TextEditingController(
          text: controller.appRepo.appService.currentUser.value.role),
      TextEditingController(
          text: controller.appRepo.appService.currentUser.value.email),TextEditingController(),TextEditingController(),TextEditingController()
    ];

    return Scaffold(
      body: BackgroundScaffold(
        hasUser: false,
        hasBack: true,
        hasEdit: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 850),
          child: SingleChildScrollView(
            child: Obx(() {
              return Column(
                children: [
                  LogoWidget(120),
                  AppText.medium("Profile",
                      fontSize: 32,
                      fontFamily: Assets.appFontFamily2,
                      alignment: TextAlign.center,
                      color: AppColors.textColor),
                  Ui.boxHeight(24),
                  ProfileLogo(
                    size: 36,
                  ),
                  Ui.boxHeight(24),
                  CustomTextField2(
                    "Full Name",
                    tecs[0],
                    readOnly: !controller.editOn.value,
                  ),
                  CustomTextField2(
                    "Username",
                    tecs[1],
                    readOnly: !controller.editOn.value,
                  ),
                  CustomTextField2.dropdown<String>(controller.userRoles,controller.userRoles, tecs[2], "Role",
                      initOption: tecs[2].text),
                  CustomTextField2(
                    "Email",
                    tecs[3],
                    readOnly: !controller.editOn.value,
                  ),
                  Ui.boxHeight(8),
                  controller.editOn.value
                      ? SignatureView(cuserSig, "My Signature",
                          size: wideUi(context))
                      : LockedSignatureWidget(title: "My Signature",signature: controller.appRepo.appService.currentUser.value.signature,),
                  Ui.boxHeight(8),
                  if (controller.editOn.value)
                    SizedBox(
                      width: wideUi(context) / 3,
                      child: AppButton(
                        onPressed: () async {
                          String sp = "";
                          if (cuserSig.value.isNotEmpty) {
                            final ssp = await UtilFunctions.saveToTempFile(cuserSig.value);
                            sp = ssp.path;
                          }
                          controller.appRepo.appService.currentUser.value.fullName = tecs[0].text;
                          controller.appRepo.appService.currentUser.value.username = tecs[1].text;
                          controller.appRepo.appService.currentUser.value.role = tecs[2].text;
                          controller.appRepo.appService.currentUser.value.email = tecs[3].text;
            
                          await controller.updateUser(sp);
                        },
                        text: "Save",
                      ),
                    ),
                  
                  Ui.boxHeight(48),
                  AppDivider(),
                  Ui.boxHeight(48),
                  AppText.medium("Change Password"),
                  Ui.boxHeight(12),
                  CustomTextField2(
                  "Old Password",
                  tecs[6],
                  varl: FPL.password,
                ),
                  CustomTextField2(
                  "New  Password",
                  tecs[4],
                  varl: FPL.password,
                ),
                CustomTextField2(
                  "Confirm Password",
                  tecs[5],
                  varl: FPL.password,
                ),
                SizedBox(
                  width: wideUi(context) / 3,
                  child: AppButton(
                    onPressed: () async {
                      final msgU = Validators.validate(FPL.password, tecs[4].text);
                      final msgP =
                          Validators.validate(FPL.password, tecs[5].text);
                          final msgV = Validators.confirmPasswordValidator(tecs[4].text, tecs[5].text);
                      if (msgU == null && msgP == null && msgV == null) {
                        bool f = await Get.find<AppController>()
                            .changePassword(tecs[6].text,tecs[5].text);
                        
                        if (f) {
                          Ui.showInfo("Successfully changed password");
                        }
                      } else {
                        Ui.showError(msgU ?? msgP ?? msgV ?? "An error occured");
                      }
                    },
                    text: "Change Password",
                  ),
                ),
                  Ui.boxHeight(48),
                  AppDivider(),
                  Ui.boxHeight(48),
                  SizedBox(
                    width: wideUi(context) / 3,
                    child: AppButton.outline(
                      () async {
                        await controller.appRepo.appService.logout();
                        Get.offAll(AuthPage());
                      },
                      "Log Out",
                    ),
                  ),
                  Ui.boxHeight(24)
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

