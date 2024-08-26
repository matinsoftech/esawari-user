import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/model/topupTranHistory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/gift_cards_order_model.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/ui/container/ContainerScreen.dart';
import 'package:emartconsumer/ui/wallet/walletScreen.dart';
import 'package:uuid/uuid.dart';

class GiftCardRedeemScreen extends StatefulWidget {
  const GiftCardRedeemScreen({super.key});

  @override
  State<GiftCardRedeemScreen> createState() => _GiftCardRedeemScreenState();
}

class _GiftCardRedeemScreenState extends State<GiftCardRedeemScreen> {
  TextEditingController giftCodeController = TextEditingController();
  TextEditingController giftPinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Colors.grey.shade900 : Colors.grey.shade100,
      appBar: AppBar(
        title: Text("Gift Redeem", style: TextStyle(color: Color(COLOR_PRIMARY), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
            color: isDarkMode(context) ? const Color(DarkContainerColor) : Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Gift Code"),
                SizedBox(
                  height: 6,
                ),
                TextFormField(
                    controller: giftCodeController,
                    keyboardType: TextInputType.number,
                    maxLength: 19,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, new CustomInputFormatter()],
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.only(left: 16, right: 16),
                      hintText: 'Gift Code'.tr(),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    )),
                SizedBox(
                  height: 10,
                ),
                Text("Gift PIN"),
                SizedBox(
                  height: 6,
                ),
                TextFormField(
                    controller: giftPinController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.only(left: 16, right: 16),
                      hintText: 'Gift Pin'.tr(),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    )),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(COLOR_PRIMARY),
            padding: EdgeInsets.symmetric(horizontal: 90, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
              side: BorderSide(
                color: Color(COLOR_PRIMARY),
              ),
            ),
          ),
          child: Text(
            'Redeem'.tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode(context) ? Colors.black : Colors.white,
            ),
          ),
          onPressed: () async {
            if (giftCodeController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Please Enter Gift Code".tr() + "\n"),
                backgroundColor: Colors.red,
              ));
            } else if (giftPinController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Please Enter Gift Pin".tr() + "\n"),
                backgroundColor: Colors.red,
              ));
            } else {
              await showProgress(context, "Please wait...".tr(), false);
              await FireStoreUtils().checkRedeemCode(giftCodeController.text.replaceAll(" ", "")).then((value) async {
                if (value != null) {
                  GiftCardsOrderModel giftCodeModel = value;
                  if (giftCodeModel.redeem == true) {
                    hideProgress();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Gift voucher already redeemed".tr() + "\n"),
                      backgroundColor: Colors.red,
                    ));
                  } else if (giftCodeModel.giftPin != giftPinController.text) {
                    hideProgress();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Gift Pin Invalid".tr() + "\n"),
                      backgroundColor: Colors.red,
                    ));
                  } else if (giftCodeModel.expireDate!.toDate().isBefore(DateTime.now())) {
                    hideProgress();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Gift Voucher expire".tr() + "\n"),
                      backgroundColor: Colors.red,
                    ));
                  } else {
                    giftCodeModel.redeem = true;

                    TopupTranHistoryModel wallet = TopupTranHistoryModel(
                        amount: giftCodeModel.price.toString(),
                        order_id: '',
                        serviceType: 'rental-service',
                        id: Uuid().v4(),
                        user_id: MyAppState.currentUser!.userID,
                        date: Timestamp.now(),
                        isTopup: false,
                        payment_method: "wallet",
                        payment_status: "success",
                        transactionUser: "customer",
                        note: 'Gift Voucher');

                    await FireStoreUtils.firestore.collection("wallet").doc(wallet.id).set(wallet.toJson()).then((value) async {
                      await FireStoreUtils.updateWalletAmount(amount: double.parse(giftCodeModel.price.toString())).then((value) async {
                        await FireStoreUtils.sendTopUpMail(paymentMethod: "Gift Voucher", amount: giftCodeModel.price.toString(), tractionId: wallet.id);
                        await FireStoreUtils().placeGiftCardOrder(giftCodeModel).then((value) {
                          hideProgress();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Voucher redeem successfully".tr() + "\n"),
                            backgroundColor: Colors.green,
                          ));
                          pushAndRemoveUntil(
                              context,
                              ContainerScreen(
                                user: MyAppState.currentUser!,
                                currentWidget: WalletScreen(),
                                appBarTitle: 'Wallet'.tr(),
                                drawerSelection: DrawerSelection.Wallet,
                              ),
                              false);
                        });
                      });
                    });
                  }
                } else {
                  hideProgress();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Invalid Gift Code".tr() + "\n"),
                    backgroundColor: Colors.red,
                  ));
                }
              });
            }
          },
        ),
      ),
    );
  }
}

class CustomInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = new StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' '); // Replace this with anything you want to put after each 4 numbers
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: new TextSelection.collapsed(offset: string.length));
  }
}
