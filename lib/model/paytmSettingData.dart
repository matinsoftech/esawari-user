class PaytmSettingData {
  String PaytmMID;
  String PAYTM_MERCHANT_KEY;
  bool isEnabled;
  bool isSandboxEnabled;

  PaytmSettingData({
    this.PaytmMID = '',
    this.PAYTM_MERCHANT_KEY = '',
    required this.isSandboxEnabled,
    required this.isEnabled,
  });

  factory PaytmSettingData.fromJson(Map<String, dynamic> parsedJson) {
    return PaytmSettingData(
      PAYTM_MERCHANT_KEY: parsedJson['PAYTM_MERCHANT_KEY'] ?? '',
      PaytmMID: parsedJson['PaytmMID'] ?? '',
      isSandboxEnabled: parsedJson['isSandboxEnabled'],
      isEnabled: parsedJson['isEnabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PaytmMID': PaytmMID,
      'PAYTM_MERCHANT_KEY': PAYTM_MERCHANT_KEY,
      'isEnabled': isEnabled,
      'isSandboxEnabled': isSandboxEnabled,
    };
  }
}
