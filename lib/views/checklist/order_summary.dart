import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/controllers/app_controller.dart';
import 'package:inventory/tools/colors.dart';
import 'package:inventory/views/shared.dart';

import '../../tools/assets.dart';

class OrderSummary extends StatefulWidget {
  const OrderSummary({super.key});

  @override
  State<OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  final controller = Get.find<AppController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
          SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                LogoWidget(100),
                AppText.bold("BILLY'S AUTO SERVICE ORDER",
                    fontSize: 32, att: true, alignment: TextAlign.center),
                Ui.boxHeight(16),
                serviceItem(
                    "CUSTOMER",
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleValueText("Full Name", controller.tecs[0].text),
                        titleValueText("Email", controller.tecs[1].text),
                        titleValueText("Phone Number", controller.tecs[2].text),
                        titleValueText(
                            "Customer Type", controller.tecs[3].text),
                      ],
                    )),
                serviceItem(
                    "VEHICLE",
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleValueText("Make", controller.tecs[6].text),
                        titleValueText("Mode", controller.tecs[7].text),
                        titleValueText("Year", controller.tecs[8].text),
                        titleValueText(
                            "License Plate No", controller.tecs[9].text),
                      ],
                    )),
                serviceItem(
                    "CONCERNS",
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [AppText.thin(controller.tecs[11].text)],
                    )),
                serviceItem(
                    "VEHICLE CONDTION",
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleValueText(
                            "Mileage At Reception", controller.tecs[12].text),
                        titleValueText("Fuel Level At Reception",
                            controller.tecs[13].text),
                        titleValueText(
                            "Visible Damage ", controller.tecs[14].text),
                        titleValueText(
                            "Additonal Observations", controller.tecs[15].text),
                      ],
                    )),
                serviceItem("SERVICE PLAN", Builder(builder: (context) {
                  List<int> goodService = [];
                  for (var i = 0; i < controller.allServicesItems.length; i++) {
                    if (controller.allServicesItems[i]) {
                      goodService.add(i);
                    }
                  }
                  return SizedBox(
                    height: 100,
                    child: Wrap(
                      direction: Axis.vertical,
                      children: goodService
                          .map((e) => AppText.thin(controller.allServices[e]))
                          .toList(),
                    ),
                  );
                })),
                serviceItem("CONTROL CHECKS", Builder(builder: (context) {
                  List<Widget> controlChecks = [];
                  controller.inspectionNo.forEach((key, value) {
                    controlChecks.add(Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.bold(key),
                        ...List.generate(value.length, (index) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            
                        AppText.thin(value[index].title),
                            Ui.boxWidth(16),
                            value[index].isChecked ? AppIcon(Icons.check,color: AppColors.green,) : AppIcon(Icons.close,color: AppColors.primaryColor,)
                          ],
                        ))
                      ],
                    ));
                  });
                  
                  return Wrap(
                    children: controlChecks,
                  );
                })),
                serviceItem(
                    "VEHICLE CONDTION",
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleValueText(
                            "Urgent Maintenance", controller.tecs[19].text),
                        titleValueText(
                            "Before Next Visit", controller.tecs[20].text),
                        titleValueText("During Next Maintenance Service ",
                            controller.tecs[21].text),
                        titleValueText(
                            "Delivery hour Forecast", controller.tecs[21].text),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  serviceItem(String title, Widget item) {
    return CurvedContainer(
      radius: 16,
      padding: EdgeInsets.only(left: 24),
      margin: EdgeInsets.only(bottom: 24),
      color: AppColors.primaryColor.withOpacity(0.5),
      child: Row(
        children: [
          SizedBox(
              width: Ui.width(context) / 4,
              child: Center(
                  child: AppText.bold(title,
                      fontSize: 24,
                      att: true,
                      color: AppColors.black,
                      alignment: TextAlign.center))),
          Ui.boxWidth(24),
          Expanded(
              child: CurvedContainer(
                  padding: EdgeInsets.all(16),
                  border: Border.all(color: AppColors.primaryColor),
                  color: AppColors.white,
                  child: item))
        ],
      ),
    );
  }

  titleValueText(String key, String value) {
    // if(value.isEmpty) return const SizedBox();
    return Text.rich(TextSpan(
        text: "$key : ",
        style: TextStyle(
            color: AppColors.black, fontWeight: FontWeight.w500, fontSize: 16),
        children: [
          TextSpan(
            text: value,
            style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w400,
                fontSize: 16),
          )
        ]));
    // return Row(
    //   children: [AppText.bold("$key :"), Ui.boxWidth(8), AppText.thin(value)],
    // );
  }
}
