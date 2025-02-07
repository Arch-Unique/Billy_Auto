import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/controllers/app_controller.dart';
import 'package:inventory/models/table_repo.dart';
import 'package:inventory/repo/app_repo.dart';
import 'package:inventory/tools/assets.dart';
import 'package:inventory/tools/colors.dart';
import 'package:inventory/views/checklist/shared2.dart';

import '../../models/inner_models/barrel.dart';
import '../shared.dart';

class CustomTable<T> extends StatefulWidget {
  const CustomTable(this.tm, {this.fm = const [], super.key});
  final List<String> tm;
  final List<FilterModel> fm;

  @override
  State<CustomTable<T>> createState() => _CustomTableState<T>();
}

class _CustomTableState<T> extends State<CustomTable<T>> {
  @override
  Widget build(BuildContext context) {
    return CurvedContainer(
      width: (Ui.width(context) * 0.75) - 24,
      height: double.maxFinite,
      color: AppColors.white.withOpacity(0.6),
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: AsyncPaginatedDataTable2(
        minWidth: (Ui.width(context)),
        onRowsPerPageChanged: (value) {
          print('Row per page changed to $value');
        },
        columnSpacing: 0,
        onSelectAll: (v) {
          print(v);
        },
        header: AppText.medium("Records",
            fontFamily: Assets.appFontFamily2, fontSize: 16),
        columns: widget.tm
            .map((e) => DataColumn2(label: AppText.bold(e), size: ColumnSize.S))
            .toList(),
        source: TableModelDataSource<T>(widget.tm, widget.fm),
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

class TableModelDataSource<T> extends AsyncDataTableSource {
  List<FilterModel> filters;
  List<String> tm;
  TableModelDataSource(this.tm, this.filters);

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    final appRepo = Get.find<AppRepo>();
    
    final res = await appRepo.getAll<T>(page: startIndex+1,limit: count);
    List<List<dynamic>> tvals;
    switch (T) {
      case User:
        tvals = res.data.map((e) => (e as User).toTableRows()).toList();
        break;
      default:
    }

    return AsyncRowsResponse(
        20,
        List.generate(count, (index) {
          return DataRow2(
              onSelectChanged: (b) {},
              cells: List.generate(tm.length, (jindex) {
                if (jindex == tm.length - 1) {
                  return DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(
                        Icons.remove_red_eye,
                        color: Colors.brown,
                      ),
                      Ui.boxWidth(12),
                      AppIcon(
                        Icons.edit,
                        color: AppColors.green,
                      ),
                      Ui.boxWidth(12),
                      AppIcon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ],
                  ));
                }
                return DataCell(AppText.thin("${startIndex + index} $jindex"));
              }));
        }));
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

class CustomTablePage<T> extends StatefulWidget {
  const CustomTablePage(this.actions, {super.key});
  final List<Widget> actions;

  @override
  State<CustomTablePage<T>> createState() => _CustomTablePageState<T>();
}

class _CustomTablePageState<T> extends State<CustomTablePage<T>> {
  final controller = Get.find<AppController>();

  @override
  void initState() {
    controller.currentHeaders.value = AllTables.tablesData[T]!.headers;
    if(!controller.currentHeaders.contains("actions")){

    controller.currentHeaders.add("actions");
    }
    controller.currentFilters.value = AllTables.tablesData[T]!.fm;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTableTitle(
          "",
          actions: widget.actions,
        ),
        Expanded(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CustomTableFilter(controller.currentFilters),
            CustomTable<T>(controller.currentHeaders,
                fm: controller.currentFilters)
          ],
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
            child: Obx(
               () {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
              }
            ),
          ),
        );
      }),
    );
  }
}
