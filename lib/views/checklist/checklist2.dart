import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:inventory/tools/assets.dart';
import 'package:inventory/tools/colors.dart';
import 'package:inventory/tools/demo.dart';
import 'package:inventory/tools/enums.dart';
import 'package:inventory/tools/functions.dart';
import 'package:inventory/views/checklist/profile.dart';
import 'package:inventory/views/shared.dart';

import '../../controllers/app_controller.dart';
import '../../models/inner_models/barrel.dart';
import 'order_summary.dart';
import 'shared2.dart';

class CheckList2Page extends StatefulWidget {
  const CheckList2Page({super.key});

  @override
  State<CheckList2Page> createState() => _CheckList2PageState();
}

class _CheckList2PageState extends State<CheckList2Page> {
  final controller = Get.find<AppController>();
  List<dynamic> screens = [];

  @override
  void initState() {
    screens = [
      customerDetails(),
      carDetails(),
      concernDetails(),
      carConditonDetails(),
      freeInspectionDetails(),
      servicePlanDetails(),
      // maintenanceDetails()
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(Ui.width(context));
    return PopScope(
      canPop: false,
      onPopInvoked: (dp) {
        if (controller.currentChecklistMode.value.index > 0 &&
            controller.currentChecklistMode.value.index <
                ChecklistModes.values.length) {
          controller.currentChecklistMode.value = ChecklistModes
              .values[controller.currentChecklistMode.value.index - 1];
        }
      },
      child: Scaffold(
        body: BackgroundScaffold(
          hasBack: true,
          child: Column(
            children: [
              Ui.boxWidth(Ui.width(context)),
              CheckList2Header(),
              Expanded(
                  child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 850),
                  child: Obx(() {
                    return Column(
                      children: [
                        ...screens[controller.currentChecklistMode.value.index],
                        Ui.boxHeight(24),
                        SizedBox(
                          width: 320,
                          child: Obx(() {
                            return Row(
                              children: [
                                if (controller
                                        .currentChecklistMode.value.index >
                                    0)
                                  Expanded(
                                      child: AppButton(
                                    onPressed: () {
                                      controller.currentChecklistMode.value =
                                          ChecklistModes.values[controller
                                                  .currentChecklistMode
                                                  .value
                                                  .index -
                                              1];
                                    },
                                    text: "Back",
                                    borderColor: AppColors.lightTextColor,
                                    color: Color(0xFFD1D1D1),
                                  )),
                                Ui.boxWidth(24),
                                Expanded(
                                    child: AppButton(
                                  onPressed: () {
                                    if (controller
                                            .currentChecklistMode.value.index ==
                                        ChecklistModes.values.length - 1) {
                                          controller.createOrderForm();
                                      Get.to(OrderSummary("Service Order Summary",controller.currentOrder.value,sig: controller.userSig.value,));
                                    } else {
                                      controller.currentChecklistMode.value =
                                          ChecklistModes.values[controller
                                                  .currentChecklistMode
                                                  .value
                                                  .index +
                                              1];
                                    }
                                  },
                                  text: controller.currentChecklistMode.value
                                              .index <
                                          ChecklistModes.values.length - 1
                                      ? "Next"
                                      : "Complete",
                                )),
                              ],
                            );
                          }),
                        ),
                        Ui.boxHeight(24),
                      ],
                    );
                  }),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> customerDetails() {
    RxString curImg = "".obs;
    return [
      CustomTextField2.dropdown(
          controller.allCustomer.map((element) => element.fullName).toList(),controller.allCustomer.map((element) => element.id).toList(), controller.tecs[5], "Select Customer"),

      Align(
          alignment: Alignment.center,
          child: AppText.thin("Or register a new customer")),
      Ui.boxHeight(32),
      CustomTextField2(
        "Full Name",
        controller.tecs[0],
        prefix: Icons.person_4_outlined,
      ),
      CustomTextField2("Email", controller.tecs[1],
          varl: FPL.email, prefix: Icons.email_rounded),
      CustomTextField2("Phone", controller.tecs[2],
          varl: FPL.phone, prefix: Icons.phone_iphone_rounded),
      CustomTextField2.dropdown(
          ["Individual", "Corporate"],["Individual", "Corporate"], controller.tecs[3], "Customer Type"),
      //Signature
      Builder(builder: (context) {
        return SignatureView(controller.userSig, "Customer Signature",
            size: wideUi(context));
      }),
      Ui.boxHeight(24),
      Builder(builder: (context) {
        return SizedBox(
          width: wideUi(context),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 0.0, bottom: 8),
                child: AppText.thin("Choose Image of Customer/Driver"),
              )),
        );
      }),
      Obx(() {
        final cc = CurvedContainer(
            border: Border.all(color: AppColors.grey),
            height: 128,
            width: wideUi(context),
            onPressed: () async {
              final img = await UtilFunctions.showCamera();
              if (img != null) {
                curImg.value = img;
              }
            },
            padding: EdgeInsets.all(curImg.value.isNotEmpty ? 0 : 24),
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: curImg.value.isNotEmpty
                ? Image.file(
                    File(curImg.value),
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: AppIcon(
                    Icons.add_a_photo,
                    size: Ui.width(context) < 750 ? 24 : 48,
                  )));
        if (curImg.value.isNotEmpty) {
          return Stack(
            children: [
              cc,
              Positioned(
                  top: 0,
                  right: 0,
                  child: AppIcon(
                    Icons.remove_circle_rounded,
                    color: Colors.red,
                    onTap: () {
                      curImg.value = "";
                    },
                  ))
            ],
          );
        }
        return cc;
      })
    ];
  }

  List<Widget> carDetails() {
    RxString carBrand = "Seat".obs;
    return [
      CustomTextField2.dropdown(
          controller.allCustomerCar.map((element) => element.desc).toList(),controller.allCustomerCar.map((element) => element.id).toList(), controller.tecs[10], "Select Customer Car"),
      Align(
          alignment: Alignment.center,
          child: AppText.thin("Or register a new customer car")),
      Ui.boxHeight(32),
      CustomTextField2.dropdown(
          controller.allCarMakes.map((element) => element.make).toList(),
          controller.allCarMakes.map((element) => element.id).toList(),
          controller.tecs[6],
          "Car Brand",initOption: carBrand.value,onChanged: (_) {
        carBrand.value =
            controller.allCarMakes[int.parse(controller.tecs[6].text)-1].make;
      }),
      Obx(
        () => 
        CustomTextField2.dropdown(
            controller.allCarModels
                .where((p0) => p0.make == carBrand.value)
                .map((e) => e.model)
                .toList(),
            controller.allCarModels
                .where((p0) => p0.make == carBrand.value)
                .map((e) => e.id)
                .toList(),
            controller.tecs[7],
            "Car Model"),
      ),
      CustomTextField2.dropdown(
          List.generate(DateTime.now().year - 1980,
              (index) => (DateTime.now().year - index).toString()),
          List.generate(DateTime.now().year - 1980,
              (index) => (DateTime.now().year - index).toString()),
          controller.tecs[8],
          "Car Year"),
      CustomTextField2("License Plate No", controller.tecs[9],
          prefix: Icons.web_asset_rounded),
      CustomTextField2("Chassis No", controller.tecs[9],
          prefix: Icons.web_asset_rounded),
    ];
  }

  List<Widget> concernDetails() {
    return [
      CustomTextField2(
        "Describe Customer Concern",
        controller.tecs[11],
        varl: FPL.multi,
      ),
    ];
  }

  List<Widget> carConditonDetails() {
    return [
      Builder(builder: (context) {
        RxString curImg = "".obs;
        return SizedBox(
          width: wideUi(context),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField2(
                        "Mileage At Reception", controller.tecs[12],
                        prefix: Icons.drive_eta_rounded),
                    CustomTextField2(
                      "Fuel Level At Reception",
                      controller.tecs[13],
                      prefix: Icons.local_gas_station_rounded,
                      hasBottomPadding: false,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Obx(() {
                  final cc = CurvedContainer(
                      border: Border.all(color: AppColors.grey),
                      onPressed: () async {
                        final img = await UtilFunctions.showCamera();
                        if (img != null) {
                          curImg.value = img;
                        }
                      },
                      padding: EdgeInsets.all(curImg.value.isNotEmpty ? 0 : 24),
                      margin: EdgeInsets.all(24),
                      child: curImg.value.isNotEmpty
                          ? Image.file(
                              File(curImg.value),
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: AppIcon(
                              Icons.add_a_photo,
                              size: Ui.width(context) < 750 ? 24 : 48,
                            )));
                  if (curImg.value.isNotEmpty) {
                    return Stack(
                      children: [
                        cc,
                        Positioned(
                            top: 0,
                            right: 0,
                            child: AppIcon(
                              Icons.remove_circle_rounded,
                              color: Colors.red,
                              onTap: () {
                                curImg.value = "";
                              },
                            ))
                      ],
                    );
                  }
                  return cc;
                }),
              )
            ],
          ),
        );
      }),
      Ui.boxHeight(24),
      CustomTextField2("Visible Damage (Body Check)", controller.tecs[14],
          varl: FPL.multi),
      CustomTextField2("Additional Observations", controller.tecs[15],
          varl: FPL.multi),
    ];
  }

  List<Widget> freeInspectionDetails() {
    return [
      CustomTextField2.dropdown(
          controller.allServiceAdvisor.map((element) => element.fullName).toList(),controller.allServiceAdvisor.map((element) => element.id).toList(), controller.tecs[16], "Select Service Advisor"),
      CustomTextField2.dropdown(
         controller.allTechnicians.map((element) => element.fullName).toList(),controller.allTechnicians.map((element) => element.id).toList(), controller.tecs[17], "Select Technician"),
      Ui.align(child: Builder(builder: (context) {
        return Padding(
          padding: EdgeInsets.only(left: Ui.width(context) < 650 ? 42 : 84.0),
          child: AppText.thin("Fill Up 10-Point Free Inspection"),
        );
      })),
      Ui.boxHeight(8),
      Builder(builder: (context) {
        return SizedBox(
          width: wideUi(context),
          child: Obx(() {
            return ExpansionPanelList(
              expansionCallback: (index, isExpanded) {
                controller.totalConditionsExpanded[index] = isExpanded;
              },
              children: List.generate(controller.totalConditionsHeaders.length,
                  (index) {
                return ExpansionPanel(
                    headerBuilder: (_, b) {
                      return Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: AppText.bold(
                                controller.totalConditionsHeaders[index]),
                          ));
                    },
                    canTapOnHeader: true,
                    body: Column(
                      children: List.generate(
                          controller.condItem[controller
                              .totalConditionsHeaders[index]]!, (jindex) {
                        final cstep = controller.inspectionNo[
                            controller.totalConditionsHeaders[index]]![jindex];
                        return Row(
                          children: [
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, top: 8, bottom: 8),
                              child: AppText.thin(cstep.title),
                            )),
                            Checkbox(
                                value: cstep.isChecked,
                                onChanged: (b) {
                                  cstep.isChecked = (b ?? false);
                                  controller.inspectionNo.refresh();
                                }),
                            Ui.boxWidth(24)
                            // Padding(
                            //     padding: EdgeInsets.all(8),
                            //     child: CustomTextField2.dropdown([
                            //       "Good",
                            //       "Repair",
                            //       "Replace"
                            //     ], controller.tecs[cstep.id], "", w: 128))
                          ],
                        );
                      }),
                    ),
                    isExpanded: controller.totalConditionsExpanded[index]);
              }),
            );
          }),
        );
      }),
      Ui.boxHeight(24),
      CustomTextField2(
          "Lost Sales (Share with us items requested that we don't have in stock)",
          controller.tecs[18],
          varl: FPL.multi),
      Builder(
        builder: (context) {
          List<User> sas = controller.allServiceAdvisor.where((p0) => p0.id == int.parse(controller.tecs[16].text)).toList();
          return LockedSignatureWidget(title: "Service Advisor Signature", signature: sas.isEmpty ? "" :  sas.first.signature);
        }
      ),
      Ui.boxHeight(24),
      Builder(
        builder: (context) {
          List<User> sas = controller.allTechnicians.where((p0) => p0.id == int.parse(controller.tecs[17].text)).toList();
          return LockedSignatureWidget(title: "Technician Signature", signature: sas.isEmpty ? "" :  sas.first.signature);
        }
      ),
    ];
  }

  List<Widget> servicePlanDetails() {
    return [
      ...List.generate(
          controller.allBillyServices.length,
          (index) => Builder(builder: (context) {
                return CurvedContainer(
                  radius: 0,
                  color: AppColors.white,
                  margin: const EdgeInsets.only(bottom: 8.0),
                  width: wideUi(context),
                  border: Border.all(
                      color: AppColors.lightTextColor.withOpacity(0.5)),
                  child: Obx(() {
                    return CheckboxListTile(
                      value: controller.allServicesItems[index],
                      onChanged: (b) {
                        controller.allServicesItems[index] = b ?? false;
                      },
                      // activeColor: AppColors.primaryColorLight,
                      // tileColor: AppColors.primaryColorLight,
                      title:
                          AppText.thin(controller.allBillyServices[index].name),
                    );
                  }),
                );
              }))
    ];
  }

  List<Widget> maintenanceDetails() {
    return [
      CustomTextField2("Urgently (Safety)", controller.tecs[19],
          varl: FPL.multi),
      CustomTextField2("Before Next Visit", controller.tecs[20],
          varl: FPL.multi),
      CustomTextField2("During Next Maintenance Service", controller.tecs[21],
          varl: FPL.multi),
      CustomTextField2("Delivery Hour Forecast", controller.tecs[22],
          prefix: Icons.timer),
    ];
  }
}

class CheckList2Header extends StatelessWidget {
  CheckList2Header({super.key});
  final controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LogoWidget(120),
        Obx(() {
          return AppText.medium(controller.currentChecklistMode.value.title,
              fontSize: 32,
              fontFamily: Assets.appFontFamily2,
              alignment: TextAlign.center,
              color: AppColors.textColor);
        }),
        Ui.boxHeight(8),
        Obx(() {
          return AppText.thin(controller.currentChecklistMode.value.desc2,
              fontSize: 15,
              fontFamily: Assets.appFontFamily1,
              color: AppColors.lightTextColor);
        }),
        Ui.boxHeight(12),
        Stack(
          alignment: AlignmentDirectional.center,
          children: [
            CurvedContainer(
              height: 1,
              width: 320,
              color: AppColors.primaryColor,
            ),
            SizedBox(
              width: 320,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(ChecklistModes.values.length, (index) {
                  return Obx(() {
                    if (controller.currentChecklistMode.value.index == index) {
                      return DottedBorder(
                          borderType: BorderType.Circle,
                          radius: Radius.circular(16),
                          dashPattern: [4, 4],
                          color: AppColors.primaryColor,
                          child: Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.white,
                            ),
                            child: Center(
                              child: AppText.thin("${index + 1}",
                                  fontFamily: Assets.appFontFamily1,
                                  color: AppColors.primaryColor),
                            ),
                          ));
                    }
                    return InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      onTap: () {
                        controller.currentChecklistMode.value =
                            ChecklistModes.values[index];
                      },
                      child: Container(
                          height: 32,
                          width: 32,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  controller.currentChecklistMode.value.index >
                                          index
                                      ? AppColors.primaryColor
                                      : AppColors.white,
                              border:
                                  Border.all(color: AppColors.primaryColor)),
                          child: Center(
                            child: AppText.thin("${index + 1}",
                                fontFamily: Assets.appFontFamily1,
                                color: controller
                                            .currentChecklistMode.value.index <
                                        index
                                    ? AppColors.primaryColor
                                    : AppColors.white),
                          )),
                    );
                  });
                }),
              ),
            )
          ],
        ),
        Ui.boxHeight(24)
      ],
    );
  }
}
