import 'package:flutter/cupertino.dart';
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
import 'package:inventory/views/explorer/dashboard_page.dart';
import 'package:inventory/views/shared.dart';

import '../../tools/assets.dart';
import '../checklist/profile.dart';

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
      ExpDashboardPage(),
      CustomTablePage([
        HeaderItem("Orders", vb: () {
          controller.setCurrentTypeTable<Order>();
        }),
        HeaderItem("Customers", vb: () {
          controller.setCurrentTypeTable<Customer>();
        }),
        HeaderItem("Customer Cars", vb: () {
          controller.setCurrentTypeTable<CustomerCar>();
        }),
        HeaderItem("Invoice", vb: () {
          controller.setCurrentTypeTable<Invoice>();
        })
      ]),
      CustomTablePage(
        [
          HeaderItem("Products", vb: () {
            controller.setCurrentTypeTable<Product>();
          }),
          HeaderItem("Categories", vb: () {
            controller.setCurrentTypeTable<ProductCategory>();
          }),
          HeaderItem("Types", vb: () {
            controller.setCurrentTypeTable<ProductType>();
          }),
          HeaderItem("Supplier", vb: () {
            controller.setCurrentTypeTable<Supplier>();
          })
        ],
      ),
      CustomTablePage(
        [
          HeaderItem("Inventory", vb: () {
            controller.setCurrentTypeTable<Inventory>();
          }),
          
           HeaderItem("Bulk Expenses", vb: () {
            controller.setCurrentTypeTable<BulkExpenses>();
          }),
           
           HeaderItem("Stock Balances", vb: () {
            controller.setCurrentTypeTable<InventoryMetricStockBalances>();
          }),
            HeaderItem("Finances", vb: () {
            controller.setCurrentTypeTable<InventoryMetricDailyProfit>();
          }),
          
          // HeaderItem("Location", vb: () {
          //   // controller.setCurrentTypeTable<Inventory>();
          // }),
        ],
      ),
      CustomTablePage([
        HeaderItem("Car Brands", vb: () {
          controller.setCurrentTypeTable<CarMake>();
        }),
        HeaderItem("Car Models", vb: () {
          controller.setCurrentTypeTable<CarModels>();
        }),
        HeaderItem("Services", vb: () {
          controller.setCurrentTypeTable<BillyServices>();
        }),
        HeaderItem("Expenses Types", vb: () {
            controller.setCurrentTypeTable<ExpensesType>();
          }),
        HeaderItem("Inspection Details", vb: () {
          controller.setCurrentTypeTable<BillyConditions>();
        }),
        HeaderItem("Inspection Category", vb: () {
          controller.setCurrentTypeTable<BillyConditionCategory>();
        }),
        
      ]),

        if(controller.appRepo.appService.currentUser.value.isAdmin)
      CustomTablePage([
        HeaderItem("Markups & Targets", vb: () {
          controller.setCurrentTypeTable<AppConstants>();
        },),
         HeaderItem("Expenses", vb: () {
            controller.setCurrentTypeTable<Expenses>();
          }),
        // HeaderItem("Reports", vb: () {
        //   controller.setCurrentTypeTable<BillyConditions>();
        // }),
        HeaderItem("Users", vb: () {
          controller.setCurrentTypeTable<User>();
        }),
        
        HeaderItem("Login History", vb: () {
          controller.setCurrentTypeTable<LoginHistory>();
        })
       
      ]),
    ];
    controller.refreshModels();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConnectivityWidget(
        child: Stack(
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
      ),
    );
  }

  header() {
    final cl = List.generate(screens.length, (i) {
            return Obx(() {
              return CurvedContainer(
                radius: 64,
                onPressed: () {
                  controller.currentDashboardMode.value =
                      DashboardModes.values[i];
                },
                color: controller.currentDashboardMode.value ==
                        DashboardModes.values[i]
                    ? AppColors.primaryColor
                    : AppColors.transparent,
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: (Ui.width(context) < 975 ? 8 :24),),
                border: Border.all(
                    color: controller.currentDashboardMode.value ==
                            DashboardModes.values[i]
                        ? AppColors.white
                        : AppColors.transparent),
                margin: EdgeInsets.symmetric(horizontal: (Ui.width(context) >= 975 ? 8 :4)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcon(DashboardModes.values[i].icon,
                        color: controller.currentDashboardMode.value ==
                                DashboardModes.values[i]
                            ? AppColors.white
                            : AppColors.primaryColorLight),
                    if(Ui.width(context) >= 975)
                    Ui.boxWidth(8),
                    if(Ui.width(context) >= 975)
                    AppText.bold(DashboardModes.values[i].title,
                        fontSize: 14,
                        color: controller.currentDashboardMode.value ==
                                DashboardModes.values[i]
                            ? AppColors.white
                            : AppColors.primaryColorLight)
                  ],
                ),
              );
            });
          });
    return Container(
      color: AppColors.primaryColor,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: BackButton(
              color: AppColors.white,
            ),
          ),
          Ui.boxWidth(24),
          Ui.boxHeight(56),
          // LogoWidget(64, isWhite: false),
          Spacer(),
          ...cl,
          Ui.boxWidth(24),
          InkWell(
              onTap: () {
                Get.find<AppController>().editOn.value = false;
                Get.to(ProfilePage());
              },
              child: ProfileLogo()),
          Ui.boxWidth(24),
        ],
      ),
    );
  }
}
