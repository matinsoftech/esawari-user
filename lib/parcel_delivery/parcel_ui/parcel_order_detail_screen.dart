import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/TaxModel.dart';
import 'package:emartconsumer/parcel_delivery/parcel_dashboard.dart';
import 'package:emartconsumer/parcel_delivery/parcel_model/parcel_order_model.dart';
import 'package:emartconsumer/parcel_delivery/parcel_ui/history_screen.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:flutter/material.dart';

class ParcelOrderDetailScreen extends StatefulWidget {
  final ParcelOrderModel? orderModel;
  final String? orderId;

  const ParcelOrderDetailScreen({Key? key, this.orderModel, this.orderId})
      : super(key: key);

  @override
  State<ParcelOrderDetailScreen> createState() =>
      _ParcelOrderDetailScreenState();
}

class _ParcelOrderDetailScreenState extends State<ParcelOrderDetailScreen> {
  ParcelOrderModel? orderModel;
  String totalAmount = "";
  String taxAmount = "0.0";

  @override
  void initState() {
    // TODO: implement initState
    loadData();
    super.initState();
  }

  void loadData() async {
    if (widget.orderModel != null) {
      orderModel = widget.orderModel;
      setState(() {});
    } else {
      await FireStoreUtils().getParcelOrderById(widget.orderId).then((value) {
        orderModel = value;
        setState(() {});
      });
    }

    //totalAmount = "${currencyData!.symbol} ${(double.parse(orderModel!.subTotal!.toString()) - double.parse(orderModel!.discount!.toString()) + taxCalculation(orderModel!)).toStringAsFixed(2)}";
    if (orderModel != null) {
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
      print("ORDERID");
      print(orderModel!.id);
      totalAmount = amountShow(
          amount: (double.parse(orderModel!.subTotal!.toString()) -
                  double.parse(orderModel!.discount!.toString()) +
                  double.parse(taxAmount))
              .toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            push(
                context,
                ParcelDahBoard(
                    user: MyAppState.currentUser,
                    drawerSelection: DrawerSelection.Orders,
                    appBarTitle: "History".tr(),
                    currentWidget: const HistoryScreen()));
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Color(COLOR_PRIMARY),
          ),
        ),
        title: Text(
          "Order Detail".tr(),
          style: TextStyle(
            color: isDarkMode(context) ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: orderModel != null
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 10),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildLine(),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    buildUsersDetails(context,
                                        isSender: true,
                                        userDetails: orderModel?.sender),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    buildUsersDetails(context,
                                        isSender: false,
                                        userDetails: orderModel?.receiver),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildOtherDetails(
                                title: "Distance".tr(),
                                value: orderModel!.distance.toString() +
                                    " " +
                                    "km".tr(),
                              ),
                              buildOtherDetails(
                                title: "Weight".tr(),
                                value: orderModel!.parcelWeight.toString(),
                              ),
                              //  buildOtherDetails(title: "Rate".tr(), value: symbol + double.parse(orderModel!.subTotal!).toStringAsFixed(decimal), color: Color(COLOR_PRIMARY)),
                              buildOtherDetails(
                                  title: "Rate".tr(),
                                  value: amountShow(
                                      amount: orderModel!.subTotal!.toString()),
                                  color: Color(COLOR_PRIMARY)),
                            ],
                          ),
                          const Divider(),
                          orderModel!.driver != null
                              ? Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          height: 60,
                                          width: 60,
                                          imageUrl: orderModel!
                                              .driver!.profilePictureURL,
                                          placeholder: (context, url) =>
                                              Image.asset(
                                                  'assets/images/img_placeholder.png'),
                                          errorWidget: (context, url, error) =>
                                              Image.network(
                                                  placeholderImage,
                                                  fit: BoxFit.fill),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              orderModel!.driver!.firstName +
                                                  " " +
                                                  orderModel!.driver!.lastName,
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(
                                              height: 2,
                                            ),
                                            Text(
                                              "Your shipper".tr(),
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.60)),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : Container(),
                          const SizedBox(
                            height: 10,
                          ),
                          buildPaymentDetails(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Container(),
    );
  }

  buildOtherDetails({
    required String title,
    required String value,
    Color color = Colors.black,
  }) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(
              height: 5,
            ),
            Text(value,
                textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  buildPaymentDetails() {
    /*if (orderModel!.taxModel != null) {
      for (var element in orderModel!.taxModel!) {
        taxAmount = (double.parse(taxAmount) + getTaxValue(amount: (double.parse(orderModel!.subTotal.toString()) -
            double.parse(orderModel!.discount.toString())).toString(), taxModel: element)).toString();
      }
    }*/
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Text(
            'Order Summary'.tr(),
            style: TextStyle(
              fontSize: 16,
              letterSpacing: 0.5,
              color:
                  isDarkMode(context) ? Colors.white : const Color(0XFF000000),
            ),
          ),
        ),
        const Divider(
          thickness: 1,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Subtotal".tr(),
              style: TextStyle(
                  color: isDarkMode(context)
                      ? const Color(0xffFFFFFF)
                      : const Color(0xff888888),
                  fontSize: 16),
            ),
            Text(
              amountShow(amount: orderModel!.subTotal!.toString()),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDarkMode(context) ? Colors.white : Colors.black,
              ),
            )
          ],
        ),
        const Divider(
          thickness: 1,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Discount".tr(),
              style: TextStyle(
                  color: isDarkMode(context)
                      ? const Color(0xffFFFFFF)
                      : const Color(0xff888888),
                  fontSize: 16),
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
        const Divider(
          thickness: 1,
        ),
        /* Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              ((orderModel!.taxLabel!.isNotEmpty) ? orderModel!.taxLabel.toString() : "Tax".tr()) + " ${(orderModel!.taxType == "fix") ? "" : "(${orderModel!.tax} %)"}",
              style: TextStyle(color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff888888), fontSize: 16),
            ),
            Text(
             // currencyData!.symbol+ taxCalculation(orderModel!).toStringAsFixed(2),
              amountShow(amount: taxCalculation(orderModel!).toString()),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDarkMode(context) ? Colors.white : Colors.black,
              ),
            )
          ],
        ),*/
        ListView.builder(
          itemCount: orderModel!.taxModel!.length,
          shrinkWrap: true,
        //  padding: EdgeInsets.zero,
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
                            color: isDarkMode(context)
                                ? const Color(0xffFFFFFF)
                                : const Color(0xff888888),
                            fontSize: 16),
                      ),
                    ),
                    Text(
                      amountShow(
                          amount: getTaxValue(
                              amount: (double.parse(
                                  orderModel!.subTotal.toString()) -
                                  double.parse(
                                      orderModel!.discount.toString()))
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
                const Divider(
                  thickness: 1,
                ),
              ],
            );
          },
        ),
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
              // "$symbol ${((double.parse(orderModel!.subTotal!.toString())) - double.parse(orderModel!.discount!.toString()) + taxCalculation(orderModel!)).toStringAsFixed(2)}",
              amountShow(
                  amount: ((double.parse(orderModel!.subTotal!.toString())) -
                          double.parse(orderModel!.discount!.toString()) +
                          double.parse(taxAmount.toString()))
                      .toString()),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(COLOR_PRIMARY),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }

  /*double taxCalculation(ParcelOrderModel orderModel) {
    double totalTax = 0.0;

    if (orderModel.taxType!.isNotEmpty) {
      if (orderModel.taxType == "percent") {
        totalTax = (double.parse(orderModel.subTotal.toString()) - double.parse(orderModel.discount.toString())) * double.parse(orderModel.tax.toString()) / 100;
      } else {
        totalTax = double.parse(orderModel.tax.toString());
      }
    }
    return totalTax;
  }*/

  buildUsersDetails(context,
      {bool isSender = true, required ParcelUserDetails? userDetails}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Text(
                  isSender ? "Sender".tr() + " " : "Receiver".tr() + " ",
                  style: TextStyle(fontSize: 18, color: Color(COLOR_PRIMARY)),
                ),
                Text(
                  userDetails!.name!,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          Text(
            userDetails.phone!,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            userDetails.address!,
            maxLines: 3,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  ///createLine
  buildLine() {
    return Column(
      children: [
        const SizedBox(
          height: 6,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
          ),
          child: Image.asset("assets/images/circle.png", height: 20),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 2),
          child: SizedBox(
            width: 1.3,
            child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: 18,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Container(
                      color: Colors.black38,
                      height: 2.5,
                    ),
                  );
                }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Image.asset("assets/images/parcel_Image.png", height: 20),
        ),
      ],
    );
  }
}
