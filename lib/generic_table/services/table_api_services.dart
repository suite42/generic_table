import 'dart:convert';
import 'package:generic_ledger/generic_table/generic_model/api_response_model.dart';
import 'package:generic_ledger/generic_table/table_body/models/table_row_data_model.dart';
import 'package:generic_ledger/generic_table/table_header/models/generic_table_model.dart';
import 'package:generic_ledger/utils/global_methods.dart';
import 'package:generic_ledger/utils/string_constants.dart';

class ApiServices {

  Future<ApiResponseModel> getTableList() async {
    
    try {
      final res = await GlobalMethods.getRequest(StringConstants.headerUrl);
      // print(res.body);
      if(res.statusCode == 200) {
        return ApiResponseModel(status: res.statusCode, message: "message", data: genericTableModelFromJson(res.body));
      } else {
        return ApiResponseModel(status: res.statusCode, message: "message", data: jsonDecode(res.body)["readable_message"]);
      }
    } on Exception catch (e) {
      rethrow;
    }

  }

  Future<ApiResponseModel> getTableRows({required String baseUrl, List<List<String>>? filters, String? sortBy,required int length}) async {

    String url = "$baseUrl?";

    url += "${filters != null && filters.isNotEmpty ? "filters=${jsonEncode(filters)}" : ""}&limit_page_length=$length&orderBy=${sortBy ?? ""}";

    print(url);
    final res = await GlobalMethods.getRequest(url);

    // print(res.body);

    if(res.statusCode == 200) {
      return ApiResponseModel(status: res.statusCode, message: "Success", data: tableRowDataModelFromJson(res.body));
    } else {
      return ApiResponseModel(status: res.statusCode, message: jsonDecode(res.body)["readable_message"], data: res.body);
    }

  }

  Future<ApiResponseModel> actionApiCall({required String baseUrl, required Map<String, dynamic> body}) async {

    try {
      final res = await GlobalMethods.postRequest(baseUrl,body);

      // print(res.body);
      if(res.statusCode == 200) {
        return ApiResponseModel(status: res.statusCode, message: "message", data: "");
      } else {
        return ApiResponseModel(status: res.statusCode, message: "message", data: jsonDecode(res.body)['readable_message']);
      }
    } on Exception catch (e) {
      rethrow;
    }
  }

}