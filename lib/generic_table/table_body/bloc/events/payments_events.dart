part of '../bloc/payment_bloc.dart';

abstract class PaymentsEvent extends Equatable {}

class PaymentsActionEvent extends PaymentsEvent {

  final String baseUrl;
  final Map<String, dynamic> body;

  PaymentsActionEvent(this.baseUrl, this.body);

  @override
  List<Object?> get props => [];

}