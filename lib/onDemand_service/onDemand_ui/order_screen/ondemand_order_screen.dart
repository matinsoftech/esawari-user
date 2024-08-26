import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/onDemand_service/onDemand_model/onprovider_order_model.dart';
import 'package:emartconsumer/onDemand_service/onDemand_model/worker_model.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/order_screen/ondemand_order_details_screen.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:flutter/material.dart';

class OnDemandOrderScreen extends StatelessWidget {
  const OnDemandOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? const Color(DARK_BG_COLOR) : const Color(0xffF9F9F9),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(PROVIDERORDER)
                .where("authorID", isEqualTo: MyAppState.currentUser!.userID)
                .where("sectionId", isEqualTo: sectionConstantModel!.id.toString())
                .orderBy("createdAt", descending: true)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Something went wrong'.tr()));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  child: Center(
                    child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                    ),
                  ),
                );
              }
              return snapshot.data!.docs.isEmpty
                  ? Center(
                      child: Text("No Booking found".tr()),
                    )
                  : ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        OnProviderOrderModel onProviderOrder = OnProviderOrderModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
                        return InkWell(
                          onTap: () {
                            push(context, OnDemandOrderDetailsScreen(orderId: onProviderOrder.id));
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              margin: const EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
                                color: isDarkMode(context) ? Color(DarkContainerColor) : Colors.white,
                              ),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Container(
                                        height: 80,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          image: onProviderOrder.provider.photos.isNotEmpty
                                              ? DecorationImage(
                                                  image: NetworkImage(onProviderOrder.provider.photos.first.toString()),
                                                  fit: BoxFit.cover,
                                                )
                                              : DecorationImage(
                                                  image: NetworkImage(placeholderImage),
                                                  fit: BoxFit.cover,
                                                ),
                                        )),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              onProviderOrder.status == ORDER_STATUS_PLACED
                                                  ? Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(5),
                                                        color: Color(colorLightDeepOrange),
                                                      ),
                                                      // padding: const EdgeInsets.all(4),
                                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                                      child: Text(
                                                        "Pending",
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontFamily: "Poppinsm",
                                                          fontSize: 14,
                                                          color: Color(colorDeepOrange),
                                                        ),
                                                      ),
                                                    )
                                                  : onProviderOrder.status == ORDER_STATUS_ACCEPTED || onProviderOrder.status == ORDER_STATUS_ASSIGNED
                                                      ? Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(5),
                                                            color: Colors.teal.shade50,
                                                          ),
                                                          // padding: const EdgeInsets.all(4),
                                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                                          child: Text(
                                                            "Accepted",
                                                            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Poppinsm", fontSize: 14, color: Colors.teal),
                                                          ),
                                                        )
                                                      : onProviderOrder.status == ORDER_STATUS_ONGOING
                                                          ? Container(
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(5),
                                                                color: Colors.lightGreen.shade100,
                                                              ),
                                                              // padding: const EdgeInsets.all(4),
                                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                                              child: Text(
                                                                "On Going",
                                                                style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Poppinsm", fontSize: 14, color: Colors.lightGreen),
                                                              ),
                                                            )
                                                          : onProviderOrder.status == ORDER_STATUS_COMPLETED
                                                              ? Container(
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(5),
                                                                    color: Colors.green.shade100,
                                                                  ),
                                                                  // padding: const EdgeInsets.all(4),
                                                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                                                  child: Text(
                                                                    "Completed",
                                                                    style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Poppinsm", fontSize: 14, color: Colors.green),
                                                                  ),
                                                                )
                                                              : onProviderOrder.status == ORDER_STATUS_REJECTED
                                                                  ? Container(
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(5),
                                                                        color: Colors.red.shade100,
                                                                      ),
                                                                      // padding: const EdgeInsets.all(4),
                                                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                                                      child: Text(
                                                                        "Rejected",
                                                                        style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Poppinsm", fontSize: 14, color: Colors.red),
                                                                      ),
                                                                    )
                                                                  : onProviderOrder.status == ORDER_STATUS_CANCELLED
                                                                      ? Container(
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(5),
                                                                            color: Colors.red.shade100,
                                                                          ),
                                                                          // padding: const EdgeInsets.all(4),
                                                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                                                          child: Text(
                                                                            "Cancelled",
                                                                            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Poppinsm", fontSize: 14, color: Colors.red),
                                                                          ),
                                                                        )
                                                                      : Container(),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 6),
                                            child: Text(
                                              onProviderOrder.provider.title.toString(),
                                              style: TextStyle(
                                                color: isDarkMode(context) ? Colors.white : Colors.black,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 6),
                                            child: onProviderOrder.provider.disPrice == "" || onProviderOrder.provider.disPrice == "0"
                                                ? Text(
                                                    onProviderOrder.provider.priceUnit == 'Fixed'
                                                        ? amountShow(
                                                            amount: onProviderOrder.provider.price.toString(),
                                                          )
                                                        : "${amountShow(
                                                            amount: onProviderOrder.provider.price.toString(),
                                                          )}/hr",
                                                    style: TextStyle(
                                                      color: Color(COLOR_PRIMARY),
                                                      fontFamily: "Poppinsm",
                                                    ),
                                                  )
                                                : Text(
                                                    onProviderOrder.provider.priceUnit == 'Fixed'
                                                        ? amountShow(
                                                            amount: onProviderOrder.provider.disPrice.toString(),
                                                          )
                                                        : "${amountShow(
                                                            amount: onProviderOrder.provider.disPrice.toString(),
                                                          )}/hr",
                                                    style: TextStyle(
                                                      color: Color(COLOR_PRIMARY),
                                                      fontFamily: "Poppinsm",
                                                    ),
                                                  ),
                                          ),
                                          SizedBox(height: 6),
                                          onProviderOrder.status != ORDER_STATUS_COMPLETED &&
                                                  onProviderOrder.status != ORDER_STATUS_CANCELLED &&
                                                  onProviderOrder.otp != null &&
                                                  onProviderOrder.otp!.isNotEmpty
                                              ? Text(
                                                  "OTP : " + onProviderOrder.otp.toString(),
                                                  style: TextStyle(
                                                    fontFamily: "Poppinsm",
                                                    fontSize: 14,
                                                    color: isDarkMode(context) ? Colors.white : Colors.black,
                                                  ),
                                                )
                                              : SizedBox()
                                        ],
                                      ),
                                    ),
                                  )
                                ]),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: isDarkMode(context) ? Colors.grey.shade900 : Colors.grey.shade100, width: 1),
                                    color: isDarkMode(context) ? Colors.grey.shade900 : Color(colorLightGrey),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Column(
                                      children: [
                                        Container(
                                            padding: const EdgeInsets.only(left: 10, right: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "Date & Time",
                                                  style: TextStyle(
                                                    color: Colors.grey.shade500,
                                                    fontFamily: "Poppinsm",
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  DateFormat('dd-MMM-yyyy hh:mm a').format(onProviderOrder.scheduleDateTime!.toDate()),
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
                                          child: Divider(
                                            thickness: 1,
                                          ),
                                        ),
                                        Container(
                                            padding: onProviderOrder.workerId == '' ? EdgeInsets.only(left: 10, right: 10) : EdgeInsets.only(left: 10, right: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "Provider",
                                                  style: TextStyle(
                                                    color: Colors.grey.shade500,
                                                    fontFamily: "Poppinsm",
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  onProviderOrder.provider.authorName.toString(),
                                                  style: TextStyle(
                                                    color: isDarkMode(context) ? Colors.white : Colors.black,
                                                    fontFamily: "Poppinsm",
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            )),
                                        onProviderOrder.provider.priceUnit == "Hourly"
                                            ? Column(
                                                children: [
                                                  onProviderOrder.startTime == null
                                                      ? SizedBox()
                                                      : Column(
                                                          children: [
                                                            const Padding(
                                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                                              child: Divider(
                                                                thickness: 1,
                                                              ),
                                                            ),
                                                            Container(
                                                                padding: EdgeInsets.only(left: 10, right: 10),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      "Start Time".tr(),
                                                                      style: TextStyle(
                                                                        fontSize: 14,
                                                                        color: Colors.grey.shade500,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      DateFormat('dd-MMM-yyyy hh:mm a').format(onProviderOrder.startTime!.toDate()),
                                                                      style: TextStyle(
                                                                        fontSize: 14,
                                                                        color: isDarkMode(context) ? Colors.white : Colors.black,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )),
                                                          ],
                                                        ),
                                                  onProviderOrder.endTime == null
                                                      ? SizedBox()
                                                      : Column(
                                                          children: [
                                                            const Padding(
                                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                                              child: Divider(
                                                                thickness: 1,
                                                              ),
                                                            ),
                                                            Container(
                                                                padding: EdgeInsets.only(left: 10, right: 10),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      "End Time".tr(),
                                                                      style: TextStyle(
                                                                        fontSize: 14,
                                                                        color: Colors.grey.shade500,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      onProviderOrder.endTime == null
                                                                          ? "0"
                                                                          : DateFormat('dd-MMM-yyyy hh:mm a').format(onProviderOrder.endTime!.toDate()),
                                                                      style: TextStyle(
                                                                        fontSize: 14,
                                                                        color: isDarkMode(context) ? Colors.white : Colors.black,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )),
                                                          ],
                                                        ),
                                                ],
                                              )
                                            : SizedBox(),
                                        onProviderOrder.workerId != ''
                                            ? FutureBuilder(
                                                future: FireStoreUtils.getWorker(onProviderOrder.workerId.toString()),
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                    return Center(child: Container());
                                                  } else {
                                                    if (snapshot.hasError) {
                                                      return Center(child: Text('Error: '.tr() + '${snapshot.error}'));
                                                    } else if (snapshot.hasData) {
                                                      WorkerModel model = snapshot.data!;
                                                      return Column(
                                                        children: [
                                                          const Padding(
                                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                                            child: Divider(
                                                              thickness: 1,
                                                            ),
                                                          ),
                                                          Container(
                                                              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    "Worker",
                                                                    style: TextStyle(
                                                                      color: Colors.grey.shade500,
                                                                      fontFamily: "Poppinsm",
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    model.fullName().toString(),
                                                                    style: TextStyle(
                                                                      color: isDarkMode(context) ? Colors.white : Colors.black,
                                                                      fontFamily: "Poppinsm",
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                ],
                                                              )),
                                                        ],
                                                      );
                                                    } else {
                                                      return Container();
                                                    }
                                                  }
                                                })
                                            : SizedBox(),
                                      ],
                                    ),
                                  ),
                                )
                              ])),
                        );
                      });
            }),
      ),
    );
  }
}
