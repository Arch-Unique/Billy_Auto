import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/controllers/app_controller.dart';
import 'package:inventory/tools/enums.dart';
import 'package:inventory/views/checklist/order_summary.dart';
import 'package:inventory/views/shared.dart';

import '../../tools/assets.dart';
import '../../tools/colors.dart';

class CheckListPage extends StatefulWidget {
  const CheckListPage({super.key});

  @override
  State<CheckListPage> createState() => _CheckListPageState();
}

class _CheckListPageState extends State<CheckListPage> {
  final controller = Get.find<AppController>();
  List<dynamic> screens = [];
  bool shouldPop = false;

  @override
  void initState() {
    screens = [
      customerDetails(),
      carDetails(),
      concernDetails(),
      carConditonDetails(),
      freeInspectionDetails(),
      servicePlanDetails(),
      maintenanceDetails()
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(Ui.width(context));
    return PopScope(
      canPop: shouldPop,
      onPopInvoked: (dp) {
        if (controller.currentChecklistMode.value.index > 0 &&
            controller.currentChecklistMode.value.index <
                ChecklistModes.values.length) {
          controller.currentChecklistMode.value = ChecklistModes
              .values[controller.currentChecklistMode.value.index - 1];
        }

        if(controller.currentChecklistMode.value.index == 0){
          setState(() {
            shouldPop=true;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: Obx(() {
            return AppText.bold(
                "CheckList ${controller.currentChecklistMode.value.index + 1}/${ChecklistModes.values.length}",
                color: AppColors.white);
          }),
          elevation: 0,
          foregroundColor: AppColors.white,
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: AppIcon(Icons.history, color: AppColors.white),
            )
          ],
        ),
        body: Stack(
          children: [
            Opacity(
                opacity: 0.16,
                child: Image.asset(
                  Assets.backg,
                  fit: BoxFit.cover,
                  width: Ui.width(context),
                  height: Ui.height(context),
                )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header(),
                Expanded(
                    child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Obx(() {
                    return Column(
                      children:
                          screens[controller.currentChecklistMode.value.index],
                    );
                  }),
                )),
                Ui.boxHeight(24),
                Ui.padding(
                  child: Obx(() {
                    return AppButton(
                      onPressed: () {
                        if (controller.currentChecklistMode.value.index >= 0 &&
                            controller.currentChecklistMode.value.index <
                                ChecklistModes.values.length - 1) {
                          controller.currentChecklistMode.value = ChecklistModes
                                  .values[
                              controller.currentChecklistMode.value.index + 1];
                        }
                        if (controller.currentChecklistMode.value.index ==
                            ChecklistModes.values.length - 1) {
                              Get.to(OrderSummary());
                            }
                      },
                      text: controller.currentChecklistMode.value.index ==
                              ChecklistModes.values.length - 1
                          ? "Submit"
                          : "Continue",
                    );
                  }),
                ),
                Ui.boxHeight(24),
              ],
            ),
          ],
        ),
      ),
    );
  }

  header() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
                7,
                (index) => Obx(() {
                      return CurvedContainer(
                        height: 8,
                        onPressed: () {
                          controller.currentChecklistMode.value =
                              ChecklistModes.values[index];
                        },
                        width: Ui.width(context) / 8,
                        color:
                            controller.currentChecklistMode.value.index >= index
                                ? AppColors.green
                                : AppColors.white,
                        margin: EdgeInsets.symmetric(vertical: 8),
                      );
                    })),
          ),
          Obx(() {
            return AppText.bold(controller.currentChecklistMode.value.title,
                color: AppColors.white);
          }),
          Obx(() {
            return AppText.thin(controller.currentChecklistMode.value.desc,
                color: AppColors.white);
          }),
        ],
      ),
    );
  }

  List<Widget> customerDetails() {
    return [
      CustomTextField.dropdown(["None"], controller.tecs[5],
          "Select Customer (Only if the customer exist)"),
     
      Align(
          alignment: Alignment.center,
          child: AppText.thin("Or register a new customer")),
      Ui.boxHeight(32),
      CustomTextField(
        "Full Name",
        controller.tecs[0],
        prefix: Icons.person_4_outlined,
      ),
      CustomTextField("Email", controller.tecs[1],
          varl: FPL.email, prefix: Icons.email_rounded),
      CustomTextField("Phone", controller.tecs[2],
          varl: FPL.phone, prefix: Icons.phone_iphone_rounded),
      CustomTextField.dropdown(
          ["Individual", "Corporate"], controller.tecs[3], "Customer Type"),
      //Signature
      SignatureView(controller.userSig, "Customer Signature")
    ];
  }

  List<Widget> carDetails() {
    return [
      CustomTextField.dropdown(["None"], controller.tecs[10],
          "Select Customer Car (Only if the customer car exist)"),
      Align(
          alignment: Alignment.center,
          child: AppText.thin("Or register a new customer car")),
      Ui.boxHeight(32),
      CustomTextField.dropdown(
          ["Toyota", "Mazda"], controller.tecs[6], "Car Make"),
      CustomTextField.dropdown(["Camry", "H"], controller.tecs[7], "Car Model"),
      CustomTextField.dropdown(
          List.generate(DateTime.now().year - 1980,
              (index) => (DateTime.now().year - index).toString()),
          controller.tecs[8],
          "Car Year"),
      CustomTextField("License Plate No", controller.tecs[9],
          prefix: Icons.web_asset_rounded),
    ];
  }

  List<Widget> concernDetails() {
    return [
      CustomTextField(
        "Describe Customer Concern",
        controller.tecs[11],
        varl: FPL.multi,
      ),
    ];
  }

  List<Widget> carConditonDetails() {
    return [
      Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            CustomTextField("Mileage At Reception", controller.tecs[12],
            prefix: Icons.drive_eta_rounded),
                  CustomTextField("Fuel Level At Reception", controller.tecs[13],
            prefix: Icons.local_gas_station_rounded),
              ],
            ),
          ),
          Builder(
            builder: (context) {
              return CurvedContainer(
                border: Border.all(color: AppColors.grey),
                width: Ui.width(context)/3,
                height: 156,
                padding: EdgeInsets.all(24),
                margin: EdgeInsets.all(24),
                child: Center(child: AppIcon(Icons.add_a_photo,size: 48,)));
            }
          )
        ],
      ),
      
      CustomTextField("Visible Damage (Body Check)", controller.tecs[14],
          varl: FPL.multi),
      CustomTextField("Additional Observations", controller.tecs[15],
          varl: FPL.multi),
    ];
  }

  List<Widget> freeInspectionDetails() {
    return [
      CustomTextField.dropdown(
          ["Ade", "Harry"], controller.tecs[16], "Select Service Advisor"),
      CustomTextField.dropdown(
          ["Ade", "Tunde"], controller.tecs[17], "Select Technician"),
      Ui.align(
          child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: AppText.thin("Fill Up 10-Point Free Inspection"),
      )),
      Ui.boxHeight(8),
      Ui.padding(
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
                        controller.totalConditionsItems[index], (jindex) {
                      final cstep = controller.allSteps[
                          controller.totalConditionsItemsZero.sublist(0,index+1).reduce((value, element) => value+element) + jindex];
                      return Row(
                        children: [
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.only(left: 16.0,top: 8,bottom: 8),
                            child: AppText.thin(cstep.title),
                          )),
                          Checkbox(value: cstep.isChecked, onChanged: (b){
                            cstep.isChecked = (b?? false);
                            controller.allSteps.refresh();
                          }),
                          Ui.boxWidth(24)
                          // Padding(
                          //     padding: EdgeInsets.all(8),
                          //     child: CustomTextField.dropdown([
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
      ),
      Ui.boxHeight(24),
      CustomTextField(
          "Lost Sales (Share with us items requested that we don't have in stock)",
          controller.tecs[18],
          varl: FPL.multi),
      SignatureView(controller.advSig, "Service Advisor Signature"),
      Ui.boxHeight(24),
      SignatureView(controller.techSig, "Technician Signature"),
    ];
  }

  List<Widget> servicePlanDetails() {
    return [
      ...List.generate(
          controller.allServices.length,
          (index) => CurvedContainer(
                radius: 0,
                color: AppColors.primaryColorLight,
                margin: const EdgeInsets.only(bottom: 8.0),
                child: Obx(() {
                  return CheckboxListTile(
                    value: controller.allServicesItems[index],
                    onChanged: (b) {
                      controller.allServicesItems[index] = b ?? false;
                    },
                    // activeColor: AppColors.primaryColorLight,
                    // tileColor: AppColors.primaryColorLight,
                    title: AppText.thin(controller.allServices[index]),
                  );
                }),
              ))
    ];
  }

  List<Widget> maintenanceDetails() {
    return [
      CustomTextField("Urgently (Safety)", controller.tecs[19],
          varl: FPL.multi),
      CustomTextField("Before Next Visit", controller.tecs[20],
          varl: FPL.multi),
      CustomTextField("During Next Maintenance Service", controller.tecs[21],
          varl: FPL.multi),
      CustomTextField("Delivery Hour Forecast", controller.tecs[22],
          prefix: Icons.timer),
    ];
  }

}
