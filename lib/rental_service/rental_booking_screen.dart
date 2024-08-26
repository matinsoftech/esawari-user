import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/topupTranHistory.dart';
import 'package:emartconsumer/rental_service/model/rental_order_model.dart';
import 'package:emartconsumer/rental_service/renatal_summary_screen.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'rental_review_screen.dart';

class RentalBookingScreen extends StatefulWidget {
  const RentalBookingScreen({Key? key}) : super(key: key);

  @override
  State<RentalBookingScreen> createState() => _RentalBookingScreenState();
}

class _RentalBookingScreenState extends State<RentalBookingScreen> {
  final FireStoreUtils _fireStoreUtils = FireStoreUtils();
  List<RentalOrderModel> ordersList = [];

  @override
  void initState() {
    // TODO: implement initState
    getBookedData("");
    super.initState();
  }

  bool isLoading = true;

  getBookedData(String status) async {
    await _fireStoreUtils.getRentalBook(MyAppState.currentUser!.userID, status).then((value) {
      setState(() {
        ordersList = value;
        isLoading = false;
        print("--->");
      });
    });
  }

  int selectedIndex = 0;
  bool isCompleted = false;

  List<String> ridesCategory = ["All", "Completed", "Ongoing", "Canceled"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          getBookedData("");
        },
        child: Column(
          children: [
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                physics: const BouncingScrollPhysics(),
                itemCount: ridesCategory.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return buildRideType(label: ridesCategory[index], index: index);
                },
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ordersList.isEmpty
                      ? Center(
                          child: Text(
                          "Booking not found".tr(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ))
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: ordersList.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return buildRides(ordersList[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  buildRideType({required String label, required index}) {
    Color textColor = selectedIndex == index ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: ChoiceChip(
        onSelected: (value) {
          if (label == "All") {
            setState(() {
              isLoading = true;
            });
            getBookedData("");
          } else if (label == "Completed") {
            setState(() {
              isLoading = true;
            });
            getBookedData(ORDER_STATUS_COMPLETED);
          } else if (label == "Ongoing") {
            setState(() {
              isLoading = true;
            });
            getBookedData(ORDER_STATUS_IN_TRANSIT);
          } else if (label == "Canceled") {
            setState(() {
              isLoading = true;
            });
            getBookedData(ORDER_STATUS_REJECTED);
          }
          setState(() {
            selectedIndex = value ? index : selectedIndex;
          });
        },
        backgroundColor: Colors.grey.shade200,
        selected: selectedIndex == index,
        selectedColor: Color(COLOR_PRIMARY),
        clipBehavior: Clip.antiAlias,
        labelStyle: TextStyle(fontSize: 16, color: textColor),
        label: Text(
          label,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
      ),
    );
  }

  buildRides(RentalOrderModel orderModel) {
    return GestureDetector(
      onTap: () {
        push(context, RenatalSummaryScreen(rentalOrderModel: orderModel));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Color(COLOR_PRIMARY),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CachedNetworkImage(
                          height: 50,
                          width: 50,
                          imageUrl: orderModel.driver!.carInfo!.carImage!.isEmpty ? "" : orderModel.driver!.carInfo!.carImage!.first,
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
                                orderModel.driver!.carName + " " + orderModel.driver!.carMakes,
                                style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Visibility(
                                visible: orderModel.bookWithDriver == true ? true : false,
                                child: const Text(
                                  "With driver trip",
                                  style: TextStyle(fontSize: 14, color: Colors.white),
                                ).tr(),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                amountShow(amount: orderModel.subTotal.toString()),
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
                decoration: BoxDecoration(
                  color: isDarkMode(context) ? const Color(DarkContainerColor) : Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
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
                                address: orderModel.pickupAddress.toString(), time: DateFormat('yyyy-MM-dd hh:mm a').format(orderModel.pickupDateTime!.toDate())),
                            const SizedBox(
                              height: 10,
                            ),
                            buildUsersDetails(context,
                                isSender: false, address: orderModel.dropAddress.toString(), time: DateFormat('yyyy-MM-dd hh:mm a').format(orderModel.dropDateTime!.toDate())),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Visibility(
                            visible: orderModel.status == ORDER_STATUS_COMPLETED,
                            child: Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                    onPressed: () async {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(COLOR_PRIMARY),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'Completed',
                                      style: TextStyle(fontSize: 16),
                                    ).tr(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: orderModel.status == ORDER_STATUS_COMPLETED ? true : false,
                            child: Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      push(context, RentalReviewScreen(order: orderModel));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'Add Review',
                                      style: TextStyle(fontSize: 16),
                                    ).tr(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: orderModel.status != ORDER_STATUS_COMPLETED && orderModel.status != ORDER_STATUS_REJECTED ? true : false,
                            child: Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.withOpacity(0.80),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    orderModel.status = ORDER_STATUS_REJECTED;
                                  });

                                  await FireStoreUtils.updateRentalOrder(orderModel).then((value) async {
                                    getBookedData("");

                                    if (orderModel.paymentMethod.toLowerCase() != "cod") {
                                      double totalTax = 0.0;
                                      if (taxList != null) {
                                        for (var element in taxList!) {
                                          totalTax = totalTax +
                                              getTaxValue(
                                                  amount: (double.parse(orderModel.subTotal.toString()) - double.parse(orderModel.discount.toString())).toString(),
                                                  taxModel: element);
                                        }
                                      }

                                      double subTotal = double.parse(orderModel.subTotal.toString()) - double.parse(orderModel.discount.toString());

                                      double driverAmount = 0;

                                      if (orderModel.paymentMethod.toLowerCase() != "cod") {
                                        driverAmount = subTotal + totalTax;
                                      }

                                      TopupTranHistoryModel wallet = TopupTranHistoryModel(
                                          amount: driverAmount,
                                          order_id: '',
                                          serviceType: 'rental-service',
                                          id: Uuid().v4(),
                                          user_id: MyAppState.currentUser!.userID,
                                          date: Timestamp.now(),
                                          isTopup: false,
                                          payment_method: "wallet",
                                          payment_status: "success",
                                          transactionUser: "customer",
                                          note: 'Booking Amount Payment');

                                      await FireStoreUtils.firestore.collection("wallet").doc(wallet.id).set(wallet.toJson()).then((value) async {
                                        await FireStoreUtils.updateWalletAmount(amount: driverAmount).then((value) {});
                                      });
                                    }
                                  });
                                },
                                child: Text(
                                  'Cancel Ride'.tr(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
              style: const TextStyle(fontSize: 18),
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
