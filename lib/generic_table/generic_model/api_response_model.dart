
// To parse this JSON data, do
//
//     final apiResponseModel = apiResponseModelFromJson(jsonString);

import 'dart:convert';

ApiResponseModel apiResponseModelFromJson(String str) => ApiResponseModel.fromJson(json.decode(str));

String apiResponseModelToJson(ApiResponseModel data) => json.encode(data.toJson());

class ApiResponseModel {
  int status;
  String message;
  // ignore: prefer_typing_uninitialized_variables
  var data;

  ApiResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ApiResponseModel.fromJson(Map<String, dynamic> json) => ApiResponseModel(
    status: json["status"],
    message: json["message"],
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data,
  };
}
