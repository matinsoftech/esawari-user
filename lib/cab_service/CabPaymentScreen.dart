import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/CabOrderModel.dart';
import 'package:emartconsumer/model/CodModel.dart';
import 'package:emartconsumer/model/FlutterWaveSettingDataModel.dart';
import 'package:emartconsumer/model/MercadoPagoSettingsModel.dart';
import 'package:emartconsumer/model/PayFastSettingData.dart';
import 'package:emartconsumer/model/PayStackSettingsModel.dart';
import 'package:emartconsumer/model/RazorPayFailedModel.dart';

import 'package:emartconsumer/model/TaxModel.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/model/createRazorPayOrderModel.dart';
import 'package:emartconsumer/model/getPaytmTxtToken.dart';
import 'package:emartconsumer/model/offer_model.dart';
import 'package:emartconsumer/model/payStackURLModel.dart';
import 'package:emartconsumer/model/paypalSettingData.dart';
import 'package:emartconsumer/model/paytmSettingData.dart';
import 'package:emartconsumer/model/razorpayKeyModel.dart';
import 'package:emartconsumer/model/stripeSettingData.dart';
import 'package:emartconsumer/model/topupTranHistory.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/services/paystack_url_genrater.dart';
import 'package:emartconsumer/services/rozorpayConroller.dart';
import 'package:emartconsumer/services/show_toast_dialog.dart';
import 'package:emartconsumer/ui/wallet/MercadoPagoScreen.dart';
import 'package:emartconsumer/ui/wallet/PayFastScreen.dart';
import 'package:emartconsumer/ui/wallet/payStackScreen.dart';
import 'package:emartconsumer/userPrefrence.dart';
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
import 'package:flutter_stripe/flutter_stripe.dart' as stripe1;
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:http/http.dart' as http;
import 'package:mercadopago_sdk/mercadopago_sdk.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';

class CabPaymentScreen extends StatefulWidget {
  final CabOrderModel? cabOrderModel;
  final List<TaxModel>? taxModel;

  const CabPaymentScreen({Key? key, required this.cabOrderModel, this.taxModel}) : super(key: key);

  @override
  _CabPaymentScreenState createState() => _CabPaymentScreenState();
}

class _CabPaymentScreenState extends State<CabPaymentScreen> {
  late Future<List<OfferModel>> coupon;
  late Future<List<OfferModel>> publicoupon;
  TextEditingController txt = TextEditingController(text: '');
  final FireStoreUtils _fireStoreUtils = FireStoreUtils();
  var tipValue = 0.0;
  bool isTipSelected = false, isTipSelected1 = false, isTipSelected2 = false, isTipSelected3 = false;
  final TextEditingController _textFieldController = TextEditingController();

  final Razorpay _razorPay = Razorpay();

  @override
  void initState() {
    super.initState();
    print("----->${widget.cabOrderModel!.paymentMethod}");
    setAllFalse(value: widget.cabOrderModel!.paymentMethod.toString() == "cod" ? "Cash".tr() : widget.cabOrderModel!.paymentMethod.toString());

    if (widget.cabOrderModel!.paymentMethod == "stripe") {
      selectedRadioTile = "Stripe";
    }
    if (widget.cabOrderModel!.paymentMethod == "cod") {
      selectedRadioTile = "Cash";
    }
    if (widget.cabOrderModel!.paymentMethod == "paytm") {
      selectedRadioTile = "PayTm";
    }
    if (widget.cabOrderModel!.paymentMethod == "razorpay") {
      selectedRadioTile = "RazorPay";
    }
    if (widget.cabOrderModel!.paymentMethod == "wallet") {
      selectedRadioTile = "Wallet";
    }
    if (widget.cabOrderModel!.paymentMethod == "paypal") {
      selectedRadioTile = "PayPal";
    }
    if (widget.cabOrderModel!.paymentMethod == "payfast") {
      selectedRadioTile = "PayFast";
    }
    if (widget.cabOrderModel!.paymentMethod == "paystack") {
      selectedRadioTile = "PayStack";
    }
    if (widget.cabOrderModel!.paymentMethod == "flutterwave") {
      selectedRadioTile = "FlutterWave";
    }
    if (widget.cabOrderModel!.paymentMethod == "mercadoPago") {
      selectedRadioTile = "Mercado Pago";
    }

    getTexDetails();
    getPaymentSettingData();
    _razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWaller);
    _razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    publicoupon = _fireStoreUtils.getOfferByCabCoupons();
    coupon = _fireStoreUtils.getCabCoupons();
    setState(() {});
  }

  double subTotal = 0.0;

  double discountAmount = 0.0;
  String discountType = "";
  String discountLable = "";
  String offerCode = "";

  List<OfferModel> couponList = [];

  getTexDetails() async {
    subTotal = double.parse(widget.cabOrderModel!.subTotal.toString());
    //await coupon.then((value) {
    await publicoupon.then((value) {
      couponList = value;
    });
    setState(() {});
  }

  // double getTaxAmount() {
  //   double totalTax = 0.0;
  //
  //   if (taxActive == true) {
  //     if (taxType == "percent") {
  //       totalTax = (subTotal - discountAmount) * taxAmount / 100;
  //     } else {
  //       totalTax = taxAmount;
  //     }
  //   }
  //   return totalTax;
  // }

  double getTotalAmount() {
    double taxAmount = 0.0;
    if (taxList != null) {
      for (var element in taxList!) {
        taxAmount = taxAmount + getTaxValue(amount: (subTotal - discountAmount).toString(), taxModel: element);
      }
    }
    return subTotal - discountAmount + taxAmount + tipValue;
  }

  // double getTotalAmount() {
  // return subTotal - discountAmount + getTaxAmount() + tipValue;
  //}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //setPrefData();
  }

  placeOrderChanges() async {
    CabOrderModel? orderModel = widget.cabOrderModel;
    orderModel!.tipValue = tipValue.toString();
    orderModel.paymentMethod = paymentType;
    /* if (taxActive != null && taxActive == true) {
      orderModel.taxType = taxType.toString();
      orderModel.tax = taxAmount.toString();
    }*/
    orderModel.discount = discountAmount;
    orderModel.adminCommission = sectionConstantModel!.adminCommision!.commission.toString();
    orderModel.adminCommissionType = sectionConstantModel!.adminCommision!.type;
    orderModel.paymentStatus = true;
    orderModel.taxModel = taxList;

    await FireStoreUtils().cabOrderPlace(orderModel, true);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Text(
          'Payment'.tr(),
          style: TextStyle(color: isDarkMode(context) ? const Color(0xffFFFFFF) : Colors.black),
        ).tr(),
      ),
      backgroundColor: isDarkMode(context) ? Colors.black : const Color(0xffFFFFFF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            couponList.isNotEmpty ? buildListPromoCode() : Container(),
            buildTotalRow(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: paymentListView(),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
          onPressed: () async {
            if (razorPay) {
              paymentType = 'razorpay';
              showLoadingAlert();
              RazorPayController().createOrderRazorPay(amount: getTotalAmount().toInt()).then((value) {
                if (value == null) {
                  Navigator.pop(context);
                  showAlert(_globalKey.currentContext!, response: "contact-admin".tr(), colors: Colors.red);
                } else {
                  CreateRazorPayOrderModel result = value;
                  openCheckout(
                    amount: getTotalAmount(),
                    orderId: result.id,
                  );
                }
              });
            } else if (payTm) {
              paymentType = 'paytm';
              showLoadingAlert();
              getPaytmCheckSum(context, amount: getTotalAmount());
            } else if (stripe) {
              paymentType = 'stripe';
              showLoadingAlert();
              stripeMakePayment(amount: getTotalAmount().toString());
            } else if (payFast) {
              paymentType = 'payfast';
              showLoadingAlert();
              PayStackURLGen.getPayHTML(payFastSettingData: payFastSettingData!, amount: getTotalAmount().toStringAsFixed(currencyData!.decimal)).then((value) async {
                bool isDone = await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PayFastScreen(
                          htmlData: value,
                          payFastSettingData: payFastSettingData!,
                        )));

                print(isDone);
                if (isDone) {
                  Navigator.pop(context, true);
                  placeOrderChanges();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text(
                      "Payment Successful!!\n",
                    ).tr(),
                    backgroundColor: Colors.green.shade400,
                    duration: const Duration(seconds: 6),
                  ));
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Builder(builder: (context) {
                      return const Text(
                        "Payment UnSuccessful!!\n",
                      ).tr();
                    }),
                    backgroundColor: Colors.red.shade400,
                    duration: const Duration(seconds: 6),
                  ));
                }
              });
            } else if (payStack) {
              paymentType = 'paystack';
              showLoadingAlert();
              payStackPayment(context);
            } else if (flutterWave) {
              setRef();
              paymentType = 'flutterwave';
              _flutterWaveInitiatePayment(context);
            } else if (paypal) {
              paymentType = 'paypal';
              showLoadingAlert();
              //  _makePaypalPayment(amount: getTotalAmount().toString());
              paypalPaymentSheet(amount: getTotalAmount().toString());
            } else if (wallet && walletBalanceError == false) {
              paymentType = 'wallet';

              showLoadingAlert();

              TopupTranHistoryModel wallet = TopupTranHistoryModel(
                  amount: getTotalAmount(),
                  order_id: widget.cabOrderModel!.id,
                  serviceType: 'cab-service',
                  id: Uuid().v4(),
                  user_id: MyAppState.currentUser!.userID,
                  date: Timestamp.now(),
                  isTopup: false,
                  payment_method: "wallet",
                  payment_status: "success",
                  transactionUser: "customer",
                  note: 'Cab Booking Amount Payment');

              await FireStoreUtils.firestore.collection("wallet").doc(wallet.id).set(wallet.toJson()).then((value) {
                FireStoreUtils.updateWalletAmount(amount: -getTotalAmount()).then((value) {
                  Navigator.pop(context, true);
                }).whenComplete(() {
                  placeOrderChanges();
                  showAlert(_globalKey.currentContext!, response: "Payment Successful Via Wallet".tr(), colors: Colors.green);
                });
              });
            } else if (codPay) {
              paymentType = 'cod';
              placeOrderChanges();

              // print(DateTime.now().millisecondsSinceEpoch.toString());
              // if (widget.take_away!) {
              //   placeOrder(_globalKey.currentContext!);
              // } else {
              //   toCheckOutScreen(false, context);
              // }
            } else if (mercadoPago) {
              paymentType = 'mercadoPago';
              mercadoPagoMakePayment();
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
      ),
    );
  }

  buildListPromoCode() {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(left: 13, top: 10, right: 13, bottom: 13),
        decoration: BoxDecoration(
          color: isDarkMode(context) ? Colors.grey.shade700 : Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 2,
              offset: const Offset(0, 2), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15),
          child: SizedBox(
            height: 85,
            child: ListView.builder(
                itemCount: couponList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (couponList[index].discountTypeOffer == 'Percentage' || couponList[index].discountTypeOffer == 'Percent') {
                        discountAmount = subTotal * double.parse(couponList[index].discountOffer!) / 100;
                        discountType = couponList[index].discountTypeOffer.toString();
                        discountLable = couponList[index].discountOffer.toString();
                        offerCode = couponList[index].offerCode.toString();
                      } else {
                        discountAmount = double.parse(couponList[index].discountOffer!);
                        discountType = couponList[index].discountTypeOffer.toString();
                        discountLable = couponList[index].discountOffer.toString();
                        offerCode = couponList[index].offerCode.toString();
                      }

                      print(discountAmount);
                      setState(() {});
                    },
                    child: buildOfferItem(couponList, index),
                  );
                }),
          ),
        ),
      ),
    );
  }

  Widget buildOfferItem(List<OfferModel> snapshot, int index) {
    return Container(
      margin: const EdgeInsets.fromLTRB(7, 10, 7, 10),
      height: 85,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(2),
        padding: const EdgeInsets.all(2),
        color: const Color(COUPON_DASH_COLOR),
        strokeWidth: 2,
        dashPattern: const [5],
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
              ),
              margin: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Image(
                        image: AssetImage('assets/images/offer_icon.png'),
                        height: 25,
                        width: 25,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        child: Text(
                          snapshot[index].discountTypeOffer == "Fix Price"
                              ? (currencyData!.symbolatright == true)
                                  ? "${snapshot[index].discountOffer}${currencyData!.symbol.toString()} OFF"
                                  : "${currencyData!.symbol.toString()}${snapshot[index].discountOffer} OFF"
                              : "${snapshot[index].discountOffer} % Off",
                          style: const TextStyle(color: Color(GREY_TEXT_COLOR), fontWeight: FontWeight.bold, letterSpacing: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        snapshot[index].offerCode!,
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, letterSpacing: 0.5, color: Color(GREY_TEXT_COLOR)),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 15, right: 15, top: 3),
                        width: 1,
                        color: const Color(COUPON_DASH_COLOR),
                      ),
                      Text("valid till ".tr() + getDate(snapshot[index].expireOfferDate!.toDate().toString())!,
                          style: const TextStyle(letterSpacing: 0.5, color: Color(0Xff696A75)))
                    ],
                  ),
                ],
              )),
        ),
      ),
    );
  }

  String? getDate(String date) {
    final format = DateFormat("MMM dd, yyyy");
    String formattedDate = format.format(DateTime.parse(date));
    return formattedDate;
  }

  Widget buildTotalRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            margin: const EdgeInsets.only(left: 13, top: 13, right: 13, bottom: 13),
            decoration: BoxDecoration(
              color: isDarkMode(context) ? Colors.grey.shade700 : Colors.white,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: const Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Image(
                    image: AssetImage("assets/images/reedem.png"),
                    width: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      children: [
                        Text(
                          "Redeem Coupon".tr(),
                          style: const TextStyle(),
                        ),
                        Text("Add coupon code".tr(), style: const TextStyle()),
                      ],
                    ),
                  )
                ]),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        isDismissible: true,
                        context: context,
                        backgroundColor: Colors.transparent,
                        enableDrag: true,
                        builder: (BuildContext context) => sheet());
                  },
                  child: const Image(image: AssetImage("assets/images/add.png"), width: 40),
                )
              ],
            )),
        Container(
          margin: const EdgeInsets.only(left: 13, top: 10, right: 13, bottom: 13),
          decoration: BoxDecoration(
            color: isDarkMode(context) ? Colors.grey.shade700 : Colors.white,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 2,
                offset: const Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Subtotal".tr(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        amountShow(amount: subTotal.toString()),
                        style: TextStyle(color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff333333), fontSize: 16),
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
                        "Discount".tr(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        "(-" + amountShow(amount: discountAmount.toString()) + ")",
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ],
                  )),
              Visibility(
                visible: offerCode.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Text(
                    "Coupon code :".tr() + "${offerCode}",
                    style: TextStyle(fontWeight: FontWeight.w600, color: Color(COLOR_PRIMARY), fontSize: 16),
                  ),
                ),
              ),
              const Divider(
                thickness: 1,
              ),
              ListView.builder(
                itemCount: taxList!.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  TaxModel taxModel = taxList![index];
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${taxModel.title.toString()} (${taxModel.type == "fix" ? amountShow(amount: taxModel.tax) : "${taxModel.tax}%"})",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            Text(
                              amountShow(amount: getTaxValue(amount: (subTotal - discountAmount).toString(), taxModel: taxModel).toString()),
                              style: TextStyle(color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff333333), fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                    ],
                  );
                },
              ),
              // Container(
              //     padding:
              //         const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text(
              //           ((taxLable.isNotEmpty)
              //                   ? taxLable.toString()
              //                   : "Tax".tr()) +
              //               " ${(taxType == "fix") ? "(${taxAmount} ${currencyData!.symbol})" : "($taxAmount %)"}",
              //           style: const TextStyle(fontSize: 16),
              //         ),
              //         Text(
              //           amountShow(amount:getTaxAmount().toString()),
              //           style: TextStyle(
              //               color: isDarkMode(context)
              //                   ? const Color(0xffFFFFFF)
              //                   : const Color(0xff333333),
              //               fontSize: 16),
              //         ),
              //       ],
              //     )),
              // const Divider(
              //   color: Color(0xffE2E8F0),
              //   height: 0.1,
              // ),
              Visibility(
                  visible: ((tipValue) > 0),
                  child: Column(
                    children: [
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Tip amount".tr(),
                                style: TextStyle(color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff333333), fontSize: 16),
                              ),
                              Text(
                                amountShow(amount: tipValue.toString()),
                                style: TextStyle(color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff333333), fontSize: 16),
                              ),
                            ],
                          )),
                      const Divider(
                        thickness: 1,
                      ),
                    ],
                  )),

              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order Total".tr(),
                        style: TextStyle(color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff333333), fontSize: 16),
                      ),
                      Text(
                        amountShow(amount: getTotalAmount().toString()),
                        style: TextStyle(color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff333333), fontSize: 16),
                      ),
                    ],
                  )),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tip your delivery partner".tr(),
                textAlign: TextAlign.start,
                style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff333333), fontSize: 15),
              ),
              Text(
                "100% of the tip will go to your delivery partner".tr(),
                style: const TextStyle(color: Color(0xff9091A4), fontSize: 14),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isTipSelected) {
                          isTipSelected = false;
                          tipValue = 0;
                        } else {
                          tipValue = 10;
                          isTipSelected = true;
                        }

                        isTipSelected1 = false;
                        isTipSelected2 = false;
                        isTipSelected3 = false;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 5),
                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                      decoration: BoxDecoration(
                        color: tipValue == 10 && isTipSelected
                            ? Color(COLOR_PRIMARY)
                            : isDarkMode(context)
                                ? Colors.black
                                : const Color(0xffFFFFFF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xff9091A4), width: 1),
                      ),
                      child: Center(
                          child: Text(
                        amountShow(amount: "10"),
                        style: TextStyle(color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff333333), fontSize: 14),
                      )),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isTipSelected1) {
                          isTipSelected1 = false;
                          tipValue = 0;
                        } else {
                          tipValue = 20;
                          isTipSelected1 = true;
                        }
                        isTipSelected = false;
                        isTipSelected2 = false;
                        isTipSelected3 = false;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 5),
                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                      decoration: BoxDecoration(
                        color: tipValue == 20 && isTipSelected1
                            ? Color(COLOR_PRIMARY)
                            : isDarkMode(context)
                                ? Colors.black
                                : const Color(0xffFFFFFF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xff9091A4), width: 1),
                      ),
                      child: Center(
                          child: Text(
                        amountShow(amount: "20"),
                        style: TextStyle(color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff333333), fontSize: 14),
                      )),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isTipSelected2) {
                          isTipSelected2 = false;
                          tipValue = 0;
                        } else {
                          tipValue = 30;
                          isTipSelected2 = true;
                        }

                        isTipSelected = false;
                        isTipSelected1 = false;

                        isTipSelected3 = false;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 5),
                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                      decoration: BoxDecoration(
                        color: tipValue == 30 && isTipSelected2
                            ? Color(COLOR_PRIMARY)
                            : isDarkMode(context)
                                ? Colors.black
                                : const Color(0xffFFFFFF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xff9091A4), width: 1),
                      ),
                      child: Center(
                          child: Text(
                        //symbol + "30",
                        amountShow(amount: "30"),
                        style: TextStyle(color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff333333), fontSize: 14),
                      )),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (isTipSelected3) {
                          setState(() {
                            if (isTipSelected3) {
                              isTipSelected3 = false;
                              tipValue = 0;
                            }
                            isTipSelected = false;
                            isTipSelected1 = false;
                            isTipSelected2 = false;
                            // grandtotal += tipValue;
                          });
                        } else {
                          _displayDialog(context);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        decoration: BoxDecoration(
                          color: isTipSelected3
                              ? Color(COLOR_PRIMARY)
                              : isDarkMode(context)
                                  ? Colors.black
                                  : const Color(0xffFFFFFF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xff9091A4), width: 1),
                        ),
                        child: Center(
                            child: Text(
                          "Other".tr(),
                          style: TextStyle(color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff333333), fontSize: 14),
                        )),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  sheet() {
    return Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 4.3, left: 25, right: 25),
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(color: Colors.transparent, border: Border.all(style: BorderStyle.none)),
        child: FutureBuilder<List<OfferModel>>(
            future: coupon,
            initialData: const [],
            builder: (context, snapshot) {
              snapshot = snapshot;
              print(snapshot.data!.length.toString() + "[][]][][][][][][][][]][][====");
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                  ),
                );
              }

              // coupon = snapshot.data as Future<List<CouponModel>> ;
              return Column(children: [
                InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 0.3), color: Colors.transparent, shape: BoxShape.circle),

                      // radius: 20,
                      child: const Center(
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    )),
                const SizedBox(
                  height: 25,
                ),
                Expanded(
                    child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                            padding: const EdgeInsets.only(top: 30),
                            child: const Image(
                              image: AssetImage('assets/images/redeem_coupon.png'),
                              width: 100,
                            )),
                        Container(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              'Redeem Your Coupons'.tr(),
                              style: const TextStyle(color: Color(0XFF2A2A2A), fontSize: 16),
                            )),
                        Container(
                            padding: const EdgeInsets.only(top: 10),
                            child: const Text(
                              "Voucher or Coupon code",
                              style: TextStyle(color: Color(0XFF9091A4), letterSpacing: 0.5, height: 2),
                            ).tr()),
                        Container(
                            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                            // height: 120,
                            child: DottedBorder(
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(12),
                                dashPattern: const [4, 2],
                                color: const Color(0XFFB7B7B7),
                                child: ClipRRect(
                                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                                    child: Container(
                                        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                                        color: const Color(0XFFF1F4F7),
                                        // height: 120,
                                        alignment: Alignment.center,
                                        child: TextFormField(
                                          textAlign: TextAlign.center,
                                          controller: txt,
                                          style: TextStyle(color: Colors.black),
                                          // textAlignVertical: TextAlignVertical.center,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Write Coupon Code".tr(),
                                            hintStyle: const TextStyle(color: Color(0XFF9091A4)),
                                            labelStyle: const TextStyle(color: Color(0XFF333333)),
                                            //  hintTextDirection: TextDecoration.lineThrough
                                            // contentPadding: EdgeInsets.only(left: 80,right: 30),
                                          ),
                                        ))))),
                        Padding(
                          padding: const EdgeInsets.only(top: 30, bottom: 30),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                              backgroundColor: Color(COLOR_PRIMARY),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                for (int a = 0; a < snapshot.data!.length; a++) {
                                  OfferModel couponModel = snapshot.data![a];
                                  if (txt.text.toString() == couponModel.offerCode!.toString()) {
                                    if (couponModel.discountTypeOffer == 'Percentage' || couponModel.discountTypeOffer == 'Percent') {
                                      discountAmount = subTotal * double.parse(couponModel.discountOffer!) / 100;
                                      offerCode = couponModel.offerCode.toString();
                                      break;
                                    } else {
                                      discountAmount = double.parse(couponModel.discountOffer!);
                                      offerCode = couponModel.offerCode.toString();
                                    }
                                  }
                                }
                              });

                              Navigator.pop(context);
                            },
                            child: Text(
                              "REDEEM NOW".tr(),
                              style: TextStyle(color: isDarkMode(context) ? Colors.black : Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                //buildcouponItem(snapshot)
                //  listData(snapshot)
              ]);
            }));
  }

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('Tip your driver partner'.tr()),
            content: TextField(
              controller: _textFieldController,
              textInputAction: TextInputAction.go,
              keyboardType: const TextInputType.numberWithOptions(),
              decoration: InputDecoration(hintText: "Enter your tip".tr()),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(COLOR_PRIMARY), textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal)),
                child: const Text('cancel').tr(),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(COLOR_PRIMARY), textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal)),
                child: const Text('Submit').tr(),
                onPressed: () {
                  setState(() {
                    var value = _textFieldController.text.toString();
                    if (value.isEmpty) {
                      isTipSelected3 = false;
                      tipValue = 0;
                    } else {
                      isTipSelected3 = true;
                      tipValue = double.parse(value);
                    }
                    isTipSelected = false;
                    isTipSelected1 = false;
                    isTipSelected2 = false;

                    Navigator.of(context).pop();
                  });
                },
              )
            ],
          );
        });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>>? userQuery;
  final fireStoreUtils = FireStoreUtils();
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;
  StripeSettingData? stripeData;
  PaytmSettingData? paytmSettingData;
  PaypalSettingData? paypalSettingData;
  PayStackSettingData? payStackSettingData;
  FlutterWaveSettingData? flutterWaveSettingData;
  PayFastSettingData? payFastSettingData;
  MercadoPagoSettingData? mercadoPagoSettingData;

  RazorPayModel? razorPayData = UserPreference.getRazorPayData();

  showAlert(BuildContext context123, {required String response, required Color colors}) {
    return ScaffoldMessenger.of(context123).showSnackBar(SnackBar(
      content: Text(response),
      backgroundColor: colors,
    ));
  }

  getPaymentSettingData() async {
    userQuery = fireStore.collection(USERS).doc(MyAppState.currentUser!.userID).snapshots();
    await UserPreference.getStripeData().then((value) async {
      stripeData = value;
      stripe1.Stripe.publishableKey = stripeData!.clientpublishableKey;
      stripe1.Stripe.merchantIdentifier = PAYID;
      await stripe1.Stripe.instance.applySettings();
    });
    razorPayData = await UserPreference.getRazorPayData();
    paytmSettingData = await UserPreference.getPaytmData();
    paypalSettingData = await UserPreference.getPayPalData();
    payStackSettingData = await UserPreference.getPayStackData();
    flutterWaveSettingData = await UserPreference.getFlutterWaveData();
    payFastSettingData = await UserPreference.getPayFastData();
    mercadoPagoSettingData = await UserPreference.getMercadoPago();

    futurecod = fireStoreUtils.getCod();

    initPayPal();
  }

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
          ShowToastDialog.showToast("Payment canceled");
        },
        onSuccess: (data) {
          //successfully paid
          //remove all items from queue
          Navigator.pop(context);
          _flutterPaypalNativePlugin.removeAllPurchaseItems();
          ShowToastDialog.showToast("Payment Successfully");
          placeOrderChanges();
        },
        onError: (data) {
          Navigator.pop(context);
          ShowToastDialog.showToast("error: ${data.reason}");
        },
        onShippingChange: (data) {
          Navigator.pop(context);
          ShowToastDialog.showToast("shipping change: ${data.shippingChangeAddress?.adminArea1 ?? ""}");
        },
      ),
    );
  }

  Widget paymentListView() {
    return Column(
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
                      return const Text(
                        "error",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ).tr();
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

                    walletBalanceError = userData.wallet_amount < getTotalAmount() ? true : false;
                    return Column(
                      children: [
                        // CheckboxListTile(
                        //   onChanged: (bool? value) {
                        //     setState(() {
                        //       if (!walletBalanceError) {
                        //         wallet = true;
                        //       } else {
                        //         wallet = false;
                        //       }
                        //
                        //       razorPay = false; //razorPay ? false : true;
                        //       codPay = false;
                        //       payTm = false;
                        //       payStack = false;
                        //       flutterWave = false;
                        //       pay = false;
                        //       paypal = false;
                        //       payFast = false;
                        //       stripe = false;
                        //       selectedCardID = '';
                        //       paymentOption = "Pay Online Via Wallet".tr();
                        //     });
                        //   },
                        //   value: wallet,
                        //   contentPadding: const EdgeInsets.all(0),
                        //   secondary: const FaIcon(FontAwesomeIcons.wallet),
                        //   title: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       Text('Wallet'.tr()),
                        //       Column(
                        //         children: [
                        //           Text(
                        //             currencyData!.symbol + double.parse(userData.wallet_amount.toString()).toStringAsFixed(decimal),
                        //             style: TextStyle(
                        //                 color: walletBalanceError ? Colors.red : Colors.green, fontWeight: FontWeight.w600, fontSize: 18),
                        //           ),
                        //         ],
                        //       )
                        //     ],
                        //   ),
                        // ),

                        buildPaymentTile(
                            isVisible: UserPreference.getWalletData() ?? false,
                            selectedPayment: wallet,
                            walletError: walletBalanceError,
                            image: "assets/images/wallet_icon.png",
                            value: "Wallet".tr(),
                            childWidget: Text(
                              amountShow(amount: userData.wallet_amount.toString()),
                              style: TextStyle(
                                color: walletBalanceError ? Colors.red : Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            )),
                        Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Row(
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
                        ),
                      ],
                    );
                  }),
            ],
          ),
        ),

        buildPaymentTile(
          isVisible: UserPreference.getWalletData() ?? false,
          selectedPayment: codPay,
          image: "assets/images/cash.png",
          value: "Cash".tr(),
        ),
        buildPaymentTile(
          isVisible: (stripeData == null) ? false : stripeData!.isEnabled,
          selectedPayment: stripe,
          value: "Stripe".tr(),
        ),
        buildPaymentTile(
          isVisible: razorPayData!.isEnabled,
          selectedPayment: razorPay,
          image: "assets/images/razorpay_@3x.png",
          value: "RazorPay".tr(),
        ),
        buildPaymentTile(
          isVisible: (paytmSettingData == null) ? false : paytmSettingData!.isEnabled,
          selectedPayment: payTm,
          image: "assets/images/paytm_@3x.png",
          value: "PayTm".tr(),
        ),
        buildPaymentTile(
          isVisible: (paypalSettingData == null) ? false : paypalSettingData!.isEnabled,
          selectedPayment: paypal,
          image: "assets/images/paypal_@3x.png",
          value: "PayPal".tr(),
        ),

        buildPaymentTile(
          isVisible: (payFastSettingData == null) ? false : payFastSettingData!.isEnable,
          selectedPayment: payFast,
          image: "assets/images/payfast.png",
          value: "PayFast".tr(),
        ),
        buildPaymentTile(
          isVisible: (payStackSettingData == null) ? false : payStackSettingData!.isEnabled,
          selectedPayment: payStack,
          image: "assets/images/paystack.png",
          value: "PayStack".tr(),
        ),
        buildPaymentTile(
          isVisible: (flutterWaveSettingData == null) ? false : flutterWaveSettingData!.isEnable,
          selectedPayment: paypal,
          image: "assets/images/flutterwave.png",
          value: "FlutterWave".tr(),
        ),

        buildPaymentTile(
          isVisible: (mercadoPagoSettingData == null) ? false : mercadoPagoSettingData!.isEnabled,
          selectedPayment: mercadoPago,
          image: "assets/images/mercadopago.png",
          value: "Mercado Pago".tr(),
        ),

        // Visibility(
        //   visible: true,
        //   child: Column(
        //     children: [
        //       const Divider(),
        //       FutureBuilder<CodModel?>(
        //           future: futurecod,
        //           builder: (context, snapshot) {
        //             if (snapshot.connectionState == ConnectionState.waiting) {
        //               return Center(
        //                 child: CircularProgressIndicator.adaptive(
        //                   valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
        //                 ),
        //               );
        //             }
        //             if (snapshot.hasData) {
        //               return snapshot.data!.cod == true
        //                   ? Container(
        //                       decoration: BoxDecoration(
        //                         border: Border.all(color: codPay ? Color(COLOR_PRIMARY) : Colors.black12),
        //                         borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
        //                             ),
        //                       ),
        //                       padding: const EdgeInsets.symmetric(horizontal: 10),
        //                       child: CheckboxListTile(
        //                         onChanged: (bool? value) {
        //                           setState(() {
        //                             payStack = false;
        //                             flutterWave = false;
        //                             razorPay = false;
        //                             wallet = false;
        //                             codPay = true; //codPay ? false : true;
        //                             selectedCardID = '';
        //                             payTm = false;
        //                             payFast = false;
        //                             pay = false;
        //                             paypal = false;
        //                             stripe = false;
        //                             paymentOption = 'Cash on Delivery'.tr();
        //                           });
        //                         },
        //                         value: codPay,
        //                         contentPadding: const EdgeInsets.all(0),
        //                         secondary: const FaIcon(FontAwesomeIcons.handHoldingUsd),
        //                         title: Text('Cash on Delivery'.tr()),
        //                       ),
        //                     )
        //                   : const Center();
        //             }
        //             return const Center();
        //           }),
        //     ],
        //   ),
        // ),
        // Visibility(
        //   visible: razorPayData!.isEnabled,
        //   child: Padding(
        //     padding: const EdgeInsets.only(top: 10),
        //     child: Container(
        //       decoration: BoxDecoration(
        //         border: Border.all(color: razorPay ? Color(COLOR_PRIMARY) : Colors.black12),
        //         borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
        //         ),
        //       ),
        //       padding: const EdgeInsets.symmetric(horizontal: 10),
        //       child: CheckboxListTile(
        //         onChanged: (bool? value) {
        //           setState(() {
        //             payStack = false;
        //             flutterWave = false;
        //             wallet = false;
        //             razorPay = true; //razorPay ? false : true;
        //             codPay = false;
        //             payTm = false;
        //             pay = false;
        //             payFast = false;
        //             paypal = false;
        //             stripe = false;
        //             selectedCardID = '';
        //             paymentOption = "Pay Online Via RazorPay".tr();
        //           });
        //         },
        //         value: razorPay,
        //         contentPadding: const EdgeInsets.all(0),
        //         secondary: const FaIcon(FontAwesomeIcons.amazonPay),
        //         title: Text('Razor Pay'.tr()),
        //       ),
        //     ),
        //   ),
        // ),
        // Visibility(
        //   visible: (stripeData == null) ? false : stripeData!.isEnabled,
        //   child: Padding(
        //     padding: const EdgeInsets.only(top: 10),
        //
        //     child: Container(
        //       decoration: BoxDecoration(
        //         border: Border.all(color: stripe ? Color(COLOR_PRIMARY) : Colors.black12),
        //         borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
        //         ),
        //       ),
        //       padding: const EdgeInsets.symmetric(horizontal: 10),
        //       child: CheckboxListTile(
        //         onChanged: (bool? value) {
        //           setState(() {
        //             payStack = false;
        //             flutterWave = false;
        //             stripe = true;
        //             wallet = false;
        //             razorPay = false; //razorPay ? false : true;
        //             codPay = false;
        //             payTm = false;
        //             payFast = false;
        //             pay = false;
        //             paypal = false;
        //             selectedCardID = '';
        //             paymentOption = "Pay Online Via Stripe".tr();
        //           });
        //         },
        //         value: stripe,
        //         contentPadding: const EdgeInsets.all(0),
        //         secondary: const FaIcon(FontAwesomeIcons.stripe),
        //         title: Text('Stripe'.tr()),
        //       ),
        //     ),
        //   ),
        // ),
        // Visibility(
        //   visible: (paytmSettingData == null) ? false : paytmSettingData!.isEnabled,
        //   child: Padding(
        //     padding: const EdgeInsets.only(top: 10),
        //     child: Container(
        //       decoration: BoxDecoration(
        //         border: Border.all(color: payTm ? Color(COLOR_PRIMARY) : Colors.black12),
        //         borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
        //         ),
        //       ),
        //       padding: const EdgeInsets.symmetric(horizontal: 10),
        //       child: CheckboxListTile(
        //         onChanged: (bool? value) {
        //           setState(() {
        //             payStack = false;
        //             flutterWave = false;
        //             razorPay = false;
        //             wallet = false; //razorPay ? false : true;
        //             codPay = false;
        //             payTm = true;
        //             payFast = false;
        //             pay = false;
        //             paypal = false;
        //             stripe = false;
        //             selectedCardID = '';
        //             paymentOption = "Pay Online Via PayTm".tr();
        //           });
        //         },
        //         value: payTm,
        //         contentPadding: const EdgeInsets.all(0),
        //         secondary: const FaIcon(FontAwesomeIcons.alipay),
        //         title: Text('PayTm'.tr()),
        //       ),
        //     ),
        //   ),
        // ),
        // Visibility(
        //   visible: (paypalSettingData == null) ? false : paypalSettingData!.isEnabled,
        //   child: Padding(
        //     padding: const EdgeInsets.only(top: 10),
        //     child: Container(
        //       decoration: BoxDecoration(
        //         border: Border.all(color: paypal ? Color(COLOR_PRIMARY) : Colors.black12),
        //         borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
        //         ),
        //       ),
        //       padding: const EdgeInsets.symmetric(horizontal: 10),
        //       child: CheckboxListTile(
        //         onChanged: (bool? value) {
        //           setState(() {
        //             payStack = false;
        //             flutterWave = false;
        //             paypal = true;
        //             wallet = false;
        //             razorPay = false;
        //             codPay = false;
        //             payTm = false;
        //             pay = false;
        //             payFast = false;
        //             stripe = false;
        //             selectedCardID = '';
        //             paymentOption = "Pay Online PayPal".tr();
        //           });
        //         },
        //         value: paypal,
        //         contentPadding: const EdgeInsets.all(0),
        //         secondary: const FaIcon(FontAwesomeIcons.paypal),
        //         title: Text(' Paypal'.tr()),
        //       ),
        //     ),
        //   ),
        // ),
        // Visibility(
        //   visible: (payFastSettingData == null) ? false : payFastSettingData!.isEnable,
        //   child: Padding(
        //     padding: const EdgeInsets.only(top: 10),
        //     child: Container(
        //       decoration: BoxDecoration(
        //         border: Border.all(color: payFast ? Color(COLOR_PRIMARY) : Colors.black12),
        //         borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
        //         ),
        //       ),
        //       padding: const EdgeInsets.symmetric(horizontal: 10),
        //       child: CheckboxListTile(
        //         onChanged: (bool? value) {
        //           setState(() {
        //             payFast = true;
        //             paypal = false;
        //             wallet = false;
        //             razorPay = false;
        //             payStack = false;
        //             codPay = false;
        //             payTm = false;
        //             pay = false;
        //             flutterWave = false;
        //             stripe = false;
        //             selectedCardID = '';
        //             paymentOption = "Pay Online PayFast".tr();
        //           });
        //         },
        //         value: payFast,
        //         contentPadding: const EdgeInsets.all(0),
        //         secondary: Image.asset(
        //           'assets/images/payfastmini.png',
        //           width: 25,
        //           height: 25,
        //         ),
        //         title: Text(' PayFast'.tr()),
        //       ),
        //     ),
        //   ),
        // ),
        // Visibility(
        //   visible: (payStackSettingData == null) ? false : payStackSettingData!.isEnabled,
        //   child: Padding(
        //     padding: const EdgeInsets.only(top: 10),
        //     child: Container(
        //       decoration: BoxDecoration(
        //         border: Border.all(color: payStack ? Color(COLOR_PRIMARY) : Colors.black12),
        //         borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
        //         ),
        //       ),
        //       padding: const EdgeInsets.symmetric(horizontal: 10),
        //       child: CheckboxListTile(
        //         onChanged: (bool? value) {
        //           setState(() {
        //             payStack = true;
        //             paypal = false;
        //             flutterWave = false;
        //             wallet = false;
        //             payFast = false;
        //             razorPay = false;
        //             codPay = false;
        //             payTm = false;
        //             pay = false;
        //             stripe = false;
        //             selectedCardID = '';
        //             paymentOption = "Pay Online PayStack".tr();
        //           });
        //         },
        //         value: payStack,
        //         contentPadding: const EdgeInsets.all(0),
        //         secondary: Image.asset(
        //           'assets/images/paystackmini.png',
        //           width: 25,
        //           height: 25,
        //         ),
        //         title: Text(' PayStack'.tr()),
        //       ),
        //     ),
        //   ),
        // ),
        // Visibility(
        //   visible: (flutterWaveSettingData == null) ? false : flutterWaveSettingData!.isEnable,
        //   child: Padding(
        //     padding: const EdgeInsets.only(top: 10),
        //     child: Container(
        //       decoration: BoxDecoration(
        //         border: Border.all(color: payStack ? Color(COLOR_PRIMARY) : Colors.black12),
        //         borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
        //         ),
        //       ),
        //       padding: const EdgeInsets.symmetric(horizontal: 10),
        //       child: CheckboxListTile(
        //         onChanged: (bool? value) {
        //           setRef();
        //           setState(() {
        //             payStack = false;
        //             flutterWave = true;
        //             razorPay = false; //razorPay ? false : true;
        //             codPay = false;
        //             payTm = false;
        //             payFast = false;
        //             wallet = false;
        //             pay = false;
        //             paypal = false;
        //             stripe = false;
        //             selectedCardID = '';
        //             paymentOption = "Pay Online Via FlutterWave".tr();
        //           });
        //         },
        //         value: flutterWave,
        //         contentPadding: const EdgeInsets.all(0),
        //         secondary: const FaIcon(FontAwesomeIcons.moneyBillWave),
        //         title: Text(' FlutterWave'.tr()),
        //       ),
        //     ),
        //   ),
        // ),
        const Divider(),
      ],
    );
  }

  bool walletBalanceError = false;
  bool payStack = false;
  bool flutterWave = false;
  bool wallet = false;
  bool razorPay = false;
  bool codPay = false;
  bool payTm = false;
  bool pay = false;
  bool stripe = false;
  bool paypal = false;
  bool payFast = false;
  bool mercadoPago = false;

  String selectedCardID = '';
  bool isStaging = true;
  bool enableAssist = true;
  bool restrictAppInvoke = false;
  String result = "";

  Future<CodModel?>? futurecod;
  String paymentOption = 'Pay Via Wallet'.tr();
  String paymentType = "";

  setAllFalse({required String value}) {
    print("----->dd" + value);
    setState(() {
      codPay = false;
      stripe = false;
      wallet = false;
      payTm = false;
      razorPay = false;
      payStack = false;
      flutterWave = false;
      pay = false;
      paypal = false;
      payFast = false;
      mercadoPago = false;

      if (value == "Stripe" || value == "stripe") {
        stripe = true;
        print("-------->$stripe");
      }
      if (value == "Cash") {
        codPay = true;
        print("-------->$codPay");
      }
      if (value == "PayTm" || value == "paytm") {
        payTm = true;
      }
      if (value == "RazorPay" || value == "razorpay") {
        razorPay = true;
      }
      if (value == "Wallet" || value == "wallet") {
        wallet = true;
      }
      if (value == "PayPal" || value == "paypal") {
        paypal = true;
      }
      if (value == "PayFast" || value == "payfast") {
        payFast = true;
      }
      if (value == "PayStack" || value == "paystack") {
        payStack = true;
      }
      if (value == "FlutterWave" || value == "flutterwave") {
        flutterWave = true;
      }
      if (value == "Google Pay" || value == "Stripe") {
        pay = true;
      }
      if (value == "Mercado Pago" || value == "mercadoPago") {
        mercadoPago = true;
      }
    });
  }

  String? selectedRadioTile;

  ///show payment Options
  buildPaymentTile({
    bool walletError = false,
    Widget childWidget = const Center(),
    required bool isVisible,
    String value = "Stripe",
    image = "assets/images/stripe.png",
    required selectedPayment,
  }) {
    return Visibility(
      visible: isVisible,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          color: isDarkMode(context) ? const Color(DarkContainerColor) : Colors.white,
          elevation: selectedRadioTile == value ? 0.5 : 1.2,
          child: RadioListTile(
            controlAffinity: ListTileControlAffinity.trailing,
            value: value,
            groupValue: selectedRadioTile,
            onChanged: walletError != true
                ? (String? value) {
                    setState(() {
                      setAllFalse(value: value!);
                      selectedPayment = true;
                      selectedRadioTile = value;
                    });
                  }
                : (String? value) {},
            selected: selectedPayment,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 6,
            ),

            toggleable: true,
            activeColor: Color(COLOR_PRIMARY),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                              child: Image.asset(image),
                            ),
                          ),
                        )),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(value,
                        style: TextStyle(
                          color: isDarkMode(context) ? const Color(0xffFFFFFF) : Colors.black,
                        )),
                  ],
                ),
                childWidget
              ],
            ),
            //toggleable: true,
          ),
        ),
      ),
    );
  }

  //RazorPay payment function
  void openCheckout({required amount, required orderId}) async {
    var options = {
      'key': razorPayData!.razorpayKey,
      'amount': amount * 100,
      'name': PAYID,
      'order_id': orderId,
      "currency": currencyData?.code,
      'description': 'wallet Topup'.tr(),
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
    Navigator.pop(_globalKey.currentContext!, true);
    print(response.orderId);
    print(response.paymentId);

    placeOrderChanges();
    ScaffoldMessenger.of(_globalKey.currentContext!).showSnackBar(SnackBar(
      content: Text(
        "Payment Successful!!\n".tr() + response.orderId!,
      ),
      backgroundColor: Colors.green.shade400,
      duration: const Duration(seconds: 6),
    ));
  }

  void _handleExternalWaller(ExternalWalletResponse response) {
    Navigator.pop(_globalKey.currentContext!);
    ScaffoldMessenger.of(_globalKey.currentContext!).showSnackBar(SnackBar(
      content: Text(
        "Payment Proccessing Via\n".tr() + response.walletName!,
      ),
      backgroundColor: Colors.blue.shade400,
      duration: const Duration(seconds: 8),
    ));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Navigator.pop(_globalKey.currentContext!);
    print(response.code);
    RazorPayFailedModel lom = RazorPayFailedModel.fromJson(jsonDecode(response.message!.toString()));
    ScaffoldMessenger.of(_globalKey.currentContext!).showSnackBar(SnackBar(
      content: Text(
        "Payment Failed!!\n".tr() + lom.error.description,
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
        Navigator.pop(_globalKey.currentContext!);
        showAlert(_globalKey.currentContext!, response: "contact-admin".tr(), colors: Colors.red);
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
        Navigator.pop(context, true);
        placeOrderChanges();

        ScaffoldMessenger.of(_globalKey.currentContext!).showSnackBar(SnackBar(
          content: Text("paid successfully".tr()),
          duration: const Duration(seconds: 8),
          backgroundColor: Colors.green,
        ));

        paymentIntentData = null;
      }).onError((error, stackTrace) {
        Navigator.pop(_globalKey.currentContext!);
        var lo1 = jsonEncode(error);
        var lo2 = jsonDecode(lo1);
        showDialog(context: context, builder: (_) => AlertDialog(content: Text("Payment Failed")));
      });
    } on stripe1.StripeException catch (e) {
      Navigator.pop(_globalKey.currentContext!);
      var lo1 = jsonEncode(e);
      var lo2 = jsonDecode(lo1);
      showDialog(context: context, builder: (_) => AlertDialog(content: Text("Payment Failed")));
    } catch (e) {
      print('$e');
      Navigator.pop(_globalKey.currentContext!);
      ScaffoldMessenger.of(_globalKey.currentContext!).showSnackBar(SnackBar(
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
  final _flutterPaypalNativePlugin = FlutterPaypalNative.instance;

  paypalPaymentSheet({required amount}) {
    //add 1 item to cart. Max is 4!
    if (_flutterPaypalNativePlugin.canAddMorePurchaseUnit) {
      _flutterPaypalNativePlugin.addPurchaseUnit(
        FPayPalPurchaseUnit(
          // random prices
          amount: double.parse(amount),

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
  //         displayName: PAYID);
  //
  //     BraintreePaymentMethodNonce? resultData;
  //     try {
  //       resultData =
  //           await Braintree.requestPaypalNonce(tokenizationKey, request);
  //     } on Exception {
  //       print("Stripe error");
  //       showAlert(_globalKey.currentContext!,
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
  //             placeOrderChanges();
  //             ScaffoldMessenger.of(_globalKey.currentContext!)
  //                 .showSnackBar(SnackBar(
  //               content: Text(
  //                 "Status".tr() +
  //                     " : ${settleResult.data.transaction.status}\n"
  //                             "Transaction id"
  //                         .tr() +
  //                     " : ${settleResult.data.transaction.id}\n"
  //                             "Amount"
  //                         .tr() +
  //                     " : ${settleResult.data.transaction.amount}",
  //               ),
  //               duration: const Duration(seconds: 8),
  //               backgroundColor: Colors.green,
  //             ));
  //           } else {
  //             print(value);
  //             payPalCurrModel.PayPalCurrencyCodeErrorModel settleResult =
  //                 payPalCurrModel.PayPalCurrencyCodeErrorModel.fromJson(value);
  //             Navigator.pop(_globalKey.currentContext!);
  //             ScaffoldMessenger.of(_globalKey.currentContext!)
  //                 .showSnackBar(SnackBar(
  //               content:
  //                   Text("Status".tr() + " : ${settleResult.data.message}"),
  //               duration: const Duration(seconds: 8),
  //               backgroundColor: Colors.red,
  //             ));
  //           }
  //         } else {
  //           PayPalErrorSettleModel settleResult =
  //               PayPalErrorSettleModel.fromJson(value);
  //           Navigator.pop(_globalKey.currentContext!);
  //           ScaffoldMessenger.of(_globalKey.currentContext!)
  //               .showSnackBar(SnackBar(
  //             content: Text("Status".tr() + " : ${settleResult.data.message}"),
  //             duration: const Duration(seconds: 8),
  //             backgroundColor: Colors.red,
  //           ));
  //         }
  //       });
  //     } else {
  //       Navigator.pop(_globalKey.currentContext!);
  //       ScaffoldMessenger.of(_globalKey.currentContext!).showSnackBar(SnackBar(
  //         content: Text("Status : Payment Incomplete!!".tr()),
  //         duration: const Duration(seconds: 8),
  //         backgroundColor: Colors.red,
  //       ));
  //     }
  //   });
  // }

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
        GetPaymentTxtTokenModel result = value;
        String callback = "";
        if (paytmSettingData!.isSandboxEnabled) {
          callback = callback + "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
        } else {
          callback = callback + "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
        }

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
        callBackURL,
        isStaging,
        true,
        enableAssist,
      );

      response.then((value) {
        if (value!["RESPMSG"] == "Txn Success") {
          print("txt done!!");
          print(amount);
          Navigator.pop(_globalKey.currentContext!, true);
          placeOrderChanges();
          showAlert(context, response: "Payment Successful!!\n".tr() + "${value['RESPMSG']}", colors: Colors.green);
        }
      }).catchError((onError) {
        if (onError is PlatformException) {
          print("======>>1");
          Navigator.pop(_globalKey.currentContext!);

          print("Error124 : $onError");
          result = onError.message.toString() + " \n  " + onError.code.toString();
          showAlert(_globalKey.currentContext!, response: onError.message.toString(), colors: Colors.red);
        } else {
          print("======>>2");

          result = onError.toString();
          Navigator.pop(_globalKey.currentContext!);
          showAlert(_globalKey.currentContext!, response: result, colors: Colors.red);
        }
      });
    } catch (err) {
      print("======>>3");
      result = err.toString();
      Navigator.pop(_globalKey.currentContext!);
      showAlert(_globalKey.currentContext!, response: result, colors: Colors.red);
    }
  }

  Future<GetPaymentTxtTokenModel> initiatePayment({required double amount, required orderId}) async {
    String initiateURL = "${GlobalURL}payments/initiatepaytmpayment";

    print("uday");
    print(amount.toString());
    print(amount.toStringAsFixed(currencyData!.decimal).toString());
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
      "amount": amount.toStringAsFixed(currencyData!.decimal),
      "currency": "INR", //currencyData!.code,
      "callback_url": callback,
      "custId": MyAppState.currentUser!.userID,
      "issandbox": paytmSettingData!.isSandboxEnabled ? "1" : "2",
    });
    // print(response.body);
    final data = jsonDecode(response.body);
    if (data["body"]["txnToken"] == null || data["body"]["txnToken"].toString().isEmpty) {
      Navigator.pop(_globalKey.currentContext!);
      showAlert(_globalKey.currentContext!, response: "contact-admin".tr(), colors: Colors.red);
    }
    print(data);
    return GetPaymentTxtTokenModel.fromJson(data);
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
      amount: getTotalAmount().toStringAsFixed(currencyData!.decimal).trim(),
      currency: currencyData!.code,
      customer: Customer(name: MyAppState.currentUser!.firstName, phoneNumber: MyAppState.currentUser!.phoneNumber.trim(), email: MyAppState.currentUser!.email.trim()),
      context: context,
      publicKey: flutterWaveSettingData!.publicKey.trim(),
      paymentOptions: "card, payattitude",
      customization: Customization(title: PAYID),
      txRef: _ref!,
      isTestMode: flutterWaveSettingData!.isSandbox,
      redirectUrl: '${GlobalURL}success',
    );
    final ChargeResponse response = await flutterwave.charge();
    if (response.success!) {
      placeOrderChanges();
      ScaffoldMessenger.of(_globalKey.currentContext!).showSnackBar(SnackBar(
        content: Text("Payment Successful!!\n".tr()),
        backgroundColor: Colors.green,
      ));
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

  ///MercadoPago Payment Method

  Future<Map<String, dynamic>> makePreference() async {
    final mp = MP.fromAccessToken(mercadoPagoSettingData!.accessToken);
    var pref = {
      "items": [
        {"title": "Wallet TopUp", "quantity": 1, "unit_price": double.parse(getTotalAmount().toString().trim())}
      ],
      "auto_return": "all",
      "back_urls": {"failure": "${GlobalURL}payment/failure", "pending": "${GlobalURL}payment/pending", "success": "${GlobalURL}payment/success"},
    };

    var result = await mp.createPreference(pref);
    return result;
  }

  mercadoPagoMakePayment() {
    makePreference().then((result) async {
      if (result.isNotEmpty) {
        var preferenceId = result['response']['id'];
        print("uday");
        print(result);
        print(result['response']['init_point']);

        final bool isDone = await Navigator.push(context, MaterialPageRoute(builder: (context) => MercadoPagoScreen(initialURl: result['response']['init_point'])));
        print(isDone);
        print(result.toString());
        print(preferenceId);

        if (isDone) {
          placeOrderChanges();
          ScaffoldMessenger.of(_globalKey.currentContext!).showSnackBar(SnackBar(
            content: Text("Payment Successful!!\n".tr()),
            backgroundColor: Colors.green,
          ));
        } else {
          Navigator.pop(_globalKey.currentContext!);
          ScaffoldMessenger.of(_globalKey.currentContext!).showSnackBar(SnackBar(
            content: Text("Payment UnSuccessful!!\n".tr()),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        hideProgress();

        Navigator.pop(_globalKey.currentContext!);
        ScaffoldMessenger.of(_globalKey.currentContext!).showSnackBar(SnackBar(
          content: Text("Error while transaction!".tr()),
          backgroundColor: Colors.red,
        ));
      }
    });
  }

  ///PayStack Payment Method
  payStackPayment(BuildContext context) async {
    var amount = (double.parse(getTotalAmount().toStringAsFixed(currencyData!.decimal)) * 100).toString();
    print(amount);
    await PayStackURLGen.payStackURLGen(
      amount: amount,
      currency: "NGN", //currencyData!.code,
      secretKey: payStackSettingData!.secretKey,
    ).then((value) async {
      print(value);
      if (value != null) {
        if (value["status"]) {
          PayStackUrlModel _payStackModel = PayStackUrlModel.fromJson(value);
          bool isDone = await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PayStackScreen(
                    secretKey: payStackSettingData!.secretKey,
                    callBackUrl: payStackSettingData!.callbackURL,
                    initialURl: _payStackModel.data.authorizationUrl,
                    amount: amount,
                    reference: _payStackModel.data.reference,
                  )));
          //Navigator.pop(_globalKey.currentContext!);

          if (isDone) {
            Navigator.pop(_globalKey.currentContext!, true);
            placeOrderChanges();
            ScaffoldMessenger.of(_globalKey.currentContext!).showSnackBar(SnackBar(
              content: Text("Payment Successful!!\n".tr()),
              backgroundColor: Colors.green,
            ));
          } else {
            Navigator.pop(_globalKey.currentContext!);
            ScaffoldMessenger.of(_globalKey.currentContext!).showSnackBar(SnackBar(
              content: Text("Payment UnSuccessful!!\n".tr()),
              backgroundColor: Colors.red,
            ));
          }
        } else {
          Navigator.pop(_globalKey.currentContext!);
          showAlert(_globalKey.currentContext!, response: value['message'].toString(), colors: Colors.red);
        }
      } else {
        Navigator.pop(_globalKey.currentContext!);
        showAlert(_globalKey.currentContext!, response: "Something went wrong, please contact admin.".tr(), colors: Colors.red);
      }
    });
  }

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  showLoadingAlert() {
    return showDialog<void>(
      context: _globalKey.currentContext!,
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
              children: [
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
}
