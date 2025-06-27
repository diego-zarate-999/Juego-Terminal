import 'dart:typed_data';

class IMdbEvent {
  IMdbEvent();

  factory IMdbEvent.fromJson(Map<String, dynamic> jsonData) {
    final eventName = jsonData["eventName"];
    if (eventName is String) {
      if (eventName == MdbResetEvent.eventName) {
        return MdbSetupConfigDataEvent();
      }
      if (eventName == MdbSetupConfigDataEvent.eventName) {
        return MdbSetupConfigDataEvent();
      }
      if (eventName == MdbSetupPriceLimitEvent.eventName) {
        return MdbSetupPriceLimitEvent();
      }
      if (eventName == MdbSetupConfigDataEvent.eventName) {
        return MdbSetupConfigDataEvent();
      }
      if (eventName == MdbReaderEnableEvent.eventName) {
        return MdbReaderEnableEvent();
      }
      if (eventName == MdbReaderCancelEvent.eventName) {
        return MdbReaderCancelEvent();
      }
      if (eventName == MdbReaderDisableEvent.eventName) {
        return MdbReaderDisableEvent();
      }
      if (eventName == MdbVendRequestEvent.eventName) {
        return MdbVendRequestEvent.fromJson(jsonData);
      }
      if (eventName == MdbVendCancelEvent.eventName) {
        return MdbVendCancelEvent();
      }
      if (eventName == MdbVendSuccessEvent.eventName) {
        return MdbVendSuccessEvent();
      }
      if (eventName == MdbVendFailureEvent.eventName) {
        return MdbVendFailureEvent();
      }
      if (eventName == MdbSessionCompleteEvent.eventName) {
        return MdbSessionCompleteEvent();
      }
      if (eventName == MdbRevalueRequestEvent.eventName) {
        return MdbRevalueRequestEvent();
      }
      if (eventName == MdbRevalueLimitEvent.eventName) {
        return MdbRevalueLimitEvent();
      }
    }
    throw StateError(
      "El valor de 'eventName' no es correcto para crear el evento.",
    );
  }
}

class MdbResetEvent extends IMdbEvent {
  static const eventName = "reset";

  MdbResetEvent();

  Map<String, dynamic> toJson() {
    return {"eventName": eventName};
  }
}

class MdbSetupConfigDataEvent extends IMdbEvent {
  static const eventName = "setupConfigData";

  MdbSetupConfigDataEvent();

  Map<String, dynamic> toJson() {
    return {"eventName": eventName};
  }
}

class MdbSetupPriceLimitEvent extends IMdbEvent {
  static const eventName = "setupPriceLimit";

  MdbSetupPriceLimitEvent();

  Map<String, dynamic> toJson() {
    return {"eventName": eventName};
  }
}

class MdbReaderEnableEvent extends IMdbEvent {
  static const eventName = "readerEnable";

  MdbReaderEnableEvent();

  Map<String, dynamic> toJson() {
    return {"eventName": eventName};
  }
}

class MdbReaderCancelEvent extends IMdbEvent {
  static const eventName = "readerCancel";

  MdbReaderCancelEvent();

  Map<String, dynamic> toJson() {
    return {"eventName": eventName};
  }
}

class MdbReaderDisableEvent extends IMdbEvent {
  static const eventName = "readerDisable";

  MdbReaderDisableEvent();

  Map<String, dynamic> toJson() {
    return {"eventName": eventName};
  }
}

class MdbVendRequestEvent extends IMdbEvent {
  static const eventName = "vendRequest";
  final String itemPrice;
  final double itemIndex;
  final String amount;

  MdbVendRequestEvent(this.amount, this.itemIndex, this.itemPrice);

  factory MdbVendRequestEvent.fromJson(Map<String, dynamic> jsonData) {
    return MdbVendRequestEvent(
      jsonData["itemPrice"],
      jsonData["itemIndex"],
      jsonData["amount"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "itemPrice": itemPrice,
      "itemIndex": itemIndex,
      "amount": amount,
    };
  }
}

class MdbVendCancelEvent extends IMdbEvent {
  static const eventName = "vendCancel";

  MdbVendCancelEvent();

  Map<String, dynamic> toJson() {
    return {"eventName": eventName};
  }
}

class MdbVendSuccessEvent extends IMdbEvent {
  static const eventName = "vendSuccess";

  MdbVendSuccessEvent();

  Map<String, dynamic> toJson() {
    return {"eventName": eventName};
  }
}

class MdbVendFailureEvent extends IMdbEvent {
  static const eventName = "vendFailure";

  MdbVendFailureEvent();

  Map<String, dynamic> toJson() {
    return {"eventName": eventName};
  }
}

class MdbSessionCompleteEvent extends IMdbEvent {
  static const eventName = "sessionComplete";

  MdbSessionCompleteEvent();

  Map<String, dynamic> toJson() {
    return {"eventName": eventName};
  }
}

class MdbRevalueRequestEvent extends IMdbEvent {
  static const eventName = "revalueRequest";

  MdbRevalueRequestEvent();

  Map<String, dynamic> toJson() {
    return {"eventName": eventName};
  }
}

class MdbRevalueLimitEvent extends IMdbEvent {
  static const eventName = "revalueLimit";

  MdbRevalueLimitEvent();

  Map<String, dynamic> toJson() {
    return {"eventName": eventName};
  }
}
