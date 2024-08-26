class PayFastSettingData {
  bool isEnable;
  bool isSandbox;
  String merchant_id;
  String merchant_key;

  String return_url;
  String cancel_url;
  String notify_url;

  PayFastSettingData({
    this.merchant_id = '',
    this.cancel_url = '',
    required this.isEnable,
    required this.isSandbox,
    this.merchant_key = '',
    this.notify_url = '',
    this.return_url = '',
  });

  factory PayFastSettingData.fromJson(Map<String, dynamic> parsedJson) {
    return PayFastSettingData(
      isSandbox: parsedJson['isSandbox'] ?? false,
      isEnable: parsedJson['isEnable'] ?? false,
      return_url: parsedJson['return_url'] ?? '',
      notify_url: parsedJson['notify_url'] ?? '',
      merchant_key: parsedJson['merchant_key'] ?? '',
      cancel_url: parsedJson['cancel_url'] ?? '',
      merchant_id: parsedJson['merchant_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchant_id': merchant_id,
      'merchant_key': merchant_key,
      'return_url': return_url,
      'cancel_url': cancel_url,
      'notify_url': notify_url,
      'isEnable': isEnable,
      'isSandbox': isSandbox,
    };
  }
}
