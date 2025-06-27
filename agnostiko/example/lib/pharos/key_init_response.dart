class PharosKeyInitResponse{
  bool successful;
  String encryptedNewKey;
  String newKeyCheckValue;
  String newKeyCRC;
  String newKeyKsn;



  PharosKeyInitResponse({
    required this.successful,
    required this.encryptedNewKey,
    required this.newKeyCheckValue,
    required this.newKeyCRC,
    required this.newKeyKsn,
  });


  factory PharosKeyInitResponse.fromJson(Map<String, dynamic> jsonData) {
    return PharosKeyInitResponse(
      successful: jsonData['successful'],
      encryptedNewKey: jsonData['encrypted_new_key'],
      newKeyCheckValue: jsonData['new_key_check_value'],
      newKeyCRC: jsonData['new_key_crc'],
      newKeyKsn: jsonData['new_key_ksn'],


    );
  }

}
