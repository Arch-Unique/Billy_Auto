import 'dart:nativewrappers/_internal/vm/lib/mirrors_patch.dart';

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
                AppIcon(Icons.add_circle,color: AppColors.green,size: 40,), //add new
              ],
              
          columns: controller.currentHeaders
              .map((e) =>
                  DataColumn2(label: AppText.bold(e,fontSize: 14), size: ColumnSize.S))
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

class TableModelDataSource<T> extends AsyncDataTableSource {
  List<FilterModel> filters;
  List<String> tm;
  TableModelDataSource(this.tm, this.filters);

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    final appRepo = Get.find<AppRepo>();
    int page = (startIndex ~/ count) + 1;

    final res = await appRepo.getAll<T>(page: page, limit: count);
    List<List<dynamic>> tvals =
        res.data.map((e) => (e as BaseModel).toTableRows()).toList();

    return AsyncRowsResponse(
        res.total,
        List.generate(res.data.length, (index) {
          final tval = tvals[index];
          return DataRow2(
              onSelectChanged: (b) {},
              cells: List.generate(tm.length, (jindex) {
                if (jindex == tm.length - 1) {
                  return DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppIcon(
                        Icons.remove_red_eye,
                        color: Colors.brown,
                      ),
                      Ui.boxWidth(12),
                      const AppIcon(
                        Icons.edit,
                        color: AppColors.green,
                      ),
                      Ui.boxWidth(12),
                      const AppIcon(
                        Icons.delete,
                        color: Colors.red,
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
    if(oldWidget.hi != widget.hi){

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


class DynamicFormGenerator<T extends BaseModel> extends StatefulWidget {
  final T model;
  final Function(Map<String, dynamic>) onSave;

  const DynamicFormGenerator({
    Key? key,
    required this.model,
    required this.onSave,
  }) : super(key: key);

  @override
  State<DynamicFormGenerator> createState() => _DynamicFormGeneratorState<T>();
}

class _DynamicFormGeneratorState<T extends BaseModel> extends State<DynamicFormGenerator<T>> {
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
    final mirror = reflect(widget.model);
    Map<String, dynamic> jsonMap = widget.model.toJson();
    
    // Create controllers for each field
    jsonMap.forEach((key, value) {
      if (!['id', 'createdAt', 'updatedAt'].contains(key)) {
        _controllers[key] = TextEditingController(
          text: value?.toString() ?? ''
        );
      }
    });
  }

  Widget _buildField(String fieldName, dynamic value) {
    // Determine field type based on value
    if (value is String) {
      return TextFormField(
        controller: _controllers[fieldName],
        decoration: InputDecoration(
          labelText: _formatFieldName(fieldName),
          border: const OutlineInputBorder(),
        ),
        onSaved: (value) => _formData[fieldName] = value,
      );
    } else if (value is int) {
      return TextFormField(
        controller: _controllers[fieldName],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: _formatFieldName(fieldName),
          border: const OutlineInputBorder(),
        ),
        onSaved: (value) => _formData[fieldName] = int.tryParse(value ?? ''),
      );
    } else if (value is double) {
      return TextFormField(
        controller: _controllers[fieldName],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: _formatFieldName(fieldName),
          border: const OutlineInputBorder(),
        ),
        onSaved: (value) => _formData[fieldName] = double.tryParse(value ?? ''),
      );
    } else if (value is DateTime) {
      return _buildDateTimePicker(fieldName);
    }
    // Add more field types as needed
    
    return Container(); // Default empty container for unsupported types
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
        .capitalize();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> jsonMap = widget.model.toJson();
    
    return Form(
      key: _formKey,
      child: Column(
        children: [
          ...jsonMap.entries
              .where((entry) => !['id', 'createdAt', 'updatedAt'].contains(entry.key))
              .map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildField(entry.key, entry.value),
                  ))
              .toList(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState?.save();
                widget.onSave(_formData);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}