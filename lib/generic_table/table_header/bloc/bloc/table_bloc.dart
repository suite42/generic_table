import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:generic_ledger/generic_table/services/table_api_services.dart';
import 'package:generic_ledger/generic_table/table_header/models/generic_table_model.dart';

part '../events/table_events.dart';
part '../states/table_states.dart';

class TableBloc extends Bloc<TableEvents, TableStates> {

  final ApiServices _apiServices = ApiServices();

  TableBloc() : super(TableInitialState()){
    on<FetchTableList>((event, emit) async {
      emit(TableLoadingState());
      final res = await _apiServices.getTableList();
      res.status == 200 ? emit(TableLoadedState(res.data)) : emit(TableErrorState(res.data));
    });

    on<UpdateTable>((event, emit) async {
      emit(TableUpdateInitialState());
      final res = await _apiServices.actionApiCall(baseUrl: event.url, body: event.body);
      res.status == 200 ? emit(TableUpdateState("Changes Saved")) : emit(TableUpdateErrorState("${res.data} -  Changes not saved "));
    });

    on<SendTableDataEvent>((event, emit) {
      emit(TableLoadingState());
    });
  }


}