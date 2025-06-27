import 'dart:core';

//TODO resolver variable posEnvironment dinamicamente segun el tipo de terminal
class PharosVoidRequest{
  String tranType = "VOID";
  String stan;
  String terminalCode;
  String merchantCode;

  PharosVoidRequest(
      this.stan,
      this.terminalCode,
      this.merchantCode
      );

  Map<String, dynamic> toJson() {
    return {
      'tran_type': tranType,
      'stan': stan,
      'terminal_code': terminalCode,
      'merchant_code': merchantCode,

    };
  }

}
