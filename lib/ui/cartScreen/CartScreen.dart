import 'dart:convert';

import 'package:bottom_picker/bottom_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/AddressModel.dart';
import 'package:emartconsumer/model/ProductModel.dart';
import 'package:emartconsumer/model/TaxModel.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/model/VendorModel.dart';
import 'package:emartconsumer/model/offer_model.dart';
import 'package:emartconsumer/model/variant_info.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/services/localDatabase.dart';
import 'package:emartconsumer/ui/deliveryAddressScreen/DeliveryAddressScreen.dart';
import 'package:emartconsumer/ui/productDetailsScreen/ProductDetailsScreen.dart';
import 'package:emartconsumer/ui/vendorProductsScreen/NewVendorProductsScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/DeliveryChargeModel.dart';
import '../payment/PaymentScreen.dart';

class CartScreen extends StatefulWidget {
  final bool fromStoreSelection;

  const CartScreen({Key? key, this.fromStoreSelection = false}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<List<CartProduct>> cartFuture;
  late List<CartProduct> cartProducts = [];
  TextEditingController noteController = TextEditingController(text: '');

  double subTotal = 0.0;
  late CartDatabase cartDatabase;
  double grandtotal = 0.0;
  var per = 0.0;
  late Future<List<OfferModel>> coupon;
  TextEditingController txt = TextEditingController(text: '');
  final FireStoreUtils _fireStoreUtils = FireStoreUtils();
  var percentage, type = 0.0;
  var amount = 0.00;
  late String couponId = '';
  String vendorID = "";
  late List<AddAddonsDemo> lstExtras = [];
  late List<String> commaSepratedAddOns = [];
  String? commaSepratedAddOnsString = "";
  bool? deliverExec = false;
  var deliveryCharges = "0.0";
  VendorModel? vendorModel;
  String? selctedOrderTypeValue = "Delivery".tr();
  bool isDeliverFound = false;
  var tipValue = 0.0;
  bool isTipSelected = false, isTipSelected1 = false, isTipSelected2 = false, isTipSelected3 = false;
  final TextEditingController _textFieldController = TextEditingController();

  double specialDiscount = 0.0;
  double specialDiscountAmount = 0.0;
  String specialType = "";

  Timestamp? scheduleTime;
  bool specialDiscountEnable = false;
  AddressModel addressModel = AddressModel();

  @override
  void initState() {
    super.initState();
    addressModel = MyAppState.selectedPosotion;

    coupon = _fireStoreUtils.getAllCoupons();
    getFoodType();
  }

  getFoodType() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      selctedOrderTypeValue = sp.getString("foodType") == "" || sp.getString("foodType") == null ? "Delivery" : sp.getString("foodType");
    });
    await FirebaseFirestore.instance.collection(Setting).doc('specialDiscountOffer').get().then((value) {
      specialDiscountEnable = value.data()!['isEnable'];
    });
  }

  Future<void> getDeliveyData() async {
    isDeliverFound = true;
    await _fireStoreUtils.getVendorByVendorID(cartProducts.first.vendorID).then((value) {
      vendorModel = value;
    });
    if (selctedOrderTypeValue == "Delivery") {
      num km = num.parse(getKm(addressModel.location!, UserLocation(latitude: vendorModel!.latitude, longitude: vendorModel!.longitude)));

      getDeliveryCharges(km);
    }
  }

  getDeliveryCharges(num km) async {
    deliverExec = true;
    if (sectionConstantModel!.serviceTypeFlag == "ecommerce-service") {
      deliveryCharges = sectionConstantModel!.delivery_charge!;
      setState(() {});
    } else {
      _fireStoreUtils.getDeliveryCharges().then((value) {
        if (value != null) {
          DeliveryChargeModel deliveryChargeModel = value;

          if (!deliveryChargeModel.vendorCanModify) {
            if (km > deliveryChargeModel.minimumDeliveryChargesWithinKm) {
              deliveryCharges = (km * deliveryChargeModel.deliveryChargesPerKm).toDouble().toStringAsFixed(currencyData!.decimal);
              setState(() {});
            } else {
              deliveryCharges = deliveryChargeModel.minimumDeliveryCharges.toDouble().toStringAsFixed(currencyData!.decimal);
              setState(() {});
            }
          } else {
            if (vendorModel != null && vendorModel!.deliveryCharge != null) {
              if (km > vendorModel!.deliveryCharge!.minimumDeliveryChargesWithinKm) {
                deliveryCharges = (km * vendorModel!.deliveryCharge!.deliveryChargesPerKm).toDouble().toStringAsFixed(currencyData!.decimal);
                setState(() {});
              } else {
                deliveryCharges = vendorModel!.deliveryCharge!.minimumDeliveryCharges.toDouble().toStringAsFixed(currencyData!.decimal);
                setState(() {});
              }
            } else {
              if (km > deliveryChargeModel.minimumDeliveryChargesWithinKm) {
                deliveryCharges = (km * deliveryChargeModel.deliveryChargesPerKm).toDouble().toStringAsFixed(currencyData!.decimal);
                setState(() {});
              } else {
                deliveryCharges = deliveryChargeModel.minimumDeliveryCharges.toDouble().toStringAsFixed(currencyData!.decimal);
                setState(() {});
              }
            }
          }
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    cartDatabase = Provider.of<CartDatabase>(context, listen: true);
    cartFuture = cartDatabase.allCartProducts;
    getPrefData();
    //setPrefData();
  }

  @override
  Widget build(BuildContext context) {
    cartDatabase = Provider.of<CartDatabase>(context, listen: true);
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Colors.black : const Color(0xffFFFFFF),
      body: StreamBuilder<List<CartProduct>>(
        stream: cartDatabase.watchProducts,
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
              ),
            );
          }

          if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
            return SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              child: Center(
                child: showEmptyState('Empty Cart'.tr(), context),
              ),
            );
          } else {
            cartProducts = snapshot.data!;
            if (!isDeliverFound) {
              getDeliveyData();
            }
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: cartProducts.length,
                          itemBuilder: (context, index) {
                            vendorID = cartProducts[index].vendorID;
                            return Container(
                              margin: const EdgeInsets.only(left: 13, top: 13, right: 13, bottom: 13),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
                                color: isDarkMode(context) ? Color(DarkContainerColor) : Colors.white,
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
                                  buildCartRow(cartProducts[index], lstExtras),
                                ],
                              ),
                            );
                          },
                        ),
                        buildTotalRow(snapshot.data!, lstExtras, vendorID),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (couponId.isEmpty) {
                      txt.text = "";
                    }

                    Map<String, dynamic> specialDiscountMap = {'special_discount': specialDiscountAmount, 'special_discount_label': specialDiscount, 'specialType': specialType};

                    if (selctedOrderTypeValue == "Delivery") {
                      // push(
                      //   context,
                      //   DeliveryAddressScreen(
                      //     total: grandtotal,
                      //     products: cartProducts,
                      //     discount: per == 0.0 ? type : per,
                      //     couponCode: txt.text,
                      //     notes: noteController.text,
                      //     couponId: couponId,
                      //     extra_addons: commaSepratedAddOns,
                      //     tipValue: tipValue.toString(),
                      //     take_away: selctedOrderTypeValue == "Delivery" ? false : true,
                      //     deliveryCharge: deliveryCharges,
                      //     taxModel: taxList,
                      //     specialDiscountMap: specialDiscountMap,
                      //     scheduleTime: scheduleTime,
                      //   ),
                      // );
                      push(
                        context,
                        PaymentScreen(
                          total: grandtotal,
                          products: cartProducts,
                          discount: per == 0.0 ? type : per,
                          couponCode: txt.text,
                          couponId: couponId,
                          notes: noteController.text,
                          extra_addons: commaSepratedAddOns,
                          tipValue: tipValue.toString(),
                          take_away: selctedOrderTypeValue == "Delivery" ? false : true,
                          deliveryCharge: deliveryCharges,
                          taxModel: taxList,
                          specialDiscountMap: specialDiscountMap,
                          scheduleTime: scheduleTime,
                          addressModel: addressModel,
                        ),
                      );
                    } else {
                      push(
                        context,
                        PaymentScreen(
                          total: grandtotal,
                          discount: per == 0.0 ? type : per,
                          couponCode: txt.text,
                          couponId: couponId,
                          notes: noteController.text,
                          products: cartProducts,
                          extra_addons: commaSepratedAddOns,
                          tipValue: "0",
                          take_away: true,
                          deliveryCharge: "0",
                          taxModel: taxList,
                          specialDiscountMap: specialDiscountMap,
                          scheduleTime: scheduleTime,
                          addressModel: addressModel,
                        ),
                      );
                      // placeOrder();
                    }
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 1,
                    height: MediaQuery.of(context).size.height * 0.080,
                    child: Container(
                      color: Color(COLOR_PRIMARY),
                      padding: const EdgeInsets.only(left: 15, right: 10, bottom: 8, top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Text("Total : ".tr(),
                                style: const TextStyle(
                                  color: Color(0xFFFFFFFF),
                                )),
                            Text(
                              amountShow(amount: grandtotal.toString()),
                              style: const TextStyle(
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                          ]),
                          Text("PROCEED TO CHECKOUT".tr(),
                              style: const TextStyle(
                                color: Color(0xFFFFFFFF),
                              )),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }

  buildCartRow(CartProduct cartProduct, List<AddAddonsDemo> addons) {
    List addOnVal = [];
    var quen = cartProduct.quantity;
    double priceTotalValue = 0.0;
    // priceTotalValue   = double.parse(cartProduct.price);
    double AddOnVal = 0;
    for (int i = 0; i < lstExtras.length; i++) {
      AddAddonsDemo addAddonsDemo = lstExtras[i];
      if (addAddonsDemo.categoryID == cartProduct.id) {
        AddOnVal = AddOnVal + double.parse(addAddonsDemo.price!);
      }
    }

    ProductModel? productModel;
    FireStoreUtils().getProductByID(cartProduct.id.split('~').first).then((value) {
      productModel = value;
    });

    VariantInfo? variantInfo;
    if (cartProduct.variant_info != null) {
      variantInfo = VariantInfo.fromJson(jsonDecode(cartProduct.variant_info.toString()));
    }
    if (cartProduct.extras == null) {
      addOnVal.clear();
    } else {
      if (cartProduct.extras is String) {
        if (cartProduct.extras == '[]') {
          addOnVal.clear();
        } else {
          String extraDecode = cartProduct.extras.toString().replaceAll("[", "").replaceAll("]", "").replaceAll("\"", "");
          if (extraDecode.contains(",")) {
            addOnVal = extraDecode.split(",");
          } else {
            if (extraDecode.trim().isNotEmpty) {
              addOnVal = [extraDecode];
            }
          }
        }
      }

      if (cartProduct.extras is List) {
        addOnVal = List.from(cartProduct.extras);
      }
    }

    if (cartProduct.extras_price != null && cartProduct.extras_price != "" && double.parse(cartProduct.extras_price!) != 0.0) {
      priceTotalValue += double.parse(cartProduct.extras_price!) * cartProduct.quantity;
    }
    priceTotalValue += double.parse(cartProduct.price) * cartProduct.quantity;

    // VariantInfo variantInfo= cartProduct.variant_info;
    return InkWell(
      onTap: () {
        _fireStoreUtils.getVendorByVendorID(cartProduct.vendorID).then((value) {
          push(
            context,
            NewVendorProductsScreen(vendorModel: value),
          );
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                      height: 80,
                      width: 80,
                      imageUrl: getImageVAlidUrl(cartProduct.photo),
                      imageBuilder: (context, imageProvider) => Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            )),
                          ),
                      errorWidget: (context, url, error) => ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.network(
                            placeholderImage,
                            fit: BoxFit.cover,
                          ))),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartProduct.name,
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        amountShow(amount: priceTotalValue.toString()),
                        style: TextStyle(fontSize: 20, color: Color(COLOR_PRIMARY)),
                      ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (quen != 0) {
                          quen--;
                          removetocard(cartProduct, quen);
                        }
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
                      '${cartProduct.quantity}'.tr(),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        print(productModel!.quantity);
                        print(quen);
                        if (productModel!.itemAttributes != null) {
                          if (productModel!.itemAttributes!.variants!.where((element) => element.variant_sku == variantInfo!.variant_sku).isNotEmpty) {
                            if (int.parse(productModel!.itemAttributes!.variants!
                                        .where((element) => element.variant_sku == variantInfo!.variant_sku)
                                        .first
                                        .variant_quantity
                                        .toString()) >
                                    quen ||
                                int.parse(productModel!.itemAttributes!.variants!
                                        .where((element) => element.variant_sku == variantInfo!.variant_sku)
                                        .first
                                        .variant_quantity
                                        .toString()) ==
                                    -1) {
                              quen++;
                              addtocard(cartProduct, quen);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Product is out of Stock".tr()),
                              ));
                            }
                          } else {
                            if (productModel!.quantity > quen || productModel!.quantity == -1) {
                              quen++;
                              addtocard(cartProduct, quen);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Product is out of Stock".tr()),
                              ));
                            }
                          }
                        } else {
                          if (productModel!.quantity > quen || productModel!.quantity == -1) {
                            quen++;
                            addtocard(cartProduct, quen);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Product is out of Stock".tr()),
                            ));
                          }
                        }
                      },
                      child: Image(
                        image: const AssetImage("assets/images/plus.png"),
                        color: Color(COLOR_PRIMARY),
                        height: 30,
                      ),
                    )
                  ],
                )
              ],
            ),
            variantInfo == null || variantInfo.variant_options!.isEmpty
                ? Container()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: Wrap(
                      spacing: 6.0,
                      runSpacing: 6.0,
                      children: List.generate(
                        variantInfo.variant_options!.length,
                        (i) {
                          return _buildChip(
                              "${variantInfo!.variant_options!.keys.elementAt(i)} : ${variantInfo.variant_options![variantInfo.variant_options!.keys.elementAt(i)]}", i);
                        },
                      ).toList(),
                    ),
                  ),
            SizedBox(
              height: addOnVal.isEmpty ? 0 : 30,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ListView.builder(
                    itemCount: addOnVal.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Text(
                        "${addOnVal[index].toString().replaceAll("\"", "")} ${(index == addOnVal.length - 1) ? "" : ","}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      );
                    }),
              ),
            ),
            // cartProduct.variant_info != null?ListView.builder(
            //   itemCount: variantInfo.variant_options!.length,
            //   shrinkWrap: true,
            //   itemBuilder: (context, index) {
            //     String key = cartProduct.variant_info.variant_options!.keys.elementAt(index);
            //     return Padding(
            //       padding: const EdgeInsets.symmetric(vertical: 2),
            //       child: Row(
            //         children: [
            //           Text("$key : "),
            //           Text("${cartProduct.variant_info.variant_options![key]}"),
            //         ],
            //       ),
            //     );
            //   },
            // ):Container(),
          ],
        ),
      ),
    );
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    final currentDate = DateTime.now();
    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }

  Widget buildTotalRow(List<CartProduct> data, List<AddAddonsDemo> lstExtras, String vendorID) {
    var _font = 16.00;
    subTotal = 0.00;
    grandtotal = 0;
    double discountVal = 0;

    for (int a = 0; a < data.length; a++) {
      CartProduct e = data[a];
      bool isAddOnApplied = false;
      double AddOnVal = 0;
      for (int i = 0; i < lstExtras.length; i++) {
        AddAddonsDemo addAddonsDemo = lstExtras[i];
        if (addAddonsDemo.categoryID == e.id) {
          isAddOnApplied = true;
          AddOnVal = AddOnVal + double.parse(addAddonsDemo.price!);
        }
      }
      if (e.extras_price != null && e.extras_price != "" && double.parse(e.extras_price!) != 0.0) {
        subTotal += double.parse(e.extras_price!) * e.quantity;
      }
      subTotal += double.parse(e.price) * e.quantity;

      grandtotal = subTotal + double.parse(deliveryCharges) + tipValue;
    }

    if (percentage != null) {
      amount = 0;
      amount = subTotal * percentage / 100;
      discountVal = subTotal * percentage / 100;
      grandtotal = grandtotal - amount;
      per = amount.toDouble();
      // print(amount);
    }
    amount = grandtotal - type;
    grandtotal = amount;
    if (type != 0) {
      discountVal = type;
    }
    // print(amount);

    if (vendorModel != null && specialDiscountEnable) {
      if (vendorModel!.specialDiscountEnable) {
        final now = new DateTime.now();
        var day = DateFormat('EEEE', 'en_US').format(now);
        var date = DateFormat('dd-MM-yyyy').format(now);
        vendorModel!.specialDiscount.forEach((element) {
          if (day == element.day.toString()) {
            if (element.timeslot!.isNotEmpty) {
              element.timeslot!.forEach((element) {
                if (element.discount_type == "delivery") {
                  var start = DateFormat("dd-MM-yyyy HH:mm").parse(date + " " + element.from.toString());
                  var end = DateFormat("dd-MM-yyyy HH:mm").parse(date + " " + element.to.toString());
                  if (isCurrentDateInRange(start, end)) {
                    specialDiscount = double.parse(element.discount.toString());
                    specialType = element.type.toString();
                    if (element.type == "percentage") {
                      specialDiscountAmount = subTotal * specialDiscount / 100;
                    } else {
                      specialDiscountAmount = specialDiscount;
                    }
                    grandtotal = grandtotal - specialDiscountAmount;
                  }
                }
              });
            }
          }
        });
      } else {
        specialDiscount = double.parse("0");
        specialType = "amount";
      }
    }
    //  grandtotal += getTaxValue(taxModel, subTotal - discountVal - specialDiscountAmount);
    if (taxList != null) {
      for (var element in taxList!) {
        grandtotal = grandtotal + getTaxValue(amount: (subTotal - discountVal - specialDiscountAmount).toString(), taxModel: element);
      }
    }

    // });
    // });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            margin: const EdgeInsets.only(left: 13, top: 13, right: 13, bottom: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
              color: isDarkMode(context) ? Color(DarkContainerColor) : Colors.white,
              boxShadow: [
                isDarkMode(context)
                    ? const BoxShadow()
                    : BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 5,
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
        selctedOrderTypeValue == "Delivery"
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                margin: const EdgeInsets.only(left: 13, top: 13, right: 13, bottom: 5),
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
                          getDeliveyData();
                          setState(() {});
                        });
                      },
                      child: Text(
                        "Change",
                        style: TextStyle(fontFamily: "Poppinsm", color: Color(COLOR_PRIMARY)),
                      ),
                    )
                  ],
                ))
            : SizedBox(),
        if (sectionConstantModel!.serviceTypeFlag != "ecommerce-service")
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin: const EdgeInsets.all(10),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Schedule Order".tr(),
                        style: const TextStyle(
                          fontFamily: "Poppinsm",
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      BottomPicker.dateTime(
                        onSubmit: (index) {
                          setState(() {
                            DateTime dateAndTime = index;
                            scheduleTime = Timestamp.fromDate(dateAndTime);
                          });
                        },
                        minDateTime: DateTime.now(),
                        buttonAlignment: MainAxisAlignment.center,
                        displaySubmitButton: true,
                        pickerTitle: Text(""),
                        buttonSingleColor: Color(COLOR_PRIMARY),
                      ).show(context);
                    },
                    child: Text(
                      scheduleTime == null ? "Select".tr() : DateFormat("EEE dd MMMM , HH:mm aa").format(scheduleTime!.toDate()),
                      style: TextStyle(fontFamily: "Poppinsm", color: Color(COLOR_PRIMARY)),
                    ),
                  )
                ],
              )),
        Container(
          margin: const EdgeInsets.only(left: 13, top: 10, right: 13, bottom: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
            color: isDarkMode(context) ? Color(DarkContainerColor) : Colors.white,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Delivery Option: ".tr(),
                        style: TextStyle(fontSize: _font),
                      ),
                      Text(
                        selctedOrderTypeValue == "Delivery" ? "Delivery (${amountShow(amount: deliveryCharges.toString())})" : selctedOrderTypeValue! + " (Free)",
                        //selctedOrderTypeValue == "Delivery" ? "Delivery (${symbol + double.parse(deliveryCharges).toStringAsFixed(decimal)})" : selctedOrderTypeValue! + " (Free)",
                        style:
                            TextStyle(color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff333333), fontSize: selctedOrderTypeValue == "Delivery" ? _font : 15),
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
                        "Subtotal".tr(),
                        style: TextStyle(fontSize: _font),
                      ),
                      Text(
                        amountShow(amount: subTotal.toString()),
                        style: TextStyle(color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff333333), fontSize: _font),
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
                        style: TextStyle(fontSize: _font),
                      ),
                      Text(
                        //percentage != 0.0
                        // ? percentage != null
                        // ? "(" + symbol + per.toDouble().toStringAsFixed(decimal) + ")"
                        //    : "(" + symbol + 0.toStringAsFixed(decimal) + ")"
                        //  : type != null
                        //  ? "(" + symbol + type.toDouble().toStringAsFixed(decimal) + ")"
                        //  : "(" + symbol + 0.toStringAsFixed(decimal) + ")",

                        percentage != 0.0
                            ? percentage != null
                                ? "(-" + amountShow(amount: (per.toDouble()).toString()) + ")"
                                : "(-" + amountShow(amount: "0.0") + ")"
                            : type != null
                                ? "(-" + amountShow(amount: (type.toDouble()).toString()) + ")"
                                : "(-" + amountShow(amount: "0.0") + ")",

                        style: TextStyle(fontFamily: "Poppinsm", color: Colors.red, fontSize: _font),
                      ),
                    ],
                  )),
              const Divider(
                thickness: 1,
              ),
              Visibility(
                visible: vendorModel != null && specialDiscountEnable ? vendorModel!.specialDiscountEnable : false,
                child: Column(
                  children: [
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Special Discount".tr() + "($specialDiscount ${specialType == "amount" ? currencyData!.symbol : "%"})",
                              style: TextStyle(fontSize: _font),
                            ),
                            Text(
                              "(-${amountShow(amount: specialDiscountAmount.toString())})",
                              //symbol + specialDiscountAmount.toStringAsFixed(decimal),
                              style: TextStyle(fontFamily: "Poppinsm", color: Colors.red, fontSize: _font),
                            ),
                          ],
                        )),
                    const Divider(
                      thickness: 1,
                    ),
                  ],
                ),
              ),

              selctedOrderTypeValue == "Delivery"
                  ? (widget.fromStoreSelection && !deliverExec! && MyAppState.selectedPosotion.location!.latitude == 0.0 && MyAppState.selectedPosotion.location!.longitude == 0)
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Text("Delivery Charge Will Applied Next Step.".tr(), style: TextStyle(fontSize: _font)),
                        )
                      : Column(
                          children: [
                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Delivery Charges".tr(),
                                      style: TextStyle(fontSize: _font),
                                    ),
                                    Text(
                                      amountShow(amount: deliveryCharges.toString()),
                                      style: TextStyle(color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff333333), fontSize: _font),
                                    ),
                                  ],
                                )),
                            const Divider(
                              thickness: 1,
                            ),
                          ],
                        )
                  : Container(),
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
                                style: TextStyle(fontFamily: "Poppinsm", fontSize: _font),
                              ),
                            ),
                            Text(
                              amountShow(
                                  amount: getTaxValue(amount: (double.parse(subTotal.toString()) - discountVal - specialDiscountAmount).toString(), taxModel: taxModel).toString()),
                              style: TextStyle(fontFamily: "Poppinsm", color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff333333), fontSize: _font),
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
              /* taxModel != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ((taxModel!.tax_lable!.isNotEmpty)
                                    ? taxModel!.tax_lable.toString()
                                    : "Tax") +
                                " ${(taxModel!.tax_type == "fix") ? "" : "(${taxModel!.tax_amount} %)"}",
                            style: TextStyle(fontSize: _font),
                          ),
                          Text(
                            //symbol + getTaxValue(taxModel, subTotal - discountVal - specialDiscountAmount).toStringAsFixed(decimal),
                            amountShow(amount: getTaxValue(taxModel,subTotal -
                                discountVal -
                                specialDiscountAmount).toString()),

                            style: TextStyle(
                                color: isDarkMode(context)
                                    ? const Color(0xffFFFFFF)
                                    : const Color(0xff333333),
                                fontSize: _font),
                          ),
                        ],
                      ))
                  : Container(),*/
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
                                style: TextStyle(color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff333333), fontSize: _font),
                              ),
                              Text(
                                '${amountShow(amount: tipValue.toString())}',
                                style: TextStyle(color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff333333), fontSize: _font),
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
                        style: TextStyle(color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff333333), fontSize: _font),
                      ),
                      Text(
                        amountShow(amount: grandtotal.toString()),
                        style: TextStyle(color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff333333), fontSize: _font),
                      ),
                    ],
                  )),
            ],
          ),
        ),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
              color: isDarkMode(context) ? Color(DarkContainerColor) : Colors.white,
              boxShadow: [
                isDarkMode(context)
                    ? const BoxShadow()
                    : BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 5,
                      ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Remarks".tr(),
                      style: const TextStyle(),
                    ),
                    Text("remarks-restaurant".tr(), style: const TextStyle()),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        isDismissible: true,
                        context: context,
                        backgroundColor: Colors.transparent,
                        enableDrag: true,
                        builder: (BuildContext context) => Notesheet());
                  },
                  child: const Image(image: AssetImage("assets/images/add.png"), width: 40),
                )
              ],
            )),
        selctedOrderTypeValue == "Delivery"
            ? Container(
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
                      "tip-to-driver".tr(),
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
            : Container(),
      ],
    );
  }

  addtocard(CartProduct cartProduct, qun) async {
    await cartDatabase.updateProduct(CartProduct(
        id: cartProduct.id,
        name: cartProduct.name,
        photo: cartProduct.photo,
        price: cartProduct.price,
        vendorID: cartProduct.vendorID,
        quantity: qun,
        category_id: cartProduct.category_id,
        discountPrice: cartProduct.discountPrice!));
  }

  removetocard(CartProduct cartProduct, qun) async {
    if (qun >= 1) {
      await cartDatabase.updateProduct(CartProduct(
          id: cartProduct.id,
          category_id: cartProduct.category_id,
          name: cartProduct.name,
          photo: cartProduct.photo,
          price: cartProduct.price,
          vendorID: cartProduct.vendorID,
          quantity: qun,
          discountPrice: cartProduct.discountPrice!));
    } else {
      cartDatabase.removeProduct(cartProduct.id);
    }
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
                            child: Text(
                              "Voucher or Coupon code".tr(),
                              style: const TextStyle(color: Color(0XFF9091A4), letterSpacing: 0.5, height: 2),
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
                              percentage = 0.0;
                              type = 0.0;
                              couponId = "";
                              setState(() {
                                for (int a = 0; a < snapshot.data!.length; a++) {
                                  OfferModel couponModel = snapshot.data![a];

                                  if (vendorID == couponModel.storeId || couponModel.storeId == "") {
                                    if (txt.text.toString() == couponModel.offerCode!.toString()) {
                                      if (couponModel.discountTypeOffer == 'Percentage' || couponModel.discountTypeOffer == 'Percent') {
                                        percentage = double.parse(couponModel.discountOffer!);
                                        couponId = couponModel.offerId!;
                                        break;
                                      } else {
                                        type = double.parse(couponModel.discountOffer!);
                                        couponId = couponModel.offerId!;
                                      }
                                    }
                                  }
                                }
                              });

                              Navigator.pop(context);
                            },
                            child: Text(
                              "REDEEM NOW".tr(),
                              style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontSize: 16),
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

  Notesheet() {
    return Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 4.3, left: 25, right: 25),
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(color: Colors.transparent, border: Border.all(style: BorderStyle.none)),
        child: Column(children: [
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
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: isDarkMode(context) ? Colors.grey.shade700 : Colors.white),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        'Remarks'.tr(),
                        style: TextStyle(color: isDarkMode(context) ? const Color(0XFFD5D5D5) : const Color(0XFF2A2A2A), fontSize: 16),
                      )),
                  Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Write remarks for Store'.tr(),
                        style: TextStyle(color: isDarkMode(context) ? Colors.white70 : const Color(0XFF9091A4), letterSpacing: 0.5, height: 2),
                      ).tr()),
                  Container(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                      // height: 120,
                      child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(12),
                          dashPattern: const [4, 2],
                          color: isDarkMode(context) ? const Color(0XFF484848) : const Color(0XFFB7B7B7),
                          child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(12)),
                              child: Container(
                                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                                  color: isDarkMode(context) ? const Color(0XFF0e0b08) : const Color(0XFFF1F4F7),
                                  // height: 120,
                                  alignment: Alignment.center,
                                  child: TextFormField(
                                    textAlign: TextAlign.center,
                                    controller: noteController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Write Remarks'.tr(),
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
                        Navigator.pop(context);
                      },
                      child: Text(
                        'SUBMIT'.tr(),
                        style: TextStyle(color: isDarkMode(context) ? Colors.black : Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ]));
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

// listData(snapshot){

//   return Container(height: 0,
//             child:
//           ListView.builder(
//                   itemCount: snapshot.data!.length,
//                   itemBuilder: (context, index) {

//                return
//           buildcouponItem(snapshot.data![index]);

//                   }));
// }
/*  buildcouponItem(snapshot) {
//   var time = DateTime.fromMicrosecondsSinceEpoch(couponModel.exipreAt.microsecondsSinceEpoch);
// //  print(txt.text);
//  print(time);
//  var nowtime =DateTime.now();
// //   print(couponModel.code);
// print(nowtime.compareTo(time));
//  print(couponModel.exipreAt);
    return Container(
        height: 0,
        child: ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              OfferModel couponModel = snapshot.data[index];
              couponId = couponModel.offerId!;

              if (txt.text == couponModel.offerCode! &&
                  couponModel.isEnableOffer == true &&
                  couponModel.discountTypeOffer == 'Percentage') {
                percentage = double.parse(couponModel.discountOffer!);
                print(couponModel.discountOffer.toString()+"====OFFER");
                // widget.per =couponModel.discount;
              }
              if (txt.text == couponModel.offerCode &&
                  couponModel.isEnableOffer == true &&
                  couponModel.discountTypeOffer == 'Fix Price') {
                type = double.parse(couponModel.discountOffer!);
                print(type.toString()+"====OFFERtype");
                //  print(couponModel.discount);
              } else {
                print("No====================");
              }
              return Center();
            }));
  }*/

  Future<void> getPrefData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("musics_key")) {
      final String musicsString = prefs.getString('musics_key')!;
      if (musicsString.isNotEmpty) {
        lstExtras = AddAddonsDemo.decode(musicsString);
        for (var element in lstExtras) {
          commaSepratedAddOns.add(element.name!);
        }
        commaSepratedAddOnsString = commaSepratedAddOns.join(", ");
      }
    }
    /* _fireStoreUtils.getSectionTaxSetting(SELECTED_CATEGORY).then((value) {
      if (value != null && value.tax_active != null && value.tax_active!) {
        taxModel = value;
        setState(() {});
      }
    });*/
  }

  Future<void> setPrefData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    sp.setString("musics_key", "");
    sp.setString("addsize", "");
  }

  Widget TipWidgetMethod({String? amount}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 5),
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
        decoration: BoxDecoration(
          color: tipValue == 10 && isTipSelected
              ? Color(COLOR_PRIMARY)
              : tipValue == 20 && isTipSelected1
                  ? Color(COLOR_PRIMARY)
                  : tipValue == 30 && isTipSelected2
                      ? Color(COLOR_PRIMARY)
                      : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xff9091A4), width: 1),
        ),
        child: Center(
            child: Text(
          amountShow(amount: amount!),
          //symbol + amount!,
          style: TextStyle(
            color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff333333),
          ),
        )),
      ),
    );
  }
}

Widget _buildChip(String label, int attributesOptionIndex) {
  return Container(
    decoration: BoxDecoration(color: const Color(0xffEEEDED), borderRadius: BorderRadius.circular(4)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
    ),
  );
}
