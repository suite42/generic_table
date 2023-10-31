part of '../bloc/table_body_bloc.dart';

abstract class TableRowStates extends Equatable {}

class TableRowInitialState extends TableRowStates {
  @override
  List<Object?> get props => [];
}

class TableRowLoadingState extends TableRowStates {
  @override
  List<Object?> get props => [];
}

class TableRowLoadedState extends TableRowStates {

  final TableRowDataModel tableRowDataModel;

  TableRowLoadedState(this.tableRowDataModel);
  
  @override
  List<Object?> get props => [];
}

class TableRowErrorState extends TableRowStates {
  TableRowErrorState(this.message);

  final String message;

  @override
  List<Object?> get props => [];
}

class TableRowNoDataState extends TableRowStates {
  @override
  List<Object?> get props => [];
}