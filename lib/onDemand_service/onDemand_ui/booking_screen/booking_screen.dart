import 'package:bottom_picker/bottom_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/AddressModel.dart';
import 'package:emartconsumer/model/TaxModel.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/model/offer_model.dart';
import 'package:emartconsumer/onDemand_service/onDemand_model/onprovider_order_model.dart';
import 'package:emartconsumer/onDemand_service/onDemand_model/provider_serivce_model.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/onDemand_dashboard.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/ondemand_payment_screen/ondemand_payment_screen.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/order_screen/ondemand_order_screen.dart';
import 'package:emartconsumer/send_notification.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/services/show_toast_dialog.dart';
import 'package:emartconsumer/ui/deliveryAddressScreen/DeliveryAddressScreen.dart';
import 'package:flutter/material.dart';

class OnDemandBookingScreen extends StatefulWidget {
  final ProviderServiceModel providerModel;
  final String categoryTitle;

  OnDemandBookingScreen({Key? key, required this.providerModel, required this.categoryTitle}) : super(key: key);

  @override
  _OnDemandBookingScreenState createState() => _OnDemandBookingScreenState();
}

class _OnDemandBookingScreenState extends State<OnDemandBookingScreen> {
  int quantity = 1;
  TextEditingController mapName = TextEditingController();
  TextEditingController mapAddress = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController description = TextEditingController();
  var latValue = 0.0, longValue = 0.0;
  AddressModel addressModel = AddressModel();
  final dateTimeController = TextEditingController();

  DateTime selectedDateTime = DateTime.now();
  double subTotal = 0.0;
  double price = 0.0;
  double discountAmount = 0.0;
  double totalAmount = 0.0;
  ProviderServiceModel provider = ProviderServiceModel();

  @override
  void initState() {
    super.initState();
    provider = widget.providerModel;

    addressModel = MyAppState.selectedPosotion;
    getDetails();
    setState(() {});
  }

  late Future<List<OfferModel>> coupon;
  late Future<List<OfferModel>> publiccoupon;
  List<OfferModel> couponList = [];

  getDetails() {
    publiccoupon = FireStoreUtils().getProviderCoupon(provider.author.toString());
    coupon = FireStoreUtils().getProviderCouponAfterExpire(provider.author.toString());
    coupon.then((value) {
      setState(() {
        couponList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? const Color(DARK_BG_COLOR) : const Color(0xffF9F9F9),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: isDarkMode(context) ? const Color(DARK_BG_COLOR) : Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0.0,
        title: Text(
          'Book Service',
          style: TextStyle(
            fontFamily: "Poppinsm",
            color: isDarkMode(context) ? Colors.white : Colors.black,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text("Services", style: TextStyle(fontFamily: "Poppinsm", fontSize: 16)),
              ),
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
                    color: isDarkMode(context) ? Color(DarkContainerColor) : Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.providerModel.title.toString(),
                            style: TextStyle(fontFamily: "Poppinsm", fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            widget.categoryTitle.toString(),
                            style: TextStyle(fontFamily: "Poppinsm", fontSize: 14, fontWeight: FontWeight.w400),
                          ),
                          widget.providerModel.priceUnit == "Fixed"
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (quantity != 1) {
                                            quantity--;
                                          }
                                          setState(() {});
                                        },
                                        child: Image(
                                          image: const AssetImage("assets/images/minus.png"),
                                          color: Color(COLOR_PRIMARY),
                                          height: 30,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        '${int.parse(quantity.toString())}',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          quantity++;
                                          setState(() {});

                                          setState(() {});
                                        },
                                        child: Image(
                                          image: const AssetImage("assets/images/plus.png"),
                                          color: Color(COLOR_PRIMARY),
                                          height: 30,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : SizedBox()
                        ],
                      )),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: getImageVAlidUrl(provider.photos.isNotEmpty ? provider.photos.first.toString() : ""),
                          height: 100,
                          width: 100,
                          memCacheHeight: 100,
                          memCacheWidth: 100,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                          placeholder: (context, url) => Center(
                              child: CircularProgressIndicator.adaptive(
                            valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                          )),
                          errorWidget: (context, url, error) => ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                placeholderImage,
                                fit: BoxFit.cover,
                                cacheHeight: 100,
                                cacheWidth: 100,
                              )),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ]),
                  )),
              SizedBox(
                height: 15,
              ),
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
                    color: isDarkMode(context) ? const Color(DarkContainerColor) : Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Address".tr(),
                              style: const TextStyle(fontFamily: "Poppinsm", fontWeight: FontWeight.w700),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              addressModel.getFullAddress(),
                              style: const TextStyle(
                                fontFamily: "Poppinsm",
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.of(context).push(MaterialPageRoute(builder: (context) => DeliveryAddressScreen())).then((value) {
                            addressModel = value;
                            setState(() {});
                          });
                        },
                        child: Text(
                          "Change",
                          style: TextStyle(fontFamily: "Poppinsm", color: Color(COLOR_PRIMARY)),
                        ),
                      )
                    ],
                  )),
              SizedBox(
                height: 15,
              ),
              Text("Description", style: TextStyle(fontFamily: "Poppinsm", fontSize: 16)),
              SizedBox(
                height: 10,
              ),
              Theme(
                data: Theme.of(context).copyWith(textSelectionTheme: TextSelectionThemeData(selectionColor: Colors.grey.shade400)),
                child: TextFormField(
                  controller: description,
                  maxLines: 5,
                  textAlignVertical: TextAlignVertical.center,
                  textInputAction: TextInputAction.next,
                  validator: validateEmptyField,
                  style: const TextStyle(fontSize: 18.0),
                  keyboardType: TextInputType.text,
                  cursorColor: Color(COLOR_PRIMARY),
                  decoration: InputDecoration(
                    hintText: 'Enter Description',
                    hintStyle: TextStyle(
                      color: isDarkMode(context) ? Colors.white : const Color(0Xff333333),
                      fontSize: 14,
                      fontFamily: "Poppinsm",
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: isDarkMode(context) ? const Color(DarkContainerColor) : Colors.white,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: isDarkMode(context) ? Colors.grey.shade900 : Color(COLOR_PRIMARY), width: 2.0)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: isDarkMode(context) ? Colors.grey.shade900 : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onTap: () {},
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text("Booking Date & Slot", style: TextStyle(fontFamily: "Poppinsm", fontSize: 16)),
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () async {
                  BottomPicker.dateTime(
                    onSubmit: (index) {
                      setState(() {
                        DateTime dateAndTime = index;
                        selectedDateTime = dateAndTime;
                        dateTimeController.text = DateFormat('dd-MM-yyyy HH:mm').format(dateAndTime);
                      });
                    },
                    minDateTime: DateTime.now(),
                    buttonAlignment: MainAxisAlignment.center,
                    displaySubmitButton: true,
                    buttonSingleColor: Color(COLOR_PRIMARY),
                    buttonPadding: 10,
                    buttonWidth: 70,
                    pickerTitle: Text(""),
                  ).show(context);

                  setState(() {});
                },
                child: TextFormField(
                  readOnly: false,
                  controller: dateTimeController,
                  textAlignVertical: TextAlignVertical.center,
                  textInputAction: TextInputAction.next,
                  validator: validateEmptyField,
                  cursorColor: Color(COLOR_PRIMARY),
                  enabled: false,
                  style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    errorStyle: const TextStyle(color: Colors.red),
                    fillColor: isDarkMode(context) ? const Color(DarkContainerColor) : Colors.white,
                    hintText: "Choose Date and Time".tr(),
                    hintStyle: TextStyle(color: isDarkMode(context) ? Colors.white : const Color(0Xff333333)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              widget.providerModel.priceUnit == "Fixed"
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        couponList.isNotEmpty ? buildListPromoCode() : Container(),
                        buildPromoCode(),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "Price Detail",
                            style: TextStyle(fontFamily: "Poppinsm", fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        priceTotalRow(),
                      ],
                    )
                  : SizedBox()
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(36.0),
                side: BorderSide(color: Color(COLOR_PRIMARY)),
              ),
              backgroundColor: Color(COLOR_PRIMARY)),
          onPressed: () async {
            if (addressModel.id == null) {
              final snack = SnackBar(
                content: Text(
                  'Address is Empty.'.tr(),
                  style: const TextStyle(color: Colors.white),
                ),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.black,
              );
              ScaffoldMessenger.of(context).showSnackBar(snack);
            } else if (dateTimeController.text.isEmpty) {
              final snack = SnackBar(
                content: Text(
                  'Please select time slot.'.tr(),
                  style: const TextStyle(color: Colors.white),
                ),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.black,
              );
              ScaffoldMessenger.of(context).showSnackBar(snack);
            } else {
              if (widget.providerModel.priceUnit == "Fixed") {
                OnProviderOrderModel onDemandOrderModel = OnProviderOrderModel(
                    authorID: MyAppState.currentUser!.userID,
                    author: MyAppState.currentUser,
                    quantity: double.parse(quantity.toString()),
                    sectionId: sectionConstantModel!.id,
                    address: addressModel,
                    taxModel: taxList,
                    provider: provider,
                    status: ORDER_STATUS_PLACED,
                    scheduleDateTime: Timestamp.fromDate(selectedDateTime),
                    notes: description.text.toString(),
                    discount: discountAmount.toString(),
                    discountType: discountType.toString(),
                    discountLabel: discountLable.toString(),
                    adminCommission: sectionConstantModel!.adminCommision!.commission.toString(),
                    adminCommissionType: sectionConstantModel!.adminCommision!.type,
                    otp: getReferralCode(),
                    couponCode: offerCode.toString());

                push(
                    context,
                    OnDemandPaymentScreen(
                      onDemandOrderModel: onDemandOrderModel,
                      totalAmount: totalAmount,
                      isExtra: false,
                    ));
              } else {
                await showProgress(context, "Please wait...".tr(), false);
                OnProviderOrderModel _onDemandOrder = OnProviderOrderModel(
                    otp: getReferralCode(),
                    authorID: MyAppState.currentUser!.userID,
                    author: MyAppState.currentUser,
                    address: addressModel,
                    status: ORDER_STATUS_PLACED,
                    createdAt: Timestamp.now(),
                    taxModel: taxList,
                    quantity: double.parse(quantity.toString()),
                    sectionId: sectionConstantModel!.id,
                    provider: provider,
                    extraPaymentStatus: true,
                    scheduleDateTime: Timestamp.fromDate(selectedDateTime),
                    notes: description.text.toString(),
                    adminCommission: sectionConstantModel!.adminCommision!.commission.toString(),
                    adminCommissionType: sectionConstantModel!.adminCommision!.type,
                    paymentStatus: true);

                await FireStoreUtils().onDemandOrderPlace(_onDemandOrder, 0.0).then((value) async {});
                await FireStoreUtils.sendOrderOnDemandServiceEmail(orderModel: _onDemandOrder);
                print("============${_onDemandOrder.provider.author.toString()}");
                User? providerUser = await FireStoreUtils.getCurrentUser(_onDemandOrder.provider.author.toString());
                Map<String, dynamic> payLoad = <String, dynamic>{"type": 'provider_order', "orderId": _onDemandOrder.id};
                if (providerUser != null) {
                  await SendNotification.sendFcmMessage(providerBookingPlaced, providerUser.fcmToken.toString(), payLoad);
                }

                await hideProgress();
                ShowToastDialog.showToast("OnDemand Service successfully booked".tr());
                await push(
                    context,
                    OnDemandDahBoard(
                      user: MyAppState.currentUser!,
                      currentWidget: OnDemandOrderScreen(),
                      appBarTitle: 'Booking'.tr(),
                      drawerSelection: DrawerSelection.Order,
                    ));
              }
            }
          },
          child: Text(
            'Confirm'.tr(),
            style: TextStyle(
              fontSize: 20,
              fontFamily: "Poppinsm",
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  String discountType = "";
  String discountLable = "0.0";
  String offerCode = "";

  buildListPromoCode() {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
          color: isDarkMode(context) ? const Color(DarkContainerColor) : Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
          child: SizedBox(
            height: 85,
            child: ListView.builder(
                itemCount: couponList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (couponList[index].discountTypeOffer.toString() == 'Percentage' || couponList[index].discountTypeOffer.toString() == 'Percent') {
                        discountAmount = price * double.parse(couponList[index].discountOffer.toString()) / 100;
                      } else {
                        discountAmount = double.parse(couponList[index].discountOffer.toString());
                      }
                      if (subTotal > discountAmount) {
                        discountType = couponList[index].discountTypeOffer.toString();
                        discountLable = couponList[index].discountOffer.toString();
                        offerCode = couponList[index].offerCode.toString();
                      } else {
                        ShowToastDialog.showToast("Coupon not applied");
                      }

                      // if (couponList[index].discountTypeOffer == 'Percentage' || couponList[index].discountTypeOffer == 'Percent') {
                      //   discountAmount = subTotal * double.parse(couponList[index].discountOffer!) / 100;
                      //   discountType = couponList[index].discountTypeOffer.toString();
                      //   discountLable = couponList[index].discountOffer.toString();
                      //   offerCode = couponList[index].offerCode.toString();
                      // } else {
                      //   discountAmount = double.parse(couponList[index].discountOffer!);
                      //   discountType = couponList[index].discountTypeOffer.toString();
                      //   discountLable = couponList[index].discountOffer.toString();
                      //   offerCode = couponList[index].offerCode.toString();
                      // }

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

  Widget priceTotalRow() {
    price = 0.0;
    totalAmount = 0.0;
    discountAmount = 0.0;

    if (provider.disPrice == "" || provider.disPrice == "0") {
      price = double.parse(provider.price.toString()) * quantity;
    } else {
      price = double.parse(provider.disPrice.toString()) * quantity;
    }

    if (discountType == 'Percentage' || discountType == 'Percent') {
      discountAmount = price * double.parse(discountLable.toString()) / 100;
    } else {
      discountAmount = double.parse(discountLable);
    }

    if (subTotal < discountAmount) {
      discountType = "";
      discountLable = "0.0";
      offerCode = "0.0";
      discountAmount = 0.0;
    }

    subTotal = price - discountAmount;
    totalAmount = subTotal;
    if (taxList != null) {
      for (var element in taxList!) {
        totalAmount = totalAmount + getTaxValue(amount: (subTotal).toString(), taxModel: element);
      }
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
        color: isDarkMode(context) ? Color(DarkContainerColor) : Colors.white,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 5,
          ),
          Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Price",
                    style: TextStyle(
                      color: isDarkMode(context) ? Colors.white : Colors.black,
                      fontFamily: "Poppinsm",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    amountShow(amount: price.toString()),
                    style: TextStyle(
                      color: isDarkMode(context) ? Colors.white : Colors.black,
                      fontFamily: "Poppinsm",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )),
          discountAmount != 0
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Divider(),
                )
              : SizedBox(),
          discountAmount != 0
              ? Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Discount".tr() + " ${discountType == 'Percentage' || discountType == 'Percent' ? "(${discountLable}%)" : "(${amountShow(amount: discountLable)})"}",
                              style: TextStyle(
                                color: isDarkMode(context) ? Colors.white : Colors.black,
                                //fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              offerCode.toString(),
                              style: TextStyle(
                                color: isDarkMode(context) ? Colors.white : Colors.black,
                                //fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "(-" + amountShow(amount: discountAmount.toString()) + ")",
                        style: const TextStyle(
                          color: Colors.red,
                          fontFamily: "Poppinsm",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ))
              : SizedBox(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Divider(),
          ),
          Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "SubTotal",
                    style: TextStyle(
                      color: isDarkMode(context) ? Colors.white : Colors.black,
                      fontFamily: "Poppinsm",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    amountShow(amount: subTotal.toString()),
                    style: TextStyle(
                      color: isDarkMode(context) ? Colors.white : Colors.black,
                      fontFamily: "Poppinsm",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Divider(),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${taxModel.title.toString()} (${taxModel.type == "fix" ? amountShow(amount: taxModel.tax) : "${taxModel.tax}%"})",
                            style: TextStyle(fontFamily: "Poppinsm", fontWeight: FontWeight.w500, color: isDarkMode(context) ? Colors.white : Colors.black),
                          ),
                        ),
                        Text(
                          amountShow(amount: getTaxValue(amount: (double.parse(subTotal.toString())).toString(), taxModel: taxModel).toString()),
                          style: TextStyle(fontFamily: "Poppinsm", fontWeight: FontWeight.w500, color: isDarkMode(context) ? Colors.white : Colors.black, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Divider(),
                  ),
                ],
              );
            },
          ),
          taxList!.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Divider(),
                )
              : Container(),
          Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Amount",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode(context) ? Colors.white : Colors.black,
                      fontFamily: "Poppinsm",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    amountShow(amount: totalAmount.toString()),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode(context) ? Colors.white : Colors.black,
                      fontFamily: "Poppinsm",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )),
          SizedBox(
            height: 5,
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    description.clear();
    dateTimeController.clear();
    dateTimeController.clear();
    super.dispose();
  }

  buildPromoCode() {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
          color: isDarkMode(context) ? const Color(DarkContainerColor) : Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset("assets/images/reedem.png", height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Promo Code".tr(), style: const TextStyle(fontSize: 18)),
                        const SizedBox(
                          height: 5,
                        ),
                        Text("Apply promo code".tr(), style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),
                ],
              ),
              FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      isDismissible: true,
                      context: context,
                      backgroundColor: Colors.transparent,
                      enableDrag: true,
                      builder: (BuildContext context) => sheet());
                },
                mini: true,
                backgroundColor: Colors.blueGrey.shade50,
                elevation: 0,
                child: const Icon(
                  Icons.add,
                  color: Colors.black54,
                ),
              )
            ],
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
          padding: const EdgeInsets.fromLTRB(12, 5, 12, 0),
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
                      //"${snapshot[index].discountTypeOffer == "Fix Price" ? currencyData!.symbol : ""}${snapshot[index].discountOffer}${snapshot[index].discountTypeOffer == "Percentage" ? "% OFF" : " OFF"}",
                      snapshot[index].discountTypeOffer == "Fix Price"
                          ? amountShow(amount: snapshot[index].discountOffer.toString()) + " OFF"
                          : "${snapshot[index].discountOffer} % Off",
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.7),
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, letterSpacing: 0.5),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 15, right: 15, top: 3),
                    width: 1,
                    color: const Color(COUPON_DASH_COLOR),
                  ),
                  Text("valid till ".tr() + getDate(snapshot[index].expireOfferDate!.toDate().toString())!, style: const TextStyle(letterSpacing: 0.5))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? getDate(String date) {
    final format = DateFormat("MMM dd, yyyy");
    String formattedDate = format.format(DateTime.parse(date));
    return formattedDate;
  }

  TextEditingController couponTextFieldController = TextEditingController(text: '');

  sheet() {
    return Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 4.3, left: 25, right: 25),
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(color: Colors.transparent, border: Border.all(style: BorderStyle.none)),
        child: FutureBuilder<List<OfferModel>>(
            future: publiccoupon,
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
                        Center(
                          child: Container(
                              padding: const EdgeInsets.only(top: 10, left: 22, right: 22),
                              child: const Text(
                                "Voucher or Coupon code",
                                style: TextStyle(color: Color(0XFF9091A4), letterSpacing: 0.5, height: 2),
                              ).tr()),
                        ),
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
                                          style: TextStyle(color: Colors.black),
                                          controller: couponTextFieldController,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Write Coupon Code".tr(),
                                            hintStyle: const TextStyle(color: Color(0XFF9091A4)),
                                            labelStyle: const TextStyle(color: Color(0XFF333333)),
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

                                  if (couponTextFieldController.text.toLowerCase().toString() == couponModel.offerCode!.toLowerCase().toString()) {
                                    if (couponModel.discountTypeOffer.toString() == 'Percentage' || couponModel.discountTypeOffer.toString() == 'Percent') {
                                      discountAmount = price * double.parse(couponModel.discountOffer.toString()) / 100;
                                    } else {
                                      discountAmount = double.parse(couponModel.discountOffer.toString());
                                    }

                                    if (subTotal > discountAmount) {
                                      discountType = couponModel.discountTypeOffer.toString();
                                      discountLable = couponModel.discountOffer.toString();
                                      offerCode = couponModel.offerCode.toString();
                                    } else {
                                      ShowToastDialog.showToast("Coupon not applied");
                                    }
                                    setState(() {});
                                    break;
                                  } else {
                                    ShowToastDialog.showToast("Applied coupon not valid.");
                                  }

                                  // if (txt.text.toString() == couponModel.offerCode!.toString()) {
                                  //   if (couponModel.discountTypeOffer == 'Percentage' || couponModel.discountTypeOffer == 'Percent') {
                                  //     discountAmount = subTotal * double.parse(couponModel.discountOffer!) / 100;
                                  //     discountType = couponModel.discountTypeOffer.toString();
                                  //     discountLable = couponModel.discountOffer.toString();
                                  //     break;
                                  //   } else {
                                  //     discountAmount = double.parse(couponModel.discountOffer!);
                                  //     discountType = couponModel.discountTypeOffer.toString();
                                  //     discountLable = couponModel.discountOffer.toString();
                                  //   }
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

  Future<TimeOfDay?> _selectTime() async {
    FocusScope.of(context).requestFocus(new FocusNode()); //remove focus
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (newTime != null) {
      return newTime;
    }
    return null;
  }
}
