class PaypalSettingData {
  bool isEnabled;
  bool isLive;
  String paypalSecret;
  String paypalClient;


  PaypalSettingData({
    required this.isLive,
    required this.isEnabled,
    required this.paypalSecret,
    required this.paypalClient
  });

  factory PaypalSettingData.fromJson(Map<String, dynamic> parsedJson) {
    return PaypalSettingData(
      paypalSecret: parsedJson['paypalSecret'] ?? '',
      paypalClient: parsedJson['paypalClient'] ?? '',
      isLive: parsedJson['isLive'],
      isEnabled: parsedJson['isEnabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'isLive': isLive,
      'paypalSecret': paypalSecret,
      'paypalClient': paypalClient,
    };
  }
}
