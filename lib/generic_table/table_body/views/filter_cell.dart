import 'package:flutter/material.dart';
import 'package:generic_ledger/generic_table/table_header/models/generic_table_model.dart';

class FilterCell extends StatelessWidget {
  const FilterCell({
    super.key,
    required this.columnSize,
    required this.controller,
    required this.tableHeader, required this.index, required this.onChanged,
  });

  final double columnSize;
  final TextEditingController controller;
  final ValueNotifier<TableHeader?> tableHeader;
  final int index;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: columnSize,
      height: 40,
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 7),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              right: BorderSide(color: Colors.grey.withOpacity(.3)),
              top: BorderSide(color: Colors.grey.withOpacity(.3)))),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(10)),
            disabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            filled: true,
            hintStyle: const TextStyle(fontSize: 14),
            hintText:
            tableHeader.value!.data.columns[index].filterData.supportedFilters.isNotEmpty
                ? "Type here"
                : "N/A",
            fillColor: Colors.grey.shade100),
        enabled: tableHeader.value!.data.columns[index].filterData.supportedFilters.isNotEmpty,
        cursorHeight: 14,
        onChanged: onChanged,
      ),
    );
  }
}