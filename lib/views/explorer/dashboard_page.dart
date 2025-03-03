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
    return Padding(
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
          Obx(
             () {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  itemDataWidget(
                      "Total Orders",
                      controller.allOrders.length.toString(),
                      Colors.lightGreen[100]!.withOpacity(0.7)),
                  itemDataWidget(
                      "Pending Orders",
                      controller.allPendingOrders.length.toString(),
                      Colors.red[100]!.withOpacity(0.7)),
                ],
              );
            }
          ),
          Expanded(
              child: Row(
            children: [
              Expanded(child: MyBarChart()),
              Column(
                children: [
                  Expanded(child: recentOrders()),
                  Expanded(child: recentInventory()),
                ],
              )
            ],
          ))
        ],
      ),
    );
  }

  itemDataWidget(String title, String value, Color color, {String desc = ""}) {
    return Expanded(
      child: CurvedContainer(
        height: 160,
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.all(16),
        color: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.thin(title,
                fontSize: 20, fontFamily: Assets.appFontFamily2),
            Ui.spacer(),
            AppText.bold(value, fontSize: 48),
            if (desc.isNotEmpty) AppText.thin(desc)
          ],
        ),
      ),
    );
  }

  Widget recentOrders() {
    return SizedBox(
      width: (Ui.width(context) * 0.4),
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
    print(bms.length);
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
    print(bms.length);
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
  List<DateTime> dtt = [];
  List<int> orderCnt=[];
  Map<DateTime, int> groupedOrders = {};

  @override
  void initState() {
    getMapOrder();
    dtt = getLast6Mth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
    
      BarChartData(
        
        barTouchData: barTouchData,
        titlesData: titlesData,
        borderData: borderData,
        barGroups: barGroups,
        gridData: const FlGridData(show: false,drawVerticalLine: false),
        
        backgroundColor: AppColors.primaryColorLight.withOpacity(0.2),
        maxY: orderCnt.reduce(max).toDouble()*1.3,
      ),
    );
  }

  List<DateTime> getLast6Mth() {
    DateTime currentDate = DateTime.now();

    // List to hold last 6 months
    List<DateTime> last6Months = [];

    for (int i = 5; i >= 0; i--) {
      DateTime month = DateTime(currentDate.year, currentDate.month - i);
      last6Months.add(month);
      orderCnt.add(groupedOrders[month] ?? 0);
    }
    return last6Months;
  }

  getMapOrder(){
     // Group orders by month-year
  for (var order in Get.find<AppController>().allOrders) {
    DateTime month = DateTime(order.createdAt!.year, order.createdAt!.month);
    if (groupedOrders.containsKey(month)) {
      groupedOrders[month] = groupedOrders[month]! + 1;
    } else {
      groupedOrders[month] = 1;
    }
  }
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: EdgeInsets.only(bottom: 16),
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                color: Colors.cyan,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    final text = DateFormat("MMM yyyy").format(dtt[value.toInt()]);
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
        leftTitles:  AxisTitles(
          axisNameWidget: Padding(
            padding: const EdgeInsets.all(24.0),
            child: AppText.bold("No of Service Orders per Month",fontFamily: Assets.appFontFamily2),
          ),
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles:  AxisTitles(
          axisNameWidget: Padding(
            padding: const EdgeInsets.all(24.0),
            child: AppText.bold("Service Order Metrics",fontFamily: Assets.appFontFamily2),
          ),
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  LinearGradient get _barsGradient => const LinearGradient(
        colors: [
          Colors.blue,
          Colors.cyan,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  List<BarChartGroupData> get barGroups => List.generate(dtt.length, (index) => BarChartGroupData(x: index,barRods: [
            BarChartRodData(
              toY: orderCnt[index].toDouble(),
              gradient: _barsGradient,
              borderRadius: BorderRadius.circular(16),
              width: 100
            )
          ],
          showingTooltipIndicators: [0],)) ;
}
