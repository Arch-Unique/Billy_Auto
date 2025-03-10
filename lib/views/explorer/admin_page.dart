import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

import '../../models/inner_models/barrel.dart';
import '../../tools/functions.dart';
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
  @override
  Widget build(BuildContext context) {
    return LoadingWidget(
      child: CurvedContainer(
        width: Ui.width(context) < 975
            ? wideUi(context)
            : ((Ui.width(context) * 0.75) - 24),
        height: Ui.width(context) < 975 ? null : double.maxFinite,
        border: Border.all(color: AppColors.primaryColorLight),
        color: AppColors.white.withOpacity(0.6),
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Obx(() {
          return AsyncPaginatedDataTable2(
            minWidth: Ui.width(context) < 975
                ? wideUi(context)
                : ((Ui.width(context) * 0.75) - 56),
            // border: TableBorder.all(),

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
            headingRowHeight: Ui.width(context) < 975 ? 8 : 56,
            dataRowHeight:
                Ui.width(context) < 975 ? 156 : kMinInteractiveDimension,
            header: AppText.medium("Records",
                fontFamily: Assets.appFontFamily2, fontSize: 16),
            headingRowColor: WidgetStatePropertyAll<Color>(
                AppColors.primaryColorLight.withOpacity(0.5)),
            actions: [
              Material(
                color: AppColors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppIcon(
                  Icons.add,
                  color: AppColors.white,
                  onTap: () async {
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
                    Get.dialog(AppDialog(
                        title: AppText.medium("Add New Record"),
                        content: Obx(() {
                          return DynamicFormGenerator(
                              model: controller.currentBaseModel.value,
                              isNew: true,
                              onSave: (v) async {
                                await controller.saveNewRecord(v);
                              });
                        })));
                  },
                  size: 40,
                ),
              ), //add new
            ],
            columns: Ui.width(context) < 975
                ? [
                    DataColumn2(
                        label: AppText.bold("",
                            fontSize: 8, fontFamily: Assets.appFontFamily2),
                        size: ColumnSize.S)
                  ]
                : controller.currentHeaders
                    .map((e) => DataColumn2(
                        label: AppText.bold(e,
                            fontSize: 14, fontFamily: Assets.appFontFamily2),
                        size: ColumnSize.S))
                    .toList(),
            source: controller.tmds.value,
          );
        }),
      ),
    );
  }
}

class CustomTableFilter extends StatelessWidget {
  CustomTableFilter({super.key});
  final controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
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
                        firstDate: DateTime(1980),
                        lastDate: DateTime.now());
                    if (dtr != null) {
                      e.tec!.text =
                          "${DateFormat("dd/MM/yyyy").format(dtr.start)} - ${DateFormat("dd/MM/yyyy").format(dtr.end)}";
                    }
                  },
                );
              }),
              Ui.boxHeight(16),
              if (controller.currentFilters.isEmpty) AppText.thin("No Filters"),
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
  }
}

class TableModelDataSource<T extends BaseModel> extends AsyncDataTableSource {
  List<String> tm;
  TableModelDataSource(this.tm);

  editRecord(BaseModel bm) async {
    if (T == InventoryMetricStockBalances) return;
    if (!Get.find<AppService>().currentUser.value.isServiceAdvisor) {
      Ui.showError("Not enough permissions");
      return;
    }
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
        title: AppText.medium("Edit Record"),
        content: Obx(() {
          return DynamicFormGenerator(
              model: Get.find<AppController>().currentBaseModel.value,
              onSave: (v) async {
                await Get.find<AppController>().editExisitingRecord(v);
              });
        })));
  }

  deleteRecord(BaseModel bm) {
    if (T == InventoryMetricStockBalances) return;
    if (!Get.find<AppService>().currentUser.value.isServiceAdvisor) {
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

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    final appRepo = Get.find<AppRepo>();
    int page = (startIndex ~/ count) + 1;

    try {
      List<T> bms = [];
      List<List<dynamic>> tvals = [];
      TotalResponse<T> res;
      if (T == InventoryMetricStockBalances) {
        await Get.find<AppController>().initMetrics();
        res = TotalResponse<T>(
            Get.find<AppController>().allStockBalances.length,
            Get.find<AppController>().allStockBalances.cast<T>());
      } else {
        res = await appRepo.getAll<T>(
            page: page,
            limit: count,
            fm: Get.find<AppController>().currentFilters);
      }

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
                              AppIcon(
                                Icons.edit,
                                color: AppColors.green,
                                onTap: () async {
                                  await editRecord(bm);
                                },
                              ),
                              Ui.boxWidth(12),
                              if (T != BulkExpenses)
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
                          return DataCell(Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // const AppIcon(
                              //   Icons.remove_red_eye,
                              //   color: Colors.brown,
                              // ),
                              // Ui.boxWidth(12),
                              AppIcon(
                                Icons.edit,
                                color: AppColors.green,
                                onTap: () async {
                                  await editRecord(bm);
                                },
                              ),
                              Ui.boxWidth(12),
                              if (T != BulkExpenses)
                                AppIcon(
                                  Icons.delete,
                                  color: Colors.red,
                                  onTap: () {
                                    deleteRecord(bm);
                                  },
                                ),
                            ],
                          ));
                        }
                        if (T == Order && jindex == 3) {
                          return DataCell(Chip(
                            label: AppText.thin(
                                tval[jindex] ? "Dispatched" : "In Progress",
                                color: tval[jindex]
                                    ? Colors.green
                                    : Colors.orange[700]!),
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: tval[jindex]
                                        ? Colors.green
                                        : Colors.orange[700]!),
                                borderRadius: BorderRadius.circular(8)),
                          ));
                        }
                        return DataCell(AppText.thin(tval[jindex].toString()));
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
        color: AppColors.white.withOpacity(0.6),
        padding: const EdgeInsets.all(0),
        radius: 16,
        border: Border.all(color: AppColors.primaryColorLight),
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
  const CustomTablePage(this.hi, {super.key});
  final List<HeaderItem> hi;

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
      children: [
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
            children: [CustomTableFilter(), CustomTable()],
          ))
      ],
    );
  }
}

class HeaderChooser extends StatelessWidget {
  const HeaderChooser(this.hi, {this.i = 0, super.key});
  final List<HeaderItem> hi;
  final int i;

  @override
  Widget build(BuildContext context) {
    RxInt curHeader = i.obs;
    final cl = List.generate(hi.length, (i) {
      const rd = Radius.circular(12);
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            curHeader.value = i;
            if (hi[i].vb != null) hi[i].vb!();
          },
          child: Obx(() {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: Ui.width(context) < 975
                    ? BorderRadius.all(rd)
                    : BorderRadius.only(
                        topLeft: i == 0 ? rd : Radius.zero,
                        topRight: i == hi.length - 1 ? rd : Radius.zero,
                        bottomLeft: i == 0 ? rd : Radius.zero,
                        bottomRight: i == hi.length - 1 ? rd : Radius.zero,
                      ),
                color: curHeader.value == i
                    ? AppColors.primaryColor
                    : AppColors.white,
              ),
              child: AppText.medium(
                hi[i].title,
                fontSize: 16,
                color: curHeader.value == i
                    ? AppColors.white
                    : AppColors.primaryColor,
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
    if (fieldName.endsWith("Id") ||
        fieldName.endsWith("Type") ||
        fieldName.endsWith("status") ||
        fieldName.endsWith("role")) {
      if ((widget.model.runtimeType == Product &&
              fieldName == "productCategoryId") ||
          (widget.model.runtimeType == Inventory &&
              (fieldName == "productCategoryId" ||
                  fieldName == "productTypeId" ||
                  fieldName == "status"))) {
        return SizedBox();
      }
      return CustomTextField.dropdown(
          Get.find<AppController>().filterOptions[fieldName]?.titles ??
              ["None"],
          Get.find<AppController>().filterOptions[fieldName]?.values ?? [0],
          _controllers[fieldName]!,
          "Select ${_formatFieldName(fieldName).replaceAll(" id", "")}",
          useOld: false,
          initOption: value, onChanged: (a) {
        try {
          if (widget.model.runtimeType == Product &&
              fieldName == "productTypeId") {
            _controllers["productCategoryId"]!.text = Get.find<AppController>()
                .allProductType
                .where((test) => test.id == a)
                .first
                .productCategoryId
                .toString();
          } else if (widget.model.runtimeType == Inventory &&
              fieldName == "productId") {
            _controllers["productCategoryId"]!.text = Get.find<AppController>()
                .allProducts
                .where((test) => test.id == a)
                .first
                .productCategoryId
                .toString();
            _controllers["productTypeId"]!.text = Get.find<AppController>()
                .allProducts
                .where((test) => test.id == a)
                .first
                .productTypeId
                .toString();
          } else if (widget.model.runtimeType == Inventory &&
              fieldName == "transactionType") {
            _controllers["status"]!.text = a;
          }
        } catch (e) {
          // TODO

          print(e);
        }
      });
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
      for (var i = 0; i < conds.length; i++) {
        if (conds[i] as int != 0) {
          newConds.add(values[i]);
        }
      }
      return CustomMultiDropdown(
        options,
        values,
        _controllers[fieldName]!,
        _formatFieldName(fieldName),
        initValues: widget.isNew ? [] : newConds,
        isEnable: true,
      );
    }

    if (fieldName.toLowerCase().endsWith("image")) {
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

    return CustomTextField(
      _formatFieldName(fieldName),
      _controllers[fieldName]!,
      customOnChanged: () {
        if (widget.model.runtimeType == Expenses &&
            fieldName.toLowerCase().endsWith("cost")) {
          (widget.model as Expenses).rawCost.value =
              double.tryParse(_controllers[fieldName]!.text) ?? 0;
        }
      },
      varl: fieldName.toLowerCase().endsWith("cost") ||
              fieldName.toLowerCase().endsWith("price")
          ? FPL.number
          : FPL.text,
    );
  }

  Widget _buildDateTimePicker(String fieldName) {
    return CustomTextField(
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
    if (widget.model.runtimeType == Invoice) {
      Rx<Invoice> inv = (widget.model as Invoice).obs;
      if (widget.isNew) {
        inv.value = Invoice(servicesUsed: [], productsUsed: []);
      }

      return SingleChildScrollView(
        child: Column(
          children: [
            if (!widget.isNew)
              CustomTextField(_formatFieldName("id"),
                  TextEditingController(text: _formData['id'].toString()),
                  readOnly: true),
            _buildField("orderId", jsonMap["orderId"]),
            InvoiceList(
              inv,
              isOwn: false,
            ),
            AppButton(
              onPressed: () async {
                inv.value.orderId =
                    int.tryParse(_controllers["orderId"]!.text) ?? 0;
                inv.value.totalCost = inv.value.rawTotalCost;
                if (inv.value.validate()) {
                  inv.value.orderCreatedAt = Get.find<AppController>().allOrders.where((test) => test.id == inv.value.orderId).firstOrNull?.createdAt ?? DateTime.now();
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
              CustomTextField(_formatFieldName("id"),
                  TextEditingController(text: _formData['id'].toString()),
                  readOnly: true),
            if (inv.value.expenses.isNotEmpty)
              CustomTextField(
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
            if (!widget.isNew)
              CustomTextField(_formatFieldName("id"),
                  TextEditingController(text: _formData['id'].toString()),
                  readOnly: true),
            ...jsonMap.entries
                .where((entry) =>
                    !['id', 'createdAt', 'updatedAt'].contains(entry.key))
                .map((entry) => _buildField(entry.key, entry.value)),
            if (!widget.isNew)
              CustomTextField(
                _formatFieldName("createdAt"),
                TextEditingController(
                    text: DateFormat("dd/MM/yyyy hh:mm:ss")
                        .format(DateTime.parse(_formData['createdAt']))),
                readOnly: true,
              ),
            if (!widget.isNew)
              CustomTextField(
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
    final qtyTec = TextEditingController(text: expense.rawCost.toString());

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
