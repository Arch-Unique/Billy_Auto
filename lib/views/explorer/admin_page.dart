import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/controllers/app_controller.dart';
import 'package:inventory/models/table_repo.dart';
import 'package:inventory/tools/colors.dart';

import '../shared.dart';

class CustomTable extends StatefulWidget {
  const CustomTable(this.type,this.tm, {this.fm=const [],super.key});
  final List<String> tm;
  final List<FilterModel> fm;
  final int type;

  @override
  State<CustomTable> createState() => _CustomTableState();
}

class _CustomTableState extends State<CustomTable> {
  @override
  Widget build(BuildContext context) {
    return CurvedContainer(
      width: (Ui.width(context) * 0.75)-48,
      height: double.maxFinite,
      color: AppColors.white.withOpacity(0.5),
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 16),
      child: AsyncPaginatedDataTable2(
        columns: widget.tm
            .map((e) => DataColumn2(label: AppText.bold(e)))
            .toList(),
        source: TableModelDataSource(widget.type,widget.tm,widget.fm),
      ),
    );
  }
}

class CustomTableFilter extends StatelessWidget {
  const CustomTableFilter(this.fm, {super.key});
  final List<FilterModel> fm;

  @override
  Widget build(BuildContext context) {
    return CurvedContainer(
      width: (Ui.width(context) * 0.25)-48,
      height: double.maxFinite,
      color: AppColors.white.withOpacity(0.5),
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          if (fm.isEmpty) SizedBox(),
          ...fm.map((e) {
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
      ),
    );
  }
}

class TableModelDataSource extends AsyncDataTableSource {
  List<FilterModel> filters;
  List<String> tm;
  int t;
  TableModelDataSource(this.t,this.tm, this.filters);

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    return AsyncRowsResponse(
        20,
        List.generate(
            20,
            (index) => DataRow2(
                cells: List.generate(
                    5, (jindex) => DataCell(AppText.thin("$index $jindex"))))));
  }
}


class CustomTablePage extends StatefulWidget {
  const CustomTablePage({super.key});

  @override
  State<CustomTablePage> createState() => _CustomTablePageState();
}

class _CustomTablePageState extends State<CustomTablePage> {
  final controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CustomTableFilter(controller.currentFilters),
            CustomTable(controller.currentType.value,controller.currentHeaders,fm: controller.currentFilters)
          ],
        ))
      ],
    );
  }
}