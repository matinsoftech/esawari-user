import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paypal_native/flutter_paypal_native.dart';
import 'package:flutter_paypal_native/models/custom/currency_code.dart';
import 'package:flutter_paypal_native/models/custom/environment.dart';
import 'package:flutter_paypal_native/models/custom/order_callback.dart';
import 'package:flutter_paypal_native/models/custom/purchase_unit.dart';
import 'package:flutter_paypal_native/models/custom/user_action.dart';
import 'package:flutter_paypal_native/str_helper.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/FlutterWaveSettingDataModel.dart';
import 'package:emartconsumer/model/MercadoPagoSettingsModel.dart';
import 'package:emartconsumer/model/PayFastSettingData.dart';
import 'package:emartconsumer/model/PayStackSettingsModel.dart';

import 'package:emartconsumer/model/createRazorPayOrderModel.dart';
import 'package:emartconsumer/model/getPaytmTxtToken.dart';
import 'package:emartconsumer/model/gift_cards_model.dart';
import 'package:emartconsumer/model/gift_cards_order_model.dart';
import 'package:emartconsumer/model/payStackURLModel.dart';
import 'package:emartconsumer/model/paypalSettingData.dart';
import 'package:emartconsumer/model/paytmSettingData.dart';
import 'package:emartconsumer/model/razorpayKeyModel.dart';
import 'package:emartconsumer/model/stripeSettingData.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/ui/wallet/MercadoPagoScreen.dart';
import 'package:emartconsumer/ui/wallet/payStackScreen.dart';
import 'package:http/http.dart' as http;
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/services/paystack_url_genrater.dart';
import 'package:emartconsumer/services/rozorpayConroller.dart';
import 'package:emartconsumer/ui/wallet/PayFastScreen.dart';
import 'package:emartconsumer/userPrefrence.dart';
import 'package:mercadopago_sdk/mercadopago_sdk.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe1;
import 'package:uuid/uuid.dart';

class GiftCardPurchaseScreen extends StatefulWidget {
  final GiftCardsModel giftCardModel;
  final String price;
  final String msg;

  const GiftCardPurchaseScreen({super.key, required this.giftCardModel, required this.price, required this.msg});

  @override
  State<GiftCardPurchaseScreen> createState() => _GiftCardPurchaseScreenState();
}

class _GiftCardPurchaseScreenState extends State<GiftCardPurchaseScreen> {
  GiftCardsModel giftCardModel = GiftCardsModel();
  String gradTotal = "0";

  @override
  void initState() {
    giftCardModel = widget.giftCardModel;
    gradTotal = widget.price;
    getPaymentSettingData();
    super.initState();
  }

  Razorpay _razorPay = Razorpay();
  RazorPayModel? razorPayData;
  StripeSettingData? stripeData;
  PaytmSettingData? paytmSettingData;
  PaypalSettingData? paypalSettingData;
  PayStackSettingData? payStackSettingData;
  FlutterWaveSettingData? flutterWaveSettingData;
  PayFastSettingData? payFastSettingData;
  MercadoPagoSettingData? mercadoPagoSettingData;

  getPaymentSettingData() async {
    await UserPreference.getStripeData().then((value) async {
      stripeData = value;
      stripe1.Stripe.publishableKey = stripeData!.clientpublishableKey;
      stripe1.Stripe.merchantIdentifier = 'Foodie';
      await stripe1.Stripe.instance.applySettings();
    });

    _razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWaller);
    _razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

    razorPayData = await UserPreference.getRazorPayData();
    paytmSettingData = await UserPreference.getPaytmData();
    paypalSettingData = await UserPreference.getPayPalData();
    payStackSettingData = await UserPreference.getPayStackData();
    flutterWaveSettingData = await UserPreference.getFlutterWaveData();
    payFastSettingData = await UserPreference.getPayFastData();
    mercadoPagoSettingData = await UserPreference.getMercadoPago();
    setRef();
    initPayPal();
  }

  final _flutterPaypalNativePlugin = FlutterPaypalNative.instance;

  void initPayPal() async {
    //set debugMode for error logging
    FlutterPaypalNative.isDebugMode = paypalSettingData!.isLive == false ? true : false;
    //initiate payPal plugin
    await _flutterPaypalNativePlugin.init(
      //your app id !!! No Underscore!!! see readme.md for help
      returnUrl: "com.emart.customer://paypalpay",
      //client id from developer dashboard
      clientID: paypalSettingData!.paypalClient,
      //sandbox, staging, live etc
      payPalEnvironment: paypalSettingData!.isLive == true ? FPayPalEnvironment.live : FPayPalEnvironment.sandbox,
      //what currency do you plan to use? default is US dollars
      currencyCode: FPayPalCurrencyCode.usd,
      //action paynow?
      action: FPayPalUserAction.payNow,
    );

    //call backs for payment
    _flutterPaypalNativePlugin.setPayPalOrderCallback(
      callback: FPayPalOrderCallback(
        onCancel: () {
          //user canceled the payment
          Navigator.pop(context);
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text("Payment canceled".tr() + "\n"),
            backgroundColor: Colors.red,
          ));
        },
        onSuccess: (data) {
          Navigator.pop(context);
          _flutterPaypalNativePlugin.removeAllPurchaseItems();
          String visitor = data.cart?.shippingAddress?.firstName ?? 'Visitor';
          String address = data.cart?.shippingAddress?.line1 ?? 'Unknown Address';

          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text("Payment Successfully".tr() + "\n"),
            backgroundColor: Colors.red,
          ));
          paymentCompleted(paymentMethod: "Paypal");
        },
        onError: (data) {
          Navigator.pop(context);
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text("error".tr() + "\n"),
            backgroundColor: Colors.red,
          ));
        },
        onShippingChange: (data) {
          //the user updated the shipping address
          Navigator.pop(context);
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text("shipping change: ${data.shippingChangeAddress?.adminArea1 ?? ""}"),
            backgroundColor: Colors.red,
          ));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode(context) ? Colors.grey.shade900 : Colors.grey.shade100,
      appBar: AppBar(
        title: Text("Complete purchase", style: TextStyle(color: Color(COLOR_PRIMARY), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  height: 200,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white, width: 5),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          giftCardModel.image.toString(),
                        ),
                      ),
                    ),
                  )),
              SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Color(COLOR_PRIMARY).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Text("Complete payment and share this e-gift card with loved ones using any app."),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text("BILL SUMMARY".toUpperCase(), style: TextStyle(fontSize: 16, color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade700, fontWeight: FontWeight.w600)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 13),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
                  color: isDarkMode(context) ? const Color(DarkContainerColor) : Colors.white,
                  boxShadow: [
                    isDarkMode(context)
                        ? const BoxShadow()
                        : BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 5,
                          ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Subtotal".tr(),
                              style: TextStyle(fontFamily: "Poppinsm"),
                            ),
                            Text(
                              amountShow(amount: widget.price),
                              style: TextStyle(fontFamily: "Poppinsm", color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff333333)),
                            ),
                          ],
                        )),
                    const Divider(
                      thickness: 1,
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Grand Total".tr(),
                              style: TextStyle(fontFamily: "Poppinsm"),
                            ),
                            Text(
                              amountShow(amount: widget.price),
                              style: TextStyle(fontFamily: "Poppinsm", color: Colors.red),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
              Text(
                "Gift Card expire  ${giftCardModel.expiryDay} days after purchase ",
                style: TextStyle(color: Colors.grey),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 10, bottom: 10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: double.infinity),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(COLOR_PRIMARY),
              padding: EdgeInsets.only(top: 12, bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
                side: BorderSide(
                  color: Color(COLOR_PRIMARY),
                ),
              ),
            ),
            child: Text(
              'Continue'.tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode(context) ? Colors.black : Colors.white,
              ),
            ),
            onPressed: () {
              topUpBalance();
            },
          ),
        ),
      ),
    );
  }

  paymentCompleted({required String paymentMethod}) async {

    GiftCardsOrderModel giftCardsOrderModel = GiftCardsOrderModel();
    giftCardsOrderModel.id = Uuid().v4();
    giftCardsOrderModel.giftId = giftCardModel.id.toString();
    giftCardsOrderModel.giftTitle = giftCardModel.title.toString();
    giftCardsOrderModel.price = gradTotal.toString();
    giftCardsOrderModel.redeem = false;
    giftCardsOrderModel.message = widget.msg;
    giftCardsOrderModel.giftPin = generateGiftPin();
    giftCardsOrderModel.giftCode = generateGiftCode();
    giftCardsOrderModel.paymentType = paymentMethod;
    giftCardsOrderModel.createdDate = Timestamp.now();
    DateTime dateTime = DateTime.now().add(Duration(days: int.parse(giftCardModel.expiryDay.toString())));
    giftCardsOrderModel.expireDate = Timestamp.fromDate(dateTime);
    giftCardsOrderModel.userid = MyAppState.currentUser!.userID;

    await FireStoreUtils().placeGiftCardOrder(giftCardsOrderModel).then((value) {
      Navigator.pop(context);
    });
  }

  String generateGiftCode(){
    var rng = Random();
    String generatedNumber = '';
    for(int i=0;i<16;i++){
      generatedNumber += (rng.nextInt(9)+1).toString();
    }
    return generatedNumber;
  }

  String generateGiftPin(){
    var rng = Random();
    String generatedNumber = '';
    for(int i=0;i<6;i++){
      generatedNumber += (rng.nextInt(9)+1).toString();
    }
    return generatedNumber;
  }


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool stripe = true;

  bool razorPay = false;
  bool payTm = false;
  bool paypal = false;
  bool payStack = false;
  bool flutterWave = false;
  bool payFast = false;
  bool mercadoPago = false;
  String? selectedRadioTile;

  topUpBalance() {
    final size = MediaQuery.of(context).size;
    return showModalBottomSheet(
        elevation: 5,
        enableDrag: true,
        useRootNavigator: true,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) => Container(
              width: size.width,
              height: size.height * 0.85,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                          child: RichText(
                            text: TextSpan(
                              text: "Select Payment Option".tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDarkMode(context) ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: stripeData!.isEnabled,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 20),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: stripe ? 0 : 2,
                          child: RadioListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: stripe ? Color(COLOR_PRIMARY) : Colors.transparent)),
                            controlAffinity: ListTileControlAffinity.trailing,
                            value: "Stripe",
                            groupValue: selectedRadioTile,
                            onChanged: (String? value) {
                              setState(() {
                                flutterWave = false;
                                stripe = true;
                                mercadoPago = false;
                                payFast = false;
                                payStack = false;
                                razorPay = false;
                                payTm = false;
                                paypal = false;
                                selectedRadioTile = value!;
                              });
                            },
                            selected: stripe,
                            //selectedRadioTile == "strip" ? true : false,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                                      child: SizedBox(
                                        width: 80,
                                        height: 35,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                                          child: Image.asset(
                                            "assets/images/stripe.png",
                                          ),
                                        ),
                                      ),
                                    )),
                                SizedBox(
                                  width: 20,
                                ),
                                Text("Stripe"),
                              ],
                            ),
                            //toggleable: true,
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: payStackSettingData!.isEnabled,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 20),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: payStack ? 0 : 2,
                          child: RadioListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: payStack ? Color(COLOR_PRIMARY) : Colors.transparent)),
                            controlAffinity: ListTileControlAffinity.trailing,
                            value: "PayStack",
                            groupValue: selectedRadioTile,
                            onChanged: (String? value) {
                              setState(() {
                                flutterWave = false;
                                payStack = true;
                                mercadoPago = false;
                                stripe = false;
                                payFast = false;
                                razorPay = false;
                                payTm = false;
                                paypal = false;
                                selectedRadioTile = value!;
                              });
                            },
                            selected: payStack,
                            //selectedRadioTile == "strip" ? true : false,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                                      child: SizedBox(
                                        width: 80,
                                        height: 35,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                                          child: Image.asset(
                                            "assets/images/paystack.png",
                                          ),
                                        ),
                                      ),
                                    )),
                                SizedBox(
                                  width: 20,
                                ),
                                Text("PayStack"),
                              ],
                            ),
                            //toggleable: true,
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: flutterWaveSettingData != null && flutterWaveSettingData!.isEnable,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 20),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: flutterWave ? 0 : 2,
                          child: RadioListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: flutterWave ? Color(COLOR_PRIMARY) : Colors.transparent)),
                            controlAffinity: ListTileControlAffinity.trailing,
                            value: "FlutterWave",
                            groupValue: selectedRadioTile,
                            onChanged: (String? value) {
                              setState(() {
                                flutterWave = true;
                                payStack = false;
                                mercadoPago = false;
                                payFast = false;
                                stripe = false;
                                razorPay = false;
                                payTm = false;
                                paypal = false;
                                selectedRadioTile = value!;
                              });
                            },
                            selected: flutterWave,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                                      child: SizedBox(
                                        width: 80,
                                        height: 35,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                                          child: Image.asset(
                                            "assets/images/flutterwave.png",
                                          ),
                                        ),
                                      ),
                                    )),
                                SizedBox(
                                  width: 20,
                                ),
                                Text("FlutterWave"),
                              ],
                            ),
                            //toggleable: true,
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: razorPayData!.isEnabled,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 20),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: razorPay ? 0 : 2,
                          child: RadioListTile(
                            //toggleable: true,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: razorPay ? Color(COLOR_PRIMARY) : Colors.transparent)),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                            controlAffinity: ListTileControlAffinity.trailing,
                            value: "RazorPay",
                            groupValue: selectedRadioTile,
                            onChanged: (String? value) {
                              setState(() {
                                mercadoPago = false;
                                flutterWave = false;
                                stripe = false;
                                razorPay = true;
                                payTm = false;
                                payFast = false;
                                paypal = false;
                                payStack = false;
                                selectedRadioTile = value!;
                              });
                            },
                            selected: razorPay,
                            //selectedRadioTile == "strip" ? true : false,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10),
                                      child: SizedBox(width: 80, height: 35, child: Image.asset("assets/images/razorpay_@3x.png")),
                                    )),
                                SizedBox(
                                  width: 20,
                                ),
                                Text("RazorPay"),
                              ],
                            ),
                            //toggleable: true,
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: payFastSettingData != null && payFastSettingData!.isEnable,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: payFast ? 0 : 2,
                          child: RadioListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: payFast ? Color(COLOR_PRIMARY) : Colors.transparent)),
                            controlAffinity: ListTileControlAffinity.trailing,
                            value: "payFast",
                            groupValue: selectedRadioTile,
                            onChanged: (String? value) {
                              setState(() {
                                payFast = true;
                                stripe = false;
                                mercadoPago = false;
                                razorPay = false;
                                payStack = false;
                                flutterWave = false;
                                payTm = false;
                                paypal = false;
                                selectedRadioTile = value!;
                              });
                            },
                            selected: payFast,
                            //selectedRadioTile == "strip" ? true : false,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                                      child: SizedBox(
                                        width: 80,
                                        height: 35,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                                          child: Image.asset(
                                            "assets/images/payfast.png",
                                          ),
                                        ),
                                      ),
                                    )),
                                SizedBox(
                                  width: 20,
                                ),
                                Text("Pay Fast"),
                              ],
                            ),
                            //toggleable: true,
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: paytmSettingData!.isEnabled,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 20),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: payTm ? 0 : 2,
                          child: RadioListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: payTm ? Color(COLOR_PRIMARY) : Colors.transparent)),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                            controlAffinity: ListTileControlAffinity.trailing,
                            value: "PayTm",
                            groupValue: selectedRadioTile,
                            onChanged: (String? value) {
                              setState(() {
                                stripe = false;
                                flutterWave = false;
                                payTm = true;
                                mercadoPago = false;
                                razorPay = false;
                                paypal = false;
                                payFast = false;
                                payStack = false;
                                selectedRadioTile = value!;
                              });
                            },
                            selected: payTm,
                            //selectedRadioTile == "strip" ? true : false,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10),
                                      child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                                            child: Image.asset(
                                              "assets/images/paytm_@3x.png",
                                            ),
                                          )),
                                    )),
                                SizedBox(
                                  width: 20,
                                ),
                                Text("Paytm"),
                              ],
                            ),
                            //toggleable: true,
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: mercadoPagoSettingData != null && mercadoPagoSettingData!.isEnabled,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: mercadoPago ? 0 : 2,
                          child: RadioListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: mercadoPago ? Color(COLOR_PRIMARY) : Colors.transparent)),
                            controlAffinity: ListTileControlAffinity.trailing,
                            value: "MercadoPago",
                            groupValue: selectedRadioTile,
                            onChanged: (String? value) {
                              setState(() {
                                mercadoPago = true;
                                payFast = false;
                                stripe = false;
                                razorPay = false;
                                payStack = false;
                                flutterWave = false;
                                payTm = false;
                                paypal = false;
                                selectedRadioTile = value!;
                              });
                            },
                            selected: mercadoPago,
                            //selectedRadioTile == "strip" ? true : false,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                                      child: SizedBox(
                                        width: 80,
                                        height: 35,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                                          child: Image.asset(
                                            "assets/images/mercadopago.png",
                                          ),
                                        ),
                                      ),
                                    )),
                                SizedBox(
                                  width: 20,
                                ),
                                Text("Mercado Pago"),
                              ],
                            ),
                            //toggleable: true,
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: paypalSettingData != null && paypalSettingData!.isEnabled,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 20),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: paypal ? 0 : 2,
                          child: RadioListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: paypal ? Color(COLOR_PRIMARY) : Colors.transparent)),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                            controlAffinity: ListTileControlAffinity.trailing,
                            value: "PayPal",
                            groupValue: selectedRadioTile,
                            onChanged: (String? value) {
                              setState(() {
                                stripe = false;
                                payTm = false;
                                mercadoPago = false;
                                flutterWave = false;
                                razorPay = false;
                                paypal = true;
                                payFast = false;
                                payStack = false;
                                selectedRadioTile = value!;
                              });
                            },
                            selected: paypal,
                            //selectedRadioTile == "strip" ? true : false,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10),
                                      child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                                            child: Image.asset("assets/images/paypal_@3x.png"),
                                          )),
                                    )),
                                SizedBox(
                                  width: 20,
                                ),
                                Text("PayPal"),
                              ],
                            ),
                            //toggleable: true,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 22),
                      child: GestureDetector(
                        onTap: () async {
                          if (selectedRadioTile == "Stripe" && stripeData?.isEnabled == true) {
                            Navigator.pop(context);
                            showLoadingAlert();
                            stripeMakePayment(amount: gradTotal);
                          } else if (selectedRadioTile == "MercadoPago") {
                            Navigator.pop(context);
                            showLoadingAlert();
                            mercadoPagoMakePayment();
                          } else if (selectedRadioTile == "payFast") {
                            showLoadingAlert();
                            PayStackURLGen.getPayHTML(payFastSettingData: payFastSettingData!, amount: gradTotal).then((value) async {
                              bool isDone = await Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PayFastScreen(
                                        htmlData: value,
                                        payFastSettingData: payFastSettingData!,
                                      )));
                              print(isDone);
                              if (isDone) {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                await paymentCompleted(paymentMethod: "PayFast");
                              } else {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                    "Payment Unsuccessful!!".tr() + "\n",
                                  ),
                                  backgroundColor: Colors.red.shade400,
                                  duration: const Duration(seconds: 6),
                                ));
                              }
                            });
                          } else if (selectedRadioTile == "RazorPay") {
                            showLoadingAlert();
                            RazorPayController().createOrderRazorPay(isTopup: true, amount: int.parse(gradTotal)).then((value) {
                              if (value != null) {
                                CreateRazorPayOrderModel result = value;

                                openCheckout(
                                  amount: gradTotal,
                                  orderId: result.id,
                                );
                              } else {
                                Navigator.pop(context);
                                showAlert(_scaffoldKey.currentContext!, response: "Something went wrong, please contact admin.".tr(), colors: Colors.red);
                              }
                            });
                          } else if (selectedRadioTile == "PayTm") {
                            showLoadingAlert();
                            getPaytmCheckSum(context, amount: double.parse(gradTotal));
                          } else if (selectedRadioTile == "PayPal") {
                            showLoadingAlert();
                            paypalPaymentSheet();
                          } else if (selectedRadioTile == "PayStack") {
                            showLoadingAlert();
                            payStackPayment();
                          } else if (selectedRadioTile == "FlutterWave") {
                            _flutterWaveInitiatePayment(context);
                          }
                        },
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Color(COLOR_PRIMARY),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                              child: Text(
                            "CONTINUE".tr(),
                            style: TextStyle(color: Colors.white),
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  showLoadingAlert() {
    return showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const CircularProgressIndicator(),
              const Text('Please wait!!').tr(),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const SizedBox(
                  height: 15,
                ),
                Text(
                  'Please wait!! while completing Transaction'.tr(),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  showAlert(context, {required String response, required Color colors}) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(response),
      backgroundColor: colors,
      duration: Duration(seconds: 8),
    ));
  }

  Map<String, dynamic>? paymentIntentData;

  /// RazorPay Payment Gateway
  void openCheckout({required amount, required orderId}) async {
    var options = {
      'key': razorPayData!.razorpayKey,
      'amount': amount * 100,
      'name': 'Foodies',
      'order_id': orderId,
      "currency": currencyData?.code,
      'description': 'wallet Topup',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': MyAppState.currentUser!.phoneNumber,
        'email': MyAppState.currentUser!.email,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorPay.open(options);
    } catch (e) {
      debugPrint('error'.tr() + ': $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    paymentCompleted(paymentMethod: "RazorPay");
  }

  void _handleExternalWaller(ExternalWalletResponse response) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        "Payment Processing Via".tr() + "\n" + response.walletName!,
      ),
      backgroundColor: Colors.blue.shade400,
      duration: Duration(seconds: 8),
    ));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        "Payment Failed!!".tr() + "\n" + jsonDecode(response.message!)['error']['description'],
      ),
      backgroundColor: Colors.red.shade400,
      duration: Duration(seconds: 8),
    ));
  }

  /// Paytm Payment Gateway
  bool isStaging = true;
  String callbackUrl = "http://162.241.125.167/~foodie/payments/paytmpaymentcallback?ORDER_ID=";
  bool restrictAppInvoke = false;
  bool enableAssist = true;
  String result = "";

  getPaytmCheckSum(
    context, {
    required double amount,
  }) async {
    final String orderId = UserPreference.getPaymentId();
    String getChecksum = "${GlobalURL}payments/getpaytmchecksum";

    final response = await http.post(
        Uri.parse(
          getChecksum,
        ),
        headers: {},
        body: {
          "mid": paytmSettingData?.PaytmMID,
          "order_id": orderId,
          "key_secret": paytmSettingData?.PAYTM_MERCHANT_KEY,
        });

    final data = jsonDecode(response.body);

    await verifyCheckSum(checkSum: data["code"], amount: amount, orderId: orderId).then((value) {
      initiatePayment(context, amount: amount, orderId: orderId).then((value) {
        GetPaymentTxtTokenModel result = value;
        String callback = "";
        if (paytmSettingData!.isSandboxEnabled) {
          callback = callback + "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
        } else {
          callback = callback + "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
        }

        _startTransaction(
          context,
          txnTokenBy: result.body.txnToken,
          orderId: orderId,
          amount: amount,
        );
      });
    });
  }

  Future verifyCheckSum({required String checkSum, required double amount, required orderId}) async {
    String getChecksum = "${GlobalURL}payments/validatechecksum";
    final response = await http.post(
        Uri.parse(
          getChecksum,
        ),
        headers: {},
        body: {
          "mid": paytmSettingData?.PaytmMID,
          "order_id": orderId,
          "key_secret": paytmSettingData?.PAYTM_MERCHANT_KEY,
          "checksum_value": checkSum,
        });
    final data = jsonDecode(response.body);
    return data['status'];
  }

  Future<GetPaymentTxtTokenModel> initiatePayment(BuildContext context, {required double amount, required orderId}) async {
    String initiateURL = "${GlobalURL}payments/initiatepaytmpayment";
    String callback = "";
    if (paytmSettingData!.isSandboxEnabled) {
      callback = callback + "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
    } else {
      callback = callback + "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
    }
    final response = await http.post(
        Uri.parse(
          initiateURL,
        ),
        headers: {},
        body: {
          "mid": paytmSettingData?.PaytmMID,
          "order_id": orderId,
          "key_secret": paytmSettingData?.PAYTM_MERCHANT_KEY.toString(),
          "amount": amount.toString(),
          "currency": currencyData!.code,
          "callback_url": callback,
          "custId": MyAppState.currentUser!.userID,
          "issandbox": paytmSettingData!.isSandboxEnabled ? "1" : "2",
        });
    final data = jsonDecode(response.body);
    if (data["body"]["txnToken"] == null || data["body"]["txnToken"].toString().isEmpty) {
      Navigator.pop(_scaffoldKey.currentContext!);
      showAlert(_scaffoldKey.currentContext!, response: "something went wrong, please contact admin.".tr(), colors: Colors.red);
    }
    return GetPaymentTxtTokenModel.fromJson(data);
  }

  Future<void> _startTransaction(
    context, {
    required String txnTokenBy,
    required orderId,
    required double amount,
  }) async {
    try {
      var response = AllInOneSdk.startTransaction(
        paytmSettingData!.PaytmMID,
        orderId,
        amount.toString(),
        txnTokenBy,
        "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId",
        isStaging,
        true,
        enableAssist,
      );

      response.then((value) {
        if (value!["RESPMSG"] == "Txn Success") {
          Navigator.pop(context);
          paymentCompleted(paymentMethod: "Paytm");
        }
      }).catchError((onError) {
        if (onError is PlatformException) {
          Navigator.pop(_scaffoldKey.currentContext!);

          result = onError.message.toString() + " \n  " + onError.code.toString();
          showAlert(_scaffoldKey.currentContext!, response: onError.message.toString(), colors: Colors.red);
        } else {
          result = onError.toString();
          Navigator.pop(_scaffoldKey.currentContext!);
          showAlert(_scaffoldKey.currentContext!, response: result, colors: Colors.red);
        }
      });
    } catch (err) {
      result = err.toString();
      Navigator.pop(_scaffoldKey.currentContext!);
      showAlert(_scaffoldKey.currentContext!, response: result, colors: Colors.red);
    }
  }

  /// Stripe Payment Gateway
  Future<void> stripeMakePayment({required String amount}) async {
    try {
      paymentIntentData = await createStripeIntent(
        amount,
      );
      if (paymentIntentData!.containsKey("error")) {
        Navigator.pop(context);
        showAlert(_scaffoldKey.currentContext, response: "Something went wrong, please contact admin.".tr(), colors: Colors.red);
      } else {
        await stripe1.Stripe.instance
            .initPaymentSheet(
                paymentSheetParameters: stripe1.SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentData!['client_secret'],
              applePay: const stripe1.PaymentSheetApplePay(
                merchantCountryCode: 'US',
              ),
              allowsDelayedPaymentMethods: false,
              googlePay: stripe1.PaymentSheetGooglePay(
                merchantCountryCode: 'US',
                testEnv: true,
                currencyCode: currencyData!.code,
              ),
              style: ThemeMode.system,
              appearance: stripe1.PaymentSheetAppearance(
                colors: stripe1.PaymentSheetAppearanceColors(
                  primary: Color(COLOR_PRIMARY),
                ),
              ),
              merchantDisplayName: 'Emart',
            ))
            .then((value) {});
        setState(() {});
        displayStripePaymentSheet();
      }
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayStripePaymentSheet() async {
    try {
      await stripe1.Stripe.instance.presentPaymentSheet().then((value) async {

        Navigator.pop(context);
        paymentCompleted(paymentMethod: "Stripe");
        paymentIntentData = null;
      });
    } on stripe1.StripeException catch (e) {
      Navigator.pop(context);
      var lo1 = jsonEncode(e);
      var lo2 = jsonDecode(lo1);
      showDialog(context: context, builder: (_) => AlertDialog(content: Text("Payment Failed")));

    } catch (e) {
      print('$e');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("$e"),
        duration: Duration(seconds: 8),
        backgroundColor: Colors.red,
      ));
    }
  }

  createStripeIntent(String amount) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currencyData!.code,
      };
      print(body);
      var response = await http.post(Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body, headers: {'Authorization': 'Bearer ${stripeData?.stripeSecret}', 'Content-Type': 'application/x-www-form-urlencoded'});
      print('Create Intent response ===> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      print('error charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }

  /// PayPal Payment Gateway
  /// PayPal Payment Gateway
  paypalPaymentSheet() {
    //add 1 item to cart. Max is 4!
    if (_flutterPaypalNativePlugin.canAddMorePurchaseUnit) {
      _flutterPaypalNativePlugin.addPurchaseUnit(
        FPayPalPurchaseUnit(
          // random prices
          amount: double.parse(gradTotal),

          ///please use your own algorithm for referenceId. Maybe ProductID?
          referenceId: FPayPalStrHelper.getRandomString(16),
        ),
      );
    }
    // initPayPal();
    _flutterPaypalNativePlugin.makeOrder(
      action: FPayPalUserAction.payNow,
    );
  }

  ///MercadoPago Payment Method

  mercadoPagoMakePayment() {
    makePreference().then((result) async {
      if (result.isNotEmpty) {
        var preferenceId = result['response']['id'];

        final bool isDone = await Navigator.push(context, MaterialPageRoute(builder: (context) => MercadoPagoScreen(initialURl: result['response']['init_point'])));
        print(isDone);
        print(result.toString());
        print(preferenceId);

        if (isDone) {
          Navigator.pop(context);
          paymentCompleted(paymentMethod: "Mercado Pago");
        } else {
          Navigator.pop(_scaffoldKey.currentContext!);
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text("Payment UnSuccessful!!".tr() + "\n"),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        hideProgress();

        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text("Error while transaction!".tr() + "\n"),
          backgroundColor: Colors.red,
        ));
      }
    });
  }

  Future<Map<String, dynamic>> makePreference() async {
    final mp = MP.fromAccessToken(mercadoPagoSettingData!.accessToken);
    var pref = {
      "items": [
        {"title": "Wallet TopUp", "quantity": 1, "unit_price": double.parse(gradTotal)}
      ],
      "auto_return": "all",
      "back_urls": {"failure": "${GlobalURL}payment/failure", "pending": "${GlobalURL}payment/pending", "success": "${GlobalURL}payment/success"},
    };

    var result = await mp.createPreference(pref);
    return result;
  }

  ///FlutterWave Payment Method
  String? _ref;

  setRef() {
    Random numRef = Random();
    int year = DateTime.now().year;
    int refNumber = numRef.nextInt(20000);
    if (Platform.isAndroid) {
      setState(() {
        _ref = "AndroidRef$year$refNumber";
      });
    } else if (Platform.isIOS) {
      setState(() {
        _ref = "IOSRef$year$refNumber";
      });
    }
  }

  _flutterWaveInitiatePayment(
    BuildContext context,
  ) async {
    final flutterwave = Flutterwave(
      amount: gradTotal,
      currency: currencyData!.code,
      customer: Customer(name: MyAppState.currentUser!.firstName, phoneNumber: MyAppState.currentUser!.phoneNumber.trim(), email: MyAppState.currentUser!.email.trim()),
      context: context,
      publicKey: flutterWaveSettingData!.publicKey.trim(),
      paymentOptions: "card, payattitude",
      customization: Customization(title: "Foodies"),
      txRef: _ref!,
      redirectUrl: '${GlobalURL}success',
      isTestMode: flutterWaveSettingData!.isSandbox,
    );
    final ChargeResponse response = await flutterwave.charge();
    if (response.toString().isNotEmpty) {
      if (response.success!) {
        paymentCompleted(paymentMethod: "FlutterWave");
      } else {
        showLoading(message: response.status!);
      }
      print("${response.toJson()}");
    } else {
      this.showLoading(message: "No Response!".tr(), txtColor: Colors.red);
    }
  }

  Future<void> showLoading({required String message, Color txtColor = Colors.black}) {
    return showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
            width: double.infinity,
            height: 30,
            child: Text(
              message,
              style: TextStyle(color: txtColor),
            ),
          ),
        );
      },
    );
  }

  ///PayStack Payment Method
  payStackPayment() async {
    await PayStackURLGen.payStackURLGen(
      amount: (double.parse(gradTotal) * 100).toString(),
      currency: "ZAR",
      secretKey: payStackSettingData!.secretKey,
    ).then((value) async {
      if (value != null) {
        PayStackUrlModel _payStackModel = value;
        bool isDone = await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PayStackScreen(
                  secretKey: payStackSettingData!.secretKey,
                  callBackUrl: payStackSettingData!.callbackURL,
                  initialURl: _payStackModel.data.authorizationUrl,
                  amount: gradTotal,
                  reference: _payStackModel.data.reference,
                )));
        Navigator.pop(_scaffoldKey.currentContext!);

        if (isDone) {
          Navigator.pop(context);
          paymentCompleted(paymentMethod: "PayStack");
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text("Payment UnSuccessful!!".tr() + "\n"),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text("Error while transaction!".tr() + "\n"),
          backgroundColor: Colors.red,
        ));
      }
    });
  }
}
