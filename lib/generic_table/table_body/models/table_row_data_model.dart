import 'dart:convert';

TableRowDataModel tableRowDataModelFromJson(String str) => TableRowDataModel.fromJson(json.decode(str));

String tableRowDataModelToJson(TableRowDataModel data) => json.encode(data.toJson());

class TableRowDataModel {
  TableBodyMessage message;

  TableRowDataModel({
    required this.message,
  });

  factory TableRowDataModel.fromJson(Map<String, dynamic> json) => TableRowDataModel(
    message: TableBodyMessage.fromJson(json["message"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message.toJson(),
  };
}

class TableBodyMessage {
  List<MessageRow> rows;
  Update? update;

  TableBodyMessage({
    required this.rows,
    required this.update,
  });

  factory TableBodyMessage.fromJson(Map<String, dynamic> json) => TableBodyMessage(
    rows: List<MessageRow>.from(json["rows"].map((x) => MessageRow.fromJson(x))),
    update: json["update"] == null ? null : Update.fromJson(json["update"]),
  );

  Map<String, dynamic> toJson() => {
    "rows": List<dynamic>.from(rows.map((x) => x.toJson())),
  };
}

class MessageRow {
  List<GenericTableRow> row;
  List<ActionElement>? action;

  MessageRow({
    required this.row,
    required this.action,
  });

  factory MessageRow.fromJson(Map<String, dynamic> json) => MessageRow(
    row: List<GenericTableRow>.from(json["row"].map((x) => GenericTableRow.fromJson(x))),
    action: json["action"] == null ? null : List<ActionElement>.from(json["action"].map((x) => ActionElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "row": List<dynamic>.from(row.map((x) => x.toJson())),
    "action": List<dynamic>.from(action!.map((x) => x)),
  };
}

class GenericTableRow {
  String key;
  var value;
  String? href;
  String cellFillColour;
  String cellTextColour;
  bool writeEnabled;

  GenericTableRow({
    required this.key,
    required this.value,
    required this.cellFillColour,
    required this.cellTextColour,
    required this.writeEnabled,
    required this.href,
  });

  factory GenericTableRow.fromJson(Map<String, dynamic> json) => GenericTableRow(
    key: json["key"],
    value: json["value"],
    cellFillColour: json["cell_fill_colour"],
    href: json["href"],
    cellTextColour: json["cell_text_colour"],
    writeEnabled: json["write_enabled"],
  );

  Map<String, dynamic> toJson() => {
    "key": key,
    "value": value,
    "cell_fill_colour": cellFillColour,
    "cell_text_colour": cellTextColour,
    "write_enabled": writeEnabled,
  };
}

class ActionElement {
  String action;

  ActionElement({
    required this.action,
  });

  factory ActionElement.fromJson(Map<String, dynamic> json) => ActionElement(
    action: json["action"],
  );

  Map<String, dynamic> toJson() => {
    "action": action,
  };
}

class Update {
  String actionApi;
  String actionApiRequestType;
  List<Identifier> identifiers;

  Update({
    required this.actionApi,
    required this.actionApiRequestType,
    required this.identifiers,
  });

  factory Update.fromJson(Map<String, dynamic> json) => Update(
    actionApi: json["action_api"],
    actionApiRequestType: json["action_api_request_type"],
    identifiers: List<Identifier>.from(json["fields"].map((x) => Identifier.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "action_api": actionApi,
    "action_api_request_type": actionApiRequestType,
    "fields": List<dynamic>.from(identifiers.map((x) => x.toJson())),
  };
}

class Identifier {
  String fieldNameInTable;
  String fieldNameInActionApi;
  bool? mandatory;

  Identifier({
    required this.fieldNameInTable,
    required this.fieldNameInActionApi,
    this.mandatory,
  });

  factory Identifier.fromJson(Map<String, dynamic> json) => Identifier(
    fieldNameInTable: json["field_name_in_table"],
    fieldNameInActionApi: json["field_name_in_action_api"],
    mandatory: json["mandatory"],
  );

  Map<String, dynamic> toJson() => {
    "field_name_in_table": fieldNameInTable,
    "field_name_in_action_api": fieldNameInActionApi,
    "mandatory": mandatory,
  };
}