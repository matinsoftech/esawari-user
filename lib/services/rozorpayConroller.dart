import 'dart:convert';

import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/model/createRazorPayOrderModel.dart';
import 'package:emartconsumer/model/razorpayKeyModel.dart';
import 'package:emartconsumer/userPrefrence.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class RazorPayController {
  Future<CreateRazorPayOrderModel?> createOrderRazorPay({required int amount, bool isTopup = false}) async {
    RazorPayModel razorPayData = UserPreference.getRazorPayData();
    print(razorPayData.razorpayKey);
    print("we Enter In");
    const url = "${GlobalURL}payments/razorpay/createorder";
    final response = await http.post(
      Uri.parse(url),
      body: {
        "amount": (amount * 100).toString(),
        "receipt_id": Uuid().v4(),
        "currency": currencyData?.code,
        "razorpaykey": razorPayData.razorpayKey,
        "razorPaySecret": razorPayData.razorpaySecret,
        "isSandBoxEnabled": razorPayData.isSandboxEnabled.toString(),
      },
    );

    if (response.statusCode == 500) {
      return null;
    } else {
      final data = jsonDecode(response.body);
      print(data);

      return CreateRazorPayOrderModel.fromJson(data);
    }
  }
}
