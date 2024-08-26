import 'dart:convert';

import 'package:emartconsumer/model/PayFastSettingData.dart';
import 'package:emartconsumer/model/payStackURLModel.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

class PayStackURLGen {
  static Future payStackURLGen(
      {required String amount,
      required String secretKey,
      required String currency}) async {
    const url = "https://api.paystack.co/transaction/initialize";
    final response = await http.post(Uri.parse(url), body: {
      "email": MyAppState.currentUser?.email,
      "amount": amount,
      "currency": currency,
    }, headers: {
      "Authorization": "Bearer $secretKey",
    });
    final data = jsonDecode(response.body);

    print(data);
    if (!data["status"]) {
      return null;
    }
    return PayStackUrlModel.fromJson(data);
  }

  static Future<bool> verifyTransaction({
    required String reference,
    required String secretKey,
    required String amount,
  }) async {
    final url = "https://api.paystack.co/transaction/verify/$reference";
    var response = await http.get(Uri.parse(url), headers: {
      "Authorization": "Bearer $secretKey",
    });

    final data = jsonDecode(response.body);
    if (data["status"] == true) {
      if (data["message"] == "Verification successful") {}
    }
    return data["status"];
  }

  static Future<String> getPayHTML(
      {required String amount,
      required PayFastSettingData payFastSettingData,
      String itemName = "wallet Topup"}) async {
    String newUrl =
        'https://${!payFastSettingData.isSandbox ? "www" : "sandbox"}.payfast.co.za/eng/process';
    Map body = {
      'merchant_id': payFastSettingData.merchant_id,
      'merchant_key': payFastSettingData.merchant_key,
      'amount': amount,
      'item_name': itemName,
      'return_url': payFastSettingData.return_url,
      'cancel_url': payFastSettingData.cancel_url,
      'notify_url': payFastSettingData.notify_url,
      'name_first': MyAppState.currentUser!.firstName,
      'name_last': MyAppState.currentUser!.lastName,
      'email_address': MyAppState.currentUser!.email,
    };

    final response = await http.post(
      Uri.parse(newUrl),
      body: body,
    );

    print(response.body);
    return response.body;
  }
}
