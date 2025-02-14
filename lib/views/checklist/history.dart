import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/controllers/app_controller.dart';
import 'package:inventory/tools/colors.dart';
import 'package:inventory/views/checklist/order_summary.dart';
import 'package:inventory/views/checklist/shared2.dart';
import 'package:inventory/views/shared.dart';

import '../../models/inner_models/barrel.dart';
import '../../tools/assets.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Order> orders = Get.find<AppController>().allOrders;
    
    orders.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

    return Scaffold(
        body: BackgroundScaffold(
          hasBack: true,
            child: Column(children: [
      LogoWidget(144),
      AppText.medium("Order History",
          fontSize: 32,
          alignment: TextAlign.center,
          fontFamily: Assets.appFontFamily2),
      Ui.boxHeight(24),
      Ui.boxWidth(Ui.width(context)),
      Expanded(
          child: orders.isEmpty ? Center(child: AppText.bold("No Orders Found"),) : ListView.builder(
        itemBuilder: (_, i) {
          final order = orders[i];
          return SizedBox(
            width: wideUi(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 24),
              child: ListTile(
              selectedTileColor: order.isDispatched ? AppColors.green: AppColors.primaryColor,
              selected: true,
                leading: AppIcon(
                  Icons.widgets_rounded,
                  color: AppColors.primaryColor,
                ),
                title: AppText.bold(order.title),
                subtitle: AppText.thin(order.desc),
                onTap: (){
                  Get.to(OrderSummary(order));
                },
              ),
            ),
          );
        },
        itemCount: orders.length,
      ))
    ])));
  }
}
