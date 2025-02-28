import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/controllers/app_controller.dart';
import 'package:inventory/tools/colors.dart';
import 'package:inventory/views/checklist/order_summary.dart';
import 'package:inventory/views/checklist/shared2.dart';
import 'package:inventory/views/shared.dart';

import '../../models/inner_models/barrel.dart';
import '../../tools/assets.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List<Order> orders = Get.find<AppController>().allOrders;
  RxList<Order> suggestions = <Order>[].obs;

  final tec = TextEditingController();
  final tec2 = TextEditingController();

  @override
  void initState() {
    suggestions.value = List.from(orders);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BackgroundScaffold(
            hasBack: true,
            child: Column(children: [
              
                Ui.boxWidth(24),
              LogoWidget(144),
              AppText.medium("Order History",
                  fontSize: 32,
                  alignment: TextAlign.center,
                  fontFamily: Assets.appFontFamily2),
              Ui.boxHeight(24),
              Ui.boxWidth(Ui.width(context)),
              Expanded(
                  child: orders.isEmpty
                      ? Center(
                          child: AppText.bold("No Orders Found"),
                        )
                      : ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 850),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Ui.boxWidth(24),
                                  Expanded(
                                      child: CustomTextField2(
                                    "Search",
                                    tec,
                                    hasBottomPadding: false,
                                    customOnChanged: () {
                                      if (tec.text.trim().isEmpty) {
                                        suggestions.value = List.from(orders);
                                      } else {
                                        suggestions.value = orders
                                            .where((element) =>
                                                element.customer
                                                    .toLowerCase()
                                                    .contains(tec.text
                                                        .toLowerCase()) ||
                                                element.car
                                                    .toLowerCase()
                                                    .contains(tec.text
                                                        .toLowerCase()) ||
                                                (element.customerConcerns
                                                            ?.toLowerCase() ??
                                                        "")
                                                    .contains(
                                                        tec.text.toLowerCase()))
                                            .toList();
                                      }
                                      suggestions.refresh();
                                    },
                                  )),
                                  Ui.boxWidth(24),
                                  Expanded(
                                      child: CustomTextField2(
                                    "Date Range",
                                    tec2,
                                    hasBottomPadding: false,
                                    readOnly: true,
                                    onTap: () async {
                                      final dtr = await showDateRangePicker(
                                          context: context,
                                          firstDate: DateTime(1980),
                                          lastDate: DateTime.now());

                                      if (dtr != null) {
                                        suggestions.value = orders
                                            .where((element) =>
                                                element.createdAt!
                                                    .isAfter(dtr.start) &&
                                                element.createdAt!
                                                    .isBefore(dtr.end))
                                            .toList();
                                        tec2.text =
                                            "${DateFormat("dd/MM/yyyy").format(dtr.start)} - ${DateFormat("dd/MM/yyyy").format(dtr.end)}";
                                      }
                                      suggestions.refresh();
                                    },
                                  )),
                                  Ui.boxWidth(24),
                                  CurvedContainer(
                                    width: 24,
                                    height: 24,
                                    onPressed: () {
                                      suggestions.value = List.from(orders);
                                      tec.clear();
                                      tec2.clear();
                                      suggestions.refresh();
                                    },
                                    child: Center(
                                        child: Icon(
                                      Icons.close,
                                      color: AppColors.primaryColor,
                                    )),
                                  ),
                                  Ui.boxWidth(24),
                                ],
                              ),
                              Ui.boxHeight(12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Ui.boxHeight(24),
Obx(
   () {
    return AppText.bold("Total Orders : ${suggestions.length}");
  }
),
Ui.boxHeight(24),
Obx(
   () {
    return AppText.bold("Dispatched Orders : ${suggestions.where((p0) => p0.isDispatched).length}",color: AppColors.green);
  }
),
Ui.boxHeight(24),
Obx(
   () {
    return AppText.bold("Pending Orders : ${suggestions.where((p0) => !p0.isDispatched).length}",color: AppColors.primaryColor);
  }
),
Ui.boxHeight(24),
                                ],
                              ),
                              Ui.boxHeight(12),
                              Expanded(
                                child: Obx(() {
                                  return ListView.builder(
                                    itemBuilder: (_, i) {
                                      final order = suggestions[i];
                                      return Material(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 24
                                              ),
                                          child: ListTile(
                                            selectedTileColor: order.isDispatched
                                                ? AppColors.green.withOpacity(0.2)
                                                : AppColors.primaryColor.withOpacity(0.2),
                                            selected: true,
                                            leading: AppIcon(
                                              Icons.widgets_rounded,
                                              color: AppColors.primaryColor,
                                            ),
                                            title: Row(
                                              children: [
                                                AppText.bold(order.title),
                                                Ui.spacer(),
                                                AppText.thin(order.createdAtRaw)
                                              ],
                                            ),
                                            subtitle: AppText.thin(order.desc),
                                            onTap: () {
                                              Get.to(OrderSummary(order));
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: suggestions.length,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ))
            ])));
  }
}
