import 'dart:core';

//TODO resolver variable posEnvironment dinamicamente segun el tipo de terminal
class PharosSaleRequest{
  String tranType;
  String date;
  final String posEnvironment = "attended";
  String amount;
  String currency;
  String orderNumber;
  String terminalCode;
  String merchantCode;
  bool isSale;


  PharosSaleRequest(
        this.date,
        this.amount,
        this.currency,
        this.orderNumber,
        this.terminalCode,
        this.merchantCode,
        this.isSale
        ): tranType = isSale? "SALE" : "REFUND";

  Map<String, dynamic> toJson() {
    return {
      'tran_type': tranType,
      'date': date,
      'pos_environment': posEnvironment,
      'amount': amount,
      'currency': currency,
      'order_number': orderNumber,
      'terminal_code': terminalCode,
      'merchant_code': merchantCode,

    };
  }

}
