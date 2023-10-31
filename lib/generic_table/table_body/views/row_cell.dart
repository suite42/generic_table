import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:generic_ledger/generic_table/table_body/models/table_row_data_model.dart';
import 'package:generic_ledger/generic_table/table_header/models/generic_table_model.dart';
import 'package:generic_ledger/utils/global_methods.dart';
import 'package:generic_ledger/utils/string_constants.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:url_launcher/url_launcher.dart';


class RowCell extends StatefulWidget {
  RowCell({
    super.key,
    required this.message,
    required this.activePage,
    required this.rowsPerPage,
    required this.index, this.selectedCell,required this.cellSize, required this.subIndex,
    required this.tableHeader, required this.isSelected, required this.body,
  });

  final TableBodyMessage message;
  final int activePage;
  final int rowsPerPage;
  final int index;
  final int subIndex;
  final bool isSelected;
  final int? selectedCell;
  final double cellSize;
  final TableHeader tableHeader;
  final Map<String, String> body;

  @override
  State<RowCell> createState() => _RowCellState();
}

class _RowCellState extends State<RowCell> {

  ValueNotifier<String> _valueNotifier = ValueNotifier("");

  @override
  void initState() {
    _valueNotifier.value = "${widget.message.rows[widget.index].row[widget.subIndex].value ?? ""}";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    switch(widget.tableHeader.data.columns[widget.subIndex].dataType.toLowerCase()) {
      case "text" : return buildContainer(child: widget.selectedCell == widget.index && widget.message.rows[widget.index].row[widget.subIndex].writeEnabled
          ? buildTextFormField(context)
          : Text(
        _valueNotifier.value.isEmpty ? StringConstants.notAvailable : _valueNotifier.value,softWrap: true,overflow: TextOverflow.ellipsis,
        style: TextStyle(
            color: GlobalMethods.getColor(
                widget.message.rows[widget.index].row[widget.subIndex].cellTextColour),
            fontWeight: FontWeight.bold),
      )
      );
      case "number" : return buildContainer(
        child: widget.selectedCell == widget.index && widget.message.rows[widget.index].row[widget.subIndex].writeEnabled
            ? buildTextFormField(context)
            : Text(
          _valueNotifier.value.isEmpty ? StringConstants.notAvailable : _valueNotifier.value,
          style: TextStyle(
              color: GlobalMethods.getColor(
                  widget.message.rows[widget.index].row[widget.subIndex].cellTextColour),
              fontWeight: FontWeight.bold),
        ),
      );
      case "hyperlink" : return buildContainer(
          child: TextButton(
              child: Text(_valueNotifier.value.isEmpty ? StringConstants.notAvailable : _valueNotifier.value,style: const TextStyle(color: Colors.blue)),
            onPressed: (){launchUrl(Uri.parse(widget.message.rows[widget.index].row[widget.subIndex].href ?? ""));},
          )
      );
      case "datetime" : return buildContainer(
        child: widget.selectedCell == widget.index && widget.message.rows[widget.index].row[widget.subIndex].writeEnabled
            ? ValueListenableBuilder<String>(
            valueListenable: _valueNotifier,
            builder: (context, snapshot,w) {
                return TextFormField(
                  controller: TextEditingController(text: snapshot),
          style: TextStyle(
                  fontSize: 14,
                  color: GlobalMethods.getColor(widget.message.rows[widget.index].row[widget.subIndex].cellTextColour)),
          readOnly: true,
          decoration: InputDecoration(
                hintText: "Select Date",
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.zero),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.grey.withOpacity(.4)),
                      borderRadius: BorderRadius.zero),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 0)),
          onTap: () async {
                final abc = await showOmniDateTimePicker(context: context);
                for (var element in widget.message.update!.identifiers) {
                  if(element.mandatory == true) {
                    for(var x in widget.message.rows[widget.index].row) {
                      if(x.key == element.fieldNameInTable) {
                        widget.body[element.fieldNameInActionApi] = x.value ?? "";
                      }
                    }
                  }
                  if(element.fieldNameInTable.toLowerCase() == widget.message.rows[widget.index].row[widget.subIndex].key.toLowerCase()) {
                    widget.body[element.fieldNameInActionApi] = "${abc!.year}-${abc.month}-${abc.day}+${abc.hour}:${abc.minute}:${abc.second}";
                    _valueNotifier.value = "${abc.year}-${abc.month}-${abc.day} ${abc.hour}:${abc.minute}:${abc.second}";
                  }
                }
                print("body ${widget.body}");
          },
        );
              }
            )
            : Text(
          _valueNotifier.value.isEmpty ? StringConstants.notAvailable : _valueNotifier.value,
          style: TextStyle(
              color: GlobalMethods.getColor(
                  widget.message.rows[widget.index ].row[widget.subIndex].cellTextColour!),
              fontWeight: FontWeight.bold),
        ),
      );
      case "date" : return buildContainer(
        child: widget.selectedCell == widget.index && widget.message.rows[widget.index].row[widget.subIndex].writeEnabled
            ? ValueListenableBuilder<String>(
              valueListenable: _valueNotifier,
              builder: (context, snapshot,w) {
                return TextFormField(
          controller: TextEditingController(text: snapshot),
          style: TextStyle(
                  fontSize: 14,
                  color: GlobalMethods.getColor(widget.message.rows[widget.index].row[widget.subIndex].cellTextColour)),
          readOnly: true,
          decoration: InputDecoration(
                  hintText: "Select Date",
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.zero),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.grey.withOpacity(.4)),
                      borderRadius: BorderRadius.zero),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 0)),
          onTap: () async {
                final abc = await showOmniDateTimePicker(context: context,type: OmniDateTimePickerType.date);
                for (var element in widget.message.update!.identifiers) {
                  if(element.mandatory == true) {
                    for(var x in widget.message.rows[widget.index].row) {
                      if(x.key == element.fieldNameInTable) {
                        widget.body[element.fieldNameInActionApi] = x.value ?? "";
                      }
                    }
                  }
                  if(element.fieldNameInTable.toLowerCase() == widget.message.rows[widget.index].row[widget.subIndex].key.toLowerCase()) {
                    widget.body[element.fieldNameInActionApi] = "${abc!.year}-${abc.month}-${abc.day}";
                    _valueNotifier.value = "${abc.year}-${abc.month}-${abc.day}";
                  }
                }
                print("body ${widget.body}");
          },
          // initialValue: snapshot,
        );
              }
            )
            : Text(
          _valueNotifier.value.isEmpty ? StringConstants.notAvailable : _valueNotifier.value,
          style: TextStyle(
              color: GlobalMethods.getColor(
                  widget.message.rows[widget.index ].row[widget.subIndex].cellTextColour!),
              fontWeight: FontWeight.bold),
        ),
      );
      case "dropdown" : return buildContainer(
        child: widget.selectedCell == widget.index && widget.message.rows[widget.index].row[widget.subIndex].writeEnabled
            ? DropdownButtonFormField<String>(
          items: widget.tableHeader.data.columns[widget.subIndex].writeOptions.options.supportedValues!.map((e) => DropdownMenuItem(value: e.toString(),child: Text(e.toString()),)).toList(),
          value: _valueNotifier.value,
          onChanged: (val){
            for (var element in widget.message.update!.identifiers) {
              if(element.mandatory == true) {
                for(var x in widget.message.rows[widget.index].row) {
                  if(x.key == element.fieldNameInTable) {
                    widget.body[element.fieldNameInActionApi] = x.value ?? "";
                  }
                }
              }
              if(element.fieldNameInTable.toLowerCase() == widget.message.rows[widget.index].row[widget.subIndex].key.toLowerCase()) {
                widget.body[element.fieldNameInActionApi] = val!;
                _valueNotifier.value = val;
              }
            }
            print("body ${widget.body}");
          },
          style: TextStyle(
              fontSize: 14,
              color: GlobalMethods.getColor(widget.message.rows[widget.index].row[widget.subIndex].cellTextColour)),
          decoration: InputDecoration(
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.zero),
              enabledBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: Colors.grey.withOpacity(.4)),
                  borderRadius: BorderRadius.zero),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 5, vertical: 0)),
        )
            : Text(
          _valueNotifier.value.isEmpty ? StringConstants.notAvailable : _valueNotifier.value,
          style: TextStyle(
              color: GlobalMethods.getColor(
                  widget.message.rows[widget.index ].row[widget.subIndex].cellTextColour!),
              fontWeight: FontWeight.bold),
        ),
      );

      case "autosuggest" : return buildContainer(
        child: widget.selectedCell == widget.index && widget.message.rows[widget.index].row[widget.subIndex].writeEnabled
            ? Autocomplete(
          fieldViewBuilder: (context, textEditingController, focus, onSubmit) => TextFormField(
            cursorHeight: 16,
            onTap: (){
              textEditingController.clear();
            },
            controller: textEditingController,
            focusNode: focus,
            onFieldSubmitted: (val) => onSubmit,
            decoration: InputDecoration(
              hintText: "Search Here",
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.zero),
              enabledBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: Colors.grey.withOpacity(.4)),
                  borderRadius: BorderRadius.zero),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
            ),
          ),
          optionsBuilder: (val) async {
            List<String> list = [];
            final res = await GlobalMethods.getRequest('${widget.tableHeader.data.columns[widget.subIndex].filterData.autoSuggestLink}[["name","like","%25${val.text}%25"]]');
            final dataList = jsonDecode(res.body)["data"];
            for(var x in dataList) {
              list.add(x["name"]);
            }
            return list;
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
                  child: ListView.separated(
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
                            func(itr.elementAt(index));
                            for (var element in widget.message.update!.identifiers) {
                              if(element.mandatory == true) {
                                for(var x in widget.message.rows[widget.index].row) {
                                  if(x.key == element.fieldNameInTable) {
                                    widget.body[element.fieldNameInActionApi] = x.value ?? "";
                                  }
                                }
                              }
                              if(element.fieldNameInTable.toLowerCase() == widget.message.rows[widget.index].row[widget.subIndex].key.toLowerCase()) {
                                widget.body[element.fieldNameInActionApi] = itr.elementAt(index);
                                _valueNotifier.value = itr.elementAt(index);
                              }
                            }
                            print("body ${widget.body}");
                          },
                          title: Text(itr.elementAt(index))))
                      ),
            ),
          ),
        )
            : Text(
          _valueNotifier.value.isEmpty ? StringConstants.notAvailable : _valueNotifier.value,
          style: TextStyle(
              color: GlobalMethods.getColor(
                  widget.message.rows[widget.index ].row[widget.subIndex].cellTextColour!),
              fontWeight: FontWeight.bold),
        ),
      );

      default : return buildContainer(
        child: widget.selectedCell == widget.index && widget.message.rows[widget.index].row[widget.subIndex].writeEnabled
            ? buildTextFormField(context)
            : Text(
          _valueNotifier.value.isEmpty ? StringConstants.notAvailable : _valueNotifier.value,
          style: TextStyle(
              color: GlobalMethods.getColor(
                  widget.message.rows[widget.index].row[widget.subIndex].cellTextColour!),
              fontWeight: FontWeight.bold),
        ),
      );
    }
  }

  ValueListenableBuilder buildTextFormField(BuildContext context) {
    return ValueListenableBuilder<String>(
        valueListenable: _valueNotifier,
        builder: (context, snapshot,w) {
        return TextFormField(
          controller: TextEditingController(text: snapshot),
            onChanged: (val) {
              for (var element in widget.message.update!.identifiers) {
                if(element.mandatory == true) {
                  for(var x in widget.message.rows[widget.index].row) {
                    if(x.key == element.fieldNameInTable) {
                      widget.body[element.fieldNameInActionApi] = x.value ?? "";
                    }
                  }
                }
                if(element.fieldNameInTable.toLowerCase() == widget.message.rows[widget.index].row[widget.subIndex].key.toLowerCase()) {
                  widget.body[element.fieldNameInActionApi] = val;
                  _valueNotifier.value = val;
                }
              }
              print("body ${widget.body}");
            },
            style: TextStyle(
                fontSize: 14,
                color: GlobalMethods.getColor(widget.message.rows[widget.index].row[widget.subIndex].cellTextColour)),
            decoration: InputDecoration(
                hintText: "Write Here",
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.zero),
                enabledBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.grey.withOpacity(.4)),
                    borderRadius: BorderRadius.zero),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                suffixIcon: InkWell(onTap: (){
                  showDialog(context: context, builder: (context) => AlertDialog(
                    content: TextFormField(
                      controller: TextEditingController(text: snapshot),
                      onChanged: (val){
                        for (var element in widget.message.update!.identifiers) {
                          if(element.mandatory == true) {
                            for(var x in widget.message.rows[widget.index].row) {
                              if(x.key == element.fieldNameInTable) {
                                widget.body[element.fieldNameInActionApi] = x.value ?? "";
                              }
                            }
                          }
                          if(element.fieldNameInTable.toLowerCase() == widget.message.rows[widget.index].row[widget.subIndex].key.toLowerCase()) {
                            widget.body[element.fieldNameInActionApi] = val;
                            _valueNotifier.value = val;
                          }
                        }
                        print("body ${widget.body}");
                      },
                      decoration: InputDecoration(
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.zero),
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.grey.withOpacity(.4)),
                              borderRadius: BorderRadius.zero)
                      ),
                      maxLines: 5,
                    ),
                    contentPadding: EdgeInsets.fromLTRB(15, 15, 15, 5),
                    actions: [
                      ElevatedButton(
                          onPressed: (){
                            Navigator.pop(context);
                      }, child: const Text("Done",style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ));
                },child: const Icon(Icons.edit_note_rounded),)
            ),
          );
      }
    );
  }

  Container buildContainer({required Widget child}) {
    return Container(
      width: widget.cellSize,
      padding: widget.selectedCell == widget.index && widget.message.rows[widget.index].row[widget.subIndex].writeEnabled
          ? const EdgeInsets.symmetric(vertical: 5, horizontal: 5) : const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      // height: 40,
      decoration: BoxDecoration(
          color: widget.isSelected ? const Color(0xFFA8A7A7) : GlobalMethods.getColor(widget.message.rows[widget.index + ((widget.activePage - 1) * widget.rowsPerPage)].row[widget.subIndex].cellFillColour),
          border: Border(right: BorderSide(color: Colors.grey.shade300))),
      child: child,
    );
  }
}