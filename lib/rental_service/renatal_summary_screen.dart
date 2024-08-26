import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/TaxModel.dart';
import 'package:emartconsumer/rental_service/rental_booking_screen.dart';
import 'package:emartconsumer/rental_service/rental_service_dash_board.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:flutter/material.dart';

import 'model/rental_order_model.dart';

class RenatalSummaryScreen extends StatefulWidget {
  final RentalOrderModel? rentalOrderModel;
  final String? orderId;

  RenatalSummaryScreen({Key? key, this.rentalOrderModel, this.orderId}) : super(key: key);

  @override
  State<RenatalSummaryScreen> createState() => _RenatalSummaryScreenState();
}

class _RenatalSummaryScreenState extends State<RenatalSummaryScreen> {
  RentalOrderModel? orderModel;

  @override
  void initState() {
    // TODO: implement initState
    loadData();

    super.initState();
  }

  loadData() async {
    if (widget.rentalOrderModel != null) {
      orderModel = widget.rentalOrderModel;
      setState(() {});
    } else {
      await FireStoreUtils().getRentalOrderById(widget.orderId).then((value) {
        orderModel = value;
        setState(() {});
      });
    }
    // setState(() {
    //calculateAmount();
    // });
  }

  calculateAmount() {
    // taxType = orderModel!.taxType.toString();
    // taxLable = orderModel!.taxLabel.toString();
    // taxAmount = double.parse(orderModel!.tax.toString());
    subTotal = double.parse(orderModel!.subTotal.toString());
    driverRate = double.parse(orderModel!.driverRate.toString());
    discountAmount = double.parse(orderModel!.discount.toString());
  }

  double getTotalAmount() {
    double taxAmount = 0.0;
    subTotal = double.parse(orderModel!.subTotal.toString());
    driverRate = double.parse(orderModel!.driverRate.toString());
    discountAmount = double.parse(orderModel!.discount.toString());
    if (orderModel!.taxModel != null) {
      for (var element in orderModel!.taxModel!) {
        taxAmount = taxAmount + getTaxValue(amount: ((subTotal + driverRate) - discountAmount).toString(), taxModel: element);
      }
    }
    setState(() {});
    return (subTotal + driverRate) - discountAmount + taxAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Booking Details",
        ).tr(),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            push(
                context,
                RentalServiceDashBoard(
                    user: MyAppState.currentUser, drawerSelection: DrawerSelection.Orders, appBarTitle: 'Booking'.tr(), currentWidget: const RentalBookingScreen()));
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Color(COLOR_PRIMARY),
          ),
        ),
      ),
      body: buildRides(),
    );
  }

  buildRides() {
    return orderModel != null
        ? SingleChildScrollView(
            child: GestureDetector(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(COLOR_PRIMARY),
                    borderRadius:
                        const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CachedNetworkImage(
                                  height: 50,
                                  width: 50,
                                  imageUrl: orderModel!.driver!.carInfo!.carImage!.isEmpty ? "" : orderModel!.driver!.carInfo!.carImage!.first,
                                  imageBuilder: (context, imageProvider) => Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                    ),
                                  ),
                                  placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator.adaptive(
                                    valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                                  )),
                                  errorWidget: (context, url, error) => ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        placeholderImage,
                                        fit: BoxFit.cover,
                                      )),
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        orderModel!.driver!.carName + " " + orderModel!.driver!.carMakes,
                                        style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Visibility(
                                        visible: orderModel!.bookWithDriver == true ? true : false,
                                        child: const Text(
                                          "With driver trip",
                                          style: TextStyle(fontSize: 14, color: Colors.white),
                                        ).tr(),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        amountShow(amount: orderModel!.subTotal.toString()),
                                        style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w800),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  children: [
                                    buildUsersDetails(context,
                                        address: orderModel!.pickupAddress.toString(), time: DateFormat('yyyy-MM-dd hh:mm a').format(orderModel!.pickupDateTime!.toDate())),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    buildUsersDetails(context,
                                        isSender: false,
                                        address: orderModel!.dropAddress.toString(),
                                        time: DateFormat('yyyy-MM-dd hh:mm a').format(orderModel!.dropDateTime!.toDate())),
                                  ],
                                ),
                              ),
                              orderModel!.driver != null ? buildRequestSection() : Container(),
                              const SizedBox(
                                height: 5,
                              ),
                              Visibility(
                                visible: orderModel!.companyID!.isNotEmpty,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                                  child: Row(
                                    children: [
                                      ClipOval(
                                        child: CachedNetworkImage(
                                          width: 46,
                                          height: 46,
                                          imageUrl: orderModel!.company!.profilePictureURL,
                                          placeholder: (context, url) => Image.asset('assets/images/img_placeholder.png'),
                                          errorWidget: (context, url, error) => Image.network(placeholderImage, fit: BoxFit.cover),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(orderModel!.company!.firstName,
                                                  style: const TextStyle(fontSize: 16, color: Colors.black, letterSpacing: 1, fontWeight: FontWeight.w600)),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.location_on,
                                                    color: Colors.grey,
                                                    size: 18,
                                                  ),
                                                  Text(orderModel!.company!.companyAddress,
                                                      style: const TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: 1, fontWeight: FontWeight.w600)),
                                                ],
                                              )
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Divider(
                                color: Color(0xffE2E8F0),
                                height: 0.1,
                              ),
                              buildTotalRow(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Container();
  }

  double subTotal = 0.0;
  double driverRate = 0.0;
  String tabString = "About";
  bool? taxActive = false;
  bool? isEnableCommission = false;
  double taxAmount = 0.0;
  String taxLable = "";
  String taxType = "";
  String commissionAmount = "";
  String commissionType = "";

  double discountAmount = 0.0;
  String discountType = "";
  String discountLable = "";

  /*double getTaxAmount() {
    double totalTax = 0.0;
    if (taxType.isNotEmpty) {
      if (taxType == "percent") {
        totalTax = ((subTotal + driverRate) - discountAmount) * taxAmount / 100;
      } else {
        totalTax = taxAmount;
      }
    }

    return totalTax;
  }*/

  Widget buildTotalRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 8,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Text("Booking summary".tr(), style: const TextStyle(fontSize: 16, color: Colors.black, letterSpacing: 1, fontWeight: FontWeight.w600)),
        ),
        const Divider(
          thickness: 1,
        ),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Subtotal".tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Text(
                  amountShow(amount: orderModel!.subTotal.toString()),
                  style: TextStyle(color: const Color(0xff333333), fontSize: 16),
                ),
              ],
            )),
        const Divider(
          thickness: 1,
        ),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Driver Amount".tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Text(
                  amountShow(amount: orderModel!.driverRate.toString()),
                  style: TextStyle(color: const Color(0xff333333), fontSize: 16),
                ),
              ],
            )),
        const Divider(
          thickness: 1,
        ),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Discount".tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "(-" + amountShow(amount: orderModel!.discount.toString()) + ")",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ],
            )),
        const Divider(
          thickness: 1,
        ),
        /*Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ((taxLable.isNotEmpty) ? taxLable.toString() : "Tax".tr()) + " ${(taxType == "fix") ? "" : "($taxAmount %)"}",
                  style: TextStyle(color: Colors.black.withOpacity(0.50)),
                ),
                Text(
                  amountShow(amount: getTaxAmount().toString()),
                  style: TextStyle(color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff333333), fontSize: 16),
                ),
              ],
            )),*/

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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${taxModel.title.toString()} (${taxModel.type == "fix" ? amountShow(amount: taxModel.tax) : "${taxModel.tax}%"})",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Text(
                              amountShow(amount: getTaxValue(amount: ((subTotal + driverRate) - discountAmount).toString(), taxModel: taxModel).toString()),
                              style: TextStyle(color: const Color(0xff333333), fontSize: 16),
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
              )
            : Container(),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total".tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Text(
                  amountShow(amount: getTotalAmount().toString()),
                  style: TextStyle(color: Color(COLOR_PRIMARY), fontSize: 16),
                ),
              ],
            )),
      ],
    );
  }

  buildRequestSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 8,
          ),
          ClipOval(
            child: CachedNetworkImage(
              width: 46,
              height: 46,
              imageUrl: orderModel!.driver!.profilePictureURL,
              placeholder: (context, url) => Image.asset('assets/images/img_placeholder.png'),
              errorWidget: (context, url, error) => Image.network(placeholderImage, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Driver by",
                  style: TextStyle(color: Colors.black38),
                ).tr(),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  orderModel!.driver!.firstName + " " + orderModel!.driver!.lastName,
                  style: const TextStyle(fontSize: 17, color: Colors.black),
                ),
              ],
            ),
          ),
          Text(
            orderModel!.status == ORDER_STATUS_COMPLETED
                ? "Completed".tr()
                : orderModel!.status == ORDER_STATUS_IN_TRANSIT
                    ? "On Ride".tr()
                    : orderModel!.status == ORDER_STATUS_REJECTED
                        ? "Canceled".tr()
                        : "Pending".tr(),
            style: TextStyle(
                color: orderModel!.status == ORDER_STATUS_COMPLETED
                    ? Colors.green
                    : orderModel!.status == ORDER_STATUS_IN_TRANSIT
                        ? Colors.amber
                        : Colors.red,
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  buildUsersDetails(
    context, {
    bool isSender = true,
    required String time,
    required String address,
  }) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.0), border: Border.all(color: Colors.grey.withOpacity(0.30), width: 2.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSender ? "PickUp".tr() + " " : "Drop off".tr() + " ",
              style: const TextStyle(fontSize: 18, color: Colors.black),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.only(
                      right: 8.0,
                    ),
                    child: Icon(
                      Icons.access_time_outlined,
                      size: 20,
                      color: Color(COLOR_PRIMARY),
                    )),
                Expanded(
                  child: Text(
                    time,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Padding(
                    padding: const EdgeInsets.only(
                      right: 8.0,
                    ),
                    child: Icon(
                      Icons.location_on,
                      size: 20,
                      color: Color(COLOR_PRIMARY),
                    )),
                Expanded(
                  child: Text(
                    address,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
