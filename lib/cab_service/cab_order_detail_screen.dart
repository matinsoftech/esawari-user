import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/cab_service/cab_review_screen.dart';
import 'package:emartconsumer/cab_service/cab_service_screen.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/model/TaxModel.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:flutter/material.dart';

import '../model/CabOrderModel.dart';

class CabOrderDetailScreen extends StatefulWidget {
  final CabOrderModel? orderModel;
  final String? orderId;

  const CabOrderDetailScreen({Key? key, this.orderModel, this.orderId})
      : super(key: key);

  @override
  State<CabOrderDetailScreen> createState() => _CabOrderDetailScreenState();
}

class _CabOrderDetailScreenState extends State<CabOrderDetailScreen> {
  CabOrderModel? orderModel;
  String totalAmount = "0";

  @override
  void initState() {
    // TODO: implement initState
    if (widget.orderModel != null) {
      orderModel = widget.orderModel;
      setState(() {});
    } else {
       FireStoreUtils().getCabOrderById(widget.orderId).then((value) {
        orderModel = value;
        setState(() {});
      });
    }


    if (orderModel != null) {
      setState(() {
        totalAmount = amountShow(amount: orderModel!.subTotal!.toString());
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            if (widget.orderId != null) {
              push(context, const CabServiceScreen());
            } else {
              Navigator.pop(context);
            }
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Color(COLOR_PRIMARY),
          ),
        ),
        title: Text(
          "Ride Details".tr(),
          style: TextStyle(
            color: isDarkMode(context) ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: (orderModel != null)
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18.0, vertical: 10),
                        child: Column(
                          children: [
                            orderModel!.driver != null
                                ? Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Row(
                                          children: [
                                            CachedNetworkImage(
                                              height: 50,
                                              width: 50,
                                              imageUrl: getImageVAlidUrl(
                                                orderModel!
                                                    .driver!.profilePictureURL,
                                              ),
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  Center(
                                                      child:
                                                          CircularProgressIndicator
                                                              .adaptive(
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        Color(COLOR_PRIMARY)),
                                              )),
                                              errorWidget: (context, url,
                                                      error) =>
                                                  ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: Image.network(
                                                        placeholderImage,
                                                        fit: BoxFit.cover,
                                                      )),
                                              fit: BoxFit.cover,
                                            ),
                                            const SizedBox(
                                              width: 12,
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          orderModel!.driver!
                                                                  .firstName +
                                                              " " +
                                                              orderModel!
                                                                  .driver!
                                                                  .lastName,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                        Text(
                                                          totalAmount,
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              color: Color(
                                                                  COLOR_PRIMARY)),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 6,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          orderDate(orderModel!
                                                                  .createdAt)
                                                              .trim(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      15.0),
                                                          child: Container(
                                                            width: 7,
                                                            height: 7,
                                                            decoration:
                                                                const BoxDecoration(
                                                                    color: Colors
                                                                        .grey,
                                                                    shape: BoxShape
                                                                        .circle),
                                                          ),
                                                        ),
                                                        Text(
                                                          orderModel!
                                                                  .paymentStatus
                                                              ? "Paid".tr()
                                                              : "UnPaid".tr(),
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color: orderModel!
                                                                      .paymentStatus
                                                                  ? Colors.green
                                                                  : Colors
                                                                      .deepOrangeAccent),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      const Divider(thickness: 1),
                                      buildCabDetail(),
                                    ],
                                  )
                                : Container(),
                            const Divider(thickness: 1),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Image.asset(
                                  "assets/icons/ic_pic_drop_location.png",
                                  height: 80,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Text(
                                              orderModel!.sourceLocationName
                                                  .toString(),
                                              maxLines: 2,
                                            )),
                                            const Text(""),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Text(
                                              orderModel!
                                                  .destinationLocationName
                                                  .toString(),
                                              maxLines: 2,
                                            )),
                                            const Text(""),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            const Divider(thickness: 1),
                            buildPaymentDetails(),
                            const SizedBox(
                              height: 20,
                            ),
                            Visibility(
                              visible:
                                  orderModel!.status == ORDER_STATUS_COMPLETED
                                      ? true
                                      : false,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      push(context,
                                          CabReviewScreen(order: orderModel!));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(COLOR_PRIMARY),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 15.0,
                                    ),
                                    child:  Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Text(
                                        'Add Review'.tr(),
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Container(),
      ),
    );
  }

  buildCabDetail() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 30),
          child: Text(
            "Cab Details :".tr(),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              orderModel!.driver!.carNumber,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                "|",
                style: TextStyle(
                    color:
                        isDarkMode(context) ? Colors.white54 : Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              orderModel!.driver!.carMakes,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDarkMode(context) ? Colors.white : Colors.black,
              ),
            )
          ],
        ),
      ],
    );
  }

  buildPaymentDetails() {
    String taxAmount = "0.0";
    if (orderModel!.taxModel != null) {
      for (var element in orderModel!.taxModel!) {
        taxAmount = (double.parse(taxAmount) +
                getTaxValue(
                    amount: (double.parse(orderModel!.subTotal.toString()) -
                            double.parse(orderModel!.discount.toString()))
                        .toString(),
                    taxModel: element))
            .toString();
      }
    }

    var total = double.parse(orderModel!.subTotal.toString()) -
        double.parse(orderModel!.discount.toString()) +
        double.parse(taxAmount) +
        double.parse(orderModel!.tipValue!.isEmpty
            ? "0.0"
            : orderModel!.tipValue.toString());

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "Payment Details".tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode(context) ? Colors.white : Colors.black,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sub Total".tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode(context) ? Colors.white54 : Colors.black54,
                ),
              ),
              Text(
                amountShow(amount: orderModel!.subTotal.toString()),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode(context) ? Colors.white : Colors.black,
                ),
              )
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Discount".tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode(context) ? Colors.white54 : Colors.black54,
                ),
              ),
              Text(
                "(-" + amountShow(amount: orderModel!.discount!.toString()) + ")",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              )
            ],
          ),
          const Divider(),
          /* Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tax".tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode(context) ? Colors.white54 : Colors.black54,
                ),
              ),
              Text(
                amountShow(amount: taxCalculation(orderModel!).toString()),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode(context) ? Colors.white : Colors.black,
                ),
              )
            ],
          ),*/
          orderModel!.taxModel != null
              ? ListView.builder(
                  itemCount: orderModel!.taxModel!.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    TaxModel taxModel = orderModel!.taxModel![index];
                    return Column(
                      children: [

                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${taxModel.title.toString()} (${taxModel.type == "fix" ? amountShow(amount: taxModel.tax) : "${taxModel.tax}%"})",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDarkMode(context) ? Colors.white54 : Colors.black54,
                                ),
                              ),
                            ),
                            Text(
                              amountShow(
                                  amount: getTaxValue(
                                      amount: (double.parse(orderModel!.subTotal
                                          .toString()) -
                                          double.parse(orderModel!.discount
                                              .toString()))
                                          .toString(),
                                      taxModel: taxModel)
                                      .toString()),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDarkMode(context) ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                      ],
                    );
                  },
                )
              : Container(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tip".tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode(context) ? Colors.white54 : Colors.black54,
                ),
              ),
              Text(
                orderModel!.tipValue!.toString().isEmpty
                    ? amountShow(amount: "0.0")
                    : amountShow(amount: orderModel!.tipValue!.toString()),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode(context) ? Colors.white : Colors.black,
                ),
              )
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total".tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode(context) ? Colors.white : Colors.black,
                ),
              ),
              Text(
                // amountShow(amount : getTotalAmount().toString()),
                amountShow(amount: total.toString()),

                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(COLOR_PRIMARY),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

/* double getTotalAmount() {
    return double.parse(orderModel!.subTotal.toString()) -
        double.parse(orderModel!.discount.toString()) +
        taxCalculation(orderModel!) +
        double.parse(orderModel!.tipValue!.isEmpty ? "0.0" : orderModel!.tipValue.toString());
  */

/* double taxCalculation(CabOrderModel orderModel) {
    double totalTax = 0.0;

    if (orderModel.taxType!.isNotEmpty) {
      if (orderModel.taxType == "percent") {
        totalTax = (double.parse(orderModel.subTotal.toString()) - double.parse(orderModel.discount.toString())) * double.parse(orderModel.tax.toString()) / 100;
      } else {
        totalTax = double.parse(orderModel.tax.toString());
      }
    }
    return totalTax;
  */
}
