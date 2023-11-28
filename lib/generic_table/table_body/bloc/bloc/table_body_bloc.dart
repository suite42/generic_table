import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:generic_ledger/generic_table/services/table_api_services.dart';
import 'package:generic_ledger/generic_table/table_body/models/table_row_data_model.dart';

part '../events/table_body_events.dart';
part '../states/table_body_states.dart';

class TableBodyBloc extends Bloc<TableRowEvents, TableRowStates> {

  final ApiServices _apiServices = ApiServices();

  TableBodyBloc() : super(TableRowInitialState()){
    print("bloc Init");
    on<FetchTableRowDataEvent>((event, emit) async {
      emit(TableRowLoadingState());
      final res = await _apiServices.getTableRows(filters: event.filters,sortBy: event.sortBy,length: event.length, baseUrl: event.baseUrl);
      res.status == 200 ? emit(TableRowLoadedState(res.data)) : emit(TableRowErrorState(res.message));
    });

    // on<FilterTableRowEvent>((event, emit) async {
    //   emit(TableRowLoadingState());
    //   final res = await _apiServices.getTableList();
    //   res.status == 200 ? emit(TableRowLoadedState(res.data)) : emit(TableRowErrorState(res.data));
    // });

  }


}