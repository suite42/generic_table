import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:generic_ledger/generic_table/table_header/models/generic_table_model.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../../../utils/global_methods.dart';

class FilterCell extends StatelessWidget {
  const FilterCell({
    super.key,
    required this.columnSize,
    required this.controller,
    this.tableColumn,
    this.dataType,
    this.textFieldRadius,
    this.onlyTextField = false,
    required this.onChanged,
    required this.onSubmit,
    this.onTap,
  });

  final double columnSize;
  final TextEditingController controller;
  final TableColumn? tableColumn;
  final String? dataType;
  final bool onlyTextField;
  final double? textFieldRadius;
  final Function(String?) onChanged;
  final Function(String?) onSubmit;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    InputDecoration filterDecoration({String? hint}) {
      double borderRadius = textFieldRadius ?? 10;
      return InputDecoration(
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(borderRadius)),
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(borderRadius)),
          disabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(borderRadius)),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          filled: true,
          hintStyle: const TextStyle(fontSize: 14),
          hintText:
          tableColumn!.filterData.supportedFilters.isNotEmpty
              ? hint ?? "Type here"
              : "N/A",
          fillColor: Colors.grey.shade100);
    }

    return Container(
      width: columnSize,
      height: 40,
      padding: onlyTextField ? const EdgeInsets.symmetric(vertical: 5) : const EdgeInsets.symmetric(vertical: 7, horizontal: 7),
      decoration: onlyTextField ? null : BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey.withOpacity(.3)),
          top: BorderSide(color: Colors.grey.withOpacity(.3)),
          bottom: BorderSide(color: Colors.grey.withOpacity(.3)),
        ),
      ),
      child: getWidget(filterDecoration,context)
    );
  }

  Widget getWidget(InputDecoration Function({String? hint}) filterDecoration,BuildContext context) {
    switch (tableColumn!.dataType.toLowerCase()) {
      case "text" :
        return defaultTextField(filterDecoration());
      case "number" :
        return defaultTextField(filterDecoration());
      case "hyperlink" :
        return defaultTextField(filterDecoration());
      case "date" :
        return TextFormField(
          controller: controller,
          enabled: tableColumn!.filterData.supportedFilters.isNotEmpty,
          readOnly: true,
          decoration: filterDecoration(),
          onTap: () async {
            final abc = await showOmniDateTimePicker(context: context,type: OmniDateTimePickerType.date);
                controller.text = "${abc!.year}-${GlobalMethods.padLeftZero(abc.month)}-${GlobalMethods.padLeftZero(abc.day)}";
                onSubmit("${abc.year}-${abc.month}-${abc.day}");
          },
        );
      case "datetime" :
        return TextFormField(
          controller: controller,
          enabled: tableColumn!.filterData.supportedFilters.isNotEmpty,
          readOnly: true,
          decoration: filterDecoration(),
          onTap: () async {
            final abc = await showOmniDateTimePicker(context: context,type: OmniDateTimePickerType.dateAndTime);
            String val = "${abc!.year}-${GlobalMethods.padLeftZero(abc.month)}-${GlobalMethods.padLeftZero(abc.day)} ${GlobalMethods.padLeftZero(abc.hour)}:${GlobalMethods.padLeftZero(abc.minute)}:${GlobalMethods.padLeftZero(abc.second)}";
            controller.text = val;
            onSubmit(val);
          },
        );
      case "dropdown" :
        return DropdownButtonFormField<String>(
          items: tableColumn!.writeOptions.options.supportedValues!.map((e) =>
              DropdownMenuItem(value: e.toString(), child: Text(e.toString()),)).toList(),
          isExpanded: true,
          value: controller.text.isEmpty ? null : controller.text,
          onChanged: tableColumn!.filterData.supportedFilters.isNotEmpty ? onSubmit : null,
          decoration: filterDecoration(hint: "Select"),
        );
      case "autosuggest" :
        return  Autocomplete(
              fieldViewBuilder: (context, textEditingController, focus, onLocalSubmit) {
                textEditingController.text = controller.text;
                return TextFormField(
                  cursorHeight: 16,
                  onTap: () {
                    textEditingController.clear();
                  },
                  onChanged: onChanged,
                  controller: textEditingController,
                  focusNode: focus,
                  onFieldSubmitted: onSubmit,
                  decoration: filterDecoration(),
                );
              },
              optionsBuilder: (val) async {
                List<String> list = [];
                final res = await GlobalMethods.getRequest(
                    '${tableColumn!.filterData.autoSuggestLink}[["name","like","%25${val.text}%25"]]');
                final dataList = jsonDecode(res.body)["data"];
                for (var x in dataList) {
                  list.add(x["name"]);
                }
                return list;
              },
              optionsViewBuilder: (context, func, itr) =>
                  Align(
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
                              separatorBuilder: (context, index) =>
                                  Container(
                                    height: 1,
                                    color: Colors.grey.withOpacity(.2),
                                  ),
                              itemBuilder: (context, index) =>
                                  ListTile(
                                      dense: true,
                                      tileColor: Colors.white,
                                      onTap: () {
                                        func(itr.elementAt(index));
                                        onSubmit(itr.elementAt(index));
                                      },
                                      title: Text(itr.elementAt(index))))
                      ),
                    ),
                  ),
            );

      default :
        return defaultTextField(filterDecoration());
    }
  }

  TextFormField defaultTextField(InputDecoration filterDecoration) {
    return TextFormField(
        controller: controller,
        decoration: filterDecoration,
        enabled: tableColumn!.filterData.supportedFilters.isNotEmpty,
        cursorHeight: 14,
        onFieldSubmitted: onSubmit,
        onChanged: onChanged,
      );
  }
}
