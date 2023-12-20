import 'package:flutter/material.dart';

class ExpansionMeta {
  ExpansionMeta({required this.isExpended,required this.body,required this.header});
  bool isExpended;
  Widget header;
  Widget body;
}