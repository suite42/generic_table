part of '../bloc/payment_bloc.dart';

abstract class PaymentsState extends Equatable {}

class PaymentsInitialState extends PaymentsState {
  @override
  List<Object?> get props => throw UnimplementedError();

}

class PaymentsLoadingState extends PaymentsState {
  @override
  List<Object?> get props => throw UnimplementedError();

}

class PaymentsLoadedState extends PaymentsState {
  final int status;

  PaymentsLoadedState(this.status);
  @override
  List<Object?> get props => throw UnimplementedError();

}

class PaymentsErrorState extends PaymentsState {
  final String message;

  PaymentsErrorState(this.message);
  @override
  List<Object?> get props => throw UnimplementedError();

}