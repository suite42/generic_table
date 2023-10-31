part of '../bloc/table_body_bloc.dart';

abstract class TableRowEvents extends Equatable {}

class FetchTableRowDataEvent extends TableRowEvents {
  final List<List<String>>? filters;
  final String? sortBy;
  final String baseUrl;
  final int length;

  FetchTableRowDataEvent({required this.baseUrl, required this.length, this.filters, this.sortBy});
  @override
  List<Object?> get props => [];
}


class FilterTableRowEvent extends TableRowEvents {
  @override
  // TODO: implement props
  List<Object?> get props => [];

}