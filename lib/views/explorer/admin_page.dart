import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:inventory/controllers/app_controller.dart';
import 'package:inventory/models/inner_models/base_model.dart';
import 'package:inventory/models/table_repo.dart';
import 'package:inventory/repo/app_repo.dart';
import 'package:inventory/tools/assets.dart';
import 'package:inventory/tools/colors.dart';
import 'package:inventory/tools/enums.dart';
import 'package:inventory/tools/extensions.dart';
import 'package:inventory/views/checklist/order_summary.dart';
import 'package:inventory/views/checklist/shared2.dart';
import 'package:inventory/views/explorer/dashboard_page.dart';

import '../../models/inner_models/barrel.dart';
import '../../tools/functions.dart';
import '../../tools/reports.dart';
import '../../tools/service.dart';
import '../../tools/urls.dart';
import '../shared.dart';

class CustomTable extends StatefulWidget {
  const CustomTable({super.key});

  @override
  State<CustomTable> createState() => _CustomTableState();
}

class _CustomTableState extends State<CustomTable> {
  final controller = Get.find<AppController>();
  final perm = Get.find<AppController>()
      .allUserRoles
      .where((e) =>
          e.id == Get.find<AppRepo>().appService.currentUser.value.roleId)
      .firstOrNull;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      print(controller.changedMode.value);
      if (controller.currentType == AppConstants) {
        if (controller.currentAppMode == 0) {
          return LubeDashboard();
        }
        if (controller.currentAppMode == 2) {
          return ExtraInvoiceWidget();
        }
        return MarkupTargetsPage();
      }
      if (controller.currentType == Reports) {
        return ReportsPage();
      }

      return LoadingWidget(
        child: CurvedContainer(
          width: Ui.width(context) < 975
              ? wideUi(context)
              : (Ui.width(context) - 280),
          height: Ui.width(context) < 975 ? null : double.maxFinite,
          color: AppColors.transparent,
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Row(
                children: [
                  // SizedBox(
                  //   width: Ui.width(context) / 3,
                  //   child: CustomTextField(
                  //     "",
                  //     TextEditingController(),
                  //     hint: "Search",
                  //     suffix: Iconsax.search_normal_1_outline,
                  //     hasBottomPadding: false,
                  //   ),
                  // ),
                  AppText.bold("All Records", fontSize: 14),
                  Spacer(),
                  TableIconButton(
                    "Filter",
                    Iconsax.filter_outline,
                    onPressed: () {},
                  ),
                  Ui.boxWidth(16),
                  TableIconButton(
                    "Export",
                    Iconsax.logout_1_outline,
                    onPressed: () async {
                      final mvals = controller.currentTotalResponse.value.data;
                      if (mvals.isEmpty) {
                        return Ui.showError("Data cannot be empty");
                      }
                      List mval = [];
                      for (var element in mvals) {
                        final f = (element as BaseModel).toExcelRows();
                        Map<String, dynamic> mv = {};
                        for (var i = 0; i < f.length; i++) {
                          mv[controller.currentExcelHeaders[i]] = f[i];
                        }
                        mval.add(mv);
                      }
                      Map<String, String> hds = {};
                      for (var element in mval[0].keys) {
                        hds[element] = element
                            .replaceAll("_", " ")
                            .replaceAllMapped(
                              RegExp(r'([A-Z])'),
                              (match) => ' ${match.group(1)}',
                            )
                            .toString()
                            .capitalize!;
                      }

                      final filePath = await generateExcelReport(
                        reportTitle: controller
                            .currentBaseModel.value.runtimeType
                            .toString(),
                        data: mval,
                        startDate: controller.currentFilters
                                .where((optv) => optv.filterType == 1)
                                .firstOrNull
                                ?.dtr
                                ?.start ??
                            DateTime(2025),
                        endDate: controller.currentFilters
                                .where((optv) => optv.filterType == 1)
                                .firstOrNull
                                ?.dtr
                                ?.end ??
                            DateTime.now(),
                        columnsToTotal: [],
                        columnHeaders: hds,
                      );
                      if (filePath == null) {
                        return Ui.showError("Failed to generate report");
                      }
                      return Ui.showInfo("Export saved to:\n$filePath");
                    },
                  ),
                  Ui.boxWidth(16),
                  if (perm?.perms[AllTables.tablesType.indexOf(
                          controller.currentBaseModel.value.runtimeType)][0] ==
                      1)
                    TableIconButton(
                      "Add Record",
                      Iconsax.add_outline,
                      color: AppColors.primaryColor,
                      hasBorder: false,
                      onPressed: () async {
                        if (controller.noActionModel()) return;
                        if (!Get.find<AppService>()
                            .currentUser
                            .value
                            .isServiceAdvisor) {
                          Ui.showError("Not enough permissions");
                          return;
                        }
                        Get.find<AppController>().startLoading();
                        if (controller.currentBaseModel.value.runtimeType ==
                            BulkExpenses) {
                          (controller.currentBaseModel.value as BulkExpenses)
                              .expenses = (await Get.find<AppRepo>()
                                  .getAll<Expenses>(
                                      rurl: AppUrls.expensesMetric,
                                      date: (controller.currentBaseModel.value
                                              as BulkExpenses)
                                          .date
                                          .toSQLDate()))
                              .data;
                        }

                        Get.find<AppController>().stopLoading();
                        if (controller.currentBaseModel.value.runtimeType ==
                            BulkExpenses) {
                          Get.dialog(AppDialog(
                              title: AppDialogHeader("Add/Edit Record"),
                              content: Obx(() {
                                return DynamicFormGenerator(
                                    model: controller.currentBaseModel.value,
                                    isNew: (controller.currentBaseModel.value
                                                .runtimeType !=
                                            BulkExpenses &&
                                        (controller.currentBaseModel.value
                                                as BulkExpenses)
                                            .expenses
                                            .isEmpty),
                                    onSave: (v) async {
                                      await controller.saveNewRecord(v);
                                    });
                              })));
                        } else {
                          Get.dialog(AppDialog(
                              title: AppDialogHeader("Create Record"),
                              content: Obx(() {
                                return DynamicFormGenerator(
                                    model: controller.currentBaseModel.value,
                                    isNew: true,
                                    onSave: (v) async {
                                      await controller.saveNewRecord(v);
                                    });
                              })));
                        }
                      },
                    ),
                ],
              ),
              Ui.boxHeight(12),
              Expanded(
                child: CurvedContainer(
                  border: Border.all(color: AppColors.borderColor),
                  boxShadows: [
                    BoxShadow(
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        spreadRadius: 0,
                        color: AppColors.shadowColor.withOpacity(0.06)),
                    BoxShadow(
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        spreadRadius: 0,
                        color: AppColors.shadowColor.withOpacity(0.1)),
                  ],
                  child: Obx(() {
                    return AsyncPaginatedDataTable2(
                      minWidth: Ui.width(context) < 975
                          ? wideUi(context)
                          : ((Ui.width(context) - 280 - 24)),
                      // border: TableBorder.all(),
                      horizontalMargin: 0,

                      onRowsPerPageChanged: (value) {
                        print('Row per page changed to $value');
                      },
                      // autoRowsToHeight: true,
                      columnSpacing: 0,
                      showCheckboxColumn: false,
                      // onSelectAll: (v) {
                      //   print(v);
                      // },
                      // controller: controller.paginatorController.value,
                      dataRowHeight: Ui.width(context) < 975
                          ? 156
                          : kMinInteractiveDimension,

                      // ],
                      wrapInCard: false,
                      headingRowHeight: 44,
                      columns: Ui.width(context) < 975
                          ? [
                              DataColumn2(
                                  label: Center(
                                    child: AppText.bold("",
                                        fontSize: 8,
                                        fontFamily: Assets.appFontFamily2),
                                  ),
                                  size: ColumnSize.S)
                            ]
                          : controller.currentHeaders
                              .map((e) => DataColumn2(
                                  label: ColoredBox(
                                    color: AppColors.borderColor,
                                    child: Center(
                                      child: AppText.bold(e,
                                          fontSize: 12,
                                          fontFamily: Assets.appFontFamily2),
                                    ),
                                  ),
                                  size: ColumnSize.S))
                              .toList(),
                      source: controller.tmds.value,
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class TableIconButton extends StatelessWidget {
  const TableIconButton(this.text, this.icon,
      {this.color = AppColors.transparent,
      this.onPressed,
      this.hasBorder = true,
      super.key});
  final IconData icon;
  final String text;
  final bool hasBorder;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tcolor =
        color == AppColors.transparent ? AppColors.textColor : AppColors.white;
    return CurvedContainer(
      border: hasBorder ? Border.all(color: AppColors.borderColor) : null,
      // height: 40,
      color: color,
      onPressed: onPressed,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              icon,
              size: 16,
              color: tcolor,
            ),
            Ui.boxWidth(8),
            AppText.medium(text, color: tcolor, fontSize: 14)
          ],
        ),
      ),
    );
  }
}

class CustomTableFilter extends StatelessWidget {
  CustomTableFilter({super.key});
  final controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      print(controller.changedMode.value);
      if (controller.currentType == AppConstants ||
          controller.currentType == Reports) {
        return SizedBox();
      }
      return CurvedContainer(
        width: Ui.width(context) < 975
            ? wideUi(context)
            : ((Ui.width(context) * 0.25) - 24),
        height: Ui.width(context) < 975 ? null : double.maxFinite,
        color: AppColors.white.withOpacity(0.6),
        border: Border.all(color: AppColors.primaryColorLight),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: SingleChildScrollView(
          child: Obx(() {
            return Column(
              children: [
                AppText.medium("Filters",
                    fontFamily: Assets.appFontFamily2, fontSize: 16),
                Ui.boxHeight(24),
                if (controller.currentFilters.isEmpty) const SizedBox(),
                ...controller.currentFilters.map((e) {
                  if (e.filterType == 0) {
                    var iv = [];
                    if (e.tec != null) {
                      if (e.tec!.text.trim().isNotEmpty &&
                          e.tec!.text.trim() != ",") {
                        if (e.tec!.text.contains(",")) {
                          iv = e.tec!.text.split(",");
                        } else {
                          iv = [e.tec!.text];
                        }
                      }
                    }
                    return CustomMultiDropdown(
                        e.options!.titles, e.options!.values, e.tec!, e.title,
                        initValues: iv, isEnable: true);
                  }
                  return CustomTextField(
                    e.title,
                    e.tec!,
                    readOnly: true,
                    onTap: () async {
                      final dtr = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now());
                      if (dtr != null) {
                        e.dtr = dtr;
                        e.tec!.text =
                            "${DateFormat("dd/MM/yyyy").format(dtr.start)} - ${DateFormat("dd/MM/yyyy").format(dtr.end)}";
                      }
                    },
                  );
                }),
                Ui.boxHeight(16),
                if (controller.currentFilters.isEmpty)
                  AppText.thin("No Filters"),
                if (controller.currentFilters.isNotEmpty)
                  AppButton.row(
                    "Apply",
                    () {
                      controller.applyFilters();
                      if (Ui.width(context) < 975) {
                        Get.back();
                      }
                    },
                    "Clear",
                    () {
                      controller.resetCurrentFilters();
                      controller.applyFilters();
                    },
                  )
                // AppButton(onPressed: (){
                //   controller.applyFilters();
                // },text: "Apply Filters",),
                // Ui.boxHeight(16),
                // if (controller.currentFilters.isNotEmpty)
                // AppButton.outline((){
                //   controller.resetCurrentFilters();
                //   controller.applyFilters();
                // }, "Clear Filters",),
              ],
            );
          }),
        ),
      );
    });
  }
}

class TableModelDataSource<T extends BaseModel> extends AsyncDataTableSource {
  List<String> tm;
  TableModelDataSource(this.tm);

  editRecord(BaseModel bm) async {
    final perm = Get.find<AppController>()
        .allUserRoles
        .where((e) =>
            e.id == Get.find<AppRepo>().appService.currentUser.value.roleId)
        .firstOrNull;
    if (Get.find<AppController>().noActionModel<T>() && T != UserAttendance) {
      return;
    }
    // if (perm?.perms[AllTables.tablesType.indexOf(T)][2] != 1) {
    //   Ui.showError("Not enough permissions");
    //   return;
    // }
    Get.find<AppController>().startLoading();
    if (T == BulkExpenses) {
      (bm as BulkExpenses).expenses =
          (await Get.find<AppRepo>().getAll<Expenses>(
        date: bm.date.toSQLDate(),
        rurl: AppUrls.expensesMetric,
      ))
              .data;
    }
    Get.find<AppController>().stopLoading();
    Get.find<AppController>().currentBaseModel = bm.obs;
    Get.dialog(AppDialog(
        title: AppDialogHeader("Edit Record"),
        content: Obx(() {
          return DynamicFormGenerator(
              model: Get.find<AppController>().currentBaseModel.value,
              onSave: (v) async {
                await Get.find<AppController>().editExisitingRecord(v);
              });
        })));
  }

  deleteRecord(BaseModel bm) {
    final perm = Get.find<AppController>()
        .allUserRoles
        .where((e) =>
            e.id == Get.find<AppRepo>().appService.currentUser.value.roleId)
        .firstOrNull;
    if (Get.find<AppController>().noActionModel<T>()) return;
    if (perm?.perms[AllTables.tablesType.indexOf(T)][3] != 1) {
      Ui.showError("Not enough permissions");
      return;
    }
    Get.dialog(AppDialog.normal(
      "Delete Record",
      "Are you sure you want to remove this record from the database ?",
      titleA: "Yes",
      titleB: "No",
      onPressedA: () async {
        await Get.find<AppController>()
            .deleteExisitingRecord<T>(bm.id.toString());
      },
      onPressedB: () {
        Get.back();
      },
    ));
  }

  TotalResponse<T> paginateResponse(int count, int startIndex, List data) {
    final len = data.length;
    final endLen = len > (startIndex + count) ? (startIndex + count) : len;
    return TotalResponse(
        data.length, data.sublist(startIndex, endLen).cast<T>());
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    final appRepo = Get.find<AppRepo>();
    int page = (startIndex ~/ count) + 1;
    final perm = Get.find<AppController>()
        .allUserRoles
        .where((e) =>
            e.id == Get.find<AppRepo>().appService.currentUser.value.roleId)
        .firstOrNull;

    try {
      List<T> bms = [];
      List<List<dynamic>> tvals = [];
      TotalResponse<T> res;

      if (T == InventoryMetricStockBalances) {
        await Get.find<AppController>().initMetrics();
        res = paginateResponse(
            count, startIndex, (Get.find<AppController>().allStockBalances));
        // res = TotalResponse<T>(
        //     Get.find<AppController>().allStockBalances.length,
        //     Get.find<AppController>().allStockBalances.cast<T>());
      } else if (T == InventoryMetricDailyProfit) {
        await Get.find<AppController>().initMetrics();
        res = paginateResponse(
            count, startIndex, (Get.find<AppController>().allDailyProfit));
        // res = TotalResponse<T>(Get.find<AppController>().allDailyProfit.length,
        //     Get.find<AppController>().allDailyProfit.cast<T>());
      } else {
        res = await appRepo.getAll<T>(
            page: page,
            limit: count,
            fm: Get.find<AppController>().currentFilters);
      }

      appRepo
          .getAll<T>(fm: Get.find<AppController>().currentFilters, limit: 5000)
          .then((v) {
        Get.find<AppController>().currentTotalResponse.value = v;
        Get.find<AppController>().currentExcelHeaders.value =
            AllTables.tablesData[T]!.excelHeaders.isEmpty
                ? AllTables.tablesData[T]!.headers
                : AllTables.tablesData[T]!.excelHeaders;
      });

      bms = res.data;
      tvals = res.data.map((e) => (e as BaseModel).toTableRows()).toList();

      return AsyncRowsResponse(
          res.total,
          List.generate(res.data.length, (index) {
            final tval = tvals[index];
            final bm = bms[index];

            return DataRow2(
                onTap: () async {
                  await editRecord(bm);
                },
                color: WidgetStatePropertyAll(AppColors.white),
                cells: Ui.width(Get.context!) < 975
                    ? [
                        DataCell(CurvedContainer(
                          width: wideUi(Get.context!) - 72,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      List.generate(tm.length - 1, (jindex) {
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AppText.bold("${tm[jindex]} : ",
                                            fontSize: 14),
                                        AppText.thin(tval[jindex].toString(),
                                            fontSize: 14),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                              Ui.boxWidth(12),
                              if (perm?.perms[AllTables.tablesType.indexOf(T)]
                                      [1] ==
                                  1)
                                AppIcon(
                                  Icons.edit,
                                  color: AppColors.green,
                                  onTap: () async {
                                    await editRecord(bm);
                                  },
                                ),
                              Ui.boxWidth(12),
                              if (T != BulkExpenses &&
                                  (perm?.perms[AllTables.tablesType.indexOf(T)]
                                          [3] ==
                                      1))
                                AppIcon(
                                  Icons.delete,
                                  color: Colors.red,
                                  onTap: () {
                                    deleteRecord(bm);
                                  },
                                ),
                            ],
                          ),
                        ))
                      ]
                    : List.generate(tm.length, (jindex) {
                        if (jindex == tm.length - 1) {
                          return DataCell(Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // const AppIcon(
                                //   Icons.remove_red_eye,
                                //   color: Colors.brown,
                                // ),
                                // Ui.boxWidth(12),
                                if (perm?.perms[AllTables.tablesType.indexOf(T)]
                                        [1] ==
                                    1)
                                  AppIcon(
                                    Iconsax.edit_2_outline,
                                    size: 20,
                                    color: AppColors.green,
                                    onTap: () async {
                                      await editRecord(bm);
                                    },
                                  ),
                                Ui.boxWidth(24),
                                if (T != BulkExpenses &&
                                    (perm?.perms[AllTables.tablesType
                                            .indexOf(T)][3] ==
                                        1))
                                  AppIcon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.red,
                                    size: 20,
                                    onTap: () {
                                      deleteRecord(bm);
                                    },
                                  ),
                              ],
                            ),
                          ));
                        }
                        if (T == Order && jindex == 3) {
                          final cl =
                              tval[jindex] ? AppColors.green : AppColors.orange;
                          return DataCell(Center(
                            child: CurvedContainer(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
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
                                      tval[jindex]
                                          ? "Dispatched"
                                          : "In Progress",
                                      fontSize: 12,
                                      color: cl),
                                ],
                              ),
                            ),
                          ));
                        }
                        return DataCell(
                          Center(
                              child: AppText.thin(tval[jindex].toString(),
                                  att: true,
                                  alignment: TextAlign.center,
                                  fontSize: 13)),
                        );
                      }));
          }));
    } catch (e) {
      print(e);
    }
    return AsyncRowsResponse(0, []);
  }
}

class CustomTableTitle extends StatelessWidget {
  const CustomTableTitle(this.hi, {this.actions = const [], super.key});
  final List<Widget> actions;
  final List<HeaderItem> hi;

  @override
  Widget build(BuildContext context) {
    return CurvedContainer(
        width: Ui.width(context) < 975
            ? wideUi(context)
            : (Ui.width(context) - 24),
        color: AppColors.transparent,
        padding: const EdgeInsets.all(0),
        radius: 0,
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(child: HeaderChooser(hi)),
            if (actions.isNotEmpty) ...actions,
            if (Ui.width(context) < 975)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: AppIcon(
                  Icons.filter_alt,
                  color: AppColors.primaryColor,
                  onTap: () {
                    Get.dialog(AppDialog(
                        title: SizedBox(), content: CustomTableFilter()));
                  },
                ),
              )
          ],
        ));
  }
}

class CustomTablePage extends StatefulWidget {
  const CustomTablePage(this.hi, this.title, {super.key});
  final List<HeaderItem> hi;
  final String title;

  @override
  State<CustomTablePage> createState() => _CustomTablePageState();
}

class _CustomTablePageState extends State<CustomTablePage> {
  final controller = Get.find<AppController>();

  @override
  void initState() {
    widget.hi[0].vb!();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CustomTablePage oldWidget) {
    // TODO: implement didUpdateWidget
    if (oldWidget.hi != widget.hi) {
      widget.hi[0].vb!();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, right: 16, left: 16),
          child: AppText.bold(widget.title,
              fontSize: 30, fontFamily: Assets.appFontFamily2),
        ),
        CustomTableTitle(
          widget.hi,
        ),
        if (Ui.width(context) < 975)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [Expanded(child: CustomTable())],
            ),
          ),
        if (Ui.width(context) >= 975)
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // CustomTableFilter(),
              CustomTable()
            ],
          ))
      ],
    );
  }
}

class HeaderChooser extends StatelessWidget {
  const HeaderChooser(this.hi,
      {this.i = 0, this.shdChangeMode = true, super.key});
  final List<HeaderItem> hi;
  final bool shdChangeMode;
  final int i;

  @override
  Widget build(BuildContext context) {
    RxInt curHeader = i.obs;
    final cl = List.generate(hi.length, (i) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            curHeader.value = i;
            if (hi[i].vb != null) hi[i].vb!();
            if (shdChangeMode) {
              Get.find<AppController>().changedMode.value++;
            }
          },
          child: Obx(() {
            return CurvedContainer(
              radius: 0,
              color: AppColors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              border: Border(
                  bottom: BorderSide(
                      color: curHeader.value == i
                          ? AppColors.primaryColor
                          : AppColors.transparent)),
              child: AppText.medium(
                hi[i].title,
                fontSize: 14,
                color: curHeader.value == i
                    ? AppColors.primaryColor
                    : AppColors.lightTextColor,
              ),
            );
          }),
        ),
      );
    });
    return Wrap(
      // mainAxisSize: MainAxisSize.min,
      children: cl,
    );
  }
}

class DynamicFormGenerator extends StatefulWidget {
  final BaseModel model;
  final bool isNew;
  final Function(Map<String, dynamic>) onSave;

  const DynamicFormGenerator({
    super.key,
    required this.model,
    required this.onSave,
    this.isNew = false,
  });

  @override
  State<DynamicFormGenerator> createState() => _DynamicFormGeneratorState();
}

class _DynamicFormGeneratorState extends State<DynamicFormGenerator> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final Map<String, TextEditingController> _controllers = {};
  RxInt makeId = 1.obs;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Get the toJson fields using mirrors
    Map<String, dynamic> jsonMap = widget.model.toJson();

    // Create controllers for each field
    _formData['id'] = widget.model.id;
    _formData['createdAt'] =
        widget.model.createdAt?.toString() ?? DateTime.now().toString();
    _formData['updatedAt'] =
        widget.model.updatedAt?.toString() ?? DateTime.now().toString();
    jsonMap.forEach((key, value) {
      if (!['id', 'createdAt', 'updatedAt'].contains(key)) {
        _controllers[key] = TextEditingController(
            text: widget.isNew ? "" : value?.toString() ?? '');
      }
    });
  }

  Widget _buildField(String fieldName, dynamic value) {
    // Determine field type based on value
    if ((widget.model.runtimeType == Inventory ||
            widget.model.runtimeType == LubeInventory) &&
        (fieldName == "markup" || fieldName == "sellingPrice")) {
      return SizedBox();
    }

    if (!Get.find<AppService>().currentUser.value.isAdmin &&
        widget.model.runtimeType == Product &&
        (fieldName == "cost" ||
            fieldName == "markup" ||
            fieldName == "sellingPrice")) {
      return SizedBox();
    }
    if (!Get.find<AppService>().currentUser.value.isAdmin &&
        (fieldName == "markup")) {
      return SizedBox();
    }
    if (!Get.find<AppService>().currentUser.value.isAdmin &&
        (fieldName == "sellingPrice") &&
        ((double.tryParse(_controllers["markup"]!.text) ?? 0) == 0 ||
            (double.tryParse(_controllers["sellingPrice"]!.text) ?? 0) == 0)) {
      return SizedBox();
    }

    if (fieldName.endsWith("Id") ||
        fieldName.endsWith("Type") ||
        fieldName.endsWith("status") ||
        fieldName.endsWith("markup")) {
      if ((widget.model.runtimeType == Expenses &&
              fieldName == "expensesCategoryId") ||
          (widget.model.runtimeType == Product &&
              fieldName == "productCategoryId") ||
          ((widget.model.runtimeType == Inventory ||
                  widget.model.runtimeType == LubeInventory) &&
              (fieldName == "productCategoryId" ||
                  fieldName == "productTypeId" ||
                  fieldName == "status"))) {
        return SizedBox();
      }
      List<String> titles =
          Get.find<AppController>().filterOptions[fieldName]?.titles ??
              ["None"];
      List<dynamic> values =
          Get.find<AppController>().filterOptions[fieldName]?.values ?? [0];

      final cdd = CustomTextField.dropdown(
          titles,
          values,
          _controllers[fieldName]!,
          "${_formatFieldName(fieldName).replaceAll(" id", "")}",
          useOld: false,
          useDrop2: true,
          isVertical: false,
          initOption: value, onChanged: (a) {
        try {
          if (widget.model.runtimeType == Product &&
              fieldName == "productTypeId") {
            _controllers["productCategoryId"]!.text = Get.find<AppController>()
                .allProductType
                .where((optv) => optv.id == a)
                .first
                .productCategoryId
                .toString();
          } else if ((widget.model.runtimeType == Inventory ||
                  widget.model.runtimeType == LubeInventory) &&
              fieldName == "productId") {
            _controllers["productCategoryId"]!.text = Get.find<AppController>()
                .allProducts
                .where((optv) => optv.id == a)
                .first
                .productCategoryId
                .toString();
            _controllers["productTypeId"]!.text = Get.find<AppController>()
                .allProducts
                .where((optv) => optv.id == a)
                .first
                .productTypeId
                .toString();
          } else if (widget.model.runtimeType == Expenses &&
              fieldName == "expensesTypeId") {
            _controllers["expensesCategoryId"]!.text = Get.find<AppController>()
                .allExpensesTypes
                .where((optv) => optv.id == a)
                .first
                .category;
          } else if ((widget.model.runtimeType == Inventory ||
                  widget.model.runtimeType == LubeInventory) &&
              fieldName == "transactionType") {
            _controllers["status"]!.text = a;
          } else if (widget.model.runtimeType == Product &&
              fieldName == "markup") {
            final pd = double.tryParse(_controllers["cost"]!.text) ?? 0;
            _controllers["sellingPrice"]!.text = Get.find<AppController>()
                .calcNewSellingPrice(pd, a)
                .toCurrencyString();
            print(_controllers["sellingPrice"]!.text);
          } else if (widget.model.runtimeType == CustomerCar &&
              fieldName == "makeId") {
            makeId.value = a;
          }
        } catch (e) {
          print(e);
        }
      });

      if (widget.model.runtimeType == CustomerCar && fieldName == "modelId") {
        return Obx(() {
          print(makeId.value);
          final nt = Get.find<AppController>().allCarModels.where((p0) =>
              p0.makeId == (int.tryParse(_controllers["makeId"]!.text) ?? 0));
          titles = nt.map((e) => e.model).toList();
          values = nt.map((e) => e.id).toList();
          return CustomTextField.dropdown(
              titles,
              values,
              _controllers[fieldName]!,
              "${_formatFieldName(fieldName).replaceAll(" id", "")}",
              useOld: false,
              useDrop2: true,
              isVertical: false,
              initOption: value,
              onChanged: (_) {});
        });
      } else {
        return cdd;
      }
    }

    if (fieldName.endsWith("signature")) {
      return SizedBox();
    }

    if (fieldName.endsWith("At")) {
      return _buildDateTimePicker(fieldName);
    }

    if (fieldName == "servicesPerformed") {
      final options = Get.find<AppController>()
          .allBillyServices
          .map((element) => element.name)
          .toList();
      final values = Get.find<AppController>()
          .allBillyServices
          .map((element) => element.id)
          .toList();
      return CustomMultiDropdown(
        options,
        values,
        _controllers[fieldName]!,
        _formatFieldName(fieldName),
        initValues: widget.isNew ? [] : (jsonDecode(value) as List),
        isEnable: true,
        isDrop2: true,
      );
    }

    if (fieldName == "conditions") {
      final options = Get.find<AppController>()
          .allBillyConditions
          .map((element) => element.name)
          .toList();
      final values = Get.find<AppController>()
          .allBillyConditions
          .map((element) => element.id)
          .toList();

      List<dynamic> conds = (jsonDecode(value) as List);
      List<int> newConds = [];
      if (!widget.isNew) {
        for (var i = 0; i < options.length; i++) {
          if (conds[i] as int != 0) {
            newConds.add(values[i]);
          }
        }
      }

      return CustomMultiDropdown(
        options,
        values,
        _controllers[fieldName]!,
        _formatFieldName(fieldName),
        initValues: widget.isNew ? [] : newConds,
        isEnable: true,
        isDrop2: true,
      );
    }

    if (fieldName.toLowerCase().endsWith("image") ||
        fieldName == "imageIn" ||
        fieldName == "imageOut") {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: AppText.thin(_formatFieldName(fieldName))),
          Obx(() {
            RxString cimg = _controllers[fieldName]!.text.obs;
            final cc = CurvedContainer(
                border: Border.all(color: AppColors.grey),
                onPressed: () async {
                  final img = await UtilFunctions.showCamera();
                  if (img != null) {
                    _controllers[fieldName]!.text = img;
                    cimg.value = img;
                  }
                },
                height: 120,
                padding: EdgeInsets.all(cimg.isNotEmpty ? 0 : 24),
                margin: EdgeInsets.all(24),
                child: cimg.value.isNotEmpty
                    ? cimg.value.contains("\\")
                        ? Image.file(
                            File(cimg.value),
                            fit: BoxFit.cover,
                          )
                        : Transform.rotate(
                            angle: pi / 2,
                            child: Image.network(
                              "${AppUrls.baseURL}${AppUrls.upload}/all/${cimg.value}",
                              fit: BoxFit.contain,
                            ),
                          )
                    : Center(
                        child: AppIcon(
                        Icons.add_a_photo,
                        size: Ui.width(context) < 750 ? 24 : 48,
                      )));
            if (cimg.value.isNotEmpty) {
              return Stack(
                children: [
                  cc,
                  Positioned(
                      top: 0,
                      right: 0,
                      child: AppIcon(
                        Icons.remove_circle_rounded,
                        color: Colors.red,
                        onTap: () {
                          _controllers[fieldName]!.text = "";
                          cimg.value = "";
                        },
                      ))
                ],
              );
            }
            return cc;
          }),
        ],
      );
    }

    //Tanks ,Product,Capacity
    //Products ,Name,PPL,Spec,CostPrice,SellingPrice
    //Transaction ,Product,AmtInltr,Order

    return CustomTextField2(
      _formatFieldName(fieldName),
      _controllers[fieldName]!,
      customOnChanged: () {
        if (widget.model.runtimeType == Expenses &&
            fieldName.toLowerCase().endsWith("cost")) {
          (widget.model as Expenses).rawCost.value =
              double.tryParse(_controllers[fieldName]!.text) ?? 0;
        }
        if ((widget.model.runtimeType == Inventory ||
                widget.model.runtimeType == LubeInventory) &&
            fieldName == "cost") {
          final pd = int.tryParse(_controllers["markup"]!.text) ?? 0;
          final cd = double.tryParse(_controllers["cost"]!.text) ?? 0;
          if (pd == 0) {
            _controllers["sellingPrice"]!.text = 0.toString();
          } else {
            _controllers["sellingPrice"]!.text = Get.find<AppController>()
                .calcNewSellingPrice(cd, pd)
                .toCurrencyString();
          }
        }
      },
      isCompulsory: true,
      readOnly: (!Get.find<AppService>().currentUser.value.isAdmin &&
          (widget.model.runtimeType == Inventory ||
              widget.model.runtimeType == LubeInventory) &&
          (fieldName == "sellingPrice") &&
          (double.tryParse(_controllers["markup"]!.text) ?? 0) > 0),
      varl: fieldName.toLowerCase().endsWith("cost") ||
              fieldName.toLowerCase().endsWith("price")
          ? FPL.number
          : FPL.text,
    );
  }

  Widget _buildDateTimePicker(String fieldName) {
    return CustomTextField2(
      _formatFieldName(fieldName),
      _controllers[fieldName]!,
      readOnly: true,
      shdValidate: false,
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          // setState(() {
          _controllers[fieldName]?.text =
              DateFormat("dd/MM/yyyy hh:mm:ss").format(picked);
          _formData[fieldName] = picked;
          // });
        }
      },
    );
  }

  String _formatFieldName(String name) {
    if (name == "cost") {
      return "Unit Cost";
    }
    if (name == "sellingPrice") {
      return "Unit Selling Price";
    }
    return name
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)}',
        )
        .capitalizeFirst!;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> jsonMap = widget.model.toJson();
    if (widget.model.runtimeType == UserRole) {
      UserRole ur = widget.model as UserRole;

      return SingleChildScrollView(
        child: Column(
          children: [
            if (!widget.isNew)
              CustomTextField2(_formatFieldName("id"),
                  TextEditingController(text: _formData['id'].toString()),
                  readOnly: true),
            _buildField("name", jsonMap["name"]),
            UserRolesList(ur),
            Ui.boxHeight(24),
            if (!widget.isNew)
              CustomTextField2(
                _formatFieldName("createdAt"),
                TextEditingController(
                    text: DateFormat("dd/MM/yyyy hh:mm:ss")
                        .format(DateTime.parse(_formData['createdAt']))),
                readOnly: true,
              ),
            if (!widget.isNew)
              CustomTextField2(
                _formatFieldName("updatedAt"),
                TextEditingController(
                    text: DateFormat("dd/MM/yyyy hh:mm:ss")
                        .format(DateTime.parse(_formData['updatedAt']))),
                readOnly: true,
              ),
            AppButton(
              onPressed: () async {
                ur.name = _controllers["name"]!.text;
                if (ur.validate()) {
                  final gh = ur.toJson();
                  gh["id"] = ur.id;
                  await widget.onSave(gh);
                } else {
                  Ui.showError("User role name cannot be empty");
                }
              },
              text: "Save",
            )
          ],
        ),
      );
    }

    if (widget.model.runtimeType == Invoice) {
      Rx<Invoice> inv = (widget.model as Invoice).obs;
      TextEditingController ltec =
          TextEditingController(text: inv.value.labourCost.toCurrencyString());
      if (widget.isNew) {
        inv.value = Invoice(servicesUsed: [], productsUsed: []);
      }

      return SingleChildScrollView(
        child: Column(
          children: [
            if (!widget.isNew)
              CustomTextField2(_formatFieldName("id"),
                  TextEditingController(text: _formData['id'].toString()),
                  readOnly: true),
            _buildField("orderId", jsonMap["orderId"]),
            InvoiceList(
              inv,
              ltec,
              isOwn: false,
            ),
            if (!widget.isNew)
              CustomTextField2(
                _formatFieldName("createdAt"),
                TextEditingController(
                    text: DateFormat("dd/MM/yyyy hh:mm:ss")
                        .format(DateTime.parse(_formData['createdAt']))),
                readOnly: true,
              ),
            if (!widget.isNew)
              CustomTextField2(
                _formatFieldName("updatedAt"),
                TextEditingController(
                    text: DateFormat("dd/MM/yyyy hh:mm:ss")
                        .format(DateTime.parse(_formData['updatedAt']))),
                readOnly: true,
              ),
            AppButton(
              onPressed: () async {
                inv.value.orderId =
                    int.tryParse(_controllers["orderId"]!.text) ?? 0;
                inv.value.totalCost = inv.value.rawTotalCost;
                if (inv.value.validate()) {
                  inv.value.orderCreatedAt = Get.find<AppController>()
                          .allOrders
                          .where((optv) => optv.id == inv.value.orderId)
                          .firstOrNull
                          ?.createdAt ??
                      DateTime.now();
                  final gh = inv.value.toRawJson();
                  gh["id"] = inv.value.id;
                  await widget.onSave(gh);
                } else {
                  Ui.showError(
                      "Please check the Services/Products Section, None values are not acceptable");
                }
              },
              text: "Save",
            )
          ],
        ),
      );
    }

    if (widget.model.runtimeType == BulkExpenses) {
      Rx<BulkExpenses> inv = (widget.model as BulkExpenses).obs;
      if (widget.isNew && inv.value.expenses.isEmpty) {
        inv.value = BulkExpenses(date: DateTime.now());
        inv.value.expenses = [];
      }

      return SingleChildScrollView(
        child: Column(
          children: [
            if (inv.value.expenses.isNotEmpty)
              CustomTextField2(_formatFieldName("id"),
                  TextEditingController(text: _formData['id'].toString()),
                  readOnly: true),
            if (inv.value.expenses.isNotEmpty)
              CustomTextField2(
                _formatFieldName("createdAt"),
                TextEditingController(
                    text: DateFormat("dd/MM/yyyy hh:mm:ss")
                        .format(DateTime.parse(_formData['createdAt']))),
                readOnly: true,
              ),
            ExpensesList(inv),
            AppButton(
              onPressed: () async {
                if (inv.value.validate()) {
                  await Get.find<AppController>().syncExpenses(
                      inv.value.toJson(), inv.value.date.toSQLDate());
                } else {
                  Ui.showError("None values are not acceptable");
                }
              },
              text: "Save",
            )
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Divider(
              color: AppColors.borderColor,
            ),
            if (!widget.isNew)
              CustomTextField2(_formatFieldName("id"),
                  TextEditingController(text: _formData['id'].toString()),
                  readOnly: true),
            ...jsonMap.entries
                .where((entry) =>
                    !['id', 'createdAt', 'updatedAt'].contains(entry.key))
                .map((entry) => _buildField(entry.key, entry.value)),
            if (!widget.isNew)
              CustomTextField2(
                _formatFieldName("createdAt"),
                TextEditingController(
                    text: DateFormat("dd/MM/yyyy hh:mm:ss")
                        .format(DateTime.parse(_formData['createdAt']))),
                readOnly: true,
              ),
            if (!widget.isNew)
              CustomTextField2(
                _formatFieldName("updatedAt"),
                TextEditingController(
                    text: DateFormat("dd/MM/yyyy hh:mm:ss")
                        .format(DateTime.parse(_formData['updatedAt']))),
                readOnly: true,
              ),
            Ui.boxHeight(24),
            AppButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();
                  _controllers.forEach((key, value) {
                    if (key == "servicesPerformed") {
                      _formData[key] = value.text.isEmpty
                          ? <int>[]
                          : value.text
                              .split(",")
                              .map((e) => int.tryParse(e) ?? 0)
                              .toList();
                    } else if (key == "conditions") {
                      final vg = value.text
                          .split(",")
                          .map((e) => int.tryParse(e) ?? 0)
                          .toList();
                      _formData[key] = value.text.isEmpty
                          ? List.generate(
                              Get.find<AppController>()
                                  .allBillyConditions
                                  .length,
                              (index) => 0)
                          : List.generate(
                              Get.find<AppController>()
                                  .allBillyConditions
                                  .length,
                              (index) => vg.contains(Get.find<AppController>()
                                      .allBillyConditions[index]
                                      .id)
                                  ? 1
                                  : 0);
                    } else {
                      _formData[key] = value.text;
                    }
                  });
                  await widget.onSave(_formData);
                }
              },
              text: "Save",
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}

class ExpensesList extends StatelessWidget {
  const ExpensesList(this.bulkExpenses, {super.key});
  final Rx<BulkExpenses> bulkExpenses;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Ui.align(child: AppText.bold("Expenses")),
        Ui.boxHeight(8),
        Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: bulkExpenses.value.expenses
                .map((e) => ExpensesItemWidget(e))
                .toList(),
          );
        }),
        InvoiceItemCounter(() {
          bulkExpenses.value.expenses.add(Expenses());
          bulkExpenses.refresh();
        }, () {
          if (bulkExpenses.value.expenses.isNotEmpty) {
            bulkExpenses.value.expenses.removeLast();
          }
          bulkExpenses.refresh();
        }),
        AppDivider(),
        Obx(() {
          return ExpensesItemWidget(Expenses(),
              title: "TOTAL Expenses",
              desc: bulkExpenses.value.rawTotalCost.toCurrency());
        }),
        Ui.boxHeight(48),
      ],
    );
  }
}

class ExpensesItemWidget extends StatelessWidget {
  const ExpensesItemWidget(this.expense,
      {this.title = "", this.desc = "", super.key});
  final Expenses expense;
  final String title, desc;

  @override
  Widget build(BuildContext context) {
    final qtyTec =
        TextEditingController(text: expense.rawCost.value.toCurrencyString());

    return SizedBox(
      width: Ui.width(context),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        if (title.isNotEmpty) Expanded(flex: 3, child: AppText.bold(title)),
        if (title.isNotEmpty)
          Expanded(
              flex: 1,
              child: CustomTextField(
                "",
                TextEditingController(text: desc),
                hasBottomPadding: false,
                varl: FPL.number,
                readOnly: true,
                textAlign: TextAlign.right,
              )),
        if (title.isEmpty)
          Expanded(
              flex: 3,
              child: CustomTextField.dropdown(
                  Get.find<AppController>()
                      .filterOptions["expensesTypeId"]!
                      .titles,
                  Get.find<AppController>()
                      .filterOptions["expensesTypeId"]!
                      .values,
                  TextEditingController(),
                  "",
                  initOption: expense.expensesTypeId, onChanged: (v) {
                expense.expensesTypeId = v;
              })),
        if (title.isEmpty)
          Expanded(
            flex: 1,
            child: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: TextField(
                    controller: qtyTec,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(hintText: "Amount"),
                    onChanged: (v) {
                      expense.rawCost.value = double.tryParse(qtyTec.text) ?? 0;
                    })),
          ),
      ]),
    );
  }
}

class MarkupTargetsPage extends StatefulWidget {
  const MarkupTargetsPage({super.key});

  @override
  State<MarkupTargetsPage> createState() => _MarkupTargetsPageState();
}

class _MarkupTargetsPageState extends State<MarkupTargetsPage> {
  final controller = Get.find<AppController>();

  List<String> cmdValues = ["All", "Day", "Month", "Year"];

  List<String> cmdTitles = ["All", "Day", "Month", "Year"];

  late DateTime dtrd, dtrm, dtry;
  final TextEditingController pidTec = TextEditingController();
  final TextEditingController pmdTec = TextEditingController();
  final TextEditingController psdTec = TextEditingController();
  final TextEditingController pcdTec = TextEditingController();
  final TextEditingController curMonthDay = TextEditingController(text: "All");
  final TextEditingController curMonthDayTitle = TextEditingController();
  Rx<DateTime> curDateTime = DateTime(2025).obs;
  Rx<Product> curProduct =
      Product(name: "", productCategoryId: 0, productTypeId: 0).obs;

  setDateValues() {
    DateTime dtt = curDateTime.value;
    dtrd = DateTime(dtt.year, dtt.month, dtt.day);
    dtrm = DateTime(dtt.year, dtt.month);
    dtry = DateTime(dtt.year);
    curMonthDayTitle.text = DateFormat("dd/MM/yyyy").format(curDateTime.value);
  }

  @override
  void initState() {
    curDateTime.value = DateTime.now();
    setDateValues();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CurvedContainer(
      width:
          Ui.width(context) < 975 ? wideUi(context) : (Ui.width(context) - 280),
      height: Ui.width(context) < 975 ? null : double.maxFinite,
      color: AppColors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
          child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.medium("Targets",
                  fontFamily: Assets.appFontFamily2, fontSize: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: Ui.width(context) / 10,
                      child: CustomTextField.dropdown(
                          cmdTitles, cmdValues, curMonthDay, "",
                          initOption: curMonthDay.text, onChanged: (v) {
                        curMonthDay.text = v;
                        if (v == "All" || v == "None") {
                          setDateValues();
                        }
                        setState(() {});
                      }),
                    ),
                    Ui.boxWidth(12),
                    SizedBox(
                        width: Ui.width(context) / 10,
                        child: CustomTextField(
                          "",
                          curMonthDayTitle,
                          hasBottomPadding: false,
                          readOnly: true,
                          onTap: () async {
                            if (curMonthDay.text == "Year") {
                              final f = await showYearPicker(
                                  context: context, initialYear: 2025);
                              if (f != null) {
                                curDateTime.value = DateTime(f);
                              }
                            } else if (curMonthDay.text == "Month") {
                              final f = await showMonthPicker(
                                  context: context,
                                  initialDate: DateTime(2025, 2),
                                  firstDate: DateTime(2025, 2),
                                  lastDate: DateTime.now());
                              if (f != null) {
                                curDateTime.value = f;
                              }
                            } else if (curMonthDay.text == "Day") {
                              final f = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2025, 2),
                                  lastDate: DateTime.now());
                              if (f != null) {
                                curDateTime.value = f;
                              }
                            } else {
                              curDateTime.value = DateTime.now();
                            }
                            setDateValues();
                            setState(() {});
                          },
                        )),
                  ],
                ),
              ),
              Obx(() {
                if (controller.allPendingMarkupProducts.isNotEmpty) {
                  return TableIconButton(
                    "${controller.allPendingMarkupProducts.length} Pending Markups",
                    Icons.info,
                    color: AppColors.primaryColor,
                    onPressed: () {
                      Get.dialog(AppDialog(
                        title: AppText.medium("Edit Record"),
                        content: BulkMarkup(),
                        width: Ui.width(context) * 1.5,
                      ));
                    },
                  );
                }
                return SizedBox();
              }),
            ],
          ),
          Ui.boxHeight(12),
          SmartJustifyRow(runSpacing: 12, spacing: 12, children: [
            if (curMonthDay.text == "Day" ||
                curMonthDay.text == "None" ||
                curMonthDay.text == "All")
              OrderMarkupCard(
                  "Daily Orders",
                  controller.appConstants.value.dailyOrdersTarget.toInt(),
                  (controller.groupedOrdersByDay[dtrd] ?? 0).toDouble().toInt(),
                  ""),
            // itemDataWidget("Weekly Orders", controller.appConstants.value.weeklyOrdersTarget, (controller.groupedOrdersByDay[dtrd] ?? 0).toDouble()),
            if (curMonthDay.text == "Month" ||
                curMonthDay.text == "None" ||
                curMonthDay.text == "All")
              OrderMarkupCard(
                  "Monthly Orders",
                  controller.appConstants.value.monthlyOrdersTarget.toInt(),
                  (controller.groupedOrdersByMonth[dtrm] ?? 0)
                      .toDouble()
                      .toInt(),
                  ""),
            if (curMonthDay.text == "Year" ||
                curMonthDay.text == "None" ||
                curMonthDay.text == "All")
              OrderMarkupCard(
                  "Yearly Orders",
                  controller.appConstants.value.yearlyOrdersTarget.toInt(),
                  (controller.groupedOrdersByYear[dtry] ?? 0)
                      .toDouble()
                      .toInt(),
                  ""),
          ]),
          Ui.boxHeight(12),
          SmartJustifyRow(runSpacing: 12, spacing: 12, children: [
            if (curMonthDay.text == "Day" ||
                curMonthDay.text == "None" ||
                curMonthDay.text == "All")
              ProfitMarkupCard(
                "Daily Profit",
                (controller.allDailyProfit
                        .where((optv) =>
                            optv.date.year == curDateTime.value.year &&
                            optv.date.month == curDateTime.value.month &&
                            optv.date.day == curDateTime.value.day)
                        .firstOrNull
                        ?.profit ??
                    0),
                controller.appConstants.value.dailyProfitTarget,
              ),

            // itemDataWidget("Weekly Profit", controller.appConstants.value.weeklyProfitTarget, (controller.allDailyProfit.where((optv) => optv.date.year ==curDateTime.value.year && optv.date.month == curDateTime.value.month).firstOrNull?.profit ?? 0),isCost: true),
            if (curMonthDay.text == "Month" ||
                curMonthDay.text == "None" ||
                curMonthDay.text == "All")
              ProfitMarkupCard(
                "Monthly Profit",
                (controller.allMonthlyProfit
                        .where((optv) =>
                            optv.date.year == curDateTime.value.year &&
                            optv.date.month == curDateTime.value.month)
                        .firstOrNull
                        ?.profit ??
                    0),
                controller.appConstants.value.monthlyProfitTarget,
              ),
            if (curMonthDay.text == "Year" ||
                curMonthDay.text == "None" ||
                curMonthDay.text == "All")
              ProfitMarkupCard(
                "Yearly Profit",
                (controller.allYearlyProfit
                        .where(
                            (optv) => optv.date.year == curDateTime.value.year)
                        .firstOrNull
                        ?.profit ??
                    0),
                controller.appConstants.value.yearlyProfitTarget,
              )
          ]),
          Ui.boxHeight(12),
          // SmartJustifyRow(children: [
          //   itemDataWidget("VAT (%)", controller.appConstants.value.vat,
          //       controller.appConstants.value.vat,
          //       isMarkup: true),
          // ]),
          // Ui.boxHeight(12),
        ],
      )),
    );
  }
}

class ReportsPage extends StatelessWidget {
  ReportsPage({super.key});
  final tec = TextEditingController();
  final reptec = TextEditingController();
  RxInt rep = 0.obs;
  Rx<ReportDS> reportDs =
      ReportDS(0, DateTimeRange(start: DateTime(2024), end: DateTime.now()))
          .obs;
  RxList<String> headers = <String>["All"].obs;
  Rx<DateTimeRange> dtr =
      DateTimeRange(start: DateTime(2024), end: DateTime.now()).obs;
  static const List<String> allReports = [
    "Revenue by Service Type",
    "Product Sales Analysis",
    "Customer Service History",
    "Vehicle Service Frequency",
    "Technician Performance",
    "Inventory Status",
    "Profit and Loss Statement",
    "Service Revenue vs Parts Revenue",
    "Finance Report",
  ];
  static const List<List<String>> allReportsTotal = [
    ["service_count", "total_revenue"],
    ["quantity_sold", "revenue"],
    ["total_visits"],
    ["service_count"],
    ["orders_completed", "total_revenue_generated"],
    ["total_sales", "total_purchases"],
    [
      "total_revenue",
      "product_costs",
      "labor_costs",
      "operational_expenses",
      "fixed_expenses",
      "net_profit"
    ],
    ["orders_completed", "total_revenue_generated", "total_labor_cost"],
    [
      "Productprofit",
      "Serviceprofit",
      "labor_profit",
      "Productcost",
      "expenses",
      "Totalprofit"
    ],
  ];
  RxInt mvallength = 1.obs;
  List mval = [];

  @override
  Widget build(BuildContext context) {
    tec.text =
        "${DateFormat("dd/MM/yyyy").format(dtr.value.start)} - ${DateFormat("dd/MM/yyyy").format(dtr.value.end)}";
    return CurvedContainer(
      width:
          Ui.width(context) < 975 ? wideUi(context) : (Ui.width(context) - 280),
      height: Ui.width(context) < 975 ? null : double.maxFinite,
      color: AppColors.transparent,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Center(
            child: Container(
              // padding: EdgeInsets.sy(24),
              // constraints: BoxConstraints(maxWidth: 850),
              width: wideUi(context),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          "Select Date Range",
                          tec,
                          readOnly: true,
                          onTap: () async {
                            final dtrr = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(1980),
                                lastDate: DateTime.now());
                            if (dtrr != null) {
                              tec.text =
                                  "${DateFormat("dd/MM/yyyy").format(dtrr.start)} - ${DateFormat("dd/MM/yyyy").format(dtrr.end)}";
                              dtr.value = dtrr;
                            }
                          },
                        ),
                      ),
                      Ui.boxWidth(24),
                      Expanded(
                        child: CustomTextField.dropdown(
                            allReports,
                            List.generate(allReports.length, (i) => i + 1),
                            reptec,
                            "Select Report",
                            initOption: rep.value, onChanged: (v) async {
                          rep.value = v;
                          final bms = await Get.find<AppRepo>().getReport(
                              rep.value,
                              dtr.value.start.toSQLDate(),
                              dtr.value.end.toSQLDate());
                          mval = bms.data as List<dynamic>;
                          if (mval.isNotEmpty) {
                            mvallength.value = mval.length;
                            headers.value = mval[0].keys.toList();
                            headers.refresh();
                            reportDs.value = ReportDS(rep.value, dtr.value);
                            reportDs.value.refreshDatasource();
                          }
                        }),
                      ),
                      Ui.boxWidth(24),
                      Expanded(
                        child: AppButton(
                          onPressed: () async {
                            if (mval.isEmpty) {
                              return Ui.showError("Data cannot be empty");
                            }
                            Map<String, String> hds = {};
                            for (var element in mval[0].keys) {
                              hds[element] = element
                                  .replaceAll("_", " ")
                                  .toString()
                                  .capitalize!;
                            }

                            final filePath = await generateExcelReport(
                              reportTitle: allReports[rep.value - 1],
                              data: mval,
                              startDate: dtr.value.start,
                              endDate: dtr.value.end,
                              columnsToTotal: allReportsTotal[rep.value - 1],
                              columnHeaders: hds,
                            );
                            if (filePath == null) {
                              return Ui.showError("Failed to generate report");
                            }
                            return Ui.showInfo("Export saved to:\n$filePath");
                          },
                          text: "Export Report as Excel",
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Ui.align(child: AppText.thin("Showing the last 100 records")),
          Ui.boxHeight(16),
          Expanded(
            child: CurvedContainer(
              border: Border.all(color: AppColors.borderColor),
              boxShadows: [
                BoxShadow(
                    offset: Offset(0, 1),
                    blurRadius: 2,
                    spreadRadius: 0,
                    color: AppColors.shadowColor.withOpacity(0.06)),
                BoxShadow(
                    offset: Offset(0, 1),
                    blurRadius: 3,
                    spreadRadius: 0,
                    color: AppColors.shadowColor.withOpacity(0.1)),
              ],
              child: Obx(() {
                return AsyncPaginatedDataTable2(
                  minWidth: 800,

                  hidePaginator: true,
                  columnSpacing: 0,
                  showCheckboxColumn: false,
                  // autoRowsToHeight: true,
                  horizontalMargin: 0,
                  wrapInCard: false,
                  rowsPerPage: 100,
                  headingRowHeight: 44,

                  columns: headers.map((e) {
                    final hd = e.replaceAll("_", " ").capitalize!;
                    return DataColumn2(
                        label: ColoredBox(
                          color: AppColors.borderColor,
                          child: Center(
                            child: AppText.bold(hd,
                                fontSize: 12,
                                fontFamily: Assets.appFontFamily2),
                          ),
                        ),
                        size: ColumnSize.S);
                  }).toList(),
                  source: reportDs.value,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportDS extends AsyncDataTableSource {
  ReportDS(this.rep, this.dtr);
  final DateTimeRange dtr;
  final int rep;

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    final bms = await Get.find<AppRepo>()
        .getReport(rep, dtr.start.toSQLDate(), dtr.end.toSQLDate());
    final mval = bms.data as List<dynamic>;

    return AsyncRowsResponse(
        mval.length,
        List.generate(mval.length, (index) {
          final tval = mval[index];
          return DataRow2(
              onSelectChanged: (b) {},
              cells: List.generate(tval.keys.length, (jindex) {
                final me = tval.keys.toList()[jindex];
                return DataCell(Center(
                    child: AppText.thin(tval[me].toString(),
                        fontSize: 12, att: true, alignment: TextAlign.center)));
              }));
        }));
  }
}

class BulkMarkup extends StatefulWidget {
  BulkMarkup({super.key});

  @override
  State<BulkMarkup> createState() => _BulkMarkupState();
}

class _BulkMarkupState extends State<BulkMarkup> {
  final controller = Get.find<AppController>();
  RxList<Product> selectedProducts = <Product>[].obs;
  RxInt markup = 0.obs;
  RxInt pending = 0.obs;

  @override
  initState() {
    selectedProducts.value = pending.value == 1
        ? controller.allProducts
        : controller.allPendingMarkupProducts;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomTextField.dropdown(["Pending", "All Products"], [0, 1],
              TextEditingController(), "Product", initOption: pending.value,
              onChanged: (v) {
            // selectedProducts.value = [];
            pending.value = v;
            selectedProducts.value = pending.value == 1
                ? controller.allProducts
                : controller.allPendingMarkupProducts;

            selectedProducts.refresh();
          }),
          Row(
            children: [
              Expanded(flex: 3, child: AppText.bold("Select Products")),
              Expanded(
                  flex: 1,
                  child: AppText.thin("Cost\nPrice",
                      att: true, alignment: TextAlign.center)),
              Expanded(
                  flex: 1,
                  child: AppText.thin("Markup",
                      att: true, alignment: TextAlign.center)),
              Expanded(
                  flex: 1,
                  child: AppText.thin("Selling\nPrice(exVAT)",
                      att: true, alignment: TextAlign.center)),
              Expanded(
                  flex: 1,
                  child: AppText.thin("VAT",
                      att: true, alignment: TextAlign.center)),
              Expanded(
                  flex: 1,
                  child: AppText.thin("Selling\nPrice",
                      att: true, alignment: TextAlign.center)),
            ],
          ),
          Obx(() {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(selectedProducts.length, (i) {
                // Product e = selectedProducts[i];
                final exvat = (100 * selectedProducts[i].sellingPrice) /
                    (100 + controller.appConstants.value.vat);
                final vat = (controller.appConstants.value.vat * exvat) / 100;
                final costTec = TextEditingController(
                    text: selectedProducts[i].cost.toCurrencyString());
                final priceTec = TextEditingController(
                    text: selectedProducts[i].sellingPrice.toCurrencyString());

                final exVatTec =
                    TextEditingController(text: exvat.floor().toString());
                final vatTec =
                    TextEditingController(text: vat.floor().toString());
                final ctt = controller
                    .filterOptions[
                        pending.value == 1 ? "productId" : "productId3"]!
                    .titles;
                final vtt = controller
                    .filterOptions[
                        pending.value == 1 ? "productId" : "productId3"]!
                    .values;

                return Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: CustomTextField.dropdown(
                            ctt, vtt, TextEditingController(), "",
                            initOption: selectedProducts[i].id,
                            isEnabled: false,
                            onChanged: (p0) {})),
                    Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: TextField(
                            controller: costTec,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onChanged: (v) {
                              selectedProducts[i].cost =
                                  double.tryParse(costTec.text) ?? 0;
                              selectedProducts[i].sellingPrice =
                                  controller.calcNewSellingPrice(
                                      selectedProducts[i].cost,
                                      selectedProducts[i].markup);
                              selectedProducts[i].markup =
                                  selectedProducts[i].markup;
                              priceTec.text = selectedProducts[i]
                                  .sellingPrice
                                  .toCurrencyString();

                              // selectedProducts.refresh();
                            },
                            textAlign: TextAlign.center,
                          ),
                        )),
                    Expanded(
                      flex: 1,
                      child: CustomTextField.dropdown(
                          controller.filterOptions["markup"]!.titles,
                          controller.filterOptions["markup"]!.values,
                          TextEditingController(),
                          "",
                          initOption: selectedProducts[i].markup,
                          onChanged: (v) {
                        markup.value = v;
                        selectedProducts[i].markup = v;
                        selectedProducts[i].sellingPrice = controller
                            .calcNewSellingPrice(selectedProducts[i].cost, v);
                        priceTec.text =
                            selectedProducts[i].sellingPrice.toCurrencyString();
                        final exvatt =
                            (100 * selectedProducts[i].sellingPrice) /
                                (100 + controller.appConstants.value.vat);
                        final vatt =
                            (controller.appConstants.value.vat * exvatt) / 100;
                        exVatTec.text = exvatt.floor().toString();
                        vatTec.text = vatt.floor().toString();
                      }),
                    ),
                    Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: TextField(
                            controller: exVatTec,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            textAlign: TextAlign.center,
                            readOnly: true,
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: TextField(
                            controller: vatTec,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            textAlign: TextAlign.center,
                            readOnly: true,
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: TextField(
                            controller: priceTec,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            textAlign: TextAlign.center,
                            onChanged: (v) {
                              selectedProducts[i].sellingPrice =
                                  double.tryParse(priceTec.text) ?? 0;
                              final exvatt =
                                  (100 * selectedProducts[i].sellingPrice) /
                                      (100 + controller.appConstants.value.vat);
                              final vatt =
                                  (controller.appConstants.value.vat * exvatt) /
                                      100;
                              exVatTec.text = exvatt.floor().toString();
                              vatTec.text = vatt.floor().toString();
                            },
                          ),
                        )),
                  ],
                );
              }).toList(),
            );
          }),
          // InvoiceItemCounter(() {
          //   selectedProducts
          //       .add(Product(name: "", productCategoryId: 0, productTypeId: 0));
          //   selectedProducts.refresh();
          // }, () {
          //   if (selectedProducts.isNotEmpty) {
          //     selectedProducts.removeLast();
          //   }
          //   selectedProducts.refresh();
          // }),
          Ui.boxHeight(24),
          // CustomTextField.dropdown(
          //     controller.filterOptions["markup"]!.titles,
          //     controller.filterOptions["markup"]!.values,
          //     TextEditingController(),
          //     "Markup",
          //     initOption: markup.value, onChanged: (v) {
          //   markup.value = v;
          //   for (var element in selectedProducts) {
          //     element.markup = v;
          //     element.sellingPrice =
          //         controller.calcNewSellingPrice(element.cost, v);
          //   }
          //   selectedProducts.refresh();
          // }),
          SizedBox(
              width: Ui.width(context) / 2,
              child: AppButton(
                  onPressed: () async {
                    if (selectedProducts.isEmpty) {
                      return Ui.showError("Products cannot be empty");
                    }
                    if (selectedProducts.any((optv) => optv.id == 0)) {
                      return Ui.showError("Kindly remove the 'None' values");
                    }
                    await controller.editBulkProductPrice(selectedProducts);
                  },
                  text: "Save"))
        ],
      ),
    );
  }
}

class ExtraInvoiceWidget extends StatelessWidget {
  ExtraInvoiceWidget({super.key});

  final Rx<Invoice> inv = Invoice(servicesUsed: [], productsUsed: []).obs;
  final controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return CurvedContainer(
      width:
          Ui.width(context) < 975 ? wideUi(context) : (Ui.width(context) - 280),
      height: Ui.width(context) < 975 ? null : double.maxFinite,
      color: AppColors.transparent,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        child: Column(children: [
          InvoiceList(
            inv,
            TextEditingController(),
            isOwn: false,
            onlyProduct: true,
          ),
          Ui.boxHeight(24),
          AppButton(
            onPressed: () async {
              inv.value.orderId = 1;
              await controller.addExtraInvoice(inv.value);
            },
            text: "Save",
          )
        ]),
      ),
    );
  }
}

class LubeDashboard extends StatelessWidget {
  LubeDashboard({super.key});
  final controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    final cl = Obx(() {
      final debit = controller.allLubeInventory
          .where((test) => test.status.toLowerCase() == "inbound")
          .map((e) => e.cost * e.qty)
          .fold(0.0, (a, b) => a + b);
      final credit = controller.allLubeInventory
          .where((test) => test.status.toLowerCase() == "outbound")
          .map((e) => e.sellingPrice * e.qty)
          .fold(0.0, (a, b) => a + b);
      final prof = credit - debit;
      final cf = [
        itemDataWidget(
            "Total Products",
            controller.allProducts
                .where((test) => test.productTypeId == 201)
                .length
                .toString(),
            vals: getMonthCounts<Product>(controller.allProducts
                .where((test) => test.productTypeId == 201)
                .toList())),
        if (controller.appRepo.appService.currentUser.value.isAdmin)
          itemDataWidget(
            "Total Expenses",
            debit.toCurrency(),
          ),
        itemDataWidget(
          "Total Cost Of Goods Sold",
          credit.toCurrency(),
        ),
        if (controller.appRepo.appService.currentUser.value.isAdmin)
          itemDataWidget(
            "Total Profit/Loss",
            prof.toCurrency(),
          ),
      ];
      return SmartJustifyRow(runSpacing: 16, spacing: 16, children: cf);
    });

    return CurvedContainer(
      width:
          Ui.width(context) < 975 ? wideUi(context) : (Ui.width(context) - 280),
      height: Ui.width(context) < 975 ? null : double.maxFinite,
      color: AppColors.transparent,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AppText.bold("Lube Dashboard",
          //     fontSize: 32, fontFamily: Assets.appFontFamily2),
          // AppText.thin("Here are the current status of your lubricants."),
          Ui.boxHeight(12),
          cl,
          Ui.boxHeight(12),
          if (Ui.width(context) >= 975)
            Expanded(
                child: Align(
              alignment: Alignment.topCenter,
              child: Row(
                children: [
                  Obx(() {
                    final prds = controller.allProducts
                        .where((test) => test.productTypeId == 201)
                        .toList();
                    // final prdsIds = prds.map((e) => e.id);
                    final prdQty = prds
                        .map((e) => controller.allStockBalances
                            .where((test) => e.id == test.productId)
                            .first)
                        .toList();
                    return Expanded(
                        child: prds.isEmpty
                            ? Center(
                                child: AppText.bold("No Lube Products Found"),
                              )
                            : SingleChildScrollView(
                                child: Wrap(
                                  spacing: 24,
                                  runSpacing: 24,
                                  alignment: WrapAlignment.spaceEvenly,
                                  children: List.generate(prds.length, (i) {
                                    try {
                                      final qty = prdQty[i].quantity;
                                      return tankItem(prds[i].name, qty / 208,
                                          qty.toString());
                                    } catch (e) {
                                      return tankItem(
                                          prds[i].name, 0, 0.toString());
                                    }
                                  }),
                                ),
                              ));
                  }),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.bold("Recent Lube Movement",
                          fontFamily: Assets.appFontFamily2, fontSize: 14),
                      Ui.boxHeight(16),
                      CurvedContainer(
                          height: Ui.height(context) / 2,
                          //           width: ((Ui.width(context) - 280)) - 48,
                          border: Border.all(color: AppColors.borderColor),
                          boxShadows: [
                            BoxShadow(
                                offset: Offset(0, 1),
                                blurRadius: 2,
                                spreadRadius: 0,
                                color: AppColors.shadowColor.withOpacity(0.06)),
                            BoxShadow(
                                offset: Offset(0, 1),
                                blurRadius: 3,
                                spreadRadius: 0,
                                color: AppColors.shadowColor.withOpacity(0.1)),
                          ],
                          child: recentInventory()),
                    ],
                  )
                ],
              ),
            )),
          Ui.boxHeight(12),
        ],
      ),
    );
  }

  Widget recentInventory() {
    return SizedBox(
      width: (Ui.width(Get.context!) * 0.25),
      child: AsyncPaginatedDataTable2(
        minWidth: (Ui.width(Get.context!) * 0.25),
        hidePaginator: true,
        columnSpacing: 0,
        showCheckboxColumn: false,
        autoRowsToHeight: true,
        horizontalMargin: 0,
        wrapInCard: false,
        headingRowHeight: 44,
        dataRowHeight: 72,
        rowsPerPage: 3,
        columns: ["Date", "Product", "Status", "Qty"]
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
        source: RecentInventoryDS(),
      ),
    );
  }

  Widget tankItem(String name, double bb, String c) {
    final b = bb.clamp(0, 1);
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        CurvedContainer(
          width: 180,
          height: b * 320,
          color: AppColors.borderColor,
          border: Border.all(color: AppColors.borderColor),
        ),
        CurvedContainer(
          width: 180,
          height: 320,
          color: AppColors.transparent,
          border: Border.all(color: AppColors.borderColor),
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.thin(name, fontFamily: Assets.appFontFamily2),
              AppText.bold("${c}L", fontSize: 24, color: Colors.blue),
              Ui.spacer(),
              Center(
                child: AppText.bold("${(b * 100).toInt()}%",
                    fontSize: 48, fontFamily: Assets.appFontFamily2),
              ),
              Ui.boxHeight(24)
            ],
          ),
        )
      ],
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
}

class UserRolesList extends StatelessWidget {
  const UserRolesList(this.ur, {super.key});
  final UserRole ur;

  @override
  Widget build(BuildContext context) {
    final modelKeys = AllTables.tablesType;
    final modelKeysString =
        AllTables.tablesType.map((e) => e.toString()).toList();
    final tec = TextEditingController();
    tec.addListener(() {
      final v = tec.text;
      final df = v.split(",");
      if (df.isEmpty) {
        ur.perms.value = List.generate(AllTables.tablesType.length, (i) {
          return [0, 0, 0, 0];
        });
      }
      for (var i = 0; i < df.length; i++) {
        final b = modelKeysString.indexWhere((test) => test == df[i]);
        if (b != -1) {
          ur.perms[b] = [1, 1, 1, 1];
        }
      }
      ur.perms.refresh();
    });
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomMultiDropdown(
          modelKeys.map((e) => e.toString()).toList(),
          modelKeys.map((e) => e.toString()).toList(),
          tec,
          "Models",
        ),
        Row(
          children: [
            Expanded(flex: 3, child: AppText.bold("Models")),
            Expanded(
                flex: 1,
                child: AppText.thin("Add", alignment: TextAlign.center)),
            Expanded(
                flex: 1,
                child: AppText.thin("View", alignment: TextAlign.center)),
            Expanded(
                flex: 1,
                child: AppText.thin("Edit", alignment: TextAlign.center)),
            Expanded(
                flex: 1,
                child: AppText.thin("Delete", alignment: TextAlign.center)),
          ],
        ),
        ...List.generate(modelKeys.length, (i) {
          final ij = i;
          return Row(
            children: [
              Expanded(flex: 3, child: AppText.thin(modelKeys[i].toString())),
              ...List.generate(4, (j) {
                return Expanded(
                    flex: 1,
                    child: Obx(() {
                      return Checkbox(
                          value: ur.perms[ij][j] == 1,
                          onChanged: (g) {
                            ur.perms[ij][j] = (g ?? false) ? 1 : 0;
                            ur.perms.refresh();
                          });
                    }));
              })
            ],
          );
        })
      ],
    );
  }
}
