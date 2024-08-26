import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/parcel_delivery/parcel_model/parcel_order_model.dart';
import 'package:emartconsumer/parcel_delivery/parcel_ui/parcel_order_track_screen.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FireStoreUtils _fireStoreUtils = FireStoreUtils();
  List<ParcelOrderModel> ordersList = [];

  @override
  void initState() {
    super.initState();
    getParcelOrderModel();
  }

  bool isLoading = true;

  getParcelOrderModel() async {
    await _fireStoreUtils.getParcelOrdes(MyAppState.currentUser!.userID).then((value) {
      setState(() {
        ordersList = value;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: ordersList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return buildHistory(ordersList[index]);
        },
      ),
    );
  }

  buildHistory(ParcelOrderModel orderModel) {
    return GestureDetector(
      onTap: () {
        push(context, ParcelOrderTrackScreen(orderModel: orderModel));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildLine(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildUsersDetails(context, isSender: true, userDetails: orderModel.sender),
                          const SizedBox(
                            height: 20,
                          ),
                          buildUsersDetails(context, isSender: false, userDetails: orderModel.receiver),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.black12,
                  thickness: 1,
                ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text("Parcel Type : ".tr(), style: TextStyle(color: Colors.grey)),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(orderModel.parcelType.toString(), style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  color: Colors.black12,
                  thickness: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildOtherDetails(
                      title: "Order Status".tr(),
                      value: orderModel.status == ORDER_STATUS_PLACED
                          ? "Order Placed".tr()
                          : orderModel.status == ORDER_STATUS_DRIVER_REJECTED || orderModel.status == ORDER_STATUS_DRIVER_PENDING
                              ? "Driver Pending".tr()
                              : orderModel.status == ORDER_STATUS_SHIPPED
                                  ? "Order Ready to Pickup".tr()
                                  : orderModel.status == ORDER_STATUS_IN_TRANSIT
                                      ? "In Transit".tr()
                                      : orderModel.status == ORDER_STATUS_REJECTED
                                          ? "Order Rejected".tr()
                                          : "Order Completed".tr(),
                    ),
                    buildOtherDetails(
                      title: "Order Date".tr(),
                      value: DateFormat('yyyy-MM-dd hh:mm a').format(orderModel.createdAt!.toDate()),
                    ),
                  ],
                ),
                Visibility(
                  visible: orderModel.isSchedule == true ? true : true,
                  child: Column(
                    children: [
                      const Divider(
                        color: Colors.black12,
                        thickness: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: buildOtherDetails(
                              title: "PickUp date".tr(),
                              value: DateFormat('yyyy-MM-dd hh:mm a').format(orderModel.senderPickupDateTime!.toDate()),
                            ),
                          ),
                          Expanded(
                            child: buildOtherDetails(
                              title: "Drop Date".tr(),
                              value: DateFormat('yyyy-MM-dd hh:mm a').format(orderModel.receiverPickupDateTime!.toDate()),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.black12,
                  thickness: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildOtherDetails(
                      title: "Distance".tr(),
                      value: orderModel.distance.toString() + " " + "km".tr(),
                    ),
                    buildOtherDetails(
                      title: "Weight".tr(),
                      value: orderModel.parcelWeight.toString(),
                    ),
                   // buildOtherDetails(title: "Rate".tr(), value: symbol + double.parse(orderModel.subTotal!).toStringAsFixed(decimal), color: Color(COLOR_PRIMARY)),
                    buildOtherDetails(title: "Rate".tr(), value: amountShow(amount: orderModel.subTotal!), color: Color(COLOR_PRIMARY)),

                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
            Text(value, textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  buildUsersDetails(context, {ParcelUserDetails? userDetails, bool isSender = false}) {
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
                  style: TextStyle(fontSize: 18, color: isSender ? Color(COLOR_PRIMARY) : const Color(0xffd17e19)),
                ),
                Text(
                  userDetails!.name.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          Text(
            userDetails.phone.toString(),
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
          Text(
            userDetails.address.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

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
                itemCount: 15,
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
