import 'dart:convert';

import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/model/stripeIntentModel.dart';
import 'package:http/http.dart' as http;

class StripeCreateIntent {
  static Future<StripeCreateIntentModel> stripeCreateIntent({
    required currency,
    required amount,
    required stripesecret,
  }) async {
    const url = "${GlobalURL}payments/stripepaymentintent";

    final response = await http.post(
      Uri.parse(url),
      body: {
        "currency": currency,
        "stripesecret": stripesecret,
        "amount": amount,
      },
    );

    final data = jsonDecode(response.body);

    return StripeCreateIntentModel.fromJson(data); //PayPalClientSettleModel.fromJson(data);
  }
}
