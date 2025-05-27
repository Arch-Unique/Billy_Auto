import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:inventory/controllers/app_controller.dart';
import 'package:inventory/models/inner_models/barrel.dart';
import 'package:inventory/models/inner_models/reports.dart';
import 'package:inventory/models/table_repo.dart';
import 'package:inventory/repo/app_repo.dart';
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
  final perm = Get.find<AppController>()
      .allUserRoles
      .where((e) =>
          e.id == Get.find<AppRepo>().appService.currentUser.value.roleId)
      .firstOrNull;

  @override
  void initState() {
    print(perm?.name);
    print(perm?.perms);
    // TODO: implement initState
    screens = [
      ExpDashboardPage(),
      CustomTablePage([
        // if (perm?.perms[AllTables.tablesType.indexOf(Order)][1] ==
        //     1)
          HeaderItem("Orders", vb: () {
            controller.setCurrentTypeTable<Order>();
          }),
        if (perm?.perms[AllTables.tablesType.indexOf(Customer)]
                [1] ==
            1)
          HeaderItem("Customers", vb: () {
            controller.setCurrentTypeTable<Customer>();
          }),
        if (perm?.perms[AllTables.tablesType.indexOf(CustomerCar)]
                [1] ==
            1)
          HeaderItem("Customer Cars", vb: () {
            controller.setCurrentTypeTable<CustomerCar>();
          }),
        if (perm?.perms[AllTables.tablesType.indexOf(Invoice)]
                [1] ==
            1)
          HeaderItem("Invoice", vb: () {
            controller.setCurrentTypeTable<Invoice>();
          })
      ]),
      CustomTablePage(
        [
          
            HeaderItem("Lube Dashboard", vb: () {
              controller.setCurrentTypeTable<AppConstants>(v: 0);
            }),
            HeaderItem("Lube Inventory", vb: () {
              controller.setCurrentTypeTable<LubeInventory>();
            }),
         

        ],
      ),
      CustomTablePage(
        [
          // if (perm?.perms[AllTables.tablesType.indexOf(Product)]
          //         [1] ==
          //     1)
            HeaderItem("Products", vb: () {
              controller.setCurrentTypeTable<Product>();
            }),
          if (perm?.perms[AllTables.tablesType
                  .indexOf(ProductCategory)][1] ==
              1)
            HeaderItem("Categories", vb: () {
              controller.setCurrentTypeTable<ProductCategory>();
            }),
          if (perm?.perms[
                  AllTables.tablesType.indexOf(ProductType)][1] ==
              1)
            HeaderItem("Types", vb: () {
              controller.setCurrentTypeTable<ProductType>();
            }),
          if (perm?.perms[AllTables.tablesType.indexOf(Supplier)]
                  [1] ==
              1)
            HeaderItem("Supplier", vb: () {
              controller.setCurrentTypeTable<Supplier>();
            })
        ],
      ),
      CustomTablePage(
        [
          // if (perm?.perms[AllTables.tablesType.indexOf(Inventory)]
          //         [1] ==
          //     1)
            HeaderItem("Inventory", vb: () {
              controller.setCurrentTypeTable<Inventory>();
            }),
          // if (perm?.perms[AllTables.tablesType.indexOf(Expenses)]
          //         [1] ==
          //     1)
          //   HeaderItem("Bulk Expenses", vb: () {
          //     controller.setCurrentTypeTable<BulkExpenses>();
          //   }),
          if (perm?.perms[AllTables.tablesType.indexOf(Inventory)]
                  [1] ==
              1)
            HeaderItem("Stock Balances", vb: () {
              controller.setCurrentTypeTable<InventoryMetricStockBalances>();
            }),
          if (perm?.perms[AllTables.tablesType.indexOf(Inventory)]
                  [1] ==
              1)
            HeaderItem("Finances", vb: () {
              controller.setCurrentTypeTable<InventoryMetricDailyProfit>();
            }),

          // HeaderItem("Location", vb: () {
          //   // controller.setCurrentTypeTable<Inventory>();
          // }),
        ],
      ),
      CustomTablePage([
        // if (perm?.perms[AllTables.tablesType.indexOf(CarMake)]
        //         [1] ==
        //     1)
          HeaderItem("Car Brands", vb: () {
            controller.setCurrentTypeTable<CarMake>();
          }),
        if (perm?.perms[AllTables.tablesType.indexOf(CarModels)]
                [1] ==
            1)
          HeaderItem("Car Models", vb: () {
            controller.setCurrentTypeTable<CarModels>();
          }),
        if (perm?.perms[
                AllTables.tablesType.indexOf(BillyServices)][1] ==
            1)
          HeaderItem("Services", vb: () {
            controller.setCurrentTypeTable<BillyServices>();
          }),
        if (perm?.perms[
                AllTables.tablesType.indexOf(ExpensesType)][1] ==
            1)
          HeaderItem("Expenses Types", vb: () {
            controller.setCurrentTypeTable<ExpensesType>();
          }),
        if (perm?.perms[AllTables.tablesType
                .toList()
                .indexOf(BillyConditions)][1] ==
            1)
          HeaderItem("Inspection Details", vb: () {
            controller.setCurrentTypeTable<BillyConditions>();
          }),
        if (perm?.perms[AllTables.tablesType
                .toList()
                .indexOf(BillyConditionCategory)][1] ==
            1)
          HeaderItem("Inspection Category", vb: () {
            controller.setCurrentTypeTable<BillyConditionCategory>();
          }),
      ]),
      if (controller.appRepo.appService.currentUser.value.isAdmin)
        CustomTablePage([
          if (perm?.perms[AllTables.tablesType
                  .indexOf(AppConstants)][1] ==
              1)
            HeaderItem(
              "Markups & Targets",
              vb: () {
                controller.setCurrentTypeTable<AppConstants>();
              },
            ),
          if (perm?.perms[AllTables.tablesType.indexOf(Expenses)]
                  [1] ==
              1)
            HeaderItem("Expenses", vb: () {
              controller.setCurrentTypeTable<Expenses>();
            }),
          if (perm?.perms[AllTables.tablesType.indexOf(Reports)]
                  [1] ==
              1)
            HeaderItem("Reports", vb: () {
              controller.setCurrentTypeTable<Reports>();
            }),
          if (perm?.perms[AllTables.tablesType.indexOf(User)]
                  [1] ==
              1)
            HeaderItem("Users", vb: () {
              controller.setCurrentTypeTable<User>();
            }),
          if (perm?.perms[AllTables.tablesType.indexOf(UserRole)]
                  [1] ==
              1)
            HeaderItem("User Roles & Permissions", vb: () {
              controller.setCurrentTypeTable<UserRole>();
            }),
          if (perm?.perms[AllTables.tablesType.indexOf(Locations)]
                  [1] ==
              1)
            HeaderItem("Locations", vb: () {
              controller.setCurrentTypeTable<Locations>();
            }),
          if (perm?.perms[AllTables.tablesType.indexOf(Stations)]
                  [1] ==
              1)
            HeaderItem("Stations", vb: () {
              controller.setCurrentTypeTable<Stations>();
            }),
          if (perm?.perms[AllTables.tablesType
                  .indexOf(LoginHistory)][1] ==
              1)
            HeaderItem("Login History", vb: () {
              controller.setCurrentTypeTable<LoginHistory>();
            }),
          if (perm?.perms[AllTables.tablesType
                  .indexOf(UserAttendance)][1] ==
              1)
            HeaderItem("Attendance History", vb: () {
              controller.setCurrentTypeTable<UserAttendance>();
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
            controller.currentDashboardMode.value = DashboardModes.values[i];
          },
          color:
              controller.currentDashboardMode.value == DashboardModes.values[i]
                  ? AppColors.primaryColor
                  : AppColors.transparent,
          padding: EdgeInsets.symmetric(
            vertical: 8,
            horizontal: (Ui.width(context) < 975 ? 8 : 24),
          ),
          border: Border.all(
              color: controller.currentDashboardMode.value ==
                      DashboardModes.values[i]
                  ? AppColors.white
                  : AppColors.transparent),
          margin: EdgeInsets.symmetric(
              horizontal: (Ui.width(context) >= 975 ? 8 : 4)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(DashboardModes.values[i].icon,
                  color: controller.currentDashboardMode.value ==
                          DashboardModes.values[i]
                      ? AppColors.white
                      : AppColors.primaryColorLight),
              if (Ui.width(context) >= 975) Ui.boxWidth(8),
              if (Ui.width(context) >= 975)
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
