class PayStackSettingData {
  String publicKey;
  String secretKey;
  String callbackURL;
  String webhookURL;
  bool isEnabled;
  bool isSandbox;

  PayStackSettingData({
    this.publicKey = '',
    this.callbackURL = '',
    this.webhookURL = '',
    this.secretKey = '',
    required this.isSandbox,
    required this.isEnabled,
  });

  factory PayStackSettingData.fromJson(Map<String, dynamic> parsedJson) {
    return PayStackSettingData(
      publicKey: parsedJson['publicKey'] ?? '',
      webhookURL: parsedJson['webhookURL'] ?? '',
      callbackURL: parsedJson['callbackURL'] ?? '',
      isSandbox: parsedJson['isSandbox'] ?? false,
      isEnabled: parsedJson['isEnable'] ?? false,
      secretKey: parsedJson['secretKey'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'secretKey': secretKey,
      'callbackURL': callbackURL,
      'webhookURL': webhookURL,
      'isEnable': isEnabled,
      'isSandbox': isSandbox,
      'publicKey': publicKey,
    };
  }
}
