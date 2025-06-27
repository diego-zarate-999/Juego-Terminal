import 'dart:core';
import 'card_cancel.dart';

class PharosCancelRequest{
  String tranType;
  String date;
  String referenceNumber;
  String stan;
  String currency;
  String amount;
  CardCancel card;
  String orderNumber;
  String terminalCode;
  String merchantCode;
  String sourceIp;
  String fda;
  String posEnvironment;


  PharosCancelRequest({
    required this.tranType,
    required this.date,
    required this.referenceNumber,
    required this.stan,
    required this.currency,
    required this.amount,
    required this.card,
    required this.orderNumber,
    required this.terminalCode,
    required this.merchantCode,
    required this.sourceIp,
    required this.fda,
    required this.posEnvironment,
  });

}