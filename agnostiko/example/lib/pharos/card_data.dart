import 'tags.dart';

class CardData{
  String readingMethod;
  String track2;
  String expMonth;
  String expYear;
  String? cardholderName;
  Tags tags;

  CardData({
    required this.readingMethod,
    required this.track2,
    required this.expMonth,
    required this.expYear,
    this.cardholderName,
    required this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'reading_method': readingMethod,
      'track2': track2.toUpperCase(),
      'exp_month': expMonth,
      'exp_year': expYear,
      'cardholder_name': cardholderName,
      'tags': tags.toJson(),

    };
  }

}


