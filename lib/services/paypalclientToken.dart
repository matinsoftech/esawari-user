// import 'dart:convert';
//
// import 'package:emartconsumer/constants.dart';
// import 'package:emartconsumer/model/paypalClientToken.dart';
// import 'package:emartconsumer/model/paypalSettingData.dart';
// import 'package:http/http.dart' as http;
//
// class PayPalClientTokenGen {
//   static Future<PayPalClientTokenModel> paypalClientToken({
//     required PaypalSettingData paypalSettingData,
//   }) async {
//     // final String userId = UserPreference.getUserId();
//     // final String orderId = isTopup ? UserPreference.getPaymentId() : UserPreference.getOrderId();
//
//     print("we Enter In");
//     final url = "${GlobalURL}payments/paypalclientid";
//
//     final response = await http.post(
//       Uri.parse(url),
//       body: {
//         "environment": paypalSettingData.isLive ? "production" : "sandbox",
//         "merchant_id": paypalSettingData.braintree_merchantid,
//         "public_key": paypalSettingData.braintree_publickey,
//         "private_key": paypalSettingData.braintree_privatekey,
//       },
//     );
//     print(response.body);
//
//     final data = jsonDecode(response.body);
//     print(data);
//
//     return PayPalClientTokenModel.fromJson(data);
//   }
//
//   static paypalSettleAmount({
//     required nonceFromTheClient,
//     required amount,
//     required deviceDataFromTheClient,
//     required PaypalSettingData paypalSettingData,
//   }) async {
//     print("we Enter payment Settle");
//     final url = "${GlobalURL}payments/paypaltransaction";
//
//     final response = await http.post(
//       Uri.parse(url),
//       body: {
//         "environment": paypalSettingData.isLive ? "production" : "sandbox",
//         "merchant_id": paypalSettingData.braintree_merchantid,
//         "public_key": paypalSettingData.braintree_publickey,
//         "private_key": paypalSettingData.braintree_privatekey,
//         "nonceFromTheClient": nonceFromTheClient,
//         "amount": amount,
//         "deviceDataFromTheClient": deviceDataFromTheClient,
//       },
//     );
//     print(response.body);
//
//     final data = jsonDecode(response.body);
//     print(data);
//     print("JBL sound");
//     print(data['data']['success']);
//     // final dlo = PayPalCurrencyCodeErrorModel.fromJson(data);
//     // print(dlo.data.message);
//
//     return data; //PayPalClientSettleModel.fromJson(data);
//   }
// }
