import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:generic_ledger/generic_table/services/table_api_services.dart';

part "../events/payments_events.dart";
part "../states/payments_states.dart";

class PaymentBloc extends Bloc<PaymentsEvent, PaymentsState> {

  final ApiServices _apiServices = ApiServices();

  PaymentBloc() : super(PaymentsInitialState()) {
    print("bloc Init 2");
    on<PaymentsActionEvent>((event, emit) async {
      emit(PaymentsLoadingState());
      final res = await _apiServices.actionApiCall(baseUrl: event.baseUrl, body: event.body);
      res.status == 200 ? emit(PaymentsLoadedState(res.status)) : emit(PaymentsErrorState(res.data));
    });
  }

}