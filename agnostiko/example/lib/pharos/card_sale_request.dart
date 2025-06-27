import 'dart:core';
import 'package:agnostiko_example/pharos/sale_request.dart';

import 'card_data.dart';


class PharosCardSaleRequest extends PharosSaleRequest{
  String stan;
  CardData card;
  String ksn;

  PharosCardSaleRequest({
    required String date,
    required String amount,
    required String currency,
    required String orderNumber,
    required String terminalCode,
    required String merchantCode,
    required bool isSale,
    required this.stan,
    required this.card,
    required this.ksn,

  }) : super(date, amount, currency, orderNumber, terminalCode, merchantCode, isSale);


  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map.addAll({
      'stan': stan,
      'card': card.toJson(),
      'ksn': ksn.toUpperCase(),
    });
    return map;

  }

}
