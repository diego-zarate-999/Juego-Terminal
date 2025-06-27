import 'dart:core';

//TODO resolver variable posEnvironment dinamicamente segun el tipo de terminal
class PharosVoidResponse{
  bool successful;
  String displayMessage;
  String resultCode;

  PharosVoidResponse({
    required this.successful,
    required this.displayMessage,
    required this.resultCode,
  });

  factory PharosVoidResponse.fromJson(Map<String, dynamic> jsonData) {
    return  PharosVoidResponse(
      successful: jsonData['successful'],
      displayMessage: jsonData['display_message'],
      resultCode: jsonData['result_code'],


    );
  }

}
