import 'package:generic_ledger/generic_table/filters/filter_model.dart';

class ColumnMeta {
  ColumnMeta({required this.width,required this.fixedWidth, required this.isFreezed,required this.localFilterData, required this.isSelected, required this.isHover, required this.sortEnabled});
  double width;
  double fixedWidth;
  bool isFreezed;
  Filter localFilterData;
  bool sortEnabled;
  bool isHover;
  bool isSelected;
}