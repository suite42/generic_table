library generic_ledger;
import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:generic_ledger/generic_table/generic_model/column_meta.dart';
import 'package:generic_ledger/generic_table/table_body/models/table_row_data_model.dart';
import 'package:generic_ledger/utils/extensions.dart';
import 'package:generic_ledger/utils/global_methods.dart';
import 'package:generic_ledger/utils/string_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'generic_table/table_body/bloc/bloc/payment_bloc.dart';
import 'generic_table/table_body/bloc/bloc/table_body_bloc.dart';
import 'generic_table/table_body/views/filter_cell.dart';
import 'generic_table/table_body/views/row_cell.dart';
import 'generic_table/table_header/bloc/bloc/table_bloc.dart';
import 'generic_table/table_header/models/generic_table_model.dart';

String basePath = "";
bool reload = true;

class GenericTable extends StatefulWidget {
  const GenericTable({super.key,required this.basPath,this.tableName});
  final String basPath;
  final String? tableName;

  @override
  State<GenericTable> createState() => _GenericTableState();
}

class _GenericTableState extends State<GenericTable> {
  late final GoRouter _router;
  // This widget is the root of this application.
  @override
  void initState() {
     _router = GoRouter(
        initialLocation: widget.basPath.contains("/") ? widget.basPath : "/${widget.basPath}",
        routes: [
          GoRoute(
            name: widget.basPath,
            path: widget.basPath.contains("/") ? widget.basPath : "/${widget.basPath}",
            builder: (context, state) {
              // print("aaaa ${state.uri.queryParameters}");
              return TableView(tableName: widget.tableName,params: state.uri.queryParameters,);
            },
          )
        ]);
    basePath = widget.basPath;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => TableBloc()),
        BlocProvider(create: (context) => TableBodyBloc()),
        BlocProvider(create: (context) => PaymentBloc()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
          routeInformationParser: _router.routeInformationParser,
          routerDelegate: _router.routerDelegate,
        routeInformationProvider: _router.routeInformationProvider,
      ),
    );
  }
}


class TableView extends StatefulWidget {
  const TableView({super.key, this.tableName,this.params});

  final String? tableName;
  final Map<String, dynamic>? params;

  @override
  State<TableView> createState() => _TableViewState();
}

class _TableViewState extends State<TableView> {

  int? selectedCell;

  int? colSelected;

  late List<ColumnMeta> columnMeta;

  List<double> cellMaxWidth = [];

  int sortedIndex = 1;

  List<TableHeader> tableList = [];

  List<ScrollController?> scrollList = List.generate(102, (index) => null);

  final LinkedScrollControllerGroup _controllerGroup = LinkedScrollControllerGroup();

  List<int> filterCount = [];
  List<MessageRow> row = [];
  Map<String, dynamic> localParams = {};
  late Update? tableUpdate;
  final ValueNotifier<List<double>> rowHeight = ValueNotifier([]);

  @override
  void initState() {
    for (int x = 0; x < scrollList.length; x++) {
      scrollList[x] = _controllerGroup.addAndGet();
    }
    print("init state");
    super.initState();
    context.read<TableBloc>().add(FetchTableList());
  }

  late Map<String, TextEditingController> controllersList;

  late List<TextEditingController> filterControllers = [];

  List<int> usedControllers = [];

  List<Map<String, String>> sortList = [];

  ValueNotifier<List<List<String>>> filters = ValueNotifier([]);

  Map<String, TableColumn> validFilters = {};

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
    print("pre entering");
    // if(widget.params!.isNotEmpty && tableHeader.value != null && reload && mounted) {
    //   print("entering");
    //   reload = false;
    //   filters.value.clear();
    //   JWT jwtDecoded = JWT.decode(widget.params!["data"]);
    //   localParams = jwtDecoded.payload;
    //   for (var element in tableList) {
    //     print("chedling");
    //     if(element.tableName.contains(localParams["tableName"])) {
    //       print("found");
    //       tableHeader.value = element;
    //     }
    //   }
    //   Map<String, dynamic> params = {"tableName" : localParams["tableName"]};
    //   if(localParams["filters"] != null) {
    //     List<List<String>> paramFilters = [];
    //     for(List aa in jsonDecode(localParams["filters"])){
    //       final subFilter = List<String>.from(aa);
    //       paramFilters.add(subFilter);
    //     }
    //     filters.value.addAll(paramFilters);
    //     params["filters"] = jsonEncode(filters.value);
    //   }
    //   if(localParams["sortBy"] != null) {
    //     params["sortBy"] = localParams["sortBy"];
    //     sortByWithOrder.value = localParams["sortBy"];
    //   }
    //   rowsPerPage = int.parse(localParams["rowsPerPage"]);
    //   params["rowsPerPage"] = rowsPerPage.toString();
    //   // final jwt = JWT(params);
    //   // final signedJwt = jwt.sign(SecretKey("suite42FinanceWeb"));
    //   // mainContext.goNamed(basePath,queryParameters: {"data" : signedJwt});
    //   rowHeight.value.clear();
    //   mainContext.read<TableBodyBloc>().add(
    //       FetchTableRowDataEvent(
    //           baseUrl: tableHeader.value!.actionApi,
    //           length: rowsPerPage,
    //           filters: filters.value,
    //           sortBy: sortByWithOrder.value
    //       ));
    //   for(int y = 0; y < rowsPerPage; y++) {
    //     rowHeight.value.add(40);
    //   }
    //   sortList.clear();
    //   validFilters.clear();
    //   // filters.value.clear();
    //   refresher.value == 0 ? refresher.value = 1 : refresher.value = 0;
    //   controllersList = {};
    //   columnMeta = [];
    //   for (var x in tableHeader.value!.data.columns) {
    //     controllersList[x.key] = TextEditingController();
    //     if (x.sort.sortEnabled) {
    //       sortList.add({x.key: x.displayName});
    //     }
    //     if (x.filterData.supportedFilters.isNotEmpty) {
    //       validFilters[x.key] = x;
    //     }
    //   }
    //   columnMeta = List.generate(tableHeader.value!.data.columns.length, (index) => ColumnMeta(
    //       width: tableHeader.value!.data.columns[index].cellWidth,
    //       isFreezed: false,
    //       isHover: false,
    //       isSelected: false,
    //       sortEnabled: tableHeader.value!.data.columns[index].sort.sortEnabled
    //   ));
    //   // if(tableHeader.value!.actions != null) {
    //   columnMeta.insert(0,ColumnMeta(
    //       width: 150,
    //       isFreezed: false,
    //       isHover: false,
    //       isSelected: false,
    //       sortEnabled: false
    //   ));
    //   // }
    //   cellMaxWidth = List.filled(columnMeta.length, 0.0);
    //   FocusManager.instance.primaryFocus!.unfocus();
    // }
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
                    },icon: const Icon(Icons.invert_colors_on_sharp), label: const Text("Color"),style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),),
                    const SizedBox(width: 7,),
                    // OutlinedButton.icon(onPressed: (){},icon: const Icon(Icons.format_align_center), label: Text("Alignment"),style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),),
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
              tableColumns(mainContext),
              tableFilters(mainContext),
              tableBody(mainContext),
            ],
          )),
    );
  }

  BlocConsumer<TableBodyBloc, TableRowStates> tableBody(BuildContext mainContext) {
    return BlocConsumer<TableBodyBloc, TableRowStates>(
        listener: (context, state) {
          if (state is TableRowLoadedState) {
            // print("widget.params ${widget.params}");
            // print("localParams ${localParams}");

            for(int i=0;i < state.tableRowDataModel.message.rows.length; i++) {
              for(int j=0;j < cellMaxWidth.length; j++) {
                double cellWidth = j == 0 ? 150.0 : GlobalMethods.getTextLengthInPixels(text: state.tableRowDataModel.message.rows[i].row[j-1].value.toString(),style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold));
                cellMaxWidth[j] =  cellMaxWidth[j] <  cellWidth ? cellWidth : cellMaxWidth[j];
              }
            }
          }
        },
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
                  // dividerColor: Colors.transparent,
                  children: List.generate(
                      (row.length / rowsPerPage).ceil() == activePage ? row.length - (rowsPerPage * (activePage - 1))
                          : rowsPerPage,
                          (index) =>  InkWell(
                            onTap: (){
                              if(selectedCell != null && tableUpdate != null && updateBody.isNotEmpty) {
                                context.read<TableBloc>().add(UpdateTable(tableUpdate!.actionApi, {"data" : updateBody}));
                              }
                              selectedCell = null;
                              setState(() {});
                            },
                        onDoubleTap: () {
                            selectedCell = index;
                            setState(() {});
                        },
                        child: ValueListenableBuilder(
                            valueListenable: rowHeight,
                            builder: (context, snapshot,wid) {
                              return
                                // CustomExpansionTile(
                                // controlAffinity: ListTileControlAffinity.leading,
                                // tilePadding: EdgeInsets.zero,
                                // title:
                                SizedBox(
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
                                          slivers: List.generate(columnMeta.length, (x) {
                                            return SliverPersistentHeader(
                                              pinned: columnMeta[x].isFreezed,
                                              delegate: Header(
                                                extent: columnMeta[x].width,
                                                child: x == 0 ? Container(
                                                  padding: const EdgeInsets.only(left: 10),
                                                  // width: columnMeta[index].width,
                                                  decoration: BoxDecoration(
                                                      color:  const Color(0xFFF2F2F2),
                                                      border: Border(bottom: BorderSide(color: Colors.grey.shade300),right: BorderSide(color: Colors.grey.shade300))
                                                  ),
                                                  child: row[index].action != null && row[index].action!.isNotEmpty ? Center(
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
                                                                        dataUpdate(mainContext);
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
                                                  subIndex:x-1,
                                                  selectedCell: selectedCell,
                                                  cellSize: columnMeta[x].width,
                                                  isSelected: colSelected != null && colSelected == x,
                                                ),
                                              ),
                                            );
                                          })
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
                              // );
                            }
                        ),
                      ),
                           ),
                ),
              ),
            );
          } else if(state is TableRowErrorState) {
            return Center(child: Text(state.message,textAlign: TextAlign.center,style: const TextStyle(color: Colors.red,fontSize: 18,fontWeight: FontWeight.bold),));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  void dataUpdate(BuildContext mainContext) {
    Map<String, dynamic> params = {"tableName" : tableHeader.value!.tableName};
    if(filters.value.isNotEmpty) {
      params["filters"] = jsonEncode(filters.value);
    }
    if(sortByWithOrder.value.isNotEmpty) {
      params["sortBy"] = sortByWithOrder.value;
    }
    params["rowsPerPage"] = rowsPerPage.toString();
    // print("params $params");
    final jwt = JWT(params);

    final signedJwt = jwt.sign(SecretKey("suite42FinanceWeb"));
    // print("token $signedJwt");
    mainContext.goNamed(basePath,queryParameters: {"data" : signedJwt});
    mainContext.read<TableBodyBloc>().add(FetchTableRowDataEvent(
        baseUrl: tableHeader.value!.actionApi,
        filters: filters.value,
        sortBy: sortByWithOrder.value,
        length: rowsPerPage));
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
          slivers: List.generate(columnMeta.length, (x) {
            List<String> localList = [];
            return SliverPersistentHeader(
              delegate: Header(
                  extent: columnMeta[x].width,
                  child: x == 0 ? Container(width: columnMeta[x].width,height: 40,decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(color: Colors.grey.withOpacity(.3)),
                      top: BorderSide(color: Colors.grey.withOpacity(.3)),
                      bottom: BorderSide(color: Colors.grey.withOpacity(.3)),
                    ),
                  ),) :  FilterCell(
                    columnSize: columnMeta[x].width,
                    controller: controllersList[tableHeader.value!.data.columns[x-1].key]!,
                    tableHeader: tableHeader,
                    onChanged: (val) {
                      if ((val == "%25%25")|| val.isEmpty) {
                        filters.value.remove(localList);
                        filterCount.remove(filterCount.length);
                        dataUpdate(mainContext);
                        setState(() {});
                      }
                    },
                    onSubmit: (val) {
                      tableHeader.value!.data.columns[x-1].filterData.defaultFilterType == "Like" ||
                          tableHeader.value!.data.columns[x-1].filterData.defaultFilterType ==
                              "Not Like"
                          ? val = "%25$val%25"
                          : val;
                      if (!usedControllers.contains(x-1)) {
                        usedControllers.add(x-1);
                      }
                       localList = [
                        tableHeader.value!.data.columns[x-1].key,
                        tableHeader.value!.data.columns[x-1].filterData.defaultFilterType,
                        val
                      ];
                      var xa = List.from(filters.value);

                      for (var element in xa) {
                        if (element.first == localList.first) {
                          filters.value.remove(element);
                        }
                      }
                      filters.value.add(localList);
                      if ((val == "%25%25")|| val.isEmpty) {
                        filters.value.remove(localList);
                        filterCount.remove(filterCount.length);
                      }
                      dataUpdate(mainContext);
                    },
                    index: x-1,
                  )),
              pinned: columnMeta[x].isFreezed,
            );
          })
        ));
  }

  Positioned tableColumns(BuildContext mainContext) {
    return Positioned(
      height: 55,
      // left: 34,
      left: 0,
      right: 0,
      child: CustomScrollView(
        controller: scrollList[0],
        shrinkWrap: true,
        primary: false,
        scrollDirection: Axis.horizontal,
        slivers: [
          for(int x = 0; x < columnMeta.length; x++)
            SliverPersistentHeader(
              pinned: columnMeta[x].isFreezed,
              delegate: Header(
                  extent: columnMeta[x].width,
                  child: DragTarget<List>(
                    onAcceptWithDetails: (val){
                      final localColumnMeta = columnMeta[x-1];
                      final localColumnData = tableHeader.value!.data.columns[x-1];
                      columnMeta[x-1] = val.data[0];
                      tableHeader.value!.data.columns[x-1] = val.data[2];
                      columnMeta[val.data[1]] = localColumnMeta;
                      tableHeader.value!.data.columns[val.data[1]] = localColumnData;
                      for (var element in row) {
                      final localRowData = element.row[x-1];
                        element.row[x-1] = element.row[val.data[1]];
                        element.row[val.data[1]] = localRowData;
                      }
                      setState(() {

                      });
                    },
                    builder: (BuildContext context, List<Object?> candidateData, List<dynamic> rejectedData) => Draggable(
                      data: x == 0 ? null : [columnMeta[x-1],x-1,tableHeader.value!.data.columns[x-1]],
                      feedback: Card(
                        child: Container(
                          padding: const EdgeInsets.only(left: 5),
                          width: columnMeta[x].width,
                          color: const Color(0xFFF2F2F2),
                          child: x == 0 ? const Center(
                            child: Text("Actions",style: TextStyle(fontWeight: FontWeight.bold),)
                          ) :
                          Row(
                            children: [
                              InkWell(
                                onTap: (){
                                  columnMeta[x-1].isFreezed = !columnMeta[x-1].isFreezed;
                                  setState(() {

                                  });
                                },
                                child: Icon(columnMeta[x-1].isFreezed ? Icons.push_pin : Icons.push_pin_outlined,size: 16,),
                              ),
                              const SizedBox(width: 5,),
                              Expanded(
                                  child: Tooltip(
                                      message: tableHeader.value!.data.columns[x-1].displayName.titleCase(),
                                      preferBelow: false,
                                      child: ValueListenableBuilder(
                                          valueListenable: sortByWithOrder,
                                          builder: (context, snapshot, wid) {
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(tableHeader.value!.data.columns[x-1].displayName.titleCase(),
                                                      style: const TextStyle(fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis)),
                                                ),
                                                if (tableHeader.value!.data.columns[x-1].key == sortByWithOrder.value.split(" ")[0])
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
                      child: GestureDetector(
                        onDoubleTap: (){
                          columnMeta[x].width = cellMaxWidth[x]+20 < 75 ? 75 : cellMaxWidth[x]+20;
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.only(left: 5),
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                              color: colSelected != null && colSelected == x ? const Color(0xFFA8A7A7) : const Color(0xFFF2F2F2),
                              border: x == 0 ? const Border(right: BorderSide(color: Colors.grey,width: 1)) : null
                          ),
                          child: x == 0 ?  Center(
                            child: Row(
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
                                const Text("Actions",style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
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
                                  child: MouseRegion(
                                    onEnter: (eve){
                                      columnMeta[x].isHover = true;
                                      setState(() {

                                      });
                                      // }
                                    },
                                    onExit: (val){
                                      columnMeta[x].isHover = false;
                                      setState(() {

                                      });
                                    },
                                    child: Tooltip(
                                        message: tableHeader.value!.data.columns[x-1].displayName.titleCase(),
                                        preferBelow: false,
                                        child: ValueListenableBuilder(
                                            valueListenable: sortByWithOrder,
                                            builder: (context, snapshot, wid) {
                                              if(columnMeta[x].isHover || tableHeader.value!.data.columns[x-1].key == sortByWithOrder.value.split(" ")[0]) {
                                                sortedIndex = x-1;
                                                // print("sortedIndex $sortedIndex");
                                              }
                                              // print("columnMeta[0].sortEnabled ${columnMeta[0].sortEnabled}");
                                              return Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(tableHeader.value!.data.columns[x-1].displayName.titleCase(),
                                                        style: const TextStyle(fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis)),
                                                  ),
                                                  if((columnMeta[x].isHover || tableHeader.value!.data.columns[x-1].key == sortByWithOrder.value.split(" ")[0]) && columnMeta[x].sortEnabled)
                                                  tableHeader.value!.data.columns[x-1].key == sortByWithOrder.value.split(" ")[0] ? IconButton(
                                                      onPressed: () {
                                                        final localFilters = List.from(filters.value);
                                                        for(var val in localFilters) {
                                                          filters.value.removeWhere((val) => val.first == sortByWithOrder.value.split(" ")[0]);
                                                        }
                                                        lastValue.clear();
                                                    if (sortByWithOrder.value.split(" ")[1] == StringConstants.asc) {
                                                      sortByWithOrder.value = "${tableHeader.value!.data.columns[x-1].key} ${StringConstants.desc}";
                                                    } else {
                                                      sortByWithOrder.value = "${tableHeader.value!.data.columns[x-1].key} ${StringConstants.asc}";
                                                    }
                                                    dataUpdate(mainContext);
                                                  }, icon: sortByWithOrder.value.split(" ")[1] == "ASC"
                                                      ? const Icon(
                                                    Icons.arrow_upward,
                                                    size: 16,
                                                  )
                                                      : const Icon(
                                                    Icons.arrow_downward,
                                                    size: 16,
                                                  )) : IconButton(onPressed: (){
                                                    final localFilters = List.from(filters.value);
                                                    for(var val in localFilters) {
                                                      filters.value.removeWhere((val) => val.first == sortByWithOrder.value.split(" ")[0]);
                                                    }
                                                    lastValue.clear();
                                                    sortByWithOrder.value = "${tableHeader.value!.data.columns[x-1].key} ${StringConstants.desc}";
                                                    refresher.value == 0 ? refresher.value = 1 : refresher.value = 0;
                                                    dataUpdate(mainContext);
                                                    setState(() {});
                                                  }, icon: const Icon(Icons.swap_vert,size: 16,))
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
                                        setState(() {
                                          final temp = 150 + val.localPosition.dx;
                                          columnMeta[x].width = temp < 50 ? 50 : temp;
                                        });
                                      },
                                      child: Center(child: Container(color: Colors.grey.withOpacity(.3), width: 3,height: 40,)))),
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
                            : "${list[index][0]} - ${list[index][1].toLowerCase() == "like" || list[index][1].toLowerCase() == "not like" ? list[index][2].removePercentage() : list[index][2]}"),
                        const SizedBox(width: 3),
                        InkWell(
                            onTap: () {
                              list[index].length == 1 ? sortByWithOrder.value = tableHeader.value!.defaultSort : filters.value.remove(list[index]);
                              if (usedControllers.isNotEmpty) {
                                usedControllers.removeAt(index);
                              }
                              controllersList[list[index][0]]!.clear();
                              dataUpdate(mainContext);
                              refresher.value == 0 ? refresher.value = 1 : refresher.value = 0;
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
  List<String> lastValue = [];
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
              minWidth: 650,
              maxWidth: 650,
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
                            children: List.generate(filters.value.length, (index) {
                              Map<String, dynamic> applicableFilter = {};
                              List<String> localList = ["", "", ""];
                              for (var element in tableHeader.value!.data.columns) {
                                if(element.key == localList.first) {
                                  applicableFilter[element.key] = element.writeOptions.options.supportedValues as List<String>;
                                }
                              }
                              // print("object ${tableHeader.value!.data.columns[index].filterData.defaultFilterType}");
                              // validFilters.forEach((element) {
                              //   print(element.key);
                              // });
                              return Container(
                                margin: EdgeInsets.only(bottom: 20, top: index == 0 ? 15 : 0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        isDense: true,
                                        style: const TextStyle(overflow: TextOverflow.ellipsis),
                                        value: filters.value[index][0].isEmpty ? tableHeader.value!.data.columns[index].key : filters.value[index][0],
                                        onChanged: tableHeader.value == null ? null : (val) {
                                          filters.value[index][0] = val!;
                                          setState(() {});
                                        },
                                        onSaved: (val) {
                                          filters.value[index][0] = val!;
                                        },
                                        isExpanded: true,
                                        items: validFilters.keys.map((e) => DropdownMenuItem<String>(value: e, child: Text(validFilters[e]!.displayName))).toList(),
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
                                    SizedBox(
                                      width: 150,
                                      child: DropdownButtonFormField<String>(
                                        isDense: true,
                                        style: const TextStyle(overflow: TextOverflow.ellipsis),
                                        value: filters.value[index][1].isEmpty ? validFilters[filters.value[index][0].isEmpty ? tableHeader.value!.data.columns[index].key : filters.value[index][0]]!.filterData.defaultFilterType : filters.value[index][1],
                                        onChanged: (val) {
                                          filters.value[index][1] = val!;
                                          setState((){});
                                        },
                                        onSaved: (val) {
                                          filters.value[index][1] = val!;
                                        },
                                        isExpanded: true,
                                        items: validFilters[filters.value[index][0].isEmpty ? tableHeader.value!.data.columns[index].key : filters.value[index][0]]!.filterData.supportedFilters.map<DropdownMenuItem<String>>((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(),
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
                                    SizedBox(
                                      width: 175,
                                      child:
                                      // filters.value[index][1] == "Equals" ? DropdownButtonFormField(
                                      //   isDense: true,
                                      //   style: const TextStyle(overflow: TextOverflow.ellipsis),
                                      //   onChanged: (val) {
                                      //     localList[1] = val!;
                                      //   },
                                      //   onSaved: (val) {
                                      //     localList[1] = val!;
                                      //   },
                                      //   isExpanded: true,
                                      //   items: applicableFilter
                                      //       .map((e) => DropdownMenuItem(
                                      //     value: e,
                                      //     child: Text(e),
                                      //   ))
                                      //       .toList(),
                                      //   decoration: InputDecoration(
                                      //       constraints: const BoxConstraints(maxHeight: 30),
                                      //       focusedBorder: OutlineInputBorder(
                                      //           borderSide: const BorderSide(color: Colors.transparent),
                                      //           borderRadius: BorderRadius.circular(6)),
                                      //       enabledBorder: OutlineInputBorder(
                                      //           borderSide: const BorderSide(color: Colors.transparent),
                                      //           borderRadius: BorderRadius.circular(6)),
                                      //       contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                                      //       filled: true,
                                      //       fillColor: Colors.grey.shade100),
                                      // ) :
                                      TextFormField(
                                        // controller: filterControllers[index],
                                        initialValue: filters.value[index][2].isNotEmpty && (filters.value[index][1] == "Like" || filters.value[index][1] == "Not Like")
                                            ? filters.value[index][2].removePercentage() : filters.value[index][2],
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
                                        validator: (val) => val!.isEmpty ? "Please enter value" : null,
                                        onSaved: (val) {
                                          controllersList[filters.value[index][0]]!.text = val!;
                                          filters.value[index][1] == "Like" || filters.value[index][1] == "Not Like"
                                              ? val = "%25$val%25"
                                              : val;
                                          filters.value[index][2] = val;
                                          // for (var element in filters.value) {
                                          //   if (element.isNotEmpty  && element.first == localList.first) {
                                          //     filters.value.remove(element);
                                          //   }
                                          // }
                                          refresher.value == 0 ? refresher.value = 1 : refresher.value = 0;
                                          // filters.value[index] = localList;
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 25,
                                    ),
                                    InkWell(
                                        onTap: () {
                                          if (filters.value.isNotEmpty) {
                                            if(controllersList[filters.value[index][0]] != null) {
                                              controllersList[filters.value[index][0]]!.clear();
                                            }
                                            filters.value.removeAt(index);
                                          }
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
                                    filters.value.add(["","",""]);
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
                                    dataUpdate(mainContext);
                                    Navigator.pop(context);
                                    controllersList.forEach((key, value) {
                                      value.clear();
                                    });
                                  },
                                  child: const Text(StringConstants.clearFilters)),
                              const SizedBox(
                                width: 15,
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    if(formKey.currentState!.validate()){
                                      formKey.currentState!.save();
                                      refresher.value == 0 ? refresher.value = 1 : refresher.value = 0;
                                      dataUpdate(mainContext);
                                      Navigator.pop(context);
                                    }
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
                          Icons.sort_by_alpha,
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
                            sortByWithOrder.value = "$value ${StringConstants.desc}";
                            Navigator.pop(context);
                            refresher.value == 0 ? refresher.value = 1 : refresher.value = 0;
                            dataUpdate(mainContext);
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
                    final localFilters = List.from(filters.value);
                    for(var val in localFilters) {
                      filters.value.removeWhere((val) => val.first == sortByWithOrder.value.split(" ")[0]);
                    }
                    lastValue.clear();
                    if (sortByWithOrder.value.split(" ")[1] == StringConstants.asc) {
                      sortByWithOrder.value = "${sortByWithOrder.value.split(" ")[0]} ${StringConstants.desc}";
                    } else {
                      sortByWithOrder.value = "${sortByWithOrder.value.split(" ")[0]} ${StringConstants.asc}";
                    }
                    dataUpdate(mainContext);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5)),
                  child: const Icon(Icons.swap_vert,color: Colors.grey,),
                );
              }),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BlocConsumer<TableBloc, TableStates>(
                listener: (context, state) {
                  if(state is TableLoadedState && widget.params!.isNotEmpty) {
                    print("entering");
                    reload = false;
                    filters.value.clear();
                    JWT jwtDecoded = JWT.decode(widget.params!["data"]);
                    localParams = jwtDecoded.payload;
                    for (var element in state.table.message.tables) {
                      // print("chedling");
                      if(element.tableName.contains(localParams["tableName"])) {
                        // print("found");
                        tableHeader.value = element;
                      }
                    }
                    Map<String, dynamic> params = {"tableName" : localParams["tableName"]};
                    if(localParams["filters"] != null) {
                      List<List<String>> paramFilters = [];
                      for(List aa in jsonDecode(localParams["filters"])){
                        final subFilter = List<String>.from(aa);
                        paramFilters.add(subFilter);
                      }
                      filters.value.addAll(paramFilters);
                      params["filters"] = jsonEncode(filters.value);
                    }
                    if(localParams["sortBy"] != null) {
                      params["sortBy"] = localParams["sortBy"];
                      sortByWithOrder.value = localParams["sortBy"];
                    } else {
                      sortByWithOrder.value = tableHeader.value!.defaultSort;
                    }
                    rowsPerPage = int.parse(localParams["rowsPerPage"]);
                    params["rowsPerPage"] = rowsPerPage.toString();
                    // final jwt = JWT(params);
                    // final signedJwt = jwt.sign(SecretKey("suite42FinanceWeb"));
                    // mainContext.goNamed(basePath,queryParameters: {"data" : signedJwt});
                    rowHeight.value.clear();
                    mainContext.read<TableBodyBloc>().add(
                        FetchTableRowDataEvent(
                            baseUrl: tableHeader.value!.actionApi,
                            length: rowsPerPage,
                            filters: filters.value,
                            sortBy: sortByWithOrder.value
                        ));
                    for(int y = 0; y < rowsPerPage; y++) {
                      rowHeight.value.add(40);
                    }
                    sortList.clear();
                    validFilters.clear();
                    // filters.value.clear();
                    refresher.value == 0 ? refresher.value = 1 : refresher.value = 0;
                    controllersList = {};
                    columnMeta = [];
                    for (var x in tableHeader.value!.data.columns) {
                      controllersList[x.key] = TextEditingController();
                      if (x.sort.sortEnabled) {
                        sortList.add({x.key: x.displayName});
                      }
                      if (x.filterData.supportedFilters.isNotEmpty) {
                        validFilters[x.key] = x;
                      }
                    }
                    columnMeta = List.generate(tableHeader.value!.data.columns.length, (index) => ColumnMeta(
                        width: tableHeader.value!.data.columns[index].cellWidth,
                        isFreezed: false,
                        isHover: false,
                        isSelected: false,
                        sortEnabled: tableHeader.value!.data.columns[index].sort.sortEnabled
                    ));
                    // if(tableHeader.value!.actions != null) {
                    columnMeta.insert(0,ColumnMeta(
                        width: 150,
                        isFreezed: false,
                        isHover: false,
                        isSelected: false,
                        sortEnabled: false
                    ));
                    // }
                    cellMaxWidth = List.filled(columnMeta.length, 0.0);
                    FocusManager.instance.primaryFocus!.unfocus();
                  }
                  if(state is TableLoadedState && widget.tableName != null && widget.params!.isEmpty) {
                    tableHeader.value = null;
                    for (var element in state.table.message.tables) {
                      if(element.tableName.contains(widget.tableName!)) {
                        tableHeader.value = element;
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
                    sortByWithOrder.value = tableHeader.value!.defaultSort;
                    refresher.value == 0 ? refresher.value = 1 : refresher.value = 0;
                    controllersList = {};
                    columnMeta = [];
                    for (var x in tableHeader.value!.data.columns) {
                      controllersList[x.key] = TextEditingController();
                      if (x.sort.sortEnabled) {
                        sortList.add({x.key: x.displayName});
                      }
                      if (x.filterData.supportedFilters.isNotEmpty) {
                        validFilters[x.key] = x;
                      }
                    }
                    columnMeta = List.generate(tableHeader.value!.data.columns.length, (index) => ColumnMeta(
                        width: tableHeader.value!.data.columns[index].cellWidth,
                        isFreezed: false,
                        isHover: false,
                        isSelected: false,
                        sortEnabled: tableHeader.value!.data.columns[index].sort.sortEnabled
                    ));
                    // if(tableHeader.value!.actions != null) {
                      columnMeta.insert(0,ColumnMeta(
                          width: 150.0,
                          isFreezed: false,
                          isHover: false,
                          isSelected: false,
                          sortEnabled: false
                      ));
                    // }
                    cellMaxWidth = List.filled(columnMeta.length, 0.0);
                  }
                  else if(state is TableErrorState) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  return Autocomplete(
                    fieldViewBuilder: (context, textEditingController, focus, onSubmit) {
                      if(widget.params!.isNotEmpty) {
                        JWT jwtDecoded = JWT.decode(widget.params!["data"]);
                        localParams = jwtDecoded.payload;
                        textEditingController.text = localParams["tableName"];
                      }
                      return TextFormField(
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
                      );
                    },
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
                                      Map<String, dynamic> params = {"tableName" : tableHeader.value!.tableName,"rowsPerPage" : rowsPerPage.toString()};
                                      final jwt = JWT(params);

                                      final signedJwt = jwt.sign(SecretKey("suite42FinanceWeb"));
                                      mainContext.goNamed(basePath,queryParameters: {"data" : signedJwt});
                                      rowsPerPage = tableHeader.value!.rowsPerPage;
                                      rowHeight.value.clear();
                                      mainContext.read<TableBodyBloc>().add(FetchTableRowDataEvent(baseUrl: tableHeader.value!.actionApi,length: rowsPerPage));
                                      for(int y = 0; y < rowsPerPage; y++) {
                                        rowHeight.value.add(40);
                                      }
                                      sortList.clear();
                                      validFilters.clear();
                                      filters.value.clear();
                                      sortByWithOrder.value = tableHeader.value!.defaultSort;
                                      refresher.value == 0 ? refresher.value = 1 : refresher.value = 0;
                                      controllersList = {};
                                      columnMeta = [];
                                      for (var x in tableHeader.value!.data.columns) {
                                        controllersList[x.key] = TextEditingController();
                                        if (x.sort.sortEnabled) {
                                          sortList.add({x.key: x.displayName});
                                        }
                                        if (x.filterData.supportedFilters.isNotEmpty) {
                                          validFilters[x.key] = x;
                                        }
                                      }
                                      columnMeta = List.generate(tableHeader.value!.data.columns.length, (index) => ColumnMeta(
                                          width: tableHeader.value!.data.columns[index].cellWidth,
                                          isFreezed: false,
                                          isHover: false,
                                          isSelected: false,
                                          sortEnabled: tableHeader.value!.data.columns[index].sort.sortEnabled
                                      ));
                                      // if(tableHeader.value!.actions != null) {
                                        columnMeta.insert(0,ColumnMeta(
                                            width: 150,
                                            isFreezed: false,
                                            isHover: false,
                                            isSelected: false,
                                            sortEnabled: false
                                        ));
                                      // }
                                      cellMaxWidth = List.filled(columnMeta.length, 0.0);
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
                // scrollList.clear();
                // scrollList = List.generate(rowsPerPage+2, (index) => null);
                // for (int x = 0; x < scrollList.length; x++) {
                //   scrollList[x] = _controllerGroup.addAndGet();
                // }
                rowsPerPage = val!;
                for(int y = 0; y < rowsPerPage; y++) {
                  rowHeight.value.add(40);
                }
                activePage = 1;
                dataUpdate(mainContext);
                setState(() {});
              }),
        ),
        const VerticalDivider(),
        SizedBox(
          height: 25,
          width: 25,
          child: IconButton(
              iconSize: 20,
              style: IconButton.styleFrom(side: const BorderSide(color: Colors.grey)),
              padding: EdgeInsets.zero,
              onPressed: lastValue.isEmpty ? null : () {
                final localFilters = List.from(filters.value);
                for(var val in localFilters) {
                  filters.value.removeWhere((val) => val.first == sortByWithOrder.value.split(" ")[0]);
                }
                if(sortByWithOrder.value.split(" ")[1].toLowerCase() == "desc") {
                  filters.value.add([sortByWithOrder.value.split(" ")[0],"Greater Than",row[0].row[sortedIndex].value.toString()]);
                  filters.value.add([sortByWithOrder.value.split(" ")[0],"Less or Equals",lastValue.last]);

                } else {
                  filters.value.add([sortByWithOrder.value.split(" ")[0],"Less Than",row[0].row[sortedIndex].value.toString()]);
                  filters.value.add([sortByWithOrder.value.split(" ")[0],"Greater or Equals",lastValue.last]);
                }
                lastValue.remove(lastValue.last);
                if(lastValue.isEmpty){
                  for(var val in localFilters) {
                      filters.value.removeWhere((val) => val.first == sortByWithOrder.value.split(" ")[0]);
                  }
                }
                dataUpdate(mainContext);
                // print("object ${filters.value}");
                setState(() {

                });
              },
              tooltip: "Previous",
              icon: const Icon(Icons.keyboard_arrow_left)),
        ),
        const VerticalDivider(),
        SizedBox(
            height: 25,
            width: 25,
            child: IconButton(
              onPressed: () {
                final localFilters = List.from(filters.value);
                for(var val in localFilters) {
                  if(val.first == sortByWithOrder.value.split(" ")[0]) {
                    filters.value.remove(val);
                  }
                }
                lastValue.add(row[0].row[sortedIndex].value.toString());
                // print(lastValue);
                if(sortByWithOrder.value.split(" ")[1].toLowerCase() == "desc") {
                  filters.value.add([sortByWithOrder.value.split(" ")[0],"Less Than",row[row.length-1].row[sortedIndex].value.toString()]);
                } else {
                  filters.value.add([sortByWithOrder.value.split(" ")[0],"Greater Than",row[row.length-1].row[sortedIndex].value.toString()]);
                }
                // print("object ${filters.value}");
                dataUpdate(mainContext);
                setState(() {

                });
              },
              iconSize: 20,
              icon: const Icon(Icons.keyboard_arrow_right),
              style: IconButton.styleFrom(side: const BorderSide(color: Colors.grey)),
              tooltip: "Next",
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
  @override
  void dispose() {
    super.dispose();
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

class ExpansionMeta {
  ExpansionMeta({required this.isExpended,required this.body,required this.header});
  bool isExpended;
  Widget header;
  Widget body;
}