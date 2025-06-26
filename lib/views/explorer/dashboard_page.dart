import 'dart:math';

import 'package:data_table_2/data_table_2.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:inventory/controllers/app_controller.dart';
import 'package:inventory/models/inner_models/barrel.dart';
import 'package:inventory/models/table_repo.dart';
import 'package:inventory/tools/assets.dart';
import 'package:inventory/tools/colors.dart';
import 'package:inventory/tools/extensions.dart';
import 'package:inventory/views/checklist/shared2.dart';
import 'package:inventory/views/explorer/admin_page.dart';
import 'package:inventory/views/shared.dart';

import '../../models/inner_models/base_model.dart';

List<int> getMonthCounts<T extends BaseModel>(List<T> items) {
  final now = DateTime.now();
  final currentMonth = DateTime(now.year, now.month);
  final previousMonth = now.month == 1
      ? DateTime(now.year - 1, 12)
      : DateTime(now.year, now.month - 1);

  int currentMonthCount = 0;
  int previousMonthCount = 0;

  for (var item in items) {
    final itemMonth = DateTime(item.createdAt!.year, item.createdAt!.month);

    if (itemMonth == currentMonth) {
      currentMonthCount++;
    } else if (itemMonth == previousMonth) {
      previousMonthCount++;
    }
  }

  return [
    currentMonthCount,
    previousMonthCount,
  ];
}

List<num> getSalesMonthCounts(int b) {
  final now = DateTime.now();
  final currentMonth = DateTime(now.year, now.month);
  final previousMonth = now.month == 1
      ? DateTime(now.year - 1, 12)
      : DateTime(now.year, now.month - 1);

  final cm = Get.find<AppController>()
      .allMonthlyProfit
      .firstWhereOrNull((test) => test.date == currentMonth);
  final pm = Get.find<AppController>()
      .allMonthlyProfit
      .firstWhereOrNull((test) => test.date == previousMonth);

  if (cm == null || pm == null) {
    return [1, 1];
  }

  if (b == 0) {
    return [cm.sales, pm.sales];
  } else if (b == 1) {
    return [cm.expenses, pm.expenses];
  } else if (b == 2) {
    return [cm.productCost, pm.productCost];
  } else if (b == 3) {
    return [cm.profit, pm.profit];
  }
  return [1, 1];
}

class ExpDashboardPage extends StatefulWidget {
  const ExpDashboardPage({super.key});

  @override
  State<ExpDashboardPage> createState() => _ExpDashboardPageState();
}

class _ExpDashboardPageState extends State<ExpDashboardPage> {
  final controller = Get.find<AppController>();
  RxInt curChart = 0.obs;
  List<Widget> screens = [];

  @override
  void initState() {
    screens = [
      Builder(builder: (context) {
        return MyBarChart();
      }),
      Builder(builder: (context) {
        return ProfitChart();
      }),
      Builder(builder: (context) {
        return recentOrders();
      })
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cl = Obx(() {
      final cf = [
        itemDataWidget(
            "Total Customers", controller.allCustomer.length.toString(),
            vals: getMonthCounts(controller.allCustomer)),
        itemDataWidget(
            "Total Suppliers", controller.allSuppliers.length.toString(),
            vals: getMonthCounts(controller.allSuppliers)),
        itemDataWidget(
            "Total Products", controller.allProducts.length.toString(),
            vals: getMonthCounts(controller.allProducts)),
        itemDataWidget("Total Orders", controller.allOrders.length.toString(),
            vals: getMonthCounts(controller.allOrders)),
        itemDataWidget(
            "Pending Orders", controller.allPendingOrders.length.toString(),
            vals: getMonthCounts(controller.allPendingOrders)),
        itemDataWidget("Total Revenue", controller.totalSales.toCurrency(),
            vals: getSalesMonthCounts(0)),
        if (controller.appRepo.appService.currentUser.value.isAdmin)
          itemDataWidget(
              "Total Expenses", controller.totalExpenses.toCurrency(),
              vals: getSalesMonthCounts(1)),
        itemDataWidget("Total Cost Of Goods Sold",
            controller.totalProductCost.toCurrency(),
            vals: getSalesMonthCounts(2)),
        if (controller.appRepo.appService.currentUser.value.isAdmin)
          itemDataWidget(
              "Total Gross Profit", controller.totalProfit.toCurrency(),
              vals: getSalesMonthCounts(3)),
      ];
      return
          // Ui.width(context) < 975
          //     ? Wrap(
          //         children: cf
          //             .map((e) => SizedBox(
          //                   width: (Ui.width(context) - 48) / 2,
          //                   child: e,
          //                 ))
          //             .toList(),
          //       )
          //     :
          SmartJustifyRow(runSpacing: 16, spacing: 16, children: cf
              // .map((e) => Flexible(
              //       // width: (Ui.width(context) - 48) / 5,
              //       child: e,
              //     ))
              // .toList(),
              );
    });
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Ui.boxWidth(Ui.width(context)),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.medium(
                        "Welcome back, ${controller.appRepo.appService.currentUser.value.username} 👋",
                        fontSize: 30,
                        fontFamily: Assets.appFontFamily2),
                    AppText.thin(
                        "Quickly access everything you need to keep your shop running smoothly:")
                  ],
                ),
                Ui.boxWidth(48),
                Expanded(child: SizedBox()
                    //     CustomTextField(
                    //   "",
                    //   TextEditingController(),
                    //   hint: "Search",
                    //   suffix: Iconsax.search_normal_1_outline,
                    //   hasBottomPadding: false,
                    // )
                    ),
                Ui.boxWidth(24),
                ProfileLogo(
                  size: 16,
                ),
                // Ui.boxWidth(8),
                // AppText.thin(
                //   controller.appRepo.appService.currentUser.value.username,
                // ),
              ],
            ),
            Ui.boxHeight(24),
            cl,
            if (Ui.width(context) < 975)
              Column(
                children: [
                  SizedBox(
                    height: Ui.height(context) / 2,
                    width: Ui.width(context) - 48,
                    child: MyBarChart(),
                  ),
                  SizedBox(
                    height: Ui.height(context) / 2,
                    width: Ui.width(context) - 48,
                    child: ProfitChart(),
                  )
                ],
              ),
            Ui.boxHeight(6),
            CurvedContainer(
                width: Ui.width(context) < 975
                    ? wideUi(context)
                    : (Ui.width(context) - 24),
                color: AppColors.transparent,
                padding: const EdgeInsets.all(0),
                radius: 0,
                border:
                    Border(bottom: BorderSide(color: AppColors.borderColor)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                        child: HeaderChooser(
                      [
                        HeaderItem("Service Order", vb: () {
                          curChart.value = 0;
                        }),
                        HeaderItem("Financials", vb: () {
                          curChart.value = 1;
                        }),
                        HeaderItem("Recent Orders", vb: () {
                          curChart.value = 2;
                        }),
                      ],
                      shdChangeMode: false,
                    )),
                  ],
                )),
            Ui.boxHeight(6),
            if (Ui.width(context) >= 975)
              SizedBox(
                  height: Ui.height(context),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      children: [
                        Column(
                          children: [
                            CurvedContainer(
                              height: Ui.height(context) / 2,
                              width: ((Ui.width(context) - 280)) - 48,
                              border: Border.all(color: AppColors.borderColor),
                              boxShadows: [
                                BoxShadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                    spreadRadius: 0,
                                    color: AppColors.shadowColor
                                        .withOpacity(0.06)),
                                BoxShadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 3,
                                    spreadRadius: 0,
                                    color:
                                        AppColors.shadowColor.withOpacity(0.1)),
                              ],
                              child: Obx(() {
                                return screens[curChart.value];
                              }),
                            ),
                          ],
                        ),

                        //recentOrders()
                      ],
                    ),
                  ))
          ],
        ),
      ),
    );
  }

  Widget itemDataWidget(String title, String value,
      {String desc = "", List<num> vals = const [1, 1]}) {
    num presentValue = vals[0] == 0 ? 1 : vals[0];
    num oldValue = vals[1] == 0 ? presentValue : vals[1];
    final chg = ((presentValue - oldValue) / oldValue) * 100;
    final cc = Container(
      height: 86,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      width: 185,
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 1),
                blurRadius: 2,
                spreadRadius: 0,
                color: AppColors.shadowColor.withOpacity(0.06)),
            BoxShadow(
                offset: Offset(0, 1),
                blurRadius: 3,
                spreadRadius: 0,
                color: AppColors.shadowColor.withOpacity(0.08)),
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.thin(title,
              fontSize: 12,
              fontFamily: Assets.appFontFamily2,
              att: true,
              color: AppColors.lightTextColor),

          AppText.bold(value, fontSize: 20, att: true),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppIcon(
                  chg > 0
                      ? Iconsax.arrow_up_3_outline
                      : chg == 0
                          ? Icons.compare_arrows_outlined
                          : Iconsax.arrow_down_outline,
                  // ,
                  size: 16,
                  color: chg > 0
                      ? AppColors.green
                      : chg == 0
                          ? AppColors.lightTextColor
                          : AppColors.primaryColor),
              Ui.boxWidth(4),
              AppText.thin("${(chg).ceil()}%",
                  fontSize: 12,
                  att: true,
                  color: chg > 0
                      ? AppColors.green
                      : chg == 0
                          ? AppColors.lightTextColor
                          : AppColors.primaryColor),
              AppText.thin("  vs last month",
                  fontSize: 12, att: true, color: AppColors.lightTextColor),
              Spacer(),
              AppIcon(
                chg > 0
                    ? Assets.c1
                    : chg == 0
                        ? Assets.c3
                        : Assets.c2,
                size: 36,
              )
            ],
          )
          // if (desc.isNotEmpty) AppText.thin(desc)
        ],
      ),
    );

    return cc;
  }

  Widget recentOrders() {
    return SizedBox(
      width: (Ui.width(context) - 280) - 24,
      height: Ui.height(context),
      child: AsyncPaginatedDataTable2(
        minWidth: (Ui.width(context) - 280) - 24,
        hidePaginator: true,
        columnSpacing: 0,
        showCheckboxColumn: false,
        // autoRowsToHeight: true,
        horizontalMargin: 0,
        rowsPerPage: 7,
        wrapInCard: false,
        headingRowHeight: 44,
        columns: ["Date", "Customer", "Car", "Status"]
            .map((e) => DataColumn2(
                label: ColoredBox(
                  color: AppColors.borderColor,
                  child: Center(
                    child: AppText.bold(e,
                        fontSize: 12, fontFamily: Assets.appFontFamily2),
                  ),
                ),
                size: ColumnSize.S))
            .toList(),
        source: RecentOrderDS(),
      ),
    );
  }

  Widget recentInventory() {
    return SizedBox(
      width: (Ui.width(context) * 0.4),
      child: AsyncPaginatedDataTable2(
        minWidth: (Ui.width(context) * 0.4) - 56,
        hidePaginator: true,
        columnSpacing: 0,
        showCheckboxColumn: false,
        autoRowsToHeight: true,
        wrapInCard: false,
        headingRowColor: MaterialStatePropertyAll<Color>(
            Colors.lightBlue[100]!.withOpacity(0.7)),
        rowsPerPage: 3,
        header: AppText.medium("Recent Inventory Movements",
            fontFamily: Assets.appFontFamily2, fontSize: 14),
        columns: ["Date", "Product", "Status", "Qty"]
            .map((e) => DataColumn2(
                label: AppText.bold(e,
                    fontSize: 12, fontFamily: Assets.appFontFamily2),
                size: ColumnSize.S))
            .toList(),
        source: RecentInventoryDS(),
      ),
    );
  }
}

class RecentOrderDS<Order> extends AsyncDataTableSource {
  RecentOrderDS();

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    final tm = ["Date", "Customer", "Car", "Status"];
// await Future.delayed(Duration(seconds: 1));
    final bms = Get.find<AppController>().allOrders;
    bms.sort((a, b) => b.id.compareTo(a.id));
    List<List<dynamic>> tvals = bms
        .map((element) => [
              element.createdAtRaw,
              element.customer,
              element.car,
              element.isDispatched
            ])
        .toList();

    return AsyncRowsResponse(
        tvals.length,
        List.generate(tvals.length, (index) {
          final tval = tvals[index];
          return DataRow2(
              onSelectChanged: (b) {},
              cells: List.generate(tm.length, (jindex) {
                if (jindex == 3) {
                  final cl = tval[jindex]
                                  ? AppColors.green
                                  : AppColors.orange;
                  return DataCell(Center(
                    child: CurvedContainer(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      color: cl.withOpacity(0.1),
                      radius: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(
                            Icons.circle,
                            size: 8,
                            color: cl,
                          ),
                          Ui.boxWidth(4),
                          AppText.thin(
                              tval[jindex] ? "Dispatched" : "In Progress",
                              fontSize: 12,
                              color: cl),
                        ],
                      ),
                      
                      
                    ),
                  ));
                }
                return DataCell(Center(
                    child:
                        AppText.thin(tval[jindex].toString(), fontSize: 12)));
              }));
        }));
  }
}

class RecentInventoryDS<LubeInventory> extends AsyncDataTableSource {
  RecentInventoryDS();

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    final tm = ["Date", "Product", "Status", "Qty"];
// await Future.delayed(Duration(seconds: 1));
    final bms = Get.find<AppController>().allLubeInventory;
    bms.sort((a, b) => b.id.compareTo(a.id));
    List<List<dynamic>> tvals = bms
        .map((element) =>
            [element.createdAt, element.product, element.status, element.qty])
        .toList();

    return AsyncRowsResponse(
        tvals.length,
        List.generate(tvals.length, (index) {
          final tval = tvals[index];
          return DataRow2(
              onSelectChanged: (b) {},
              cells: List.generate(tm.length, (jindex) {
                return DataCell(
                    Center(child: AppText.thin(tval[jindex].toString(), fontSize: 12,alignment: TextAlign.center)));
              }));
        }));
  }
}

class MyBarChart extends StatefulWidget {
  const MyBarChart({super.key});

  @override
  State<MyBarChart> createState() => _MyBarChartState();
}

class _MyBarChartState extends State<MyBarChart> {
  List<DateTime> datePoints = [];
  List<int> orderCnt = [];
  int orderMax = 10;
  final controller = Get.find<AppController>();

  TextEditingController filterTec = TextEditingController(text: "Day");
  String currentFilter = "Day";

  @override
  void initState() {
    super.initState();
    // Group orders by month, day and year
    controller.groupOrderData();
    // Initialize with last 6 months
    updateChartData();
  }

  void updateChartData() {
    datePoints = [];
    orderCnt = [];

    if (currentFilter == "Month") {
      datePoints = getLast12Months();
    } else if (currentFilter == "Day") {
      datePoints = getLast30Days();
    } else if (currentFilter == "Year") {
      datePoints = getLast6Years();
    }
  }

  List<DateTime> getLast12Months() {
    DateTime currentDate = DateTime.now();
    List<DateTime> last6Months = [];
    orderCnt = [];

    for (int i = 12; i >= 0; i--) {
      DateTime month = DateTime(currentDate.year, currentDate.month - i);
      last6Months.add(month);
      orderCnt.add(controller.groupedOrdersByMonth[month] ?? 0);
    }
    orderMax = Get.find<AppController>()
        .appConstants
        .value
        .monthlyOrdersTarget
        .toInt();
    return last6Months;
  }

  List<DateTime> getLast30Days() {
    DateTime currentDate = DateTime.now();
    List<DateTime> last6Days = [];
    orderCnt = [];

    for (int i = 30; i >= 0; i--) {
      DateTime day =
          DateTime(currentDate.year, currentDate.month, currentDate.day - i);
      last6Days.add(day);
      orderCnt.add(controller.groupedOrdersByDay[day] ?? 0);
    }
    orderMax =
        Get.find<AppController>().appConstants.value.dailyOrdersTarget.toInt();
    return last6Days;
  }

  List<DateTime> getLast6Years() {
    DateTime currentDate = DateTime.now();
    List<DateTime> last6Years = [];
    orderCnt = [];

    for (int i = 5; i >= 0; i--) {
      DateTime year = DateTime(currentDate.year - i);
      last6Years.add(year);
      orderCnt.add(controller.groupedOrdersByYear[year] ?? 0);
    }
    orderMax =
        Get.find<AppController>().appConstants.value.yearlyOrdersTarget.toInt();
    return last6Years;
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barTouchData: barTouchData,
        titlesData: titlesData,
        borderData: borderData,
        barGroups: barGroups,
        gridData: const FlGridData(show: false, drawVerticalLine: false),
        backgroundColor: AppColors.white,
        maxY: orderCnt.isEmpty ? 10 : (orderCnt.reduce(max).toDouble() * 1.3),
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: const EdgeInsets.only(bottom: 0),
          tooltipMargin: 4,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            if (groupIndex >= datePoints.length)
              return BarTooltipItem("", TextStyle());
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    if (value.toInt() >= datePoints.length) {
      return const SizedBox();
    }

    String text;
    switch (currentFilter) {
      case "Month":
        text = DateFormat("MM/yyyy").format(datePoints[value.toInt()]);
        break;
      case "Day":
        text = DateFormat("dd/MM").format(datePoints[value.toInt()]);
        break;
      case "Year":
        text = DateFormat("yyyy").format(datePoints[value.toInt()]);
        break;
      default:
        text = "";
    }

    return SideTitleWidget(
      axisSide: AxisSide.bottom,
      space: 4,
      angle: pi / 4,
      child: AppText.bold(text, fontSize: 12),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 56,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: AxisTitles(
          axisNameSize: 32,
          axisNameWidget: Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 8, top: 8),
            child: AppText.thin("Orders per ${currentFilter}",
                fontSize: 12, color: AppColors.lightTextColor),
          ),
          sideTitles: const SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          drawBelowEverything: false,
          axisNameSize: 50,
          axisNameWidget: CurvedContainer(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            color: Color(0xFFF8F8F8),
            brad: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText.thin("Service Order Metrics",
                    color: AppColors.lightTextColor),
                Container(
                  width: 100,
                  child: CustomTextField.dropdown(["Month", "Day", "Year"],
                      ["Month", "Day", "Year"], filterTec, "",
                      initOption: currentFilter, onChanged: (value) {
                    if (value != null && value != currentFilter) {
                      setState(() {
                        currentFilter = value;
                        updateChartData();
                      });
                    }
                  }),
                )
              ],
            ),
          ),
          sideTitles: const SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  // LinearGradient get _barsGradient => const ;

  List<BarChartGroupData> get barGroups =>
      List.generate(datePoints.length, (index) {
        final lp = orderCnt[index] < orderMax;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
                toY: orderCnt[index].toDouble(),
                // color: lp ? AppColors.,
                gradient: LinearGradient(
                  colors: [
                    lp
                        ? AppColors.primaryColor.withOpacity(0.3)
                        : AppColors.green.withOpacity(0.3),
                    lp
                        ? AppColors.orange.withOpacity(0.6)
                        : AppColors.green.withOpacity(0.6),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(2), topRight: Radius.circular(2)),
                width: 12)
          ],
          showingTooltipIndicators: [0],
        );
      });
}

class ChartHeaderChooser extends StatelessWidget {
  const ChartHeaderChooser(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          color: AppColors.primaryColor),
      child: AppText.medium(
        title,
        fontSize: 16,
        color: AppColors.white,
      ),
    );
  }
}

// Profit Chart
class ProfitChart extends StatefulWidget {
  const ProfitChart({super.key});

  @override
  State<ProfitChart> createState() => _ProfitChartState();
}

class _ProfitChartState extends State<ProfitChart> {
  List<DateTime> datePoints = [];
  String currentFilter = "Day";
  List<InventoryMetricDailyProfit> dailyProfits = [];
  List<InventoryMetricMonthlyProfit> monthlyProfits = [];
  List<InventoryMetricYearlyProfit> yearlyProfits = [];
  TextEditingController filterTec = TextEditingController(text: "Day");
  String profitType = "Sales"; // Options: Total, Product, Service, Labor
  TextEditingController profitTypeTec = TextEditingController(text: "Sales");
  double profitMax = 100000;
  double salesMaxY = 1000000;

  List<Color> gradientColors = [
    // const Color.fromARGB(255, 204, 242, 255),
    AppColors.primaryColorLight,
    AppColors.primaryColor,
  ];

  @override
  void initState() {
    super.initState();
    // Load profit data
    loadProfitData();
    // Initialize with monthly data
    updateChartData();
  }

  Future<void> loadProfitData() async {
    // Fetch data from your API or controller
    // This is placeholder - replace with your actual data retrieval logic
    dailyProfits = Get.find<AppController>().allDailyProfit;
    monthlyProfits = Get.find<AppController>().allMonthlyProfit;
    yearlyProfits = Get.find<AppController>().allYearlyProfit;
    setState(() {});
  }

  void updateChartData() {
    datePoints = [];

    switch (currentFilter) {
      case "Month":
        datePoints = getLast12Months();
        break;
      case "Day":
        datePoints = getLast30Days();
        break;
      case "Year":
        datePoints = getLast6Years();
        break;
    }
  }

  List<DateTime> getLast12Months() {
    DateTime currentDate = DateTime.now();
    List<DateTime> last6Months = [];

    for (int i = 12; i >= 0; i--) {
      DateTime month = DateTime(currentDate.year, currentDate.month - i, 1);
      last6Months.add(month);
    }
    return last6Months;
  }

  List<DateTime> getLast30Days() {
    DateTime currentDate = DateTime.now();
    List<DateTime> last6Days = [];

    for (int i = 30; i >= 0; i--) {
      DateTime day =
          DateTime(currentDate.year, currentDate.month, currentDate.day - i);
      last6Days.add(day);
    }
    return last6Days;
  }

  List<DateTime> getLast6Years() {
    DateTime currentDate = DateTime.now();
    List<DateTime> last6Years = [];

    for (int i = 5; i >= 0; i--) {
      DateTime year = DateTime(currentDate.year - i);
      last6Years.add(year);
    }
    return last6Years;
  }

  // Get profit value based on current selection
  double getProfitValue(dynamic profitObj) {
    switch (profitType) {
      case "Sales":
        return profitObj.sales;
      case "Profit":
        return profitObj.profit;
      // case "Service":
      //   return profitObj.serviceProfit;
      // case "Labor":
      //   return profitObj.laborProfit;
      case "Expenses":
        return profitObj.cost;
      default:
        return profitObj.sales;
    }
  }

  double getMaxProfit() {
    final List<double> profitValues = datePoints.map((date) {
      return getProfitForDate(date);
    }).toList();

    if (profitValues.isEmpty) return 100; // fallback default

    final maxProfit = profitValues.reduce((a, b) => a > b ? a : b);
    return maxProfit * 1.2;
  }

  // Find profit data for a specific date
  double getProfitForDate(DateTime date) {
    switch (currentFilter) {
      case "Day":
        final profit = dailyProfits.firstWhere(
          (p) =>
              p.date.year == date.year &&
              p.date.month == date.month &&
              p.date.day == date.day,
          orElse: () => InventoryMetricDailyProfit(date: date),
        );
        profitMax =
            Get.find<AppController>().appConstants.value.dailyProfitTarget;

        return getProfitValue(profit);

      case "Month":
        final profit = monthlyProfits.firstWhere(
          (p) => p.date.year == date.year && p.date.month == date.month,
          orElse: () => InventoryMetricMonthlyProfit(date: date),
        );
        profitMax =
            Get.find<AppController>().appConstants.value.monthlyProfitTarget;
        return getProfitValue(profit);

      case "Year":
        final profit = yearlyProfits.firstWhere(
          (p) => p.date.year == date.year,
          orElse: () => InventoryMetricYearlyProfit(date: date),
        );
        profitMax =
            Get.find<AppController>().appConstants.value.yearlyProfitTarget;
        return getProfitValue(profit);

      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: false,
        ),

        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
              axisNameSize: 56,
              axisNameWidget: SizedBox()),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
              axisNameSize: 56,
              axisNameWidget: SizedBox()),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
            drawBelowEverything: true,
            axisNameSize: 50,
            axisNameWidget: CurvedContainer(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              color: Color(0xFFF8F8F8),
              brad: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText.thin("Finance Metrics",
                      color: AppColors.lightTextColor),
                  Row(
                    children: [
                      Container(
                        width: 150,
                        margin: const EdgeInsets.only(right: 8),
                        child: CustomTextField.dropdown(
                            (Get.find<AppController>()
                                    .appRepo
                                    .appService
                                    .currentUser
                                    .value
                                    .isAdmin)
                                ? ["Sales", "Profit", "Expenses"]
                                : ["Sales"],
                            (Get.find<AppController>()
                                    .appRepo
                                    .appService
                                    .currentUser
                                    .value
                                    .isAdmin)
                                ? ["Sales", "Profit", "Expenses"]
                                : ["Sales"],
                            profitTypeTec,
                            "",
                            initOption: profitType, onChanged: (value) {
                          if (value != null && value != profitType) {
                            setState(() {
                              profitType = value;
                              updateChartData();
                            });
                          }
                        }),
                      ),
                      Container(
                        width: 150,
                        child: CustomTextField.dropdown(
                            ["Month", "Day", "Year"],
                            ["Month", "Day", "Year"],
                            filterTec,
                            "",
                            initOption: currentFilter, onChanged: (value) {
                          if (value != null && value != currentFilter) {
                            setState(() {
                              currentFilter = value;
                              updateChartData();
                            });
                          }
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= datePoints.length || value.toInt() < 0) {
                  return const SizedBox();
                }

                String text;
                switch (currentFilter) {
                  case "Month":
                    text =
                        DateFormat("MM/yyyy").format(datePoints[value.toInt()]);
                    break;
                  case "Day":
                    text =
                        DateFormat("dd/MM").format(datePoints[value.toInt()]);
                    break;
                  case "Year":
                    text = DateFormat("yyyy").format(datePoints[value.toInt()]);
                    break;
                  default:
                    text = "";
                }

                return SideTitleWidget(
                  // axisSide: meta.axisSide,
                  // space: 8,
                  // angle: -56,
                  // child: AppText.bold(text, fontSize: 12),

                  axisSide: AxisSide.bottom,
                  space: 4,
                  angle: pi / 4,
                  child: AppText.bold(text, fontSize: 12),
                );
              },
            ),
          ),
          // leftTitles: AxisTitles(
          //   sideTitles: SideTitles(showTitles: false),
          // ),
          // leftTitles: AxisTitles(
          //   sideTitles: SideTitles(
          //     showTitles: true,
          //     interval: 1,
          //     reservedSize: 42,
          //     getTitlesWidget: (value, meta) {
          //       return SideTitleWidget(
          //         axisSide: meta.axisSide,
          //         space: 8,
          //         child: AppText.bold(
          //           '${value.toInt()}',
          //           fontSize: 12,
          //           color: Colors.grey,
          //         ),
          //       );
          //     },
          //   ),
          // ),
        ),
        borderData: FlBorderData(
          show: false,
          border: Border(
            left: BorderSide(color: Colors.grey.withOpacity(0.5)),
            bottom: BorderSide(color: Colors.grey.withOpacity(0.5)),
          ),
        ),
        minX: 0,
        maxX: datePoints.length - 1.0,
        maxY: getMaxProfit(),

        // minY: 0,
        // backgroundColor: AppColors.primaryColorLight.withOpacity(0.2),
        lineBarsData: [
          LineChartBarData(
            spots: datePoints.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                getProfitForDate(entry.value),
              );
            }).toList(),
            isCurved: true,
            color: AppColors.primaryColorLight,
            barWidth: 1,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                if (index >= datePoints.length) return FlDotCirclePainter();
                final lp = getProfitForDate(datePoints[index]) < profitMax;
                return FlDotCirclePainter(
                  radius: 4,
                  color: lp
                      ? AppColors.primaryColor.withOpacity(0.6)
                      : (profitType == "Expenses"
                          ? AppColors.primaryColor.withOpacity(0.6)
                          : AppColors.green.withOpacity(0.6)),
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              // color: AppColors.borderColor
              gradient: LinearGradient(
                colors: [
                  AppColors.borderColor,
                  AppColors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: AppColors.borderColor,
            tooltipRoundedRadius: 8,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final date = datePoints[barSpot.x.toInt()];
                String formattedDate;

                switch (currentFilter) {
                  case "Month":
                    formattedDate = DateFormat("MMM yyyy").format(date);
                    break;
                  case "Day":
                    formattedDate = DateFormat("dd MMM").format(date);
                    break;
                  case "Year":
                    formattedDate = DateFormat("yyyy").format(date);
                    break;
                  default:
                    formattedDate = "";
                }

                return LineTooltipItem(
                  "$formattedDate - ${barSpot.y.toCurrency()}",
                  const TextStyle(
                      color: AppColors.lightTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
      ),
    );
  }
}
