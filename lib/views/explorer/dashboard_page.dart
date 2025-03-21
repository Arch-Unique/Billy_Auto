import 'dart:math';

import 'package:data_table_2/data_table_2.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
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

class ExpDashboardPage extends StatefulWidget {
  const ExpDashboardPage({super.key});

  @override
  State<ExpDashboardPage> createState() => _ExpDashboardPageState();
}

class _ExpDashboardPageState extends State<ExpDashboardPage> {
  final controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    final cl = Obx(() {
      final cf = [
        itemDataWidget(
            "Total Customers",
            controller.allCustomer.length.toString(),
            Colors.lightBlue[100]!.withOpacity(0.7)),
        itemDataWidget(
            "Total Suppliers",
            controller.allSuppliers.length.toString(),
            Colors.yellow[100]!.withOpacity(0.7)),
        itemDataWidget(
            "Total Products",
            controller.allProducts.length.toString(),
            Colors.lightGreen[100]!.withOpacity(0.7)),
        itemDataWidget("Total Orders", controller.allOrders.length.toString(),
            Colors.lightGreen[100]!.withOpacity(0.7)),
        itemDataWidget(
            "Pending Orders",
            controller.allPendingOrders.length.toString(),
            Colors.red[100]!.withOpacity(0.7)),
        itemDataWidget("Total Revenue", controller.totalSales.toCurrency(),
            Colors.lightGreen[100]!.withOpacity(0.7)),
        if (controller.appRepo.appService.currentUser.value.isAdmin)
          itemDataWidget(
              "Total Expenses",
              controller.totalExpenses.toCurrency(),
              Colors.lightGreen[100]!.withOpacity(0.7)),
        itemDataWidget(
            "Total Cost Of Goods Sold",
            controller.totalProductCost.toCurrency(),
            Colors.lightGreen[100]!.withOpacity(0.7)),
        if (controller.appRepo.appService.currentUser.value.isAdmin)
          itemDataWidget(
              "Total Gross Profit",
              controller.totalProfit.toCurrency(),
              controller.totalProfit <= 0
                  ? Colors.red[100]!.withOpacity(0.7)
                  : Colors.lightGreen[100]!.withOpacity(0.7)),
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
                    AppText.bold(
                        "Welcome back, ${controller.appRepo.appService.currentUser.value.fullName} 👋",
                        fontSize: 32,
                        fontFamily: Assets.appFontFamily2),
                    AppText.thin(
                        "Here are the current status of your inventory and orders.")
                  ],
                ),
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
            if (Ui.width(context) >= 975)
              SizedBox(
                  height: Ui.height(context),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              height: Ui.height(context) / 2,
                              width: (Ui.width(context) * 0.6) - 48,
                              child: MyBarChart(),
                            ),
                            SizedBox(
                              height: Ui.height(context) / 2,
                              width: (Ui.width(context) * 0.6) - 48,
                              child: ProfitChart(),
                            )
                          ],
                        ),
                        // Obx(
                        //    () {
                        //     return Expanded(child: controller.currentChart.value == 0 ? MyBarChart() : ProfitChart());
                        //   }
                        // ),
                        recentOrders()
                      ],
                    ),
                  ))
          ],
        ),
      ),
    );
  }

  Widget itemDataWidget(String title, String value, Color color,
      {String desc = ""}) {
    final cc = CurvedContainer(
      height: 64,
      padding: EdgeInsets.all(12),
      color: color,
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText.thin(title,
              fontSize: 14, fontFamily: Assets.appFontFamily2, att: true),
          // Ui.spacer(),
          Ui.boxWidth(24),
          AppText.bold(value, fontSize: 36, att: true),
          // if (desc.isNotEmpty) AppText.thin(desc)
        ],
      ),
    );
    // return Ui.width(Get.context!) < 975
    //     ? cc
    //     : Expanded(
    //         child: cc,
    //       );
    return cc;
  }

  Widget recentOrders() {
    return SizedBox(
      width: (Ui.width(context) * 0.4),
      height: Ui.height(context),
      child: AsyncPaginatedDataTable2(
        minWidth: (Ui.width(context) * 0.4) - 56,
        hidePaginator: true,
        columnSpacing: 0,
        showCheckboxColumn: false,
        autoRowsToHeight: true,
        headingRowColor: MaterialStatePropertyAll<Color>(
            Colors.lightGreen[100]!.withOpacity(0.7)),
        rowsPerPage: 3,
        wrapInCard: false,
        header: AppText.medium("Recent Orders",
            fontFamily: Assets.appFontFamily2, fontSize: 14),
        columns: ["Date", "Customer", "Car", "Status"]
            .map((e) => DataColumn2(
                label: AppText.bold(e,
                    fontSize: 12, fontFamily: Assets.appFontFamily2),
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
                  return DataCell(Chip(
                    label: AppText.thin(
                        tval[jindex] ? "Dispatched" : "In Progress",
                        color:
                            tval[jindex] ? Colors.green : Colors.orange[700]!),
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: tval[jindex]
                                ? Colors.green
                                : Colors.orange[700]!),
                        borderRadius: BorderRadius.circular(8)),
                  ));
                }
                return DataCell(
                    AppText.thin(tval[jindex].toString(), fontSize: 12));
              }));
        }));
  }
}

class RecentInventoryDS<Inventory> extends AsyncDataTableSource {
  RecentInventoryDS();

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    final tm = ["Date", "Product", "Status", "Qty"];
// await Future.delayed(Duration(seconds: 1));
    final bms = Get.find<AppController>().allInventory;
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
                    AppText.thin(tval[jindex].toString(), fontSize: 12));
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
  Map<DateTime, int> groupedOrdersByMonth = {};
  Map<DateTime, int> groupedOrdersByDay = {};
  Map<DateTime, int> groupedOrdersByYear = {};

  TextEditingController filterTec = TextEditingController(text: "Day");
  String currentFilter = "Day";

  @override
  void initState() {
    super.initState();
    // Group orders by month, day and year
    groupOrderData();
    // Initialize with last 6 months
    updateChartData();
  }

  void groupOrderData() {
    // Group orders by month-year
    groupedOrdersByMonth = {};
    for (var order in Get.find<AppController>().allOrders) {
      if (!order.isDispatched) continue;
      DateTime month =
          DateTime(order.dispatchedAt!.year, order.dispatchedAt!.month);
      if (groupedOrdersByMonth.containsKey(month)) {
        groupedOrdersByMonth[month] = groupedOrdersByMonth[month]! + 1;
      } else {
        groupedOrdersByMonth[month] = 1;
      }
    }

    // Group orders by day
    groupedOrdersByDay = {};
    for (var order in Get.find<AppController>().allOrders) {
      if (!order.isDispatched) continue;
      DateTime day = DateTime(order.dispatchedAt!.year,
          order.dispatchedAt!.month, order.dispatchedAt!.day);
      if (groupedOrdersByDay.containsKey(day)) {
        groupedOrdersByDay[day] = groupedOrdersByDay[day]! + 1;
      } else {
        groupedOrdersByDay[day] = 1;
      }
    }

    // Group orders by year
    groupedOrdersByYear = {};
    for (var order in Get.find<AppController>().allOrders) {
      if (!order.isDispatched) continue;
      DateTime year = DateTime(order.dispatchedAt!.year);
      if (groupedOrdersByYear.containsKey(year)) {
        groupedOrdersByYear[year] = groupedOrdersByYear[year]! + 1;
      } else {
        groupedOrdersByYear[year] = 1;
      }
    }
  }

  void updateChartData() {
    datePoints = [];
    orderCnt = [];

    if (currentFilter == "Month") {
      datePoints = getLast6Months();
    } else if (currentFilter == "Day") {
      datePoints = getLast6Days();
    } else if (currentFilter == "Year") {
      datePoints = getLast6Years();
    }
  }

  List<DateTime> getLast6Months() {
    DateTime currentDate = DateTime.now();
    List<DateTime> last6Months = [];
    orderCnt = [];

    for (int i = 5; i >= 0; i--) {
      DateTime month = DateTime(currentDate.year, currentDate.month - i);
      last6Months.add(month);
      orderCnt.add(groupedOrdersByMonth[month] ?? 0);
    }
    orderMax = Get.find<AppController>()
        .appConstants
        .value
        .monthlyOrdersTarget
        .toInt();
    return last6Months;
  }

  List<DateTime> getLast6Days() {
    DateTime currentDate = DateTime.now();
    List<DateTime> last6Days = [];
    orderCnt = [];

    for (int i = 5; i >= 0; i--) {
      DateTime day =
          DateTime(currentDate.year, currentDate.month, currentDate.day - i);
      last6Days.add(day);
      orderCnt.add(groupedOrdersByDay[day] ?? 0);
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
      orderCnt.add(groupedOrdersByYear[year] ?? 0);
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
        backgroundColor: AppColors.primaryColorLight.withOpacity(0.2),
        maxY: orderCnt.isEmpty ? 10 : (orderCnt.reduce(max).toDouble() * 1.3),
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: const EdgeInsets.only(bottom: 4),
          tooltipMargin: 12,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
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
        text = DateFormat("MMM yyyy").format(datePoints[value.toInt()]);
        break;
      case "Day":
        text = DateFormat("dd MMM").format(datePoints[value.toInt()]);
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
      child: AppText.bold(text),
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
          axisNameWidget: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppText.bold("Orders per ${currentFilter}",
                fontSize: 14, fontFamily: Assets.appFontFamily2),
          ),
          sideTitles: const SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          drawBelowEverything: false,
          axisNameSize: 100,
          axisNameWidget: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ChartHeaderChooser("Service Order Metrics"),
                Container(
                  width: 150,
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
                        ? AppColors.primaryColor
                        : AppColors.green.withOpacity(0.9),
                    lp ? AppColors.orange : AppColors.green,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(8),
                width: 56)
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
        datePoints = getLast6Months();
        break;
      case "Day":
        datePoints = getLast6Days();
        break;
      case "Year":
        datePoints = getLast6Years();
        break;
    }
  }

  List<DateTime> getLast6Months() {
    DateTime currentDate = DateTime.now();
    List<DateTime> last6Months = [];

    for (int i = 5; i >= 0; i--) {
      DateTime month = DateTime(currentDate.year, currentDate.month - i, 1);
      last6Months.add(month);
    }
    return last6Months;
  }

  List<DateTime> getLast6Days() {
    DateTime currentDate = DateTime.now();
    List<DateTime> last6Days = [];

    for (int i = 5; i >= 0; i--) {
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
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
            drawBelowEverything: true,
            axisNameSize: 100,
            axisNameWidget: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ChartHeaderChooser("Finance Metrics"),
                  Row(
                    children: [
                      Container(
                        width: 150,
                        margin: const EdgeInsets.only(right: 8),
                        child: CustomTextField.dropdown(
                            (Get.find<AppController>().appRepo.appService.currentUser.value.isAdmin) ? ["Sales", "Profit", "Expenses"] : ["Sales"],
                            (Get.find<AppController>().appRepo.appService.currentUser.value.isAdmin) ? ["Sales", "Profit", "Expenses"] : ["Sales"],
                            
                            profitTypeTec,
                            "",
                            initOption: profitType, onChanged: (value) {
                          if (value != null && value != profitType) {
                            setState(() {
                              profitType = value;
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
                    text = DateFormat("MMM yyyy")
                        .format(datePoints[value.toInt()]);
                    break;
                  case "Day":
                    text =
                        DateFormat("dd MMM ").format(datePoints[value.toInt()]);
                    break;
                  case "Year":
                    text = DateFormat("yyyy").format(datePoints[value.toInt()]);
                    break;
                  default:
                    text = "";
                }

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: AppText.bold(text, fontSize: 14),
                );
              },
            ),
          ),
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
          show: true,
          border: Border(
            left: BorderSide(color: Colors.grey.withOpacity(0.5)),
            bottom: BorderSide(color: Colors.grey.withOpacity(0.5)),
          ),
        ),
        minX: 0,
        maxX: datePoints.length - 1.0,
        // minY: 0,
        backgroundColor: AppColors.primaryColorLight.withOpacity(0.2),
        lineBarsData: [
          LineChartBarData(
            spots: datePoints.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                getProfitForDate(entry.value),
              );
            }).toList(),
            isCurved: false,
            color: AppColors.orange,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final lp = getProfitForDate(datePoints[index]) < profitMax;
                return FlDotCirclePainter(
                  radius: 8,
                  color: lp
                      ? AppColors.primaryColor
                      : (profitType == "Expenses"
                          ? AppColors.primaryColor
                          : AppColors.green),
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primaryColor.withOpacity(0.2),
              gradient: LinearGradient(
                colors: gradientColors
                    .map((color) => color.withOpacity(0.3))
                    .toList(),
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
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
                    formattedDate = DateFormat("dd MMM yyyy").format(date);
                    break;
                  case "Year":
                    formattedDate = DateFormat("yyyy").format(date);
                    break;
                  default:
                    formattedDate = "";
                }

                return LineTooltipItem(
                  "$formattedDate\nTotal ${profitType}: ${barSpot.y.toCurrency()}",
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
