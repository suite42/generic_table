// To parse this JSON data, do
//
//     final genericTableModel = genericTableModelFromJson(jsonString);

import 'dart:convert';

GenericTableModel genericTableModelFromJson(String str) => GenericTableModel.fromJson(json.decode(str));

String genericTableModelToJson(GenericTableModel data) => json.encode(data.toJson());

class GenericTableModel {
  Message message;

  GenericTableModel({
    required this.message,
  });

  factory GenericTableModel.fromJson(Map<String, dynamic> json) => GenericTableModel(
    message: Message.fromJson(json["message"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message.toJson(),
  };
}

class Message {
  List<TableHeader> tables;

  Message({
    required this.tables,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    tables: List<TableHeader>.from(json["tables"].map((x) => TableHeader.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "tables": List<dynamic>.from(tables.map((x) => x.toJson())),
  };
}

class TableHeader {
  String tableName;
  List<int> perPageEntryOptions;
  int totalRows;
  int rowsPerPage;
  String defaultSort;
  Data data;
  Map<String,dynamic>? actions;
  String actionApi;

  TableHeader({
    required this.tableName,
    required this.perPageEntryOptions,
    required this.totalRows,
    required this.rowsPerPage,
    required this.defaultSort,
    required this.data,
    required this.actionApi,
    this.actions,
  });

  factory TableHeader.fromJson(Map<String, dynamic> json) {
    return TableHeader(
      tableName: json["table_name"],
      perPageEntryOptions: List<int>.from(json["per_page_entry_options"].map((x) => x)),
      totalRows: json["total_rows"],
      rowsPerPage: json["rows_per_page"],
      defaultSort: json["default_sort"],
      data: Data.fromJson(json["data"]),
      actionApi: json["action_api"],
      actions: json["actions"],
    );
  }

  Map<String, dynamic> toJson() => {
    "table_name": tableName,
    "per_page_entry_options": List<dynamic>.from(perPageEntryOptions.map((x) => x)),
    "total_rows": totalRows,
    "rows_per_page": rowsPerPage,
    "action_api": actionApi,
    "data": data.toJson(),
  };
}

class Data {
  List<TableColumn> columns;
  List<SubRow>? subRow;
  SubRowActionApi? subRowActionApi;

  Data({
    required this.columns,
    required this.subRow,
    required this.subRowActionApi,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    columns: List<TableColumn>.from(json["columns"].map((x) => TableColumn.fromJson(x))),
    subRow: json["sub_row"] == null ? null : List<SubRow>.from(json["sub_row"].map((x) => SubRow.fromJson(x))),
    subRowActionApi: json["sub_row_action_api"] == null ? null : SubRowActionApi.fromJson(json["sub_row_action_api"]),
  );

  Map<String, dynamic> toJson() => {
    "columns": List<dynamic>.from(columns.map((x) => x.toJson())),
    "sub_row": List<dynamic>.from(subRow!.map((x) => x.toJson())),
    "sub_row_action_api": subRowActionApi!.toJson(),
  };
}

class TableColumn {
  String key;
  String displayName;
  bool hidden;
  String dataType;
  double cellWidth;
  FilterData filterData;
  Sort sort;
  WriteOptions writeOptions;

  TableColumn({
    required this.key,
    required this.displayName,
    required this.hidden,
    required this.cellWidth,
    required this.dataType,
    required this.filterData,
    required this.sort,
    required this.writeOptions,
  });

  factory TableColumn.fromJson(Map<String, dynamic> json) => TableColumn(
    key: json["key"],
    displayName: json["display_name"],
    hidden: json["hidden"],
    dataType: json["data_type"],
    cellWidth: json["cell_width"] ?? 150,
    filterData: FilterData.fromJson(json["filter_data"]),
    sort: Sort.fromJson(json["sort"]),
    writeOptions: WriteOptions.fromJson(json["write_options"]),
  );

  Map<String, dynamic> toJson() => {
    "key": key,
    "display_name": displayName,
    "hidden": hidden,
    "data_type": dataType,
    "filter_data": filterData.toJson(),
    "sort": sort.toJson(),
    "write_options": writeOptions.toJson(),
  };
}

class FilterData {
  String defaultFilterType;
  List<String> supportedFilters;
  bool filterEnabled;
  dynamic autoSuggestLink;
  String? autoSuggestKey;

  FilterData({
    required this.defaultFilterType,
    required this.supportedFilters,
    required this.filterEnabled,
    required this.autoSuggestLink,
    this.autoSuggestKey,
  });

  factory FilterData.fromJson(Map<String, dynamic> json) => FilterData(
    defaultFilterType: json["default_filter_type"],
    supportedFilters: List<String>.from(json["supported_filters"].map((x) => x)),
    filterEnabled: json["filter_enabled"],
    autoSuggestLink: json["auto_suggest_link"],
    autoSuggestKey: json["auto_suggest_key"],
  );

  Map<String, dynamic> toJson() => {
    "default_filter_type": defaultFilterType,
    "supported_filters": List<dynamic>.from(supportedFilters.map((x) => x)),
    "filter_enabled": filterEnabled,
    "auto_suggest_link": autoSuggestLink,
  };
}

class Sort {
  bool sortEnabled;

  Sort({
    required this.sortEnabled,
  });

  factory Sort.fromJson(Map<String, dynamic> json) => Sort(
    sortEnabled: json["sort_enabled"],
  );

  Map<String, dynamic> toJson() => {
    "sort_enabled": sortEnabled,
  };
}

class WriteOptions {
  bool? writeOptionsDefault;
  bool allowNull;
  bool writeEnabledForNewRow;
  Options options;

  WriteOptions({
    required this.writeOptionsDefault,
    required this.allowNull,
    required this.writeEnabledForNewRow,
    required this.options,
  });

  factory WriteOptions.fromJson(Map<String, dynamic> json) => WriteOptions(
    writeOptionsDefault: json["default"],
    allowNull: json["allow_null"],
    writeEnabledForNewRow: json["write_enabled_for_new_row"],
    options: Options.fromJson(json["options"]),
  );

  Map<String, dynamic> toJson() => {
    "default": writeOptionsDefault,
    "allow_null": allowNull,
    "write_enabled_for_new_row": writeEnabledForNewRow,
    "options": options.toJson(),
  };
}

class Options {
  int? minLength;
  int? maxLength;
  int? min;
  int? max;
  List? supportedValues;

  Options({
    this.minLength,
    this.maxLength,
    this.min,
    this.max,
    this.supportedValues,
  });

  factory Options.fromJson(Map<String, dynamic> json) => Options(
    minLength: json["min_length"],
    maxLength: json["max_length"],
    min: json["min"],
    max: json["max"],
    supportedValues: json["support_values"],
  );

  Map<String, dynamic> toJson() => {
    "min_length": minLength,
    "max_length": maxLength,
    "min": min,
    "max": max,
  };
}

class Action {
  String actionName;
  String imageUrl;
  String actionType;
  String actionApi;
  String actionApiRequestType;
  List<ActionApiField> actionApiFields;

  Action({
    required this.actionName,
    required this.imageUrl,
    required this.actionType,
    required this.actionApi,
    required this.actionApiRequestType,
    required this.actionApiFields,
  });

  factory Action.fromJson(Map<String, dynamic> json) => Action(
    actionName: json["action_name"],
    imageUrl: json["image_url"],
    actionType: json["action_type"],
    actionApi: json["action_api"],
    actionApiRequestType: json["action_api_request_type"],
    actionApiFields: List<ActionApiField>.from(json["action_api_fields"].map((x) => ActionApiField.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "action_name": actionName,
    "image_url": imageUrl,
    "action_type": actionType,
    "action_api": actionApi,
    "action_api_request_type": actionApiRequestType,
    "action_api_fields": List<dynamic>.from(actionApiFields.map((x) => x.toJson())),
  };
}

class ActionApiField {
  String fieldNameInTable;
  String fieldNameInActionApi;
  bool editable;
  String dataType;
  bool mandatory;
  String paramType;

  ActionApiField({
    required this.fieldNameInTable,
    required this.fieldNameInActionApi,
    required this.editable,
    required this.dataType,
    required this.mandatory,
    required this.paramType,
  });

  factory ActionApiField.fromJson(Map<String, dynamic> json) => ActionApiField(
    fieldNameInTable: json["field_name_in_table"],
    fieldNameInActionApi: json["field_name_in_action_api"],
    editable: json["editable"],
    dataType: json["data_type"],
    mandatory: json["mandatory"],
    paramType: json["param_type"],
  );

  Map<String, dynamic> toJson() => {
    "field_name_in_table": fieldNameInTable,
    "field_name_in_action_api": fieldNameInActionApi,
    "editable": editable,
    "data_type": dataType,
    "mandatory": mandatory,
    "param_type": paramType,
  };
}

class SubRow {
  String key;
  String? displayName;
  String? dataType;
  bool primaryKey;

  SubRow({
    required this.key,
    this.displayName,
    this.dataType,
    required this.primaryKey,
  });

  factory SubRow.fromJson(Map<String, dynamic> json) => SubRow(
    key: json["key"],
    displayName: json["display_name"],
    dataType: json["data_type"],
    primaryKey: json["primary_key"],
  );

  Map<String, dynamic> toJson() => {
    "key": key,
    "display_name": displayName,
    "primary_key": primaryKey,
    "data_type": dataType,
  };
}

class SubRowActionApi {
  String subRowApi;
  List<ActionApiField> actionApiFields;

  SubRowActionApi({
    required this.subRowApi,
    required this.actionApiFields,
  });

  factory SubRowActionApi.fromJson(Map<String, dynamic> json) => SubRowActionApi(
    subRowApi: json["sub_row_api"],
    actionApiFields: List<ActionApiField>.from(json["action_api_fields"].map((x) => ActionApiField.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "sub_row_api": subRowApi,
    "action_api_fields": List<dynamic>.from(actionApiFields.map((x) => x.toJson())),
  };
}