import 'package:flutter/material.dart';
import 'package:generic_ledger/generic_table/widgets/sliver_header.dart';
import 'package:generic_ledger/utils/extensions.dart';

import '../../utils/string_constants.dart';
import '../filters/filter_model.dart';
import '../generic_model/column_meta.dart';
import '../table_body/models/table_row_data_model.dart';
import '../table_header/models/generic_table_model.dart';

class TableHeader extends StatelessWidget {
  TableHeader(
      {super.key,
      required this.columnMeta,
      required this.tableColumn,
      required this.scrollController,
      required this.row,
      required this.sortByWithOrder,
      required this.cellMaxWidth,
      required this.lastValue,
      required this.refresher,
      required this.colSelected,
      required this.filterModel,
      required this.sortedIndex,
      required this.dataUpdate});

  final List<ColumnMeta> columnMeta;
  final List<TableColumn> tableColumn;
  final ScrollController scrollController;
  final List<MessageRow> row;
  final ValueNotifier<String> sortByWithOrder;
  final List<double> cellMaxWidth;
  final List<String> lastValue;
  final ValueNotifier<int> refresher;
  final int? colSelected;
  final FilterListModel filterModel;
  final Function(BuildContext) dataUpdate;
  int sortedIndex;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      height: 55,
      left: 34,
      right: 0,
      child: CustomScrollView(
        controller: scrollController,
        shrinkWrap: true,
        primary: false,
        scrollDirection: Axis.horizontal,
        slivers: [
          for (int x = 0; x < columnMeta.length; x++)
            SliverPersistentHeader(
              pinned: columnMeta[x].isFreezed,
              delegate: Header(
                  extent: columnMeta[x].width,
                  child: DragTarget<List>(
                    onAcceptWithDetails: (val) {
                      final localColumnMeta = columnMeta[x - 1];
                      final localColumnData = tableColumn[x - 1];
                      columnMeta[x - 1] = val.data[0];
                      tableColumn[x - 1] = val.data[2];
                      columnMeta[val.data[1]] = localColumnMeta;
                      tableColumn[val.data[1]] = localColumnData;
                      for (var element in row) {
                        final localRowData = element.row[x - 1];
                        element.row[x - 1] = element.row[val.data[1]];
                        element.row[val.data[1]] = localRowData;
                      }
                      // setState(() {
                      //
                      // });
                    },
                    builder: (BuildContext context, List<Object?> candidateData, List<dynamic> rejectedData) =>
                        Draggable(
                      data: x == 0 ? null : [columnMeta[x - 1], x - 1, tableColumn[x - 1]],
                      feedback: Card(
                        child: Container(
                          padding: const EdgeInsets.only(left: 5),
                          width: columnMeta[x].width,
                          color: const Color(0xFFF2F2F2),
                          child: x == 0
                              ? const Center(
                                  child: Text(
                                  "Actions",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ))
                              : Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        columnMeta[x - 1].isFreezed = !columnMeta[x - 1].isFreezed;
                                        // setState(() {
                                        //
                                        // });
                                      },
                                      child: Icon(
                                        columnMeta[x - 1].isFreezed ? Icons.push_pin : Icons.push_pin_outlined,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                        child: Tooltip(
                                            message: tableColumn[x - 1].displayName.titleCase(),
                                            preferBelow: false,
                                            child: ValueListenableBuilder(
                                                valueListenable: sortByWithOrder,
                                                builder: (context, snapshot, wid) {
                                                  return Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(tableColumn[x - 1].displayName.titleCase(),
                                                            style: const TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                overflow: TextOverflow.ellipsis)),
                                                      ),
                                                      if (tableColumn[x - 1].key == sortByWithOrder.value.split(" ")[0])
                                                        sortByWithOrder.value.split(" ")[1] == "ASC"
                                                            ? const Icon(
                                                                Icons.arrow_upward,
                                                                size: 14,
                                                              )
                                                            : const Icon(
                                                                Icons.arrow_downward,
                                                                size: 14,
                                                              )
                                                    ],
                                                  );
                                                }))),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    MouseRegion(
                                        cursor: SystemMouseCursors.resizeLeftRight,
                                        child: GestureDetector(
                                            onHorizontalDragUpdate: (val) {
                                              // setState(() {
                                              final temp = 150 + val.localPosition.dx;
                                              columnMeta[x].width = temp < 30 ? 30 : temp;
                                              // });
                                            },
                                            child: Center(
                                                child: Container(
                                              color: Colors.grey.withOpacity(.3),
                                              width: 2,
                                              height: 40,
                                            )))),
                                  ],
                                ),
                        ),
                      ),
                      child: GestureDetector(
                        onDoubleTap: () {
                          columnMeta[x].width = cellMaxWidth[x] + 20 < 75 ? 75 : cellMaxWidth[x] + 20;
                          // setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.only(left: 5),
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                              color: colSelected != null && colSelected == x
                                  ? const Color(0xFFA8A7A7)
                                  : const Color(0xFFF2F2F2),
                              border: x == 0 ? const Border(right: BorderSide(color: Colors.grey, width: 1)) : null),
                          child: x == 0
                              ? Center(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          columnMeta[x].isFreezed = !columnMeta[x].isFreezed;
                                          // setState(() {
                                          //
                                          // });
                                        },
                                        child: Icon(
                                          columnMeta[x].isFreezed ? Icons.push_pin : Icons.push_pin_outlined,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      const Text(
                                        "Actions",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                )
                              : Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        columnMeta[x].isFreezed = !columnMeta[x].isFreezed;
                                        // setState(() {
                                        //
                                        // });
                                      },
                                      child: Icon(
                                        columnMeta[x].isFreezed ? Icons.push_pin : Icons.push_pin_outlined,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                        child: MouseRegion(
                                      onEnter: (eve) {
                                        columnMeta[x].isHover = true;
                                        // setState(() {
                                        //
                                        // });
                                        // }
                                      },
                                      onExit: (val) {
                                        columnMeta[x].isHover = false;
                                        // setState(() {
                                        //
                                        // });
                                      },
                                      child: Tooltip(
                                          message: tableColumn[x - 1].displayName.titleCase(),
                                          preferBelow: false,
                                          child: ValueListenableBuilder(
                                              valueListenable: sortByWithOrder,
                                              builder: (context, snapshot, wid) {
                                                if (columnMeta[x].isHover ||
                                                    tableColumn[x - 1].key == sortByWithOrder.value.split(" ")[0]) {
                                                  sortedIndex = x - 1;
                                                  // print("sortedIndex $sortedIndex");
                                                }
                                                // print("columnMeta[0].sortEnabled ${columnMeta[0].sortEnabled}");
                                                return Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(tableColumn[x - 1].displayName.titleCase(),
                                                          style: const TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              overflow: TextOverflow.ellipsis)),
                                                    ),
                                                    if ((columnMeta[x].isHover ||
                                                            tableColumn[x - 1].key ==
                                                                sortByWithOrder.value.split(" ")[0]) &&
                                                        columnMeta[x].sortEnabled)
                                                      tableColumn[x - 1].key == sortByWithOrder.value.split(" ")[0]
                                                          ? SizedBox(
                                                              width: 25,
                                                              child: IconButton(
                                                                  onPressed: () {
                                                                    final localFilters =
                                                                        List<Filter>.from(filterModel.filterData);
                                                                    for (var val in localFilters) {
                                                                      filterModel.filterData.removeWhere((val) =>
                                                                          val.key ==
                                                                          sortByWithOrder.value.split(" ")[0]);
                                                                    }
                                                                    lastValue.clear();
                                                                    if (sortByWithOrder.value.split(" ")[1] ==
                                                                        StringConstants.asc) {
                                                                      sortByWithOrder.value =
                                                                          "${tableColumn[x - 1].key} ${StringConstants.desc}";
                                                                    } else {
                                                                      sortByWithOrder.value =
                                                                          "${tableColumn[x - 1].key} ${StringConstants.asc}";
                                                                    }
                                                                    dataUpdate;
                                                                  },
                                                                  icon: sortByWithOrder.value.split(" ")[1] == "ASC"
                                                                      ? const Icon(
                                                                          Icons.arrow_upward,
                                                                          size: 16,
                                                                        )
                                                                      : const Icon(
                                                                          Icons.arrow_downward,
                                                                          size: 16,
                                                                        )),
                                                            )
                                                          : SizedBox(
                                                              width: 25,
                                                              child: IconButton(
                                                                  onPressed: () {
                                                                    final localFilters =
                                                                        List<Filter>.from(filterModel.filterData);
                                                                    for (var val in localFilters) {
                                                                      filterModel.filterData.removeWhere((val) =>
                                                                          val.key ==
                                                                          sortByWithOrder.value.split(" ")[0]);
                                                                    }
                                                                    lastValue.clear();
                                                                    sortByWithOrder.value =
                                                                        "${tableColumn[x - 1].key} ${StringConstants.desc}";
                                                                    refresher.value == 0
                                                                        ? refresher.value = 1
                                                                        : refresher.value = 0;
                                                                    dataUpdate;
                                                                    // setState(() {});
                                                                  },
                                                                  icon: const Icon(
                                                                    Icons.swap_vert,
                                                                    size: 16,
                                                                  )),
                                                            )
                                                  ],
                                                );
                                              })),
                                    )),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    MouseRegion(
                                        cursor: SystemMouseCursors.resizeLeftRight,
                                        child: GestureDetector(
                                            onHorizontalDragUpdate: (val) {
                                              // setState(() {
                                              final temp = columnMeta[x].fixedWidth + val.localPosition.dx;
                                              columnMeta[x].width = temp < 75 ? 75 : temp;
                                              // });
                                            },
                                            child: Center(
                                                child: Container(
                                              color: Colors.grey.withOpacity(.3),
                                              width: 3,
                                              height: 40,
                                            )))),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  )),
            ),
        ],
      ),
    );
  }
}
