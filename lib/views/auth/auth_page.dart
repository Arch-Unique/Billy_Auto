import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory/controllers/app_controller.dart';
import 'package:inventory/repo/app_repo.dart';
import 'package:inventory/tools/assets.dart';
import 'package:inventory/tools/auto_updater.dart';
import 'package:inventory/tools/enums.dart';
import 'package:inventory/tools/service.dart';
import 'package:inventory/tools/urls.dart';
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
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LogoWidget(w / 3),
                // Expanded(
                //   child: Image.asset(
                //     Assets.s5,
                //     width: w / 1.2,
                //   ),
                // ),
                CustomTextField("Username", username,hint: "Enter your username",isDense: false,),
                CustomTextField(
                  "Password",
                  password,
                  varl: FPL.password,
                  hint: "Enter your password",
                  isDense: false,
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
                AppButton.outline(() {
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
class ChoosePage extends StatefulWidget {
  const ChoosePage({super.key});
  static final pages = ["Service Order", "Order History", "Admin Dashboard"];
  static final assets = [Assets.s1, Assets.s2, Assets.s3];

  @override
  State<ChoosePage> createState() => _ChoosePageState();
}

class _ChoosePageState extends State<ChoosePage> {
  final au = AutoUpdater(updateUrl: AppUrls.storage);
  RxInt version = 0.obs;

  getLatestUpdate() async {
    if (GetPlatform.isDesktop &&
        version.value < Get.find<AppController>().appConstants.value.version) {
      await au.performUpdate();
    }
  }

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
                AppText.medium("Welcome to Billy Auto Plus",
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
                        radius: 20,
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
                Ui.boxHeight(24),
                ...List.generate(
                    Get.find<AppService>().currentUser.value.isServiceAdvisor
                        ? 3
                        : 2,
                    (index) => CurvedContainer(
                          height: 64,
                          width: wideUi(context)/2,
                          radius: 8,
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
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: AppText.bold(ChoosePage.pages[index],
                                fontSize: 16, color: AppColors.primaryColor),
                          ),
                        )),
                Ui.spacer(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.dialog(AppDialog(
                            title: AppText.medium("Change Station"),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                    Get.find<AppController>()
                                        .allStations
                                        .length, (i) {
                                  return Ui.padding(
                                    child: ListTile(
                                      tileColor: AppColors.primaryColor,
                                      selectedTileColor: AppColors.orange,
                                      selected: Get.find<AppController>()
                                              .allStations[i]
                                              .id ==
                                          Get.find<AppService>()
                                              .currentStation
                                              .value,
                                      title: AppText.thin(
                                          Get.find<AppController>()
                                              .allStations[i]
                                              .name,
                                          color: AppColors.white),
                                      onTap: () async {
                                        if (Get.find<AppController>()
                                                .allStations[i]
                                                .id !=
                                            Get.find<AppService>()
                                                .currentStation
                                                .value) {
                                          await Get.find<AppService>()
                                              .saveStation(
                                                  Get.find<AppController>()
                                                      .allStations[i]
                                                      .id);
                                          await Get.find<AppController>()
                                              .refreshAllData();
                                        }
                                        Get.back();
                                      },
                                    ),
                                  );
                                }),
                              ),
                            )));
                      },
                      child: Ui.padding(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppIcon(
                              Icons.location_city_rounded,
                              color: AppColors.primaryColor,
                            ),
                            Ui.boxWidth(12),
                            Obx(() {
                              return AppText.thin(Get.find<AppController>()
                                  .allStations
                                  .where((test) =>
                                      test.id ==
                                      Get.find<AppService>()
                                          .currentStation
                                          .value)
                                  .first
                                  .name);
                            }),
                          ],
                        ),
                      ),
                    ),
                    // if (GetPlatform.isDesktop)
                    //   Obx(() {
                    //     return InkWell(
                    //       onTap: () async {
                    //         Get.dialog(
                    //           AppDialog.normal("Update App",
                    //               "Are you sure you want to update this app ? The current version will be closed and the setup of the new one will be downloaded and installed",
                    //               titleA: "Yes",
                    //               titleB: "No", onPressedA: () async {
                    //             await getLatestUpdate();
                    //           }, onPressedB: () {
                    //             Get.back();
                    //           }),
                    //         );
                    //       },
                    //       child: Padding(
                    //         padding: EdgeInsets.all(8),
                    //         child: AppText.thin(
                    //             Get.find<AppController>()
                    //                         .appConstants
                    //                         .value
                    //                         .version !=
                    //                     version.value
                    //                 ? "Version ${version.value} - A new version is available (Click to Download)"
                    //                 : "Version ${version.value}",
                    //             fontSize: 12,
                    //             color: Get.find<AppController>()
                    //                         .appConstants
                    //                         .value
                    //                         .version !=
                    //                     version.value
                    //                 ? AppColors.primaryColor
                    //                 : AppColors.textColor),
                    //       ),
                    //     );
                    //   }),
                  ],
                ),
                Ui.boxHeight(24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ClockInOutPage extends StatelessWidget {
  ClockInOutPage({super.key});
  static const List<dynamic> numKeys = [1, 2, 3, 4, 5, 6, 7, 8, 9, "", 0, "x"];
  static const double maxWidth = 500;
  final tec = TextEditingController();
  RxString img = "".obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BackgroundScaffold(
            hasBack: true,
            child: Ui.width(context) > 975
                ? Column(
                    children: [
                      header(),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 1200),
                        child: Row(
                          children: [
                            imageContainer(400),
                            Expanded(child: keypad()),
                          ],
                        ),
                      ),
                    ],
                  )
                : ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 850),
                    child: Column(children: [
                      header(),
                      imageContainer(null),
                      keypad()
                    ]))));
  }

  imageContainer(double? a) {
    return Expanded(child: Obx(() {
      return CurvedContainer(
        width: maxWidth,
        height: a,
        onPressed: () async {
          final ImagePicker picker = ImagePicker();

          img.value = (await picker.pickImage(
                      source: GetPlatform.isDesktop
                          ? ImageSource.gallery
                          : ImageSource.camera))
                  ?.path ??
              "";
        },
        border: Border.all(color: AppColors.orange),
        child: img.value.isEmpty
            ? Center(
                child: AppIcon(
                Icons.add_a_photo,
                color: AppColors.orange,
                size: 56,
              ))
            : Image.file(
                File(img.value),
                fit: BoxFit.cover,
              ),
      );
    }));
  }

  header() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
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
    ]);
  }

  keypad() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Ui.boxHeight(12),
        ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: CustomTextField(
              "",
              tec,
              readOnly: true,
              fs: 24,
              textAlign: TextAlign.center,
            )),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: List.generate(numKeys.length, (i) {
              return CurvedContainer(
                onPressed: () {
                  if (i == 11) {
                    if (tec.text.isEmpty) return;
                    tec.text = tec.text.substring(0, tec.text.length - 1);
                    return;
                  }
                  if (i == 9) {
                    return;
                  }
                  if (tec.text.length < 6) {
                    tec.text = tec.text + numKeys[i].toString();
                  }
                },
                width: (maxWidth - 30) / 3,
                border: Border.all(color: AppColors.lightTextColor),
                padding: EdgeInsets.all(12),
                child: Center(child: AppText.bold(numKeys[i].toString())),
              );
            }),
          ),
        ),
        Ui.boxHeight(12),
        SizedBox(
          width: maxWidth,
          child: AppButton.row(
              "Clock In",
              () async {
                if (tec.text.length != 6) {
                  return Ui.showError("Invalid User Code");
                }
                if (img.isEmpty) {
                  return Ui.showError("Image cannot be empty");
                }
                final f = await Get.find<AppController>()
                    .clockIn(tec.text, img.value);
                if (f) {
                  Get.back();
                }
              },
              "Clock Out",
              () async {
                if (tec.text.length != 6) {
                  return Ui.showError("Invalid User Code");
                }
                final f = await Get.find<AppController>()
                    .clockOut(tec.text, img.value);
                if (f) {
                  Get.back();
                }
              }),
        ),
        Ui.boxHeight(12),
      ],
    );
  }
}
