import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:generic_ledger/utils/string_constants.dart';

import 'package:http/http.dart' as http;

class GlobalMethods {

  static Map<String,String> headers = {
    "Authorization" : StringConstants.token,
    "Content-Type" : "application/json"
  };

  static Future<http.Response> getRequest(String url) async {

    Uri uri = Uri.parse(url.trim());

    print("Get Url -$url");
    print("auth token -${StringConstants.token}");

    try {
      final res = await http.get(uri,headers: headers);

      // print(res.body);

      return res;
    } on Exception catch (e) {
      print("Get Exception--- $e");
      rethrow;
    }

  }

  static Future<http.Response> postRequest(String url,Map<String, dynamic> body) async {

    Uri uri = Uri.parse(url.trim());

    print("Post Url -$url");
    // print("Post Body -$body");
    // print(jsonEncode(body));

    try {
      final res = await http.post(uri,headers: headers,body: jsonEncode(body));
      return res;
    } on Exception catch (e) {
      print("Post Exception--- $e");
      rethrow;
    }

  }


  static Color getColor(String str) {
    return Color(int.parse(str.replaceFirst("#", "0xFF", 0)));
  }

  static double getTextLengthInPixels({required String text, TextStyle? style}) {
    final textPainter = TextPainter(
      text: TextSpan(text: text,style: style),
      textDirection: TextDirection.ltr
    );
    textPainter.layout();
    return textPainter.width;
  }

  static String padLeftZero(dynamic value) {
    return value.toString().padLeft(2,'0');
  }

}