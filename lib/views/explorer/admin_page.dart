import 'dart:io';

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
import 'package:inventory/views/checklist/shared2.dart';

import '../../models/inner_models/barrel.dart';
import '../../tools/functions.dart';
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
    return CurvedContainer(
      width: (Ui.width(context) * 0.75) - 24,
      height: double.maxFinite,
      color: AppColors.white.withOpacity(0.6),
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Obx(() {
        return AsyncPaginatedDataTable2(
          minWidth: (Ui.width(context) * 0.75) - 56,
          onRowsPerPageChanged: (value) {
            print('Row per page changed to $value');
          },

          columnSpacing: 0,
          onSelectAll: (v) {
            print(v);
          },
          // controller: controller.paginatorController.value,
          header: AppText.medium("Records",
              fontFamily: Assets.appFontFamily2, fontSize: 16),
          actions: [
            InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: () {
                  Get.dialog(AppDialog(
                      title: AppText.thin("Add New Record"),
                      content: Obx(() {
                        return DynamicFormGenerator(
                            model: controller.currentBaseModel.value,
                            onSave: (v) async{
                              await controller.saveNewRecord(v);
                            });
                      })));
                },
                child: AppIcon(
                  Icons.add_circle,
                  color: AppColors.green,
                  size: 40,
                )), //add new
          ],

          columns: controller.currentHeaders
              .map((e) => DataColumn2(
                  label: AppText.bold(e, fontSize: 14), size: ColumnSize.S))
              .toList(),
          source: controller.tmds.value,
        );
      }),
    );
  }
}

class CustomTableFilter extends StatelessWidget {
  CustomTableFilter({super.key});
  final controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return CurvedContainer(
      width: (Ui.width(context) * 0.25) - 24,
      height: double.maxFinite,
      color: AppColors.white.withOpacity(0.6),
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
                  return MultiSelectDropdown(e.options!, e.tec!, e.title);
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
              })
            ],
          );
        }),
      ),
    );
  }
}

class TableModelDataSource<T extends BaseModel> extends AsyncDataTableSource {
  List<FilterModel> filters;
  List<String> tm;
  TableModelDataSource(this.tm, this.filters);

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    final appRepo = Get.find<AppRepo>();
    int page = (startIndex ~/ count) + 1;

    final res = await appRepo.getAll<T>(page: page, limit: count);
    List<T> bms = res.data;
    List<List<dynamic>> tvals =
        res.data.map((e) => (e as BaseModel).toTableRows()).toList();

    return AsyncRowsResponse(
        res.total,
        List.generate(res.data.length, (index) {
          final tval = tvals[index];
          final bm = bms[index];
          return DataRow2(
              onSelectChanged: (b) {},
              cells: List.generate(tm.length, (jindex) {
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
                        onTap: () {
                          Get.find<AppController>().currentBaseModel = bm.obs;
                          Get.dialog(AppDialog(
                      title: AppText.thin("Edit Record"),
                      content: Obx(() {
                        return DynamicFormGenerator(
                            model: Get.find<AppController>().currentBaseModel.value,
                            onSave: (v) async{
                              await Get.find<AppController>().editExisitingRecord(v);
                            });
                      })));
                        },
                      ),
                      Ui.boxWidth(12),
                      AppIcon(
                        Icons.delete,
                        color: Colors.red,
                        onTap: (){
                          Get.dialog(AppDialog.normal(
                      "Delete Record","Are you sure you want to remove this record from the database ?",
                      titleA: "Yes",
                      titleB: "No",
                      onPressedA: () async{
                        await Get.find<AppController>().deleteExisitingRecord<T>(bm.id.toString());
                      },
                      onPressedB: (){
                        Get.back();
                      },
                      ));
                        },
                      ),
                    ],
                  ));
                }
                return DataCell(AppText.thin(tval[jindex].toString()));
              }));
        }));
  }
}

class CustomTableTitle extends StatelessWidget {
  const CustomTableTitle(this.hi, {this.actions = const [], super.key});
  final List<Widget> actions;
  final List<HeaderItem> hi;

  @override
  Widget build(BuildContext context) {
    return CurvedContainer(
        width: Ui.width(context) - 24,
        color: AppColors.white.withOpacity(0.6),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            HeaderChooser(hi),
            if (actions.isNotEmpty) ...actions,
            const Spacer(),
            SizedBox(
                width: Ui.width(context) / 4,
                child: CustomTextField2(
                  "Search",
                  TextEditingController(),
                  isDense: true,
                  hasBottomPadding: false,
                )),
            Ui.boxWidth(16),
            SizedBox(
                width: 100,
                child: AppButton(
                  onPressed: () {},
                  text: "Submit",
                ))
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
  HeaderChooser(this.hi, {super.key});
  final List<HeaderItem> hi;
  RxInt curHeader = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(hi.length, (i) {
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
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
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
      }),
    );
  }
}

class DynamicFormGenerator extends StatefulWidget {
  final BaseModel model;
  final Function(Map<String, dynamic>) onSave;

  const DynamicFormGenerator({
    super.key,
    required this.model,
    required this.onSave,
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
    _formData['createdAt'] = DateTime.now().toIso8601String();
    _formData['updatedAt'] = DateTime.now().toIso8601String();
    jsonMap.forEach((key, value) {
      if (!['id', 'createdAt', 'updatedAt'].contains(key)) {
        _controllers[key] =
            TextEditingController(text: value?.toString() ?? '');
      }
    });
  }

  Widget _buildField(String fieldName, dynamic value) {
    // Determine field type based on value
    if (fieldName.endsWith("Id") || fieldName.endsWith("Type")) {
      return CustomTextField.dropdown(["None"], _controllers[fieldName]!,
          "Select ${_formatFieldName(fieldName).replaceAll(" id", "")}");
    }

    if (fieldName == "image") {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: AppText.thin("Pick an Image")),
          Builder(builder: (_) {
            final cc = CurvedContainer(
                border: Border.all(color: AppColors.grey),
                onPressed: () async {
                  final img = await UtilFunctions.showCamera();
                  if (img != null) {
                    _controllers[fieldName]!.text = img;
                    setState(() {});
                  }
                },
                height: 120,
                padding: EdgeInsets.all(
                    _controllers[fieldName]!.text.isNotEmpty ? 0 : 24),
                margin: EdgeInsets.all(24),
                child: _controllers[fieldName]!.text.isNotEmpty
                    ? Image.file(
                        File(_controllers[fieldName]!.text),
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: AppIcon(
                        Icons.add_a_photo,
                        size: Ui.width(context) < 750 ? 24 : 48,
                      )));
            if (_controllers[fieldName]!.text.isNotEmpty) {
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
                          setState(() {});
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
        _formatFieldName(fieldName), _controllers[fieldName]!);
  }

  Widget _buildDateTimePicker(String fieldName) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() {
            _controllers[fieldName]?.text = picked.toIso8601String();
            _formData[fieldName] = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: _formatFieldName(fieldName),
          border: const OutlineInputBorder(),
        ),
        child: Text(
          _controllers[fieldName]?.text ?? 'Select Date',
        ),
      ),
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

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            ...jsonMap.entries
                .where((entry) =>
                    !['id', 'createdAt', 'updatedAt'].contains(entry.key))
                .map((entry) => _buildField(entry.key, entry.value)),
            Ui.boxHeight(24),
            AppButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();
                  _controllers.forEach((key, value) {
                    _formData[key] = value.text;
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
