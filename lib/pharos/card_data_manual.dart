
class CardDataManual{
  String readingMethod;
  String cardNumber;
  String secCode;
  String expMonth;
  String expYear;
  String? cardholderName;


  CardDataManual({
    required this.readingMethod,
    required this.cardNumber,
    required this.secCode,
    required this.expMonth,
    required this.expYear,
    this.cardholderName,

  });


  Map<String, dynamic> toJson() {
    return {
      'reading_method': readingMethod,
      'card_number': cardNumber,
      'sec_code': secCode,
      'exp_month': expMonth,
      'exp_year': expYear,
      'cardholder_name': cardholderName,


    };
  }

}


