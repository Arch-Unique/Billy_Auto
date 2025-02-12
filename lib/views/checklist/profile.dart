import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/tools/functions.dart';
import 'package:inventory/tools/urls.dart';
import 'package:inventory/views/auth/auth_page.dart';
import 'package:inventory/views/checklist/shared2.dart';
import 'package:inventory/views/shared.dart';

import '../../controllers/app_controller.dart';
import '../../tools/assets.dart';
import '../../tools/colors.dart';

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
          text: controller.appRepo.appService.currentUser.value.email)
    ];

    return Scaffold(
      body: BackgroundScaffold(
        hasUser: false,
        hasBack: true,
        hasEdit: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 850),
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
                CustomTextField2.dropdown(controller.userRoles,controller.userRoles, tecs[2], "Role",
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
                        if (cuserSig.value != Uint8List(0)) {
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
                Ui.spacer(),
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
    );
  }
}

