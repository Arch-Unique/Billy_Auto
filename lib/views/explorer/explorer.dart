import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:inventory/controllers/app_controller.dart';
import 'package:inventory/models/inner_models/barrel.dart';
import 'package:inventory/models/table_repo.dart';
import 'package:inventory/tools/colors.dart';
import 'package:inventory/tools/enums.dart';
import 'package:inventory/tools/service.dart';
import 'package:inventory/views/explorer/admin_page.dart';
import 'package:inventory/views/shared.dart';

import '../../tools/assets.dart';

class ExplorerPage extends StatefulWidget {
  const ExplorerPage({super.key});

  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  List<Widget> screens = [];
  final controller = Get.find<AppController>();

  @override
  void initState() {
    // TODO: implement initState
    screens = [
      
      Placeholder(),
      CustomTablePage<Inventory>([HeaderChooser([HeaderItem("Inventory"),HeaderItem("Inbound"),HeaderItem("Outbound")])],),
      CustomTablePage<Product>( [HeaderChooser([HeaderItem("Products"),HeaderItem("Categories"),HeaderItem("Types")])],),
      CustomTablePage<Order>([HeaderChooser([HeaderItem("Orders"),HeaderItem("Custoomers"),HeaderItem("Customer Cars")])],),
      Placeholder(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Opacity(
                opacity: 0.5,
                child: Image.asset(
                  Assets.backge,
                  fit: BoxFit.cover,
                  width: Ui.width(context),
                  height: Ui.height(context),
                )),
                Container(
              width: Ui.width(context),
              height: Ui.height(context),
              color: AppColors.white.withOpacity(0.7),
            ),
          Column(
            children: [
              header(),
              Expanded(child: Obx(() {
                return screens[controller.currentDashboardMode.value.index];
              }))
            ],
          ),
        ],
      ),
    );
  }

  header(){
    return Container(
      color: AppColors.primaryColor,
      child: Row(
              children: [
                BackButton(),
                Ui.boxWidth(24),
                LogoWidget(64,isWhite:  false),
                Spacer(),
                ...List.generate(DashboardModes.values.length, (i) {
                  return Obx(() {
                    return CurvedContainer(
                      radius: 64,
                      onPressed: (){
                        controller.currentDashboardMode.value =
                                  DashboardModes.values[i];
                      },
                      color: controller.currentDashboardMode.value ==
                                  DashboardModes.values[i]
                              ? AppColors.primaryColor
                              : AppColors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 8,horizontal: 24),
                      border: Border.all(
                          color: controller.currentDashboardMode.value ==
                                  DashboardModes.values[i]
                              ? AppColors.white
                              : AppColors.transparent),
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(DashboardModes.values[i].icon,
                              color: controller.currentDashboardMode.value ==
                                      DashboardModes.values[i]
                                  ? AppColors.white
                                  : AppColors.primaryColorLight),
                          Ui.boxWidth(8),
                          AppText.bold(DashboardModes.values[i].title,
                          fontSize:14,
                              color: controller.currentDashboardMode.value ==
                                      DashboardModes.values[i]
                                  ? AppColors.white
                                  : AppColors.primaryColorLight)
                        ],
                      ),
                    );
                  });
                }),
                 Ui.boxWidth(24),
                 ProfileLogo(),
                 Ui.boxWidth(24),
              ],
            ),
    );
  }
}

