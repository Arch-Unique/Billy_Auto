import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/controllers/app_controller.dart';
import 'package:inventory/models/table_repo.dart';
import 'package:inventory/tools/assets.dart';
import 'package:inventory/tools/colors.dart';
import 'package:inventory/views/checklist/shared2.dart';

import '../shared.dart';

class CustomTable extends StatefulWidget {
  const CustomTable(this.type, this.tm, {this.fm = const [], super.key});
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
      width: (Ui.width(context) * 0.75) - 24,
      height: double.maxFinite,
      color: AppColors.white.withOpacity(0.6),
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: AsyncPaginatedDataTable2(
        sortArrowAlwaysVisible: true,
        showCheckboxColumn: true,
        header: AppText.medium("Records",
            fontFamily: Assets.appFontFamily2, fontSize: 16),
        columns:
            widget.tm.map((e) => DataColumn2(label: AppText.bold(e))).toList(),
        source: TableModelDataSource(widget.type, widget.tm, widget.fm),
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
      width: (Ui.width(context) * 0.25) - 24,
      height: double.maxFinite,
      color: AppColors.white.withOpacity(0.6),
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        child: Column(
          children: [
            AppText.medium("Filters",
                fontFamily: Assets.appFontFamily2, fontSize: 16),
            Ui.boxHeight(24),
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
      ),
    );
  }
}

class TableModelDataSource extends AsyncDataTableSource {
  List<FilterModel> filters;
  List<String> tm;
  int t;
  TableModelDataSource(this.t, this.tm, this.filters);

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    return AsyncRowsResponse(
        20,
        List.generate(
            count,
            (index) => DataRow2(
                cells: List.generate(
                    tm.length+1, (jindex) {
                      if(jindex == tm.length){
                        return DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppIcon(Icons.remove_red_eye,color: Colors.brown,),
                            Ui.boxWidth(12),
                            AppIcon(Icons.edit,color: AppColors.green,),
                            Ui.boxWidth(12),
                            AppIcon(Icons.delete,color: Colors.red,),
                          ],

                        ));
                      }
                      return DataCell(AppText.thin("${startIndex + index} $jindex"));
                    }))));
  }
}

class CustomTableTitle extends StatelessWidget {
  const CustomTableTitle(this.title, {this.actions = const [], super.key});
  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return CurvedContainer(
        width: Ui.width(context) - 24,
        color: AppColors.white.withOpacity(0.6),
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            AppText.medium(title,
                fontFamily: Assets.appFontFamily2, fontSize: 24),
            if (actions.isNotEmpty) ...actions,
            Spacer(),
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

class CustomTablePage extends StatelessWidget {
  CustomTablePage(this.title, {this.actions = const [], super.key});
  final String title;
  final List<Widget> actions;
  final controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTableTitle(
          title,
          actions: actions,
        ),
        Expanded(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CustomTableFilter(controller.currentFilters),
            CustomTable(controller.currentType.value, controller.currentHeaders,
                fm: controller.currentFilters)
          ],
        ))
      ],
    );
  }
}
