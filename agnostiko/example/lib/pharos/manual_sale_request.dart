import 'dart:core';
import 'package:agnostiko_example/pharos/sale_request.dart';

import 'card_data_manual.dart';


class PharosManualSaleRequest extends PharosSaleRequest{
  CardDataManual card;


  PharosManualSaleRequest({
    required String date,
    required String amount,
    required String currency,
    required String orderNumber,
    required String terminalCode,
    required String merchantCode,
    required bool isSale,
    required this.card,

  }) : super(date, amount, currency, orderNumber, terminalCode, merchantCode, isSale);

  Map<String, dynamic> toJson() {

    final map = super.toJson();
    map.addAll({
      'card': card.toJson(),
    });
    return map;

  }

}
