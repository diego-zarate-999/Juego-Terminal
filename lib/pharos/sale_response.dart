import 'dart:core';

class PharosSaleResponse{
  bool successful;
  String displayMessage;
  String resultCode;
  String? authCode;
  String? referenceNumber;
  String? script1;
  String? script2;
  String? script3;
  String? arpc;
  String? issuerAuthRespCode;


  PharosSaleResponse({
    required this.successful,
    required this.displayMessage,
    required this.resultCode,
    required this.authCode,
    required this.referenceNumber,
    required this.script1,
    required this.script2,
    required this.script3,
    required this.arpc,
    required this.issuerAuthRespCode
  });



  factory PharosSaleResponse.fromJson(Map<String, dynamic> jsonData) {
    return  PharosSaleResponse(
      successful: jsonData['successful'],
      displayMessage: jsonData['display_message'],
      resultCode: jsonData['result_code'],
      authCode: jsonData['auth_code'],
      referenceNumber: jsonData['reference_number'],
      script1: jsonData['script1'],
      script2: jsonData['script2'],
      script3: jsonData['script3'],
      arpc: jsonData['arpc'],
      issuerAuthRespCode: jsonData['issuer_auth_resp_code'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'successful': successful,
      'display_message': displayMessage,
      'result_code': resultCode,
      'auth_code': authCode,
      'script1': script1,
      'script2': script2,
      'script3': script3,
      'arpc': arpc,
      'issuer_auth_resp_code': issuerAuthRespCode,

    };
  }



}
