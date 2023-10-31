part of '../bloc/table_bloc.dart';

abstract class TableEvents extends Equatable {}

class FetchTableDataEvent extends TableEvents {
  @override
  List<Object?> get props => [];
}

class SendTableDataEvent extends TableEvents {
  @override
  List<Object?> get props => [];

}

class FetchTableList extends TableEvents {
  @override
  // TODO: implement props
  List<Object?> get props => [];

}

class UpdateTable extends TableEvents {
  final String url;
  final Map<String, dynamic> body;

  UpdateTable(this.url, this.body);
  @override
  List<Object?> get props => [];

}

class FetchTableRows extends TableEvents {
  @override
  // TODO: implement props
  List<Object?> get props => [];

}