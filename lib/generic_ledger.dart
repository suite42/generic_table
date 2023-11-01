library generic_ledger;

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:generic_ledger/generic_table/generic_model/column_meta.dart';
import 'package:generic_ledger/generic_table/table_body/models/table_row_data_model.dart';
import 'package:generic_ledger/utils/extensions.dart';
import 'package:generic_ledger/utils/string_constants.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'generic_table/table_body/bloc/bloc/payment_bloc.dart';
import 'generic_table/table_body/bloc/bloc/table_body_bloc.dart';
import 'generic_table/table_body/views/filter_cell.dart';
import 'generic_table/table_body/views/row_cell.dart';
import 'generic_table/table_header/bloc/bloc/table_bloc.dart';
import 'generic_table/table_header/models/generic_table_model.dart';

class GenericTable extends StatelessWidget {
  const GenericTable({super.key, this.tableName});
  final String? tableName;
  // This widget is the root of this application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => TableBloc()),
        BlocProvider(create: (context) => TableBodyBloc()),
        BlocProvider(create: (context) => PaymentBloc()),
      ],
      child: TableView(tableName: tableName,),
    );
  }
}

class TableView extends StatefulWidget {
  const TableView({super.key, this.tableName});

  final String? tableName;

  @override
  State<TableView> createState() => _TableViewState();
}

class _TableViewState extends State<TableView> {
  int? selectedCell;

  int? colSelected;

  late List<ColumnMeta> columnMeta;

  List<ScrollController?> scrollList = List.generate(32, (index) => null);

  final LinkedScrollControllerGroup _controllerGroup = LinkedScrollControllerGroup();

  List<int> filterCount = [];
  List<MessageRow> row = [];
  late Update? tableUpdate;
  final ValueNotifier<List<double>> rowHeight = ValueNotifier([]);

  @override
  void initState() {
    for (int x = 0; x < scrollList.length; x++) {
      scrollList[x] = _controllerGroup.addAndGet();
    }
    super.initState();
    context.read<TableBloc>().add(FetchTableList());
  }

  late List<TextEditingController> controllersList;

  late List<TextEditingController> filterControllers = [];

  List<int> usedControllers = [];

  List<Map<String, String>> sortList = [];

  ValueNotifier<List<List<String>>> filters = ValueNotifier([]);

  List<TableColumn> validFilters = [];

  ValueNotifier<String> sortByWithOrder = ValueNotifier("");

  int rowsPerPage = 10;
  int activePage = 1;

  int fixedColumns = 1;
  Map<String, String> updateBody = {};

  ValueNotifier<int> refresher = ValueNotifier(0);

  final formKey = GlobalKey<FormState>();

  ValueNotifier<TableHeader?> tableHeader = ValueNotifier(null);

  @override
  Widget build(BuildContext mainContext) {
    return BlocListener<TableBloc, TableStates>(
      listener: (context, state) {
        if(state is TableUpdateState) {
          updateBody.clear();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message),backgroundColor: Colors.green,));
        } else if (state is TableUpdateErrorState){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message),backgroundColor: Colors.red,));
        }
      },
      child: GestureDetector(
        onTap: () {
          if(selectedCell != null && tableUpdate != null && updateBody.isNotEmpty) {
            context.read<TableBloc>().add(UpdateTable(tableUpdate!.actionApi, {"data" : updateBody}));
          }
          selectedCell = null;
          setState(() {});
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF2F2F2),
          body: SafeArea(
            minimum: const EdgeInsets.all(10),
            child: ValueListenableBuilder<TableHeader?>(
              valueListenable: tableHeader,
              builder: (context, snapshot, wid) {
                return Column(
                  children: [
                    header(snapshot, mainContext),
                    const Divider(
                      thickness: 2,
                    ),
                    appliedFiltersBar(mainContext),
                    if (tableHeader.value != null) table(mainContext)
                  ],
                );
              },
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Visibility(
            visible: colSelected != null,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(onPressed: () async {
                      await showDialog(context: context, builder: (context) =>AlertDialog(
                        content: ColorPicker(
                            color: Colors.red,
                            onColorChanged: (val){
                              for (var element in row) {
                                element.row[colSelected!].cellFillColour = "#${val.hex}";
                              }
                              Navigator.pop(context);
                            }
                        ),
                      ));
                      colSelected = null;
                      setState(() {

                      });
                    },icon: const Icon(Icons.invert_colors_on_sharp), label: Text("Color"),style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),),
                    SizedBox(width: 7,),
                    OutlinedButton.icon(onPressed: (){},icon: const Icon(Icons.format_align_center), label: Text("Alignment"),style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  }

  Expanded table(BuildContext mainContext) {
    return Expanded(
      child: Container(
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Stack(
            children: [
              tableColumns(),
              tableFilters(mainContext),
              tableBody(mainContext),
            ],
          )),
    );
  }

  BlocConsumer<TableBodyBloc, TableRowStates> tableBody(BuildContext mainContext) {

    return BlocConsumer<TableBodyBloc, TableRowStates>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is TableRowLoadedState) {
            row = state.tableRowDataModel.message.rows;
            tableUpdate = state.tableRowDataModel.message.update;
            return row.isEmpty
                ? const Center(
              child: Text(
                StringConstants.noData,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            )
                : Container(
              margin: const EdgeInsets.only(top: 90),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: List.generate(
                      (row.length / rowsPerPage).ceil() == activePage ? row.length - (rowsPerPage * (activePage - 1))
                          : rowsPerPage,
                          (index) => InkWell(
                        onDoubleTap: () {
                          selectedCell = index;
                          setState(() {});
                        },
                        child: ValueListenableBuilder(
                          valueListenable: rowHeight,
                          builder: (context, snapshot,wid) {
                            return SizedBox(
                              height: snapshot[index],
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: CustomScrollView(
                                      controller: scrollList[index + 2],
                                      shrinkWrap: true,
                                      primary: false,
                                      scrollDirection: Axis.horizontal,
                                      slivers: [
                                        for(int x = 0; x < (tableHeader.value!.actions != null ? row[index].row.length + 1 : row[index].row.length); x++)
                                          SliverPersistentHeader(
                                            pinned: columnMeta[x].isFreezed,
                                            delegate: Header(
                                              extent: columnMeta[x].width,
                                              child: tableHeader.value!.actions != null && x == row[index].row.length ? Container(
                                                padding: const EdgeInsets.only(left: 10),
                                                // width: columnMeta[index].width,
                                                decoration: BoxDecoration(
                                                    color:  const Color(0xFFF2F2F2),
                                                    border: Border(bottom: BorderSide(color: Colors.grey.shade300))
                                                ),
                                                child: row[index].action!.isNotEmpty ? Center(
                                                  child: ListView.builder(
                                                      shrinkWrap: true,
                                                      scrollDirection: Axis.horizontal,
                                                      itemCount: row[index].action!.length,
                                                      itemBuilder : (context,localIndex) => IconButton(
                                                        onPressed: (){
                                                          String? desc = "";
                                                          Map<String, dynamic>  valData = {};
                                                          for(var x in row[index].row) {
                                                            for(int y = 0; y < tableHeader.value!.actions![row[index].action![localIndex].action]!["action_api_fields"].length; y++) {
                                                              if(x.key == tableHeader.value!.actions![row[index].action![localIndex].action]!["action_api_fields"][y]["field_name_in_table"]){
                                                                valData[tableHeader.value!.actions![row[index].action![localIndex].action]!["action_api_fields"][y]["field_name_in_action_api"]] = x.value;
                                                              }
                                                            }
                                                          }
                                                          showDialog(context: context,barrierDismissible: false, builder: (context) {
                                                            final formKey = GlobalKey<FormState>();
                                                            return BlocProvider.value(
                                                              value: BlocProvider.of<PaymentBloc>(mainContext),
                                                              child: BlocConsumer<PaymentBloc,PaymentsState>(
                                                                  listener: (context, state) {
                                                                    if(state is PaymentsLoadedState) {
                                                                      mainContext.read<TableBodyBloc>().add(FetchTableRowDataEvent(
                                                                          baseUrl: tableHeader.value!.actionApi,
                                                                          filters: filters.value,
                                                                          sortBy: sortByWithOrder.value,
                                                                          length: rowsPerPage));
                                                                      Navigator.pop(context);
                                                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request Success"),backgroundColor: Colors.green,));
                                                                    } else if (state is PaymentsErrorState) {
                                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message),backgroundColor: Colors.red,));
                                                                    }
                                                                  },
                                                                  builder: (context, state) {
                                                                    final size = MediaQuery.of(context).size;
                                                                    return AlertDialog(
                                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                      title: Visibility(visible: state is! PaymentsLoadingState,child: Text(row[index].action![localIndex].action,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)),
                                                                      content: state is PaymentsLoadingState ? SizedBox(height: size.height / 3,child: const Center(child: CircularProgressIndicator())) : Form(
                                                                          key: formKey,
                                                                          child: SizedBox(
                                                                            width: size.width / 3,
                                                                            child: TextFormField(
                                                                              initialValue: desc,
                                                                              decoration: const InputDecoration(
                                                                                hintText: "Enter description",
                                                                                border: OutlineInputBorder(),
                                                                                focusedBorder: OutlineInputBorder(),
                                                                              ),
                                                                              maxLines: 4,
                                                                              onSaved: (val){
                                                                                valData["description"] = val != null && val.isNotEmpty ? val : valData["description"];
                                                                                context.read<PaymentBloc>().add(PaymentsActionEvent(
                                                                                    tableHeader.value!.actions![row[index].action![localIndex].action]!["action_api"],
                                                                                    {
                                                                                      "data" : valData
                                                                                    }
                                                                                ));
                                                                              },
                                                                              validator: row[index].action![localIndex].action == "Approve" ? null : (val) {
                                                                                if(val == null || val.isEmpty) {
                                                                                  return "Please enter some description";
                                                                                } else if (val.length < 5) {
                                                                                  "Please write more than one word";
                                                                                } else {
                                                                                  return null;
                                                                                }
                                                                              },
                                                                            ),
                                                                          )),
                                                                      actions: state is PaymentsLoadingState ? [] : [
                                                                        ElevatedButton(onPressed: (){
                                                                          if(formKey.currentState!.validate()) {
                                                                            formKey.currentState!.save();
                                                                          }
                                                                        }, child: const Text("Submit",style: TextStyle(fontWeight: FontWeight.bold))),
                                                                        OutlinedButton(onPressed: (){
                                                                          Navigator.pop(context);
                                                                        }, child: const Text("Cancel")),
                                                                      ],
                                                                    );
                                                                  }
                                                              ),
                                                            );
                                                          });
                                                        },
                                                        icon: Image.network(tableHeader.value!.actions![row[index].action![localIndex].action]!["image_url"],width: 20,height: 20,),
                                                        tooltip: row[index].action![localIndex].action,
                                                      )
                                                  ),
                                                ) : const Center(child: Text("No Action",style: TextStyle(fontWeight: FontWeight.bold),)),
                                              ) : RowCell(
                                                tableHeader: tableHeader.value!,
                                                message: state.tableRowDataModel.message,
                                                activePage: activePage,
                                                body: updateBody,
                                                rowsPerPage: rowsPerPage,
                                                index: index,
                                                subIndex:x,
                                                selectedCell: selectedCell,
                                                cellSize: columnMeta[x].width,
                                                isSelected: colSelected != null && colSelected == x,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  MouseRegion(
                                      cursor: SystemMouseCursors.resizeUpDown,
                                      child: GestureDetector(
                                          onVerticalDragUpdate: (val) {
                                            setState(() {
                                              final temp = 40 + val.localPosition.dy;
                                              rowHeight.value[index] = temp < 30 ? 30 : temp;
                                            });
                                          },
                                          child: Center(child: Container(color: Colors.grey.withOpacity(.3), height: 2)))),
                                ],
                              ),
                            );
                          }
                        ),
                      )),
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  Positioned tableFilters(BuildContext mainContext) {
    return Positioned(
        top: 50,
        height: 40,
        left: 0,
        right: 0,
        child: CustomScrollView(
          controller: scrollList[1],
          shrinkWrap: true,
          primary: false,
          scrollDirection: Axis.horizontal,
          slivers: [
            for(int x = 0; x < tableHeader.value!.data.columns.length; x++)
            SliverPersistentHeader(
              delegate: Header(
                  extent: columnMeta[x].width,
                  child: FilterCell(
                    columnSize: columnMeta[x].width,
                    controller: controllersList[x],
                    tableHeader: tableHeader,
                    onChanged: (val) {
                      tableHeader.value!.data.columns[x].filterData.defaultFilterType == "Like" ||
                          tableHeader.value!.data.columns[x].filterData.defaultFilterType ==
                              "Not Like"
                          ? val = "%$val%"
                          : val;
                      if (!usedControllers.contains(x)) {
                        usedControllers.add(x);
                      }
                      final localList = [
                        tableHeader.value!.data.columns[x].key,
                        tableHeader.value!.data.columns[x].filterData.defaultFilterType,
                        val
                      ];
                      for (var element in filters.value) {
                        if (element.first == localList.first) {
                          filters.value.remove(element);
                        }
                      }
                      filters.value.add(localList);
                      if (val.contains("%") && val.length == 2 || val.isEmpty) {
                        filters.value.remove(localList);
                      }
                      refresher.value == 0 ? refresher.value = 1 : refresher.value = 0;
                      mainContext.read<TableBodyBloc>().add(FetchTableRowDataEvent(
                          baseUrl: tableHeader.value!.actionApi,
                          filters: filters.value,
                          sortBy: sortByWithOrder.value,
                          length: rowsPerPage));
                    },
                    index: x,
                  )),
              pinned: columnMeta[x].isFreezed,
            ),
          ],
        ));
  }

  Positioned tableColumns() {
    int length = tableHeader.value!.data.columns.length;
    if(tableHeader.value!.actions != null) {
      length++;
    }
    return Positioned(
      height: 55,
      left: 0,
      right: 0,
      child: CustomScrollView(
        controller: scrollList[0],
        shrinkWrap: true,
        primary: false,
        scrollDirection: Axis.horizontal,
        slivers: [
          for(int x = 0; x < length; x++)
            SliverPersistentHeader(
              pinned: columnMeta[x].isFreezed,
              delegate: Header(
                  extent: columnMeta[x].width,
                  child: DragTarget<List>(
                    onAcceptWithDetails: (val){
                      final localColumnMeta = columnMeta[x];
                      final localColumnData = tableHeader.value!.data.columns[x];
                      columnMeta[x] = val.data[0];
                      tableHeader.value!.data.columns[x] = val.data[2];
                      columnMeta[val.data[1]] = localColumnMeta;
                      tableHeader.value!.data.columns[val.data[1]] = localColumnData;
                      for (var element in row) {
                      final localRowData = element.row[x];
                        element.row[x] = element.row[val.data[1]];
                        element.row[val.data[1]] = localRowData;
                      }
                      setState(() {

                      });
                    },
                    builder: (BuildContext context, List<Object?> candidateData, List<dynamic> rejectedData) => Draggable(
                      data: tableHeader.value!.actions != null && x == (length - 1) ? null : [columnMeta[x],x,tableHeader.value!.data.columns[x]],
                      feedback: Card(
                        child: Container(
                          padding: const EdgeInsets.only(left: 5),
                          width: columnMeta[x].width,
                          color: const Color(0xFFF2F2F2),
                          child: tableHeader.value!.actions != null && x == (length - 1) ? const Center(
                            child: Text("Actions",style: TextStyle(fontWeight: FontWeight.bold),),
                          ) : Row(
                            children: [
                              InkWell(
                                onTap: (){
                                  columnMeta[x].isFreezed = !columnMeta[x].isFreezed;
                                  setState(() {

                                  });
                                },
                                child: Icon(columnMeta[x].isFreezed ? Icons.push_pin : Icons.push_pin_outlined,size: 16,),
                              ),
                              const SizedBox(width: 5,),
                              Expanded(
                                  child: Tooltip(
                                      message: "",
                                      preferBelow: false,
                                      child: ValueListenableBuilder(
                                          valueListenable: sortByWithOrder,
                                          builder: (context, snapshot, wid) {
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(tableHeader.value!.data.columns[x].displayName.titleCase(),
                                                      style: const TextStyle(fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis)),
                                                ),
                                                if (tableHeader.value!.data.columns[x].key == sortByWithOrder.value.split(" ")[0])
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
                                        setState(() {
                                          final temp = 150 + val.localPosition.dx;
                                          columnMeta[x].width = temp < 30 ? 30 : temp;
                                        });
                                      },
                                      child: Center(child: Container(color: Colors.grey.withOpacity(.3), width: 2,height: 40,)))),
                            ],
                          ),
                        ),
                      ),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.resizeDown,
                        child: GestureDetector(
                          onTap: (){
                            colSelected == x ? colSelected = null : colSelected = x;
                            setState(() {

                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.only(left: 5),
                            margin: const EdgeInsets.only(bottom: 15),
                            // width: columnMeta[x].width,
                            color: colSelected != null && colSelected == x ? const Color(0xFFA8A7A7) : const Color(0xFFF2F2F2),
                            child: tableHeader.value!.actions != null && x == (length - 1) ? const Center(
                              child: Text("Actions",style: TextStyle(fontWeight: FontWeight.bold),),
                            ) : Row(
                              children: [
                                InkWell(
                                  onTap: (){
                                    columnMeta[x].isFreezed = !columnMeta[x].isFreezed;
                                    setState(() {

                                    });
                                  },
                                  child: Icon(columnMeta[x].isFreezed ? Icons.push_pin : Icons.push_pin_outlined,size: 16,),
                                ),
                                const SizedBox(width: 5,),
                                Expanded(
                                    child: Tooltip(
                                        message: "",
                                        preferBelow: false,
                                        child: ValueListenableBuilder(
                                            valueListenable: sortByWithOrder,
                                            builder: (context, snapshot, wid) {
                                              return Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(tableHeader.value!.data.columns[x].displayName.titleCase(),
                                                        style: const TextStyle(fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis)),
                                                  ),
                                                  if (tableHeader.value!.data.columns[x].key == sortByWithOrder.value.split(" ")[0])
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
                                          setState(() {
                                            final temp = 150 + val.localPosition.dx;
                                            columnMeta[x].width = temp < 30 ? 30 : temp;
                                          });
                                        },
                                        child: Center(child: Container(color: Colors.grey.withOpacity(.3), width: 2,height: 40,)))),
                              ],
                            ),
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

  ValueListenableBuilder<int> appliedFiltersBar(BuildContext mainContext) {
    return ValueListenableBuilder(
        valueListenable: refresher,
        builder: (context, snapshot, wid) {
          final list = [
            ...filters.value,
            if (sortByWithOrder.value.isNotEmpty) [sortByWithOrder.value.split(" ")[0]]
          ];
          return Visibility(
            visible: filters.value.isNotEmpty || sortByWithOrder.value.isNotEmpty,
            child: SizedBox(
              height: 45,
              width: double.infinity,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.fromLTRB(20, 5, 0, 10),
                    decoration: BoxDecoration(
                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(.2), spreadRadius: 1)],
                        borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(list[index].length == 1
                            ? "Sort By : ${list[index][0]}"
                            : "${list[index][0]} - ${list[index][2].removePercentage()}"),
                        const SizedBox(width: 3),
                        InkWell(
                            onTap: () {
                              list[index].length == 1 ? sortByWithOrder.value = "" : filters.value.remove(list[index]);
                              if (usedControllers.isNotEmpty) {
                                controllersList[usedControllers[index]].clear();
                                usedControllers.removeAt(index);
                              }
                              refresher.value == 0 ? refresher.value = 1 : refresher.value = 0;
                              mainContext.read<TableBodyBloc>().add(FetchTableRowDataEvent(
                                  baseUrl: tableHeader.value!.actionApi,
                                  filters: filters.value,
                                  sortBy: sortByWithOrder.value,
                                  length: rowsPerPage));
                            },
                            child: const Icon(
                              Icons.clear,
                              size: 17,
                            ))
                      ],
                    ),
                  )),
            ),
          );
        });
  }

  Row header(TableHeader? snapshot, BuildContext mainContext) {
    return Row(
      children: [
        Container(
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.all(4),
          child: const Icon(Icons.table_chart_outlined),
        ),
        Text(
          tableHeader.value == null ? StringConstants.selectTable : snapshot!.tableName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const VerticalDivider(),
        PopupMenuButton(
            enabled: tableHeader.value != null,
            position: PopupMenuPosition.under,
            surfaceTintColor: Colors.white,
            constraints: const BoxConstraints(
              minWidth: 500,
              maxWidth: 500,
            ),
            tooltip: StringConstants.allFilters,
            color: Colors.white,
            offset: const Offset(0, 10),
            child: Container(
                decoration: BoxDecoration(
                    color: tableHeader.value != null ? Colors.white : Colors.grey.withOpacity(.2),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(.2), spreadRadius: 1, blurRadius: 1)]),
                width: 130,
                height: 35,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Icon(
                          Icons.tune_outlined,
                          size: 18,
                        )),
                    Text(StringConstants.allFilters),
                    Expanded(child: Icon(Icons.keyboard_arrow_down_outlined))
                  ],
                )),
            itemBuilder: (context) => [
              PopupMenuItem(
                  enabled: false,
                  child: StatefulBuilder(
                    builder: (context, setState) => Column(
                      children: [
                        Form(
                          key: formKey,
                          child: Column(
                            children: List.generate(filterCount.length, (index) {
                              List<String> localList = ["", "", ""];
                              return Container(
                                margin: EdgeInsets.only(bottom: 20, top: index == 0 ? 15 : 0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<int>(
                                        value: filterCount[index],
                                        onChanged: tableHeader.value == null
                                            ? null
                                            : (val) {
                                          filterCount[index] = val!;
                                          setState(() {});
                                        },
                                        onSaved: (val) {
                                          localList[0] = validFilters[val!].key;
                                        },
                                        isExpanded: true,
                                        items: validFilters.asMap().map((key, e) => MapEntry(key, DropdownMenuItem<int>(value: key, child: Text(e.displayName))))
                                            .values
                                            .toList(),
                                        decoration: InputDecoration(
                                            hintStyle: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade400,
                                                fontWeight: FontWeight.normal),
                                            constraints: const BoxConstraints(maxHeight: 30),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(color: Colors.transparent),
                                                borderRadius: BorderRadius.circular(6)),
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(color: Colors.transparent),
                                                borderRadius: BorderRadius.circular(6)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                                            filled: true,
                                            fillColor: Colors.grey.shade100),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 25,
                                    ),
                                    Expanded(
                                      child: DropdownButtonFormField(
                                        value: validFilters[filterCount[index]].filterData.defaultFilterType,
                                        onChanged: (val) {
                                          // localList[1] = tableHeader.value!.data.columns[filterCount[index]].filterData.supportedFilters[filterCount[index]];
                                        },
                                        onSaved: (val) {
                                          localList[1] = val!;
                                        },
                                        isExpanded: true,
                                        items: validFilters[filterCount[index]]
                                            .filterData
                                            .supportedFilters
                                            .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                            .toList(),
                                        decoration: InputDecoration(
                                            constraints: const BoxConstraints(maxHeight: 30),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(color: Colors.transparent),
                                                borderRadius: BorderRadius.circular(6)),
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(color: Colors.transparent),
                                                borderRadius: BorderRadius.circular(6)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                                            filled: true,
                                            fillColor: Colors.grey.shade100),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 25,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        controller: filterControllers[index],
                                        cursorHeight: 15,
                                        decoration: InputDecoration(
                                            hintText: StringConstants.searchValue,
                                            hintStyle: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade400,
                                                fontWeight: FontWeight.normal),
                                            constraints: const BoxConstraints(maxHeight: 30),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(color: Colors.transparent),
                                                borderRadius: BorderRadius.circular(6)),
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(color: Colors.transparent),
                                                borderRadius: BorderRadius.circular(6)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                                            filled: true,
                                            fillColor: Colors.grey.shade100),
                                        onSaved: (val) {
                                          localList[1] == "Like" || localList[1] == "Not Like"
                                              ? val = "%$val%"
                                              : val;
                                          localList[2] = val!;
                                          for (var element in filters.value) {
                                            if (element.first == localList.first) {
                                              filters.value.remove(element);
                                            }
                                          }
                                          refresher.value == 0 ? refresher.value = 1 : refresher.value = 0;
                                          filters.value.add(localList);
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 25,
                                    ),
                                    InkWell(
                                        onTap: () {
                                          if (filters.value.isNotEmpty) {
                                            filters.value.removeAt(index);
                                          }
                                          filterCount.removeAt(index);
                                          filterControllers.removeAt(index);
                                          setState(() {});
                                        },
                                        child: const Icon(
                                          Icons.cancel_outlined,
                                          size: 20,
                                        ))
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              TextButton.icon(
                                  onPressed: tableHeader.value != null && filterCount.length >= validFilters.length
                                      ? null
                                      : () {
                                    filterCount.add(filterCount.length);
                                    filterControllers.add(TextEditingController());
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text(StringConstants.addFilters)),
                              const Spacer(),
                              OutlinedButton(
                                  onPressed: () {
                                    filterCount.clear();
                                    filterControllers.clear();
                                    filters.value.clear();
                                    refresher.value == 0 ? refresher.value = 1 : refresher.value = 0;
                                    mainContext.read<TableBodyBloc>().add(FetchTableRowDataEvent(
                                        baseUrl: tableHeader.value!.actionApi,
                                        filters: filters.value,
                                        sortBy: sortByWithOrder.value,
                                        length: rowsPerPage));
                                    Navigator.pop(context);
                                  },
                                  child: const Text(StringConstants.clearFilters)),
                              const SizedBox(
                                width: 15,
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    formKey.currentState!.save();
                                    refresher.value == 0 ? refresher.value = 1 : refresher.value = 0;
                                    mainContext.read<TableBodyBloc>().add(FetchTableRowDataEvent(
                                        baseUrl: tableHeader.value!.actionApi,
                                        filters: filters.value,
                                        sortBy: sortByWithOrder.value,
                                        length: rowsPerPage));
                                    Navigator.pop(context);
                                  },
                                  child: const Text(StringConstants.applyFilters)),
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
            ]),
        const VerticalDivider(),
        PopupMenuButton(
            enabled: tableHeader.value != null,
            position: PopupMenuPosition.under,
            surfaceTintColor: Colors.white,
            tooltip: StringConstants.sortBy,
            color: Colors.white,
            offset: const Offset(0, 10),
            child: Container(
                width: 130,
                height: 35,
                decoration: BoxDecoration(
                    color: tableHeader.value != null ? Colors.white : Colors.grey.withOpacity(.2),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(.2), spreadRadius: 1, blurRadius: 1)]),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Icon(
                          Icons.tune_outlined,
                          size: 18,
                        )),
                    Text(StringConstants.sortBy),
                    Expanded(child: Icon(Icons.keyboard_arrow_down_outlined))
                  ],
                )),
            itemBuilder: (context) => [
              PopupMenuItem(
                  padding: EdgeInsets.zero,
                  enabled: false,
                  child: StatefulBuilder(
                    builder: (context, setState) => Column(
                      children: sortList
                          .map((e) => RadioListTile<String?>(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                          title: Text(e.values.first),
                          value: e.keys.first,
                          groupValue: sortByWithOrder.value.split(" ")[0],
                          onChanged: (value) {
                            sortByWithOrder.value = "$value ${StringConstants.asc}";
                            Navigator.pop(context);
                            refresher.value == 0 ? refresher.value = 1 : refresher.value = 0;
                            mainContext.read<TableBodyBloc>().add(FetchTableRowDataEvent(
                                baseUrl: tableHeader.value!.actionApi,
                                filters: filters.value,
                                sortBy: sortByWithOrder.value,
                                length: rowsPerPage));
                            setState(() {});
                          }))
                          .toList(),
                    ),
                  )),
            ]),
        const VerticalDivider(),
        SizedBox(
          width: 30,
          child: ValueListenableBuilder(
              valueListenable: sortByWithOrder,
              builder: (context, snapshot, wid) {
                return ElevatedButton(
                  onPressed: snapshot.isEmpty
                      ? null
                      : () {
                    if (sortByWithOrder.value.split(" ")[1] == StringConstants.asc) {
                      sortByWithOrder.value = "${sortByWithOrder.value.split(" ")[0]} ${StringConstants.desc}";
                    } else {
                      sortByWithOrder.value = "${sortByWithOrder.value.split(" ")[0]} ${StringConstants.asc}";
                    }
                    mainContext.read<TableBodyBloc>().add(FetchTableRowDataEvent(
                        baseUrl: tableHeader.value!.actionApi,
                        filters: filters.value,
                        sortBy: sortByWithOrder.value,
                        length: rowsPerPage));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5)),
                  child: const Icon(Icons.swap_vert),
                );
              }),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BlocConsumer<TableBloc, TableStates>(
                listener: (context, state) {
                  if(state is TableLoadedState && widget.tableName != null) {
                    print(widget.tableName);
                    tableHeader.value = null;
                    for (var element in state.table.message.tables) {
                      if(element.tableName.contains(widget.tableName!)) {
                        tableHeader.value = element;
                        print("selected ${element.tableName}");
                        print(tableHeader.value!.tableName);
                      }
                    }
                    rowsPerPage = tableHeader.value!.rowsPerPage;
                    rowHeight.value.clear();
                    mainContext.read<TableBodyBloc>().add(FetchTableRowDataEvent(baseUrl: tableHeader.value!.actionApi,length: rowsPerPage));
                    for(int y = 0; y < rowsPerPage; y++) {
                      rowHeight.value.add(40);
                    }
                    sortList.clear();
                    validFilters.clear();
                    filters.value.clear();
                    sortByWithOrder.value = "";
                    refresher.value == 0 ? refresher.value = 1 : refresher.value = 0;
                    controllersList = [];
                    columnMeta = [];
                    for (var x in tableHeader.value!.data.columns) {
                      if (x.sort.sortEnabled) {
                        sortList.add({x.key: x.displayName});
                      }
                      if (x.filterData.supportedFilters.isNotEmpty) {
                        validFilters.add(x);
                      }
                    }
                    controllersList = List.generate(tableHeader.value!.data.columns.length,
                            (index) => TextEditingController());
                    columnMeta = List.generate(tableHeader.value!.data.columns.length, (index) => ColumnMeta(150, tableHeader.value!.data.columns[index].hidden,false));
                    if(tableHeader.value!.actions != null) {
                      columnMeta.add(ColumnMeta(150, false,false));
                    }
                  }
                  else if(state is TableErrorState) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  return Autocomplete(
                    fieldViewBuilder: (context, textEditingController, focus, onSubmit) => TextFormField(
                      cursorHeight: 16,
                      enabled: widget.tableName == null,
                      controller: textEditingController,
                      focusNode: focus,
                      onTap: (){
                        textEditingController.clear();
                      },
                      onFieldSubmitted: (val) => onSubmit,
                      decoration: InputDecoration(
                        constraints: const BoxConstraints(maxHeight: 35),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(color: Colors.transparent)),
                        hintText: widget.tableName == null || tableHeader.value == null ? StringConstants.searchTable : tableHeader.value!.tableName,
                        hoverColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(color: Colors.transparent)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(color: Colors.transparent)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    optionsBuilder: (val) {
                      final List<String> list = [];
                      if (state is TableLoadedState) {
                        for (var name in state.table.message.tables) {
                          list.add(name.tableName);
                        }
                      }
                      if (val.text.isEmpty) {
                        return list;
                      } else {
                        list.retainWhere((element) => element.toLowerCase().contains(val.text.toLowerCase()));
                        return list;
                      }
                    },
                    optionsViewBuilder: (context, func, itr) => Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withOpacity(.2)),
                          color: Colors.white,
                        ),
                        width: 300,
                        constraints: const BoxConstraints(maxHeight: 350),
                        child: Material(
                            child: state is TableLoadedState
                                ? ListView.separated(
                                shrinkWrap: true,
                                itemCount: itr.length,
                                separatorBuilder: (context, index) => Container(
                                  height: 1,
                                  color: Colors.grey.withOpacity(.2),
                                ),
                                itemBuilder: (context, index) => ListTile(
                                    dense: true,
                                    tileColor: Colors.white,
                                    onTap: () {
                                      selectedCell = null;
                                      updateBody = {};
                                      func(itr.elementAt(index));
                                      tableHeader.value = null;
                                      for(var x in state.table.message.tables) {
                                        if(x.tableName == itr.elementAt(index)){
                                          tableHeader.value = x;
                                        }
                                      }
                                      rowsPerPage = tableHeader.value!.rowsPerPage;
                                      rowHeight.value.clear();
                                      mainContext.read<TableBodyBloc>().add(FetchTableRowDataEvent(baseUrl: tableHeader.value!.actionApi,length: rowsPerPage));
                                      for(int y = 0; y < rowsPerPage; y++) {
                                        rowHeight.value.add(40);
                                      }
                                      sortList.clear();
                                      validFilters.clear();
                                      filters.value.clear();
                                      sortByWithOrder.value = "";
                                      refresher.value == 0 ? refresher.value = 1 : refresher.value = 0;
                                      controllersList = [];
                                      columnMeta = [];
                                      for (var x in tableHeader.value!.data.columns) {
                                        if (x.sort.sortEnabled) {
                                          sortList.add({x.key: x.displayName});
                                        }
                                        if (x.filterData.supportedFilters.isNotEmpty) {
                                          validFilters.add(x);
                                        }
                                      }
                                      controllersList = List.generate(tableHeader.value!.data.columns.length,
                                              (index) => TextEditingController());
                                      columnMeta = List.generate(tableHeader.value!.data.columns.length, (index) => ColumnMeta(150, tableHeader.value!.data.columns[index].hidden,false));
                                      if(tableHeader.value!.actions != null) {
                                        columnMeta.add(ColumnMeta(250, false,false));
                                      }
                                      FocusManager.instance.primaryFocus!.unfocus();
                                    },
                                    title: Text(itr.elementAt(index))))
                                : const Center(child: CircularProgressIndicator())),
                      ),
                    ),
                  );
                }),
          ),
        ),
        Text(
          "${StringConstants.rowsPerPage} : $rowsPerPage",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const VerticalDivider(),
        SizedBox(
          width: 50,
          child: DropdownButtonFormField<int>(
              enableFeedback: true,
              alignment: Alignment.topCenter,
              focusColor: Colors.transparent,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 6),
                isDense: true,
              ),
              value: rowsPerPage,
              isExpanded: true,
              items: tableHeader.value == null
                  ? null
                  : snapshot!.perPageEntryOptions
                  .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    "$e",
                    style: const TextStyle(fontSize: 14),
                  )))
                  .toList(),
              onChanged: (val) {
                rowHeight.value.clear();
                rowsPerPage = val!;
                for(int y = 0; y < rowsPerPage; y++) {
                  rowHeight.value.add(40);
                }
                activePage = 1;
                mainContext.read<TableBodyBloc>().add(FetchTableRowDataEvent(
                    baseUrl: tableHeader.value!.actionApi,
                    filters: filters.value,
                    sortBy: sortByWithOrder.value,
                    length: rowsPerPage));
                setState(() {});
              }),
        ),
        const VerticalDivider(),
        SizedBox(
          height: 25,
          width: 25,
          child: IconButton(
              iconSize: 16,
              style: IconButton.styleFrom(side: const BorderSide(color: Colors.grey), padding: EdgeInsets.zero),
              onPressed: () {
                if (activePage > 1) activePage--;
                setState(() {});
              },
              icon: const Icon(Icons.keyboard_arrow_left)),
        ),
        const VerticalDivider(),
        Text(
          "$activePage of ${tableHeader.value == null ? 1 : (snapshot!.totalRows / rowsPerPage).ceil()}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const VerticalDivider(),
        SizedBox(
            height: 25,
            width: 25,
            child: IconButton(
              onPressed: () {
                // if((state.table.data.rows.length / rowsPerPage).ceil() > activePage) activePage++;
                // setState(() {
                //
                // });
              },
              iconSize: 16,
              icon: const Icon(Icons.keyboard_arrow_right),
              style: IconButton.styleFrom(side: const BorderSide(color: Colors.grey)),
              padding: EdgeInsets.zero,
            )),
        const SizedBox(
          width: 15,
        ),
        PopupMenuButton(
            offset: const Offset(-10, 10),
            icon: const Icon(Icons.more_vert),
            position: PopupMenuPosition.under,
            surfaceTintColor: Colors.white,
            itemBuilder: (context) => [PopupMenuItem(onTap: () async {}, child: const Text("Export"))])
      ],
    );
  }
}



class Header extends SliverPersistentHeaderDelegate {
  final double extent;
  final Widget child;

  Header({required this.extent, required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  double get maxExtent => extent;

  @override
  double get minExtent => extent;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}