import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/CabOrderModel.dart';
import 'package:emartconsumer/model/CodModel.dart';
import 'package:emartconsumer/model/FlutterWaveSettingDataModel.dart';
import 'package:emartconsumer/model/PayFastSettingData.dart';
import 'package:emartconsumer/model/PayStackSettingsModel.dart';
import 'package:emartconsumer/model/VehicleType.dart';
import 'package:emartconsumer/model/paypalSettingData.dart';
import 'package:emartconsumer/model/paytmSettingData.dart';
import 'package:emartconsumer/model/razorpayKeyModel.dart';
import 'package:emartconsumer/model/stripeSettingData.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/userPrefrence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe1;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/MercadoPagoSettingsModel.dart';

class InterCityPaymentSelectionScreen extends StatefulWidget {
  LatLng? departureLatLong;
  LatLng? destinationLatLong;
  String? departureName;
  String? destinationName;
  String? subTotal;
  VehicleType? vehicleType;
  String? vehicleId;
  String? distance;
  String? duration;

  bool? roundTrip;
  Timestamp? scheduleDateTime;
  Timestamp? scheduleReturnDateTime;

  InterCityPaymentSelectionScreen(
      {Key? key,
      this.roundTrip,
      this.scheduleDateTime,
      this.scheduleReturnDateTime,
      this.departureLatLong,
      this.destinationLatLong,
      this.departureName,
      this.destinationName,
      this.subTotal,
      this.vehicleType,
      this.vehicleId,
      this.distance,
      this.duration})
      : super(key: key);

  @override
  State<InterCityPaymentSelectionScreen> createState() => _InterCityPaymentSelectionScreenState();
}

class _InterCityPaymentSelectionScreenState extends State<InterCityPaymentSelectionScreen> {
  final fireStoreUtils = FireStoreUtils();

  String paymentOption = "Pay Via Wallet".tr();
  RazorPayModel? razorPayData = UserPreference.getRazorPayData();

  CodModel? futurecod;
  StripeSettingData? stripeData;
  PaytmSettingData? paytmSettingData;
  PaypalSettingData? paypalSettingData;
  PayStackSettingData? payStackSettingData;
  FlutterWaveSettingData? flutterWaveSettingData;
  MercadoPagoSettingData? mercadoPagoSettingData;
  PayFastSettingData? payFastSettingData;
  String paymentType = "";
  bool isStaging = true;
  bool restrictAppInvoke = false;
  bool enableAssist = true;
  String result = "";

  bool isLoading = true;

  getPaymentSettingData() async {
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
    mercadoPagoSettingData = await UserPreference.getMercadoPago();
    payFastSettingData = await UserPreference.getPayFastData();
    await fireStoreUtils.getCod().then((value) {
      setState(() {
        futurecod = value;
      });
    });
    isLoading = false;
  }

  showAlert(BuildContext context123, {required String response, required Color colors}) {
    return ScaffoldMessenger.of(context123).showSnackBar(SnackBar(
      content: Text(response),
      backgroundColor: colors,
    ));
  }

  @override
  void initState() {
    selectedRadioTile = '';
    getPaymentSettingData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(6.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(4),
            ),
            child: const Center(
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                const Text("Select Payment Method").tr(),
                buildPaymentTile(
                  isVisible: UserPreference.getWalletData() ?? false,
                  selectedPayment: wallet,
                  image: "assets/images/wallet_icon.png",
                  value: "Wallet".tr(),
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

                // Container(
                //   decoration: BoxDecoration(
                //     border: Border.all(color: wallet ? Color(COLOR_PRIMARY) : Colors.black12),
                //     borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                //         ),
                //   ),
                //   padding: const EdgeInsets.symmetric(horizontal: 10),
                //   child: CheckboxListTile(
                //     onChanged: (bool? value) {
                //       setState(() {
                //         payStack = false;
                //         flutterWave = false;
                //         wallet = true;
                //         razorPay = false;
                //         codPay = false;
                //         payTm = false;
                //         stripe = false;
                //         paypal = false;
                //         payFast = false;
                //
                //         paymentOption = "Pay Online Via Wallet".tr();
                //       });
                //     },
                //     title: Text('Wallet'.tr()),
                //     value: wallet,
                //     contentPadding: const EdgeInsets.all(0),
                //     secondary: const FaIcon(FontAwesomeIcons.wallet),
                //   ),
                // ),
                // Visibility(
                //   visible: futurecod!.cod,
                //   child: Padding(
                //     padding: const EdgeInsets.only(top: 10),
                //     child: Container(
                //       decoration: BoxDecoration(
                //         border: Border.all(color: codPay ? Color(COLOR_PRIMARY) : Colors.black12),
                //         borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                //             ),
                //       ),
                //       padding: const EdgeInsets.symmetric(horizontal: 10),
                //       child: CheckboxListTile(
                //         onChanged: (bool? value) {
                //           setState(() {
                //             payStack = false;
                //             flutterWave = false;
                //             wallet = false;
                //             razorPay = false;
                //             codPay = true;
                //             payTm = false;
                //             stripe = false;
                //             paypal = false;
                //             payFast = false;
                //
                //             paymentOption = 'Cash'.tr();
                //           });
                //         },
                //         value: codPay,
                //         contentPadding: const EdgeInsets.all(0),
                //         secondary: const FaIcon(FontAwesomeIcons.handHoldingUsd),
                //         title: Text('Cash on Delivery'.tr()),
                //       ),
                //     ),
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
                //             ),
                //       ),
                //       padding: const EdgeInsets.symmetric(horizontal: 10),
                //       child: CheckboxListTile(
                //         onChanged: (bool? value) {
                //           setState(() {
                //             payStack = false;
                //             flutterWave = false;
                //             wallet = false;
                //             razorPay = true;
                //             codPay = false;
                //             payTm = false;
                //             stripe = false;
                //             paypal = false;
                //             payFast = false;
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
                //     padding: const EdgeInsets.only(top: 10.0),
                //     child: Container(
                //       decoration: BoxDecoration(
                //         border: Border.all(color: stripe ? Color(COLOR_PRIMARY) : Colors.black12),
                //         borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                //             ),
                //       ),
                //       padding: const EdgeInsets.symmetric(horizontal: 10),
                //       child: CheckboxListTile(
                //         onChanged: (bool? value) {
                //           setState(() {
                //             payStack = false;
                //             flutterWave = false;
                //             wallet = false;
                //             razorPay = false;
                //             codPay = false;
                //             payTm = false;
                //             stripe = true;
                //             paypal = false;
                //             payFast = false;
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
                //     padding: const EdgeInsets.only(top: 10.0),
                //     child: Container(
                //       decoration: BoxDecoration(
                //         border: Border.all(color: payTm ? Color(COLOR_PRIMARY) : Colors.black12),
                //         borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                //             ),
                //       ),
                //       padding: const EdgeInsets.symmetric(horizontal: 10),
                //       child: CheckboxListTile(
                //         onChanged: (bool? value) {
                //           setState(() {
                //             payStack = false;
                //             flutterWave = false;
                //             wallet = false;
                //             razorPay = false;
                //             codPay = false;
                //             payTm = true;
                //             stripe = false;
                //             paypal = false;
                //             payFast = false;
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
                //     padding: const EdgeInsets.only(top: 10.0),
                //     child: Container(
                //       decoration: BoxDecoration(
                //         border: Border.all(color: paypal ? Color(COLOR_PRIMARY) : Colors.black12),
                //         borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                //             ),
                //       ),
                //       padding: const EdgeInsets.symmetric(horizontal: 10),
                //       child: CheckboxListTile(
                //         onChanged: (bool? value) {
                //           setState(() {
                //             payStack = false;
                //             flutterWave = false;
                //             wallet = false;
                //             razorPay = false;
                //             codPay = false;
                //             payTm = false;
                //             stripe = false;
                //             paypal = true;
                //             payFast = false;
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
                //     padding: const EdgeInsets.only(top: 10.0),
                //     child: Container(
                //       decoration: BoxDecoration(
                //         border: Border.all(color: payFast ? Color(COLOR_PRIMARY) : Colors.black12),
                //         borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                //             ),
                //       ),
                //       padding: const EdgeInsets.symmetric(horizontal: 10),
                //       child: CheckboxListTile(
                //         onChanged: (bool? value) {
                //           setState(() {
                //             payStack = false;
                //             flutterWave = false;
                //             wallet = false;
                //             razorPay = false;
                //             codPay = false;
                //             payTm = false;
                //             stripe = false;
                //             paypal = false;
                //             payFast = true;
                //
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
                //     padding: const EdgeInsets.only(top: 10.0),
                //     child: Container(
                //       decoration: BoxDecoration(
                //         border: Border.all(color: payStack ? Color(COLOR_PRIMARY) : Colors.black12),
                //         borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                //             ),
                //       ),
                //       padding: const EdgeInsets.symmetric(horizontal: 10),
                //       child: CheckboxListTile(
                //         onChanged: (bool? value) {
                //           setState(() {
                //             payStack = true;
                //             flutterWave = false;
                //             wallet = false;
                //             razorPay = false;
                //             codPay = false;
                //             payTm = false;
                //             stripe = false;
                //             paypal = false;
                //             payFast = false;
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
                //     padding: const EdgeInsets.only(top: 10.0),
                //     child: Container(
                //       decoration: BoxDecoration(
                //         border: Border.all(color: flutterWave ? Color(COLOR_PRIMARY) : Colors.black12),
                //         borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                //             ),
                //       ),
                //       padding: const EdgeInsets.symmetric(horizontal: 10),
                //       child: CheckboxListTile(
                //         onChanged: (bool? value) {
                //           setState(() {
                //             payStack = false;
                //             flutterWave = true;
                //             wallet = false;
                //             razorPay = false;
                //             codPay = false;
                //             payTm = false;
                //             stripe = false;
                //             paypal = false;
                //             payFast = false;
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Color(COLOR_PRIMARY),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      if (razorPay) {
                        paymentType = 'razorpay';
                        placeRides();
                      } else if (payTm) {
                        paymentType = 'paytm';
                        placeRides();
                      } else if (stripe) {
                        paymentType = 'stripe';
                        placeRides();
                      } else if (payFast) {
                        paymentType = 'payfast';
                        placeRides();
                      } else if (payStack) {
                        paymentType = 'paystack';
                        placeRides();
                      } else if (flutterWave) {
                        paymentType = 'flutterwave';
                        placeRides();
                      } else if (paypal) {
                        paymentType = 'paypal';
                        placeRides();
                      } else if (mercadoPago) {
                        paymentType = 'mercadoPago';
                        placeRides();
                      } else if (wallet) {
                        paymentType = 'wallet';
                        placeRides();
                      } else if (codPay) {
                        paymentType = 'cod';
                        placeRides();
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
                      "Continue".tr(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  bool isDarkMode(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return false;
    } else {
      return true;
    }
  }

  setAllFalse({required String value}) {
    setState(() {
      codPay = false;
      stripe = false;
      wallet = false;
      payTm = false;
      razorPay = false;
      payStack = false;
      flutterWave = false;
      paypal = false;
      payFast = false;
      mercadoPago = false;

      if (value == "Stripe") {
        stripe = true;
      }
      if (value == "Cash") {
        codPay = true;
      }
      if (value == "PayTm") {
        payTm = true;
      }
      if (value == "RazorPay") {
        razorPay = true;
      }
      if (value == "Wallet") {
        wallet = true;
      }
      if (value == "PayPal") {
        paypal = true;
      }
      if (value == "PayFast") {
        payFast = true;
      }
      if (value == "PayStack") {
        payStack = true;
      }
      if (value == "FlutterWave") {
        flutterWave = true;
      }
      if (value == "Mercado Pago") {
        mercadoPago = true;
      }
    });
  }

  String? selectedRadioTile;

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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
                              width: 60,
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
      ),
    );
  }

  placeRides() async {
    LocationDatas sourceLocation = LocationDatas(
      latitude: widget.departureLatLong!.latitude,
      longitude: widget.departureLatLong!.longitude,
    );

    LocationDatas destinationLocation = LocationDatas(
      latitude: widget.destinationLatLong!.latitude,
      longitude: widget.destinationLatLong!.longitude,
    );

    CabOrderModel orderModel = CabOrderModel(
        author: MyAppState.currentUser,
        authorID: MyAppState.currentUser!.userID,
        createdAt: Timestamp.now(),
        status: ORDER_STATUS_PLACED,
        paymentMethod: paymentType,
        vehicleType: widget.vehicleType,
        vehicleId: widget.vehicleId,
        duration: widget.duration,
        distance: widget.distance,
        subTotal: widget.subTotal,
        destinationLocation: destinationLocation,
        destinationLocationName: widget.destinationName.toString(),
        sourceLocationName: widget.departureName.toString(),
        sourceLocation: sourceLocation,

        sectionId: sectionConstantModel!.id,
        rideType: "intercity",
        roundTrip: widget.roundTrip,
        scheduleDateTime: widget.scheduleDateTime,
        scheduleReturnDateTime: widget.scheduleReturnDateTime);

    await FireStoreUtils().cabOrderPlace(orderModel, false);
    Navigator.pop(context, true);
  }

  bool payStack = false;
  bool flutterWave = false;
  bool wallet = false;
  bool razorPay = false;
  bool codPay = false;
  bool payTm = false;
  bool stripe = false;
  bool paypal = false;
  bool payFast = false;
  bool mercadoPago = false;
}
