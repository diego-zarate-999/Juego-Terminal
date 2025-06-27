class PharosKeyInitRequest{
  final String tranType= "KEY_INIT";
  String terminalCode;
  String merchantCode;
  String encryptedRandomKey;
  String randomKeyCheckValue;
  String randomKeyCRC;



  PharosKeyInitRequest({
    required this.terminalCode,
    required this.merchantCode,
    required this.encryptedRandomKey,
    required this.randomKeyCheckValue,
    required this.randomKeyCRC,
  });

  Map<String, dynamic> toJson() {
    return {
      'tran_type': tranType,
      'terminal_code': terminalCode,
      'merchant_code': merchantCode,
      'encrypted_random_key': encryptedRandomKey,
      'random_key_check_value': randomKeyCheckValue,
      'random_key_crc': randomKeyCRC,

    };
  }

}
