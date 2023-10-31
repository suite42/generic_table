part of '../bloc/table_bloc.dart';

abstract class TableStates extends Equatable {}

class TableInitialState extends TableStates {
  @override
  List<Object?> get props => [];
}

class TableLoadingState extends TableStates {
  @override
  List<Object?> get props => [];
}

class TableLoadedState extends TableStates {
  
  final GenericTableModel table;

  TableLoadedState(this.table);
  
  @override
  List<Object?> get props => [];
}

class TableErrorState extends TableStates {
  TableErrorState(this.message);

  final String message;

  @override
  List<Object?> get props => [];
}

class TableUpdateState extends TableStates {
  TableUpdateState(this.message);

  final String message;

  @override
  List<Object?> get props => [];
}

class TableUpdateInitialState extends TableStates {

  @override
  List<Object?> get props => [];
}

class TableUpdateErrorState extends TableStates {
  TableUpdateErrorState(this.message);

  final String message;

  @override
  List<Object?> get props => [];
}

class TableNoDataState extends TableStates {
  @override
  List<Object?> get props => [];
}