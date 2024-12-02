import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/AddressModel.dart';
import 'package:emartconsumer/model/CodModel.dart';
import 'package:emartconsumer/model/FlutterWaveSettingDataModel.dart';
import 'package:emartconsumer/model/PayFastSettingData.dart';
import 'package:emartconsumer/model/PayStackSettingsModel.dart';
import 'package:emartconsumer/model/ProductModel.dart';
import 'package:emartconsumer/model/createRazorPayOrderModel.dart';
import 'package:emartconsumer/model/payStackURLModel.dart';
import 'package:emartconsumer/model/razorpayKeyModel.dart';
import 'package:emartconsumer/model/stripeSettingData.dart';
import 'package:emartconsumer/model/topupTranHistory.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/services/localDatabase.dart';
import 'package:emartconsumer/services/paystack_url_genrater.dart';
import 'package:emartconsumer/services/rozorpayConroller.dart';
import 'package:emartconsumer/services/show_toast_dialog.dart';
import 'package:emartconsumer/ui/checkoutScreen/CheckoutScreen.dart';
import 'package:emartconsumer/ui/wallet/MercadoPagoScreen.dart';
import 'package:emartconsumer/ui/wallet/PayFastScreen.dart';
import 'package:emartconsumer/ui/wallet/payStackScreen.dart';
import 'package:emartconsumer/userPrefrence.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe1;
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mercadopago_sdk/mercadopago_sdk.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../model/MercadoPagoSettingsModel.dart';
import '../../model/OrderModel.dart';
import '../../model/RazorPayFailedModel.dart';

import '../../model/TaxModel.dart';
import '../../model/User.dart';
import '../../model/VendorModel.dart';
import '../../model/getPaytmTxtToken.dart';
import '../../model/paypalSettingData.dart';
import '../../model/paytmSettingData.dart';
import '../placeOrderScreen/PlaceOrderScreen.dart';

class PaymentScreen extends StatefulWidget {
  final double total;
  final double? discount;
  final String? couponCode;
  final String? couponId, notes;
  final List<CartProduct> products;

  final List<String>? extra_addons;
  final String? tipValue;
  final bool? take_away;
  final String? deliveryCharge;
  final List<TaxModel>? taxModel;
  final Map<String, dynamic>? specialDiscountMap;
  final Timestamp? scheduleTime;
  final AddressModel? addressModel;

  const PaymentScreen(
      {Key? key,
      required this.total,
      this.discount,
      this.couponCode,
      this.couponId,
      required this.products,
      this.extra_addons,
      this.tipValue,
      this.take_away,
      this.deliveryCharge,
      this.notes,
      this.taxModel,
      this.specialDiscountMap,
      this.scheduleTime,
      this.addressModel})
      : super(key: key);

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  String selectedCardID = '';
  final fireStoreUtils = FireStoreUtils();
  late Future<bool> hasNativePay;

  //List<PaymentMethod> _cards = [];
  late Future<CodModel?> futurecod;

  Stream<DocumentSnapshot<Map<String, dynamic>>>? userQuery;

  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String paymentOption = 'Pay Via Wallet'.tr();
  RazorPayModel? razorPayData = UserPreference.getRazorPayData();

  final Razorpay _razorPay = Razorpay();
  StripeSettingData? stripeData;
  PaytmSettingData? paytmSettingData;
  // PaypalSettingData? paypalSettingData;
  PayStackSettingData? payStackSettingData;
  FlutterWaveSettingData? flutterWaveSettingData;
  PayFastSettingData? payFastSettingData;
  MercadoPagoSettingData? mercadoPagoSettingData;

  bool walletBalanceError = false;

  bool isStaging = true;
  String callbackUrl = "http://162.241.125.167/~foodie/payments/paytmpaymentcallback?ORDER_ID=";
  bool restrictAppInvoke = false;
  bool enableAssist = true;
  String result = "";
  String paymentType = "";

  // final _flutterPaypalNativePlugin = FlutterPaypalNative.instance;

  getPaymentSettingData() async {
    userQuery = fireStore.collection(USERS).doc(MyAppState.currentUser!.userID).snapshots();
    await UserPreference.getStripeData().then((value) async {
      stripeData = value;
      stripe1.Stripe.publishableKey = stripeData!.clientpublishableKey;
      stripe1.Stripe.merchantIdentifier = 'Emart';
      await stripe1.Stripe.instance.applySettings();
    });
    razorPayData = await UserPreference.getRazorPayData();
    paytmSettingData = await UserPreference.getPaytmData();
    // paypalSettingData = await UserPreference.getPayPalData();
    payStackSettingData = await UserPreference.getPayStackData();
    flutterWaveSettingData = await UserPreference.getFlutterWaveData();
    payFastSettingData = await UserPreference.getPayFastData();
    mercadoPagoSettingData = await UserPreference.getMercadoPago();

    ///set Refrence for FlutterWave
    setRef();

    // initPayPal();
  }

  // void initPayPal() async {
  //   //set debugMode for error logging
  //   FlutterPaypalNative.isDebugMode = paypalSettingData!.isLive == false ? true : false;
  //   //initiate payPal plugin
  //   await _flutterPaypalNativePlugin.init(
  //     returnUrl: "com.emart.customer://paypalpay",
  //     clientID: paypalSettingData!.paypalClient,
  //     payPalEnvironment: paypalSettingData!.isLive == true ? FPayPalEnvironment.live : FPayPalEnvironment.sandbox,
  //     //what currency do you plan to use? default is US dollars
  //     currencyCode: FPayPalCurrencyCode.usd,
  //     //action paynow?
  //     action: FPayPalUserAction.payNow,
  //   );

  //   //call backs for payment
  //   _flutterPaypalNativePlugin.setPayPalOrderCallback(
  //     callback: FPayPalOrderCallback(
  //       onCancel: () {
  //         //user canceled the payment
  //         Navigator.pop(context);
  //         ShowToastDialog.showToast("Payment canceled");
  //       },
  //       onSuccess: (data) {
  //         //successfully paid
  //         //remove all items from queue
  //         Navigator.pop(context);
  //         _flutterPaypalNativePlugin.removeAllPurchaseItems();
  //         ShowToastDialog.showToast("Payment Successfully");
  //         if (widget.take_away!) {
  //           placeOrder(_scaffoldKey.currentContext!,oid: Uuid().v4());
  //         } else {
  //           toCheckOutScreen(true, _scaffoldKey.currentContext!,oid: Uuid().v4());
  //         }
  //       },
  //       onError: (data) {
  //         //an error occured
  //         Navigator.pop(context);
  //         ShowToastDialog.showToast("error: ${data.reason}");
  //       },
  //       onShippingChange: (data) {
  //         //the user updated the shipping address
  //         Navigator.pop(context);
  //         ShowToastDialog.showToast("shipping change: ${data.shippingChangeAddress?.adminArea1 ?? ""}");
  //       },
  //     ),
  //   );
  // }

  showAlert(context, {required String response, required Color colors}) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(response),
      backgroundColor: colors,
    ));
  }

  @override
  void initState() {
    getPaymentSettingData();
    futurecod = fireStoreUtils.getCod();
    _razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWaller);
    _razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    print("delvery charge ${widget.deliveryCharge}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: false,
      key: _scaffoldKey,
      appBar: AppBar(),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Visibility(
            visible: UserPreference.getWalletData() ?? false,
            child: Column(
              children: [
                const Divider(),
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: userQuery,
                    builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> asyncSnapshot) {
                      if (asyncSnapshot.hasError) {
                        return Text(
                          "error".tr(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        );
                      }
                      if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 0.8,
                                  color: Colors.white,
                                  backgroundColor: Colors.transparent,
                                )));
                      }
                      if (asyncSnapshot.data == null) {
                        return Container();
                      }
                      User userData = User.fromJson(asyncSnapshot.data!.data()!);

                      walletBalanceError = userData.wallet_amount < widget.total ? true : false;
                      return Column(
                        children: [
                          CheckboxListTile(
                            onChanged: (bool? value) {
                              setState(() {
                                if (!walletBalanceError) {
                                  wallet = true;
                                } else {
                                  wallet = false;
                                }
                                payStack = false;
                                mercadoPago = false;
                                flutterWave = false;
                                razorPay = false;
                                codPay = false;
                                payTm = false;
                                pay = false;
                                payFast = false;
                                paypal = false;
                                stripe = false;
                                selectedCardID = '';
                                paymentOption = "Pay Online Via Wallet".tr();
                              });
                            },
                            value: wallet,
                            contentPadding: const EdgeInsets.all(0),
                            secondary: const FaIcon(FontAwesomeIcons.wallet),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Wallet'.tr()),
                                Column(
                                  children: [
                                    Text(
                                      amountShow(amount: userData.wallet_amount.toString()),
                                      //   currencyData!.symbol + double.parse(userData.wallet_amount.toString()).toStringAsFixed(decimal),
                                      style: TextStyle(color: walletBalanceError ? Colors.red : Colors.green, fontWeight: FontWeight.w600, fontSize: 18),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Visibility(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 0.0),
                                  child: walletBalanceError
                                      ? Text(
                                          "Your wallet doesn't have sufficient balance".tr(),
                                          style: const TextStyle(fontSize: 14, color: Colors.red),
                                        )
                                      : Text(
                                          'Sufficient Balance'.tr(),
                                          style: const TextStyle(fontSize: 14, color: Colors.green),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
              ],
            ),
          ),
          Visibility(
            visible: true,
            child: Column(
              children: [
                const Divider(),
                FutureBuilder<CodModel?>(
                    future: futurecod,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator.adaptive(
                            valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                          ),
                        );
                      }
                      if (snapshot.hasData) {
                        if (snapshot.data!.cod == true) {
                          return CheckboxListTile(
                            onChanged: (bool? value) {
                              setState(() {
                                mercadoPago = false;
                                payStack = false;
                                flutterWave = false;
                                razorPay = false;
                                wallet = false;
                                codPay = true; //codPay ? false : true;
                                selectedCardID = '';
                                payTm = false;
                                payFast = false;
                                pay = false;
                                paypal = false;
                                stripe = false;
                                paymentOption = 'Cash on Delivery'.tr();
                              });
                            },
                            value: codPay,
                            contentPadding: const EdgeInsets.all(0),
                            secondary: const FaIcon(FontAwesomeIcons.handHoldingUsd),
                            title: Text('Cash on Delivery'.tr()),
                          );
                        } else {
                          return const Center();
                        }
                      }
                      return const Center();
                    }),
              ],
            ),
          ),
          Visibility(
            visible: razorPayData!.isEnabled,
            child: Column(
              children: [
                const Divider(),
                CheckboxListTile(
                  onChanged: (bool? value) {
                    setState(() {
                      mercadoPago = false;
                      payStack = false;
                      flutterWave = false;
                      wallet = false;
                      razorPay = true; //razorPay ? false : true;
                      codPay = false;
                      payTm = false;
                      pay = false;
                      paypal = false;
                      payFast = false;
                      stripe = false;
                      selectedCardID = '';
                      paymentOption = "Pay Online Via".tr() + "RazorPay";
                    });
                  },
                  value: razorPay,
                  contentPadding: const EdgeInsets.all(0),
                  secondary: const FaIcon(FontAwesomeIcons.amazonPay),
                  title: Text('Razor Pay'.tr()),
                ),
              ],
            ),
          ),
          Visibility(
            visible: (stripeData == null) ? false : stripeData!.isEnabled,
            child: Column(
              children: [
                const Divider(),
                CheckboxListTile(
                  onChanged: (bool? value) {
                    setState(() {
                      mercadoPago = false;
                      payStack = false;
                      flutterWave = false;
                      stripe = true;
                      wallet = false;
                      razorPay = false; //razorPay ? false : true;
                      codPay = false;
                      payTm = false;
                      payFast = false;
                      pay = false;
                      paypal = false;
                      selectedCardID = '';
                      paymentOption = "Pay Online Via".tr() + "Stripe";
                    });
                  },
                  value: stripe,
                  contentPadding: const EdgeInsets.all(0),
                  secondary: const FaIcon(FontAwesomeIcons.stripe),
                  title: Text('Stripe'.tr()),
                ),
              ],
            ),
          ),
          Visibility(
            visible: (paytmSettingData == null) ? false : paytmSettingData!.isEnabled,
            child: Column(
              children: [
                const Divider(),
                CheckboxListTile(
                  onChanged: (bool? value) {
                    setState(() {
                      mercadoPago = false;
                      payStack = false;
                      flutterWave = false;
                      razorPay = false;
                      wallet = false; //razorPay ? false : true;
                      codPay = false;
                      payTm = true;
                      pay = false;
                      payFast = false;
                      paypal = false;
                      stripe = false;
                      selectedCardID = '';
                      paymentOption = "Pay Online Via".tr() + "PayTm";
                    });
                  },
                  value: payTm,
                  contentPadding: const EdgeInsets.all(0),
                  secondary: const FaIcon(FontAwesomeIcons.alipay),
                  title: Text('PayTm'.tr()),
                ),
              ],
            ),
          ),
          Visibility(
            // visible: (paypalSettingData == null) ? false : paypalSettingData!.isEnabled,
            child: Column(
              children: [
                const Divider(),
                CheckboxListTile(
                  onChanged: (bool? value) {
                    setState(() {
                      mercadoPago = false;
                      paypal = true;
                      payStack = false;
                      flutterWave = false;
                      wallet = false;
                      razorPay = false;
                      codPay = false;
                      payTm = false;
                      payFast = false;
                      pay = false;
                      stripe = false;
                      selectedCardID = '';
                      paymentOption = "Pay Online Via".tr() + "PayPal";
                    });
                  },
                  value: paypal,
                  contentPadding: const EdgeInsets.all(0),
                  secondary: const FaIcon(FontAwesomeIcons.paypal),
                  title: Text(' Paypal'.tr()),
                ),
              ],
            ),
          ),
          Visibility(
            visible: false,
            child: Column(
              children: [
                const Divider(),
                CheckboxListTile(
                  onChanged: (bool? value) {
                    setState(() {
                      mercadoPago = false;
                      payStack = false;
                      flutterWave = false;
                      razorPay = false; //razorPay ? false : true;
                      codPay = false;
                      payTm = false;
                      wallet = false;
                      payFast = false;
                      pay = true;
                      paypal = false;
                      stripe = false;
                      selectedCardID = '';
                      paymentOption = "Pay Online Via".tr() + "Pay";
                    });
                  },
                  value: pay,
                  contentPadding: const EdgeInsets.all(0),
                  secondary: const FaIcon(FontAwesomeIcons.googlePay),
                  title: Text(' Pay'.tr()),
                ),
              ],
            ),
          ),
          Visibility(
            visible: (payFastSettingData == null) ? false : payFastSettingData!.isEnable,
            child: Column(
              children: [
                const Divider(),
                CheckboxListTile(
                  onChanged: (bool? value) {
                    setState(() {
                      mercadoPago = false;
                      payFast = true;
                      paypal = false;
                      wallet = false;
                      razorPay = false;
                      payStack = false;
                      codPay = false;
                      payTm = false;
                      pay = false;
                      flutterWave = false;
                      stripe = false;
                      selectedCardID = '';
                      paymentOption = "Pay Online Via".tr() + "PayFast";
                    });
                  },
                  value: payFast,
                  contentPadding: const EdgeInsets.all(0),
                  secondary: Image.asset(
                    'assets/images/payfastmini.png',
                    width: 25,
                    height: 25,
                  ),
                  title: Text(' PayFast'.tr()),
                ),
              ],
            ),
          ),
          Visibility(
            visible: (payStackSettingData == null) ? false : payStackSettingData!.isEnabled,
            child: Column(
              children: [
                const Divider(),
                CheckboxListTile(
                  onChanged: (bool? value) {
                    setState(() {
                      mercadoPago = false;
                      payStack = true;
                      paypal = false;
                      flutterWave = false;
                      wallet = false;
                      razorPay = false;
                      codPay = false;
                      payFast = false;
                      payTm = false;
                      pay = false;
                      stripe = false;
                      selectedCardID = '';
                      paymentOption = "Pay Online Via".tr() + "PayStack";
                    });
                  },
                  value: payStack,
                  contentPadding: const EdgeInsets.all(0),
                  secondary: Image.asset(
                    'assets/images/paystackmini.png',
                    width: 25,
                    height: 25,
                  ),
                  title: Text(' PayStack'.tr()),
                ),
              ],
            ),
          ),
          Visibility(
            visible: (flutterWaveSettingData == null) ? false : flutterWaveSettingData!.isEnable,
            child: Column(
              children: [
                const Divider(),
                CheckboxListTile(
                  onChanged: (bool? value) {
                    setState(() {
                      mercadoPago = false;
                      payStack = false;
                      flutterWave = true;
                      razorPay = false; //razorPay ? false : true;
                      codPay = false;
                      payTm = false;
                      wallet = false;
                      pay = false;
                      payFast = false;
                      paypal = false;
                      stripe = false;
                      selectedCardID = '';
                      paymentOption = "Pay Online Via".tr() + "FlutterWave";
                    });
                  },
                  value: flutterWave,
                  contentPadding: const EdgeInsets.all(0),
                  secondary: const FaIcon(FontAwesomeIcons.moneyBillWave),
                  title: Text(' FlutterWave'.tr()),
                ),
              ],
            ),
          ),
          Visibility(
            visible: (mercadoPagoSettingData == null) ? false : mercadoPagoSettingData!.isEnabled,
            child: Column(
              children: [
                const Divider(),
                CheckboxListTile(
                  onChanged: (bool? value) {
                    setState(() {
                      mercadoPago = true;
                      payFast = false;
                      paypal = false;
                      wallet = false;
                      razorPay = false;
                      payStack = false;
                      codPay = false;
                      payTm = false;
                      pay = false;
                      flutterWave = false;
                      stripe = false;
                      selectedCardID = '';
                      paymentOption = "Pay Online Via".tr() + "Mercado Pago";
                    });
                  },
                  value: mercadoPago,
                  contentPadding: const EdgeInsets.all(0),
                  secondary: Image.asset(
                    'assets/images/payfastmini.png',
                    width: 25,
                    height: 25,
                  ),
                  title: Text(' Mercado Pago'.tr()),
                ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(
            height: 24,
          ),
          ElevatedButton(
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
            onPressed: () async {
              if (razorPay) {
                paymentType = 'razorpay';
                showLoadingAlert();
                RazorPayController().createOrderRazorPay(amount: widget.total.toInt()).then((value) {
                  if (value == null) {
                    Navigator.pop(context);
                    showAlert(_scaffoldKey.currentContext!, response: "Something went wrong, please contact admin.".tr(), colors: Colors.red);
                  } else {
                    CreateRazorPayOrderModel result = value;
                    openCheckout(
                      amount: widget.total,
                      orderId: result.id,
                    );
                  }
                });
              } else if (payFast) {
                paymentType = 'payfast';
                showLoadingAlert();
                PayStackURLGen.getPayHTML(payFastSettingData: payFastSettingData!, amount: widget.total.toString()).then((value) async {
                  bool isDone = await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PayFastScreen(
                            htmlData: value,
                            payFastSettingData: payFastSettingData!,
                          )));

                  print(isDone);
                  if (isDone) {
                    if (widget.take_away!) {
                      placeOrder(_scaffoldKey.currentContext!,oid: Uuid().v4());
                    } else {
                      toCheckOutScreen(true, context,oid: Uuid().v4());
                    }

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        "Payment Successful!!".tr() + "\n",
                      ),
                      backgroundColor: Colors.green.shade400,
                      duration: const Duration(seconds: 6),
                    ));
                  } else {
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
              } else if (payTm) {
                paymentType = 'paytm';
                showLoadingAlert();
                getPaytmCheckSum(context, amount: widget.total);
              } else if (stripe) {
                paymentType = 'stripe';
                showLoadingAlert();
                stripeMakePayment(amount: widget.total.toString());
              } else if (pay) {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) =>
                //             FlutterWavePayService() //UniPaymentService()
                //         ));
              } else if (payStack) {
                paymentType = 'paystack';
                showLoadingAlert();
                payStackPayment(context);
              } else if (mercadoPago) {
                paymentType = 'mercadoPago';
                mercadoPagoMakePayment();
              } else if (flutterWave) {
                paymentType = 'flutterwave';
                _flutterWaveInitiatePayment(context);
              } else if (paypal) {
                paymentType = 'paypal';
                showLoadingAlert();
                // paypalPaymentSheet();
                //  _makePaypalPayment(amount: widget.total.toString());
              } else if (wallet && walletBalanceError == false) {
                paymentType = 'wallet';
                showLoadingAlert();
                TopupTranHistoryModel wallet = TopupTranHistoryModel(
                    amount: widget.total,
                    order_id: Uuid().v4(),
                    serviceType: 'delivery-service',
                    id: Uuid().v4(),
                    user_id: MyAppState.currentUser!.userID,
                    date: Timestamp.now(),
                    isTopup: false,
                    payment_method: "wallet",
                    payment_status: "success",
                    transactionUser: "customer",
                    note: 'Order Amount Payment');

                await FireStoreUtils.firestore.collection("wallet").doc(wallet.id).set(wallet.toJson()).then((value) async {
                  await FireStoreUtils.updateWalletAmount(amount: -widget.total).then((value) {
                    showAlert(_scaffoldKey.currentContext!, response: "Payment Successful Via".tr() + " " "Wallet".tr(), colors: Colors.green);
                    if (widget.take_away!) {
                      placeOrder(_scaffoldKey.currentContext!, oid: wallet.order_id);
                    } else {
                      Navigator.pop(context);
                      toCheckOutScreen(true, context,oid: Uuid().v4());
                    }
                  });
                });
              } else if (codPay) {
                paymentType = 'cod';
                print(DateTime.now().millisecondsSinceEpoch.toString());
                if (widget.take_away!) {
                  placeOrder(_scaffoldKey.currentContext!,oid: Uuid().v4());
                } else {
                  toCheckOutScreen(false, context,oid: Uuid().v4());
                }
              } else {
                final SnackBar snackBar = SnackBar(
                  content: Text(
                    "Select Payment Method".tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Color(COLOR_PRIMARY),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            child: Text(
              'PROCEED'.tr(),
              style: TextStyle(color: isDarkMode(context) ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  bool payStack = false;
  bool flutterWave = false;
  bool wallet = false;
  bool razorPay = false;
  bool payFast = false;
  bool mercadoPago = false;
  bool codPay = false;
  bool payTm = false;
  bool pay = false;
  bool stripe = false;
  bool paypal = false;

  ///RazorPay payment function
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
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Navigator.pop(_scaffoldKey.currentContext!);
    print(response.orderId);
    print(response.paymentId);
    if (widget.take_away!) {
      placeOrder(_scaffoldKey.currentContext!,oid: Uuid().v4());
    } else {
      toCheckOutScreen(true, _scaffoldKey.currentContext!,oid: Uuid().v4());
    }

    ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
      content: Text(
        "Payment Successful!!".tr() + "\n" + response.orderId!,
      ),
      backgroundColor: Colors.green.shade400,
      duration: const Duration(seconds: 6),
    ));
  }

  void _handleExternalWaller(ExternalWalletResponse response) {
    Navigator.pop(_scaffoldKey.currentContext!);
    ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
      content: Text(
        "Payment Processing!! via".tr() + "\n" + response.walletName!,
      ),
      backgroundColor: Colors.blue.shade400,
      duration: const Duration(seconds: 8),
    ));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Navigator.pop(_scaffoldKey.currentContext!);
    print(response.code);
    RazorPayFailedModel lom = RazorPayFailedModel.fromJson(jsonDecode(response.message!.toString()));
    ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
      content: Text(
        "Payment Failed!!".tr() + "\n" + lom.error.description,
      ),
      backgroundColor: Colors.red.shade400,
      duration: const Duration(seconds: 8),
    ));
  }

  ///Stripe payment function
  Map<String, dynamic>? paymentIntentData;

  Future<void> stripeMakePayment({required String amount}) async {
    try {
      paymentIntentData = await createStripeIntent(amount);
      if (paymentIntentData!.containsKey("error")) {
        Navigator.pop(context);
        showAlert(_scaffoldKey.currentContext!, response: "Something went wrong, please contact admin.".tr(), colors: Colors.red);
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
              customFlow: true,
              appearance: stripe1.PaymentSheetAppearance(
                colors: stripe1.PaymentSheetAppearanceColors(
                  primary: Color(COLOR_PRIMARY),
                ),
              ),
              merchantDisplayName: 'Emart',
            ))
            .then((value) {});
        setState(() {});
        displayStripePaymentSheet(amount: amount);
      }
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayStripePaymentSheet({required amount}) async {
    try {
      await stripe1.Stripe.instance.presentPaymentSheet().then((value) async {

        print("wee are in");
        if (widget.take_away!) {
          placeOrder(_scaffoldKey.currentContext!,oid: Uuid().v4());
        } else {
          toCheckOutScreen(true, _scaffoldKey.currentContext!,oid: Uuid().v4());
        }

        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text("Payment Successful!!".tr()),
          duration: const Duration(seconds: 8),
          backgroundColor: Colors.green,
        ));
        paymentIntentData = null;
      }).onError((error, stackTrace) {
        Navigator.pop(_scaffoldKey.currentContext!);
        var lo1 = jsonEncode(error);
        var lo2 = jsonDecode(lo1);
        showDialog(context: context, builder: (_) => AlertDialog(content: Text("Payment Failed")));

      });
    } on stripe1.StripeException catch (e) {
      Navigator.pop(_scaffoldKey.currentContext!);
      var lo1 = jsonEncode(e);
      var lo2 = jsonDecode(lo1);
      showDialog(context: context, builder: (_) => AlertDialog(content: Text("Payment Failed")));

    } catch (e) {
      print('$e');
      Navigator.pop(_scaffoldKey.currentContext!);
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text("$e"),
        duration: const Duration(seconds: 8),
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
    final a = ((double.parse(amount)) * 100).toInt();
    print(a);
    return a.toString();
  }

  ///PayPal payment function
  // paypalPaymentSheet() {
  //   //add 1 item to cart. Max is 4!
  //   if (_flutterPaypalNativePlugin.canAddMorePurchaseUnit) {
  //     _flutterPaypalNativePlugin.addPurchaseUnit(
  //       FPayPalPurchaseUnit(
  //         // random prices
  //         amount: double.parse(widget.total.toString()),

  //         ///please use your own algorithm for referenceId. Maybe ProductID?
  //         referenceId: FPayPalStrHelper.getRandomString(16),
  //       ),
  //     );
  //   }
  //   // initPayPal();
  //   _flutterPaypalNativePlugin.makeOrder(
  //     action: FPayPalUserAction.payNow,
  //   );
  // }

  // _makePaypalPayment({required amount}) async {
  //   PayPalClientTokenGen.paypalClientToken(
  //           paypalSettingData: paypalSettingData!)
  //       .then((value) async {
  //     final String tokenizationKey =
  //         paypalSettingData!.braintree_tokenizationKey;
  //
  //     var request = BraintreePayPalRequest(
  //         amount: amount,
  //         currencyCode: currencyData!.code,
  //         billingAgreementDescription: "djsghxghf",
  //         displayName: 'Foodies company');
  //
  //     BraintreePaymentMethodNonce? resultData;
  //     try {
  //       resultData =
  //           await Braintree.requestPaypalNonce(tokenizationKey, request);
  //     } on Exception catch (ex) {
  //       print("Stripe error");
  //       showAlert(_scaffoldKey.currentContext!,
  //           response: "Something went wrong, please contact admin.".tr(),
  //           colors: Colors.red);
  //     }
  //     print(resultData?.nonce);
  //     print(resultData?.paypalPayerId);
  //     if (resultData?.nonce != null) {
  //       PayPalClientTokenGen.paypalSettleAmount(
  //         paypalSettingData: paypalSettingData!,
  //         nonceFromTheClient: resultData?.nonce,
  //         amount: amount,
  //         deviceDataFromTheClient: resultData?.typeLabel,
  //       ).then((value) {
  //         print('payment done!!');
  //         if (value['success'] == "true" || value['success'] == true) {
  //           if (value['data']['success'] == "true" ||
  //               value['data']['success'] == true) {
  //             payPalSettel.PayPalClientSettleModel settleResult =
  //                 payPalSettel.PayPalClientSettleModel.fromJson(value);
  //
  //             if (widget.take_away!) {
  //               placeOrder(_scaffoldKey.currentContext!);
  //             } else {
  //               toCheckOutScreen(true, _scaffoldKey.currentContext!);
  //             }
  //
  //             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //               content: Text(
  //                 "Status : ${settleResult.data.transaction.status}\n"
  //                 "Transaction id : ${settleResult.data.transaction.id}\n"
  //                 "Amount : ${settleResult.data.transaction.amount}",
  //               ),
  //               duration: const Duration(seconds: 8),
  //               backgroundColor: Colors.green,
  //             ));
  //           } else {
  //             print(value);
  //             payPalCurrModel.PayPalCurrencyCodeErrorModel settleResult =
  //                 payPalCurrModel.PayPalCurrencyCodeErrorModel.fromJson(value);
  //             Navigator.pop(_scaffoldKey.currentContext!);
  //             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //               content:
  //                   Text("Status :".tr() + " ${settleResult.data.message}"),
  //               duration: const Duration(seconds: 8),
  //               backgroundColor: Colors.red,
  //             ));
  //           }
  //         } else {
  //           PayPalErrorSettleModel settleResult =
  //               PayPalErrorSettleModel.fromJson(value);
  //           Navigator.pop(_scaffoldKey.currentContext!);
  //           ScaffoldMessenger.of(_scaffoldKey.currentContext!)
  //               .showSnackBar(SnackBar(
  //             content: Text("Status :".tr() + " ${settleResult.data.message}"),
  //             duration: const Duration(seconds: 8),
  //             backgroundColor: Colors.red,
  //           ));
  //         }
  //       });
  //     } else {
  //       Navigator.pop(_scaffoldKey.currentContext!);
  //       ScaffoldMessenger.of(_scaffoldKey.currentContext!)
  //           .showSnackBar(SnackBar(
  //         content: Text("Status :".tr() + "Payment Unsuccessful!!".tr()),
  //         duration: const Duration(seconds: 8),
  //         backgroundColor: Colors.red,
  //       ));
  //     }
  //   });
  // }

  showLoadingAlert() {
    return showDialog<void>(
      context: _scaffoldKey.currentContext!,
      useRootNavigator: true,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const CircularProgressIndicator(),
              Text('Please wait!!'.tr()),
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

  ///Paytm payment function
  getPaytmCheckSum(
    context, {
    required double amount,
  }) async {
    final String orderId = await UserPreference.getPaymentId();
    print(orderId);
    print('here order ID');
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
    print(data);
    await verifyCheckSum(checkSum: data["code"], amount: amount, orderId: orderId).then((value) {
      initiatePayment(amount: amount, orderId: orderId).then((value) {
        String callback = "";
        if (paytmSettingData!.isSandboxEnabled) {
          callback = callback + "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
        } else {
          callback = callback + "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
        }

        GetPaymentTxtTokenModel result = value;
        _startTransaction(context, txnTokenBy: result.body.txnToken, orderId: orderId, amount: amount, callBackURL: callback);
      });
    });
  }

  Future<void> _startTransaction(
    context, {
    required String txnTokenBy,
    required orderId,
    required double amount,
    required callBackURL,
  }) async {
    try {
      var response = AllInOneSdk.startTransaction(
        paytmSettingData!.PaytmMID,
        orderId,
        amount.toString(),
        txnTokenBy,
        callbackUrl,
        //"https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId",
        isStaging,
        true,
        enableAssist,
      );

      response.then((value) {
        if (value!["RESPMSG"] == "Txn Success") {
          print("txt done!!");
          print(amount);
          if (widget.take_away!) {
            placeOrder(_scaffoldKey.currentContext!,oid: Uuid().v4());
          } else {
            toCheckOutScreen(true, context,oid: Uuid().v4());
            print(amount);
          }
          showAlert(context, response: "Payment Successful!!".tr() + "\n ${value['RESPMSG']}", colors: Colors.green);
        }
      }).catchError((onError) {
        if (onError is PlatformException) {
          print("======>>1");
          Navigator.pop(_scaffoldKey.currentContext!);

          print("Error124 : $onError");
          result = onError.message.toString() + " \n  " + onError.code.toString();
          showAlert(_scaffoldKey.currentContext!, response: onError.message.toString(), colors: Colors.red);
        } else {
          print("======>>2");

          result = onError.toString();
          Navigator.pop(_scaffoldKey.currentContext!);
          showAlert(_scaffoldKey.currentContext!, response: result, colors: Colors.red);
        }
      });
    } catch (err) {
      print("======>>3");
      result = err.toString();
      Navigator.pop(_scaffoldKey.currentContext!);
      showAlert(_scaffoldKey.currentContext!, response: result, colors: Colors.red);
    }
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
    print(data);
    print('here one');
    print(checkSum);
    print(data['status']);
    return data['status'];
  }

  Future<GetPaymentTxtTokenModel> initiatePayment({required double amount, required orderId}) async {
    String initiateURL = "${GlobalURL}payments/initiatepaytmpayment";
    print('payment initiated now!@!');
    String callback = "";
    if (paytmSettingData!.isSandboxEnabled) {
      callback = callback + "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
    } else {
      callback = callback + "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
    }
    final response = await http.post(Uri.parse(initiateURL), headers: {}, body: {
      "mid": paytmSettingData?.PaytmMID,
      "order_id": orderId,
      "key_secret": paytmSettingData?.PAYTM_MERCHANT_KEY.toString(),
      "amount": amount.toString(),
      "currency": currencyData!.code,
      "callback_url": callback,
      "custId": MyAppState.currentUser!.userID,
      "issandbox": paytmSettingData!.isSandboxEnabled ? "1" : "2",
    });
    print(response.body);
    final data = jsonDecode(response.body);
    print(data);
    if (data["body"]["txnToken"] == null || data["body"]["txnToken"].toString().isEmpty) {
      Navigator.pop(_scaffoldKey.currentContext!);
      showAlert(_scaffoldKey.currentContext!, response: "something went wrong, please contact admin.".tr(), colors: Colors.red);
    }
    return GetPaymentTxtTokenModel.fromJson(data);
  }

  ///PayStack Payment Method
  payStackPayment(BuildContext context) async {
    await PayStackURLGen.payStackURLGen(
      amount: (widget.total * 100).toString(),
      currency: currencyData!.code,
      secretKey: payStackSettingData!.secretKey,
    ).then((value) async {
      if (value != null) {
        PayStackUrlModel _payStackModel = value;
        bool isDone = await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PayStackScreen(
                  secretKey: payStackSettingData!.secretKey,
                  callBackUrl: payStackSettingData!.callbackURL,
                  initialURl: _payStackModel.data.authorizationUrl,
                  amount: widget.total.toString(),
                  reference: _payStackModel.data.reference,
                )));
        //Navigator.pop(_globalKey.currentContext!);

        if (isDone) {
          if (widget.take_away!) {
            placeOrder(_scaffoldKey.currentContext!,oid: Uuid().v4());
          } else {
            toCheckOutScreen(true, _scaffoldKey.currentContext!,oid: Uuid().v4());
          }
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text("Payment Successful!!".tr() + "\n"),
            backgroundColor: Colors.green,
          ));
        } else {
          Navigator.pop(_scaffoldKey.currentContext!);
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text("Payment UnSuccessful!!".tr() + "\n"),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        Navigator.pop(_scaffoldKey.currentContext!);
        showAlert(_scaffoldKey.currentContext!, response: "something went wrong, please contact admin.".tr(), colors: Colors.red);
      }
    });
  }

  ///MercadoPago Payment Method

  mercadoPagoMakePayment() {
    makePreference().then((result) async {
      if (result.isNotEmpty) {
        var client_id = result['response']['client_id'];
        var preferenceId = result['response']['id'];
        print("uday");
        print(result);
        print(result['response']['init_point']);

        final bool isDone = await Navigator.push(context, MaterialPageRoute(builder: (context) => MercadoPagoScreen(initialURl: result['response']['init_point'])));
        print(isDone);
        print(result.toString());
        print(preferenceId);

        if (isDone) {
          if (widget.take_away!) {
            placeOrder(_scaffoldKey.currentContext!,oid: Uuid().v4());
          } else {
            toCheckOutScreen(true, _scaffoldKey.currentContext!,oid: Uuid().v4());
          }
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text("Payment Successful!!".tr() + "\n"),
            backgroundColor: Colors.green,
          ));
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
        {"title": "Wallet TopUp", "quantity": 1, "unit_price": double.parse(widget.total.toString().trim())}
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
      amount: widget.total.toString().trim(),
      currency: currencyData!.code,
      customer: Customer(name: MyAppState.currentUser!.firstName, phoneNumber: MyAppState.currentUser!.phoneNumber.trim(), email: MyAppState.currentUser!.email.trim()),
      context: context,
      publicKey: flutterWaveSettingData!.publicKey.trim(),
      paymentOptions: "card, payattitude",
      customization: Customization(title: "Flutterwave"),
      txRef: _ref!,
      isTestMode: flutterWaveSettingData!.isSandbox,
      redirectUrl: '${GlobalURL}success',
    );
    final ChargeResponse response = await flutterwave.charge();
    if (response.success!) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text("Payment Successful!!".tr() + "\n"),
        backgroundColor: Colors.green,
      ));
      if (widget.take_away!) {
        placeOrder(_scaffoldKey.currentContext!,oid: Uuid().v4());
      } else {
        toCheckOutScreen(true, _scaffoldKey.currentContext!,oid: Uuid().v4());
      }
    } else {
      showLoading(message: response.status!);
    }
    print("${response.toJson()}");
  }

  Future<void> showLoading({required String message, Color txtColor = Colors.black}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            margin: const EdgeInsets.fromLTRB(30, 20, 30, 20),
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

  placeOrder(BuildContext buildContext, {required String oid}) async {
    FireStoreUtils fireStoreUtils = FireStoreUtils();
    List<CartProduct> tempProduc = [];
    if (paymentType.isEmpty) {
      ShowDialogToDismiss(title: "Empty payment type".tr(), buttonText: "ok".tr(), content: "Select payment type".tr());
      return;
    }

    for (CartProduct cartProduct in widget.products) {
      CartProduct tempCart = cartProduct;
      tempProduc.add(tempCart);
    }

    //place order
    showProgress(buildContext, 'Placing Order...'.tr(), false);
    VendorModel vendorModel = await fireStoreUtils.getVendorByVendorID(widget.products.first.vendorID).whenComplete(() => setPrefData());
    OrderModel orderModel = OrderModel(
      id : oid.toString(),
      address: widget.addressModel,
      author: MyAppState.currentUser,
      authorID: MyAppState.currentUser!.userID,
      createdAt: Timestamp.now(),
      products: tempProduc,
      status: ORDER_STATUS_PLACED,
      vendor: vendorModel,
      payment_method: paymentType,
      notes: widget.notes,
      taxModel: widget.taxModel,
      vendorID: widget.products.first.vendorID,
      discount: widget.discount,
      couponCode: widget.couponCode,
      couponId: widget.couponId,
      sectionId: sectionConstantModel!.id,
      adminCommission: sectionConstantModel!.adminCommision!.commission.toString(),
      adminCommissionType: sectionConstantModel!.adminCommision!.type,
      specialDiscount: widget.specialDiscountMap,
      takeAway: true,
      scheduleTime: widget.scheduleTime,
    );

    OrderModel placedOrder = await fireStoreUtils.placeOrderWithTakeAWay(orderModel);

    for (int i = 0; i < tempProduc.length; i++) {
      await FireStoreUtils().getProductByID(tempProduc[i].id.split('~').first).then((value) async {
        ProductModel? productModel = value;
        if (tempProduc[i].variant_info != null) {
          for (int j = 0; j < productModel.itemAttributes!.variants!.length; j++) {
            if (productModel.itemAttributes!.variants![j].variant_id == tempProduc[i].id.split('~').last) {
              if (productModel.itemAttributes!.variants![j].variant_quantity != "-1") {
                productModel.itemAttributes!.variants![j].variant_quantity =
                    (int.parse(productModel.itemAttributes!.variants![j].variant_quantity.toString()) - tempProduc[i].quantity).toString();
              }
            }
          }
        } else {
          if (productModel.quantity != -1) {
            productModel.quantity = productModel.quantity - tempProduc[i].quantity;
          }
        }

        await FireStoreUtils.updateProduct(productModel).then((value) {});
      });
    }

    hideProgress();

    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      context: buildContext,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceOrderScreen(orderModel: placedOrder),
    );
  }

  Future<void> setPrefData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    sp.setString("musics_key", "");
    sp.setString("addsize", "");
  }

  toCheckOutScreen(bool val, BuildContext context, {required String oid}) {
    push(
      context,
      CheckoutScreen(
        id: oid,
        isPaymentDone: val,
        paymentType: paymentType,
        total: widget.total,
        discount: widget.discount!,
        couponCode: widget.couponCode!,
        couponId: widget.couponId!,
        notes: widget.notes!,
        paymentOption: paymentOption,
        products: widget.products,
        deliveryCharge: widget.deliveryCharge,
        tipValue: widget.tipValue,
        take_away: widget.take_away,
        taxModel: widget.taxModel,
        specialDiscountMap: widget.specialDiscountMap,
        scheduleTime: widget.scheduleTime,
        address: widget.addressModel,
      ),
    );
  }
}
