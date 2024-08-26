import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/TaxModel.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/model/offer_model.dart';
import 'package:emartconsumer/model/topupTranHistory.dart';
import 'package:emartconsumer/onDemand_service/onDemand_model/onprovider_order_model.dart';
import 'package:emartconsumer/onDemand_service/onDemand_model/worker_model.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/ondemand_payment_screen/ondemand_payment_screen.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/review_screen/ondemand_review_screen.dart';
import 'package:emartconsumer/send_notification.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/services/show_toast_dialog.dart';
import 'package:emartconsumer/ui/chat_screen/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class OnDemandOrderDetailsScreen extends StatefulWidget {
  final String? orderId;

  OnDemandOrderDetailsScreen({Key? key, this.orderId}) : super(key: key);

  @override
  _OnDemandOrderDetailsScreenState createState() => _OnDemandOrderDetailsScreenState();
}

class _OnDemandOrderDetailsScreenState extends State<OnDemandOrderDetailsScreen> {
  OnProviderOrderModel? onProviderOrder;
  double subTotal = 0.0;
  double price = 0.0;
  double discountAmount = 0.0;
  double totalAmount = 0.0;

  @override
  void initState() {
    getData();
    setState(() {});

    super.initState();
  }

  getData() async {
    await FireStoreUtils().getProviderOrderById(widget.orderId).then((value) {
      onProviderOrder = value;
      discountType = onProviderOrder!.discountType.toString();
      discountLable = onProviderOrder!.discountLabel.toString();
      discountAmount = double.parse(onProviderOrder!.discount.toString());
      offerCode = onProviderOrder!.couponCode.toString();
      setState(() {});
    });
    await getDetails();
  }

  List<OfferModel> couponList = [];
  late Future<List<OfferModel>> coupon;

  getDetails() {
    coupon = FireStoreUtils().getProviderCouponAfterExpire(onProviderOrder!.provider.author.toString());
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
        backgroundColor: isDarkMode(context) ? Colors.black : Colors.white,
        title: onProviderOrder != null
            ? Text(
                onProviderOrder!.status == ORDER_STATUS_PLACED
                    ? 'Pending'
                    : onProviderOrder!.status == ORDER_STATUS_ACCEPTED || onProviderOrder!.status == ORDER_STATUS_ASSIGNED
                        ? 'Accepted'
                        : onProviderOrder!.status == ORDER_STATUS_ONGOING
                            ? 'On Going'
                            : onProviderOrder!.status == ORDER_STATUS_COMPLETED
                                ? 'Completed'
                                : onProviderOrder!.status == ORDER_STATUS_REJECTED
                                    ? 'Rejected'
                                    : 'Cancelled',
                style: TextStyle(
                  color: isDarkMode(context) ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontFamily: "Poppinsm",
                  fontWeight: FontWeight.w500,
                ),
              )
            : Container(),
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
            )),
      ),
      body: onProviderOrder != null
          ? StreamBuilder(
              stream: FirebaseFirestore.instance.collection(PROVIDER_ORDER).doc(onProviderOrder!.id).snapshots(),
              builder: (context, snapshot) {
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
                OnProviderOrderModel onProviderOrder = OnProviderOrderModel.fromJson(snapshot.data!.data()!);

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      onProviderOrder.status == ORDER_STATUS_CANCELLED
                          ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
                                  color: isDarkMode(context) ? Color(DarkContainerColor) : Colors.white,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cancel Reason',
                                        style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
                                      ),
                                      Text(
                                        onProviderOrder.reason.toString(),
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
                                color: isDarkMode(context) ? Color(DarkContainerColor) : Colors.white,
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text(
                                    'Booking ID',
                                    style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      FlutterClipboard.copy(onProviderOrder.id).then((value) {
                                        SnackBar snackBar = SnackBar(
                                          content: Text(
                                            "Booking ID Copied".tr(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: Colors.black38,
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                      });
                                    },
                                    child: Text(
                                      '# ${onProviderOrder.id}',
                                      style: TextStyle(color: Color(COLOR_PRIMARY)),
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
                                color: isDarkMode(context) ? Color(DarkContainerColor) : Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
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
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: 6),
                                          child: Text(
                                            onProviderOrder.provider.title.toString(),
                                            style: TextStyle(
                                                color: isDarkMode(context) ? Colors.white : Colors.black, fontSize: 16, fontFamily: "Poppinsm", fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(top: 6),
                                              child: Text(
                                                'Date: ',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isDarkMode(context) ? Colors.white : Colors.black,
                                                  fontFamily: "Poppinsm",
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: 6),
                                              child: Text(
                                                DateFormat('dd-MMM-yyyy').format(onProviderOrder.scheduleDateTime!.toDate()),
                                                style: TextStyle(
                                                    fontSize: 14, fontFamily: "Poppinsm", fontWeight: FontWeight.normal, color: isDarkMode(context) ? Colors.white : Colors.black),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(top: 6),
                                              child: Text(
                                                'Time: ',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isDarkMode(context) ? Colors.white : Colors.black,
                                                  fontFamily: "Poppinsm",
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: 6),
                                              child: Text(
                                                DateFormat('hh:mm a').format(onProviderOrder.scheduleDateTime!.toDate()),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isDarkMode(context) ? Colors.white : Colors.black,
                                                  fontFamily: "Poppinsm",
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            (onProviderOrder.status == ORDER_STATUS_ACCEPTED ||
                                        onProviderOrder.status == ORDER_STATUS_ASSIGNED ||
                                        onProviderOrder.status == ORDER_STATUS_ONGOING ||
                                        onProviderOrder.status == ORDER_STATUS_COMPLETED) &&
                                    (onProviderOrder.workerId != null && onProviderOrder.workerId!.isNotEmpty)
                                ? Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: 16),
                                          child: Text(
                                            'About Worker',
                                            style: TextStyle(
                                              color: isDarkMode(context) ? Colors.white : Colors.black,
                                              fontFamily: "Poppinsm",
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        FutureBuilder(
                                            future: FireStoreUtils.getWorker(onProviderOrder.workerId.toString()),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return Center(child: Container());
                                              } else {
                                                if (snapshot.hasError) {
                                                  return Center(child: Text('Error: '.tr() + '${snapshot.error}'));
                                                } else if (snapshot.hasData) {
                                                  WorkerModel model = snapshot.data!;
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10),
                                                          border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
                                                          color: isDarkMode(context) ? Color(DarkContainerColor) : Colors.white,
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Column(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  model.profilePictureURL != ""
                                                                      ? CircleAvatar(backgroundImage: NetworkImage(model.profilePictureURL.toString()), radius: 30.0)
                                                                      : CircleAvatar(backgroundImage: NetworkImage(placeholderImage), radius: 30.0),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Expanded(
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              model.fullName().toString(),
                                                                              style: TextStyle(
                                                                                  color: isDarkMode(context) ? Colors.white : Colors.black,
                                                                                  fontFamily: "Poppinsm",
                                                                                  fontSize: 14,
                                                                                  fontWeight: FontWeight.bold),
                                                                            ),
                                                                            Container(
                                                                              decoration: BoxDecoration(
                                                                                  color: Color(SemanticColorWarning06), borderRadius: BorderRadius.all(Radius.circular(16))),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                                child: Row(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    const Icon(
                                                                                      Icons.star,
                                                                                      size: 16,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                    const SizedBox(width: 3),
                                                                                    Text(
                                                                                      model.reviewsCount != 0
                                                                                          ? ((model.reviewsSum ?? 0.0) / (model.reviewsCount ?? 0.0)).toStringAsFixed(1)
                                                                                          : 0.toString(),
                                                                                      style: const TextStyle(
                                                                                        letterSpacing: 0.5,
                                                                                        fontSize: 12,
                                                                                        fontFamily: "Poppinsm",
                                                                                        fontWeight: FontWeight.w500,
                                                                                        color: Colors.white,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsets.symmetric(vertical: 5),
                                                                          child: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              Icon(Icons.location_on_outlined, size: 15, color: isDarkMode(context) ? Colors.white : Colors.black),
                                                                              SizedBox(
                                                                                width: 5,
                                                                              ),
                                                                              Container(
                                                                                width: MediaQuery.of(context).size.width * 0.6,
                                                                                child: Text(model.address!.toString(),
                                                                                    maxLines: 5,
                                                                                    style: TextStyle(
                                                                                      color: isDarkMode(context) ? Colors.white : Colors.black,
                                                                                      fontFamily: "Poppinsm",
                                                                                      fontWeight: FontWeight.normal,
                                                                                    )),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Visibility(
                                                                visible: onProviderOrder.status == ORDER_STATUS_COMPLETED ? true : false,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                  child: SizedBox(
                                                                    width: MediaQuery.of(context).size.width,
                                                                    child: ElevatedButton(
                                                                      onPressed: () async {
                                                                        push(
                                                                            context,
                                                                            OnDemandReviewScreen(
                                                                              order: onProviderOrder,
                                                                              reviewFor: "Worker",
                                                                            ));
                                                                      },
                                                                      style: ElevatedButton.styleFrom(
                                                                        backgroundColor: Colors.orange,
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(26),
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
                                                              onProviderOrder.status == ORDER_STATUS_ACCEPTED ||
                                                                      onProviderOrder.status == ORDER_STATUS_ONGOING ||
                                                                      onProviderOrder.status == ORDER_STATUS_ASSIGNED
                                                                  ? Padding(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                                                      child: Column(
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Expanded(
                                                                                child: ElevatedButton(
                                                                                  onPressed: () async {
                                                                                    makePhoneCall(model.phoneNumber.toString());
                                                                                  },
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: Colors.orange,
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(16),
                                                                                    ),
                                                                                  ),
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    children: [
                                                                                      Icon(
                                                                                        Icons.call,
                                                                                        color: Colors.white,
                                                                                      ),
                                                                                      SizedBox(
                                                                                        width: 10,
                                                                                      ),
                                                                                      const Text(
                                                                                        'Call',
                                                                                        style: TextStyle(fontSize: 16),
                                                                                      ).tr(),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(
                                                                                width: 10,
                                                                              ),
                                                                              Expanded(
                                                                                child: ElevatedButton(
                                                                                  onPressed: () async {
                                                                                    await showProgress(context, "Please wait".tr(), false);

                                                                                    User? customer = await FireStoreUtils.getCurrentUser(onProviderOrder.authorID);
                                                                                    WorkerModel? worker = await FireStoreUtils.getWorker(model.id.toString());
                                                                                    await hideProgress();

                                                                                    push(
                                                                                        context,
                                                                                        ChatScreens(
                                                                                          type: "provider_chat",
                                                                                          customerName: customer!.firstName + " " + customer.lastName,
                                                                                          restaurantName: worker!.fullName(),
                                                                                          orderId: onProviderOrder.id,
                                                                                          restaurantId: worker.id,
                                                                                          customerId: customer.userID,
                                                                                          customerProfileImage: customer.profilePictureURL,
                                                                                          restaurantProfileImage: worker.profilePictureURL,
                                                                                          token: worker.fcmToken,
                                                                                          chatType: 'Worker',
                                                                                        ));
                                                                                  },
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: Color(COLOR_PRIMARY),
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(16),
                                                                                    ),
                                                                                  ),
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    children: [
                                                                                      Icon(
                                                                                        Icons.chat_bubble,
                                                                                        color: Colors.white,
                                                                                      ),
                                                                                      SizedBox(
                                                                                        width: 10,
                                                                                      ),
                                                                                      const Text(
                                                                                        'Chat',
                                                                                        style: TextStyle(fontSize: 16),
                                                                                      ).tr(),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          const SizedBox(
                                                                            height: 10,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : SizedBox(),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  return Container();
                                                }
                                              }
                                            }),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'About Provider',
                                style: TextStyle(
                                  color: isDarkMode(context) ? Colors.white : Colors.black,
                                  fontFamily: "Poppinsm",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            FutureBuilder<User?>(
                              future: FireStoreUtils.getCurrentUser(onProviderOrder.provider.author.toString()),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: Container());
                                } else {
                                  if (snapshot.hasError) {
                                    return Center(child: Text('Error: '.tr() + '${snapshot.error}'));
                                  } else if (snapshot.hasData) {
                                    User userModel = snapshot.data!;
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
                                        color: isDarkMode(context) ? Color(DarkContainerColor) : Colors.white,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                userModel.profilePictureURL != ""
                                                    ? CircleAvatar(backgroundImage: NetworkImage(userModel.profilePictureURL.toString()), radius: 30.0)
                                                    : CircleAvatar(backgroundImage: NetworkImage(placeholderImage), radius: 30.0),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            userModel.fullName().toString(),
                                                            style: TextStyle(
                                                                color: isDarkMode(context) ? Colors.white : Colors.black,
                                                                fontFamily: "Poppinsm",
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold),
                                                          ),
                                                          Container(
                                                            decoration: BoxDecoration(color: Color(SemanticColorWarning06), borderRadius: BorderRadius.all(Radius.circular(16))),
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                              child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  const Icon(
                                                                    Icons.star,
                                                                    size: 16,
                                                                    color: Colors.white,
                                                                  ),
                                                                  const SizedBox(width: 3),
                                                                  Text(
                                                                    userModel.reviewsCount != 0
                                                                        ? ((userModel.reviewsSum) / (userModel.reviewsCount ?? 0.0)).toStringAsFixed(1)
                                                                        : 0.toString(),
                                                                    style: const TextStyle(
                                                                      letterSpacing: 0.5,
                                                                      fontSize: 12,
                                                                      fontFamily: "Poppinsm",
                                                                      fontWeight: FontWeight.w500,
                                                                      color: Colors.white,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        userModel.email.toString(),
                                                        style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontFamily: "Poppinsm", fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Visibility(
                                              visible: onProviderOrder.status == ORDER_STATUS_COMPLETED ? true : false,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                child: SizedBox(
                                                  width: MediaQuery.of(context).size.width,
                                                  child: ElevatedButton(
                                                    onPressed: () async {
                                                      push(
                                                          context,
                                                          OnDemandReviewScreen(
                                                            order: onProviderOrder,
                                                            reviewFor: "Provider",
                                                          ));
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.orange,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(16),
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
                                            onProviderOrder.status == ORDER_STATUS_ACCEPTED ||
                                                    onProviderOrder.status == ORDER_STATUS_ONGOING ||
                                                    onProviderOrder.status == ORDER_STATUS_ASSIGNED
                                                ? Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: ElevatedButton(
                                                                onPressed: () async {
                                                                  makePhoneCall(userModel.phoneNumber.toString());
                                                                },
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor: Colors.orange,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(16),
                                                                  ),
                                                                ),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  children: [
                                                                    Icon(
                                                                      Icons.call,
                                                                      color: Colors.white,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    const Text(
                                                                      'Call',
                                                                      style: TextStyle(fontSize: 16),
                                                                    ).tr(),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Expanded(
                                                              child: ElevatedButton(
                                                                onPressed: () async {
                                                                  await showProgress(context, "Please wait".tr(), false);

                                                                  User? customer = await FireStoreUtils.getCurrentUser(onProviderOrder.authorID);

                                                                  await hideProgress();

                                                                  push(
                                                                      context,
                                                                      ChatScreens(
                                                                        type: "provider_chat",
                                                                        customerName: customer!.firstName + " " + customer.lastName,
                                                                        restaurantName: userModel.fullName(),
                                                                        orderId: onProviderOrder.id,
                                                                        restaurantId: userModel.userID,
                                                                        customerId: customer.userID,
                                                                        customerProfileImage: customer.profilePictureURL,
                                                                        restaurantProfileImage: userModel.profilePictureURL,
                                                                        token: userModel.fcmToken,
                                                                        chatType: 'Provider',
                                                                      ));
                                                                },
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor: Color(COLOR_PRIMARY),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(16),
                                                                  ),
                                                                ),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  children: [
                                                                    Icon(
                                                                      Icons.chat_bubble,
                                                                      color: Colors.white,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    const Text(
                                                                      'Chat',
                                                                      style: TextStyle(fontSize: 16),
                                                                    ).tr(),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : SizedBox(),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                }
                              },
                            ),
                            (onProviderOrder.status != ORDER_STATUS_COMPLETED || onProviderOrder.status != ORDER_STATUS_CANCELLED) && onProviderOrder.provider.priceUnit == "Fixed"
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // couponList.isNotEmpty ? buildListPromoCode() : Container(),
                                      // buildPromoCode(),
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
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      onProviderOrder.paymentStatus == false || onProviderOrder.extraPaymentStatus == false
                                          ? Column(
                                              children: [
                                                couponList.isNotEmpty ? buildListPromoCode() : Container(),
                                                buildPromoCode(),
                                              ],
                                            )
                                          : Offstage(),
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        child: Text(
                                          "Price Detail",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDarkMode(context) ? Colors.white : Colors.black,
                                            fontFamily: "Poppinsm",
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      priceTotalRow(),
                                    ],
                                  ),
                            onProviderOrder.extraCharges.toString() != ""
                                ? Container(
                                    margin: EdgeInsets.symmetric(vertical: 10),
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
                                    child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "Total Extra Charges : ",
                                                  style: TextStyle(
                                                    color: isDarkMode(context) ? Colors.white : Colors.black,
                                                    fontFamily: "Poppinsm",
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  amountShow(amount: onProviderOrder.extraCharges.toString()),
                                                  style: TextStyle(
                                                    color: isDarkMode(context) ? Colors.white : Colors.black,
                                                    fontFamily: "Poppinsm",
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "Extra charge Notes : ",
                                                    style: TextStyle(
                                                      color: isDarkMode(context) ? Colors.white : Colors.black,
                                                      fontFamily: "Poppinsm",
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  onProviderOrder.extraChargesDescription.toString(),
                                                  style: TextStyle(
                                                    color: isDarkMode(context) ? Colors.white : Colors.black,
                                                    fontFamily: "Poppinsm",
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )),
                                  )
                                : SizedBox(),
                            Visibility(
                              visible: onProviderOrder.status == ORDER_STATUS_PLACED || onProviderOrder.newScheduleDateTime != null ? true : false,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Container(
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
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    child: Column(
                                      children: [
                                        onProviderOrder.newScheduleDateTime != null
                                            ? Row(
                                                children: [
                                                  Text(
                                                    "New Date : ",
                                                    style: TextStyle(
                                                      color: isDarkMode(context) ? Colors.white : Colors.black,
                                                      fontFamily: "Poppinsm",
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${DateFormat('dd-MMM-yyyy hh:mm a').format(onProviderOrder.newScheduleDateTime!.toDate())}",
                                                    style: TextStyle(
                                                      color: isDarkMode(context) ? Colors.white : Colors.black,
                                                      fontFamily: "Poppinsm",
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : SizedBox(),
                                        onProviderOrder.status == ORDER_STATUS_PLACED || onProviderOrder.status == ORDER_STATUS_ACCEPTED
                                            ? Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 10),
                                                child: SizedBox(
                                                  width: MediaQuery.of(context).size.width * 0.9,
                                                  height: MediaQuery.of(context).size.width * 0.1,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      elevation: 0.0,
                                                      backgroundColor: Color(COLOR_PRIMARY),
                                                      padding: EdgeInsets.all(8),
                                                      side: BorderSide(color: Color(COLOR_PRIMARY), width: 0.4),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.all(
                                                          Radius.circular(36),
                                                        ),
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      showDialog(context: context, builder: (ctxDialog) => showCancelBookingDialog(onProviderOrder));
                                                    },
                                                    child: Text(
                                                      'Cancel Booking',
                                                      style: TextStyle(color: Colors.white, fontFamily: "Poppinsm"),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : SizedBox(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            onProviderOrder.extraPaymentStatus == false && onProviderOrder.status == ORDER_STATUS_ONGOING
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          double finalTotalAmount = 0.0;
                                          finalTotalAmount = double.parse(onProviderOrder.extraCharges.toString());
                                          push(
                                              context,
                                              OnDemandPaymentScreen(
                                                onDemandOrderModel: onProviderOrder,
                                                totalAmount: finalTotalAmount,
                                                isExtra: true,
                                              ));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(COLOR_PRIMARY),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: const Text(
                                          'Pay Extra Amount',
                                          style: TextStyle(fontSize: 16, color: Colors.white),
                                        ).tr(),
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                            onProviderOrder.provider.priceUnit != "Fixed" && onProviderOrder.paymentStatus == false
                                ? Visibility(
                                    visible: onProviderOrder.status == ORDER_STATUS_ONGOING ? true : false,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: SizedBox(
                                        width: MediaQuery.of(context).size.width,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            double finalTotalAmount = 0.0;
                                            finalTotalAmount =
                                                totalAmount + double.parse(onProviderOrder.extraCharges!.isNotEmpty ? onProviderOrder.extraCharges.toString() : "0.0");
                                            onProviderOrder.discount = discountAmount.toString();
                                            onProviderOrder.discountType = discountType.toString();
                                            onProviderOrder.discountLabel = discountLable.toString();
                                            onProviderOrder.couponCode = offerCode.toString();

                                            push(
                                                context,
                                                OnDemandPaymentScreen(
                                                  onDemandOrderModel: onProviderOrder,
                                                  totalAmount: finalTotalAmount,
                                                  isExtra: false,
                                                ));
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(COLOR_PRIMARY),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Pay Now',
                                            style: TextStyle(fontSize: 16, color: Colors.white),
                                          ).tr(),
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              })
          : Container(),
    );
  }

  Widget priceTotalRow() {
    price = 0.0;
    discountAmount = 0.0;
    totalAmount = 0.0;
    if (onProviderOrder!.provider.disPrice == "" || onProviderOrder!.provider.disPrice == "0") {
      price = double.parse(onProviderOrder!.provider.price.toString()) * onProviderOrder!.quantity;
    } else {
      price = double.parse(onProviderOrder!.provider.disPrice.toString()) * onProviderOrder!.quantity;
    }

    // if (onProviderOrder!.provider.priceUnit != "Fixed") {
    if (discountType == 'Percentage' || discountType == 'Percent') {
      discountAmount = price * double.parse(discountLable.toString()) / 100;
    } else {
      discountAmount = double.parse(discountLable);
    }

    subTotal = price - discountAmount;
    totalAmount = subTotal;
    if (onProviderOrder!.taxModel != null) {
      for (var element in onProviderOrder!.taxModel!) {
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
                  Row(
                    children: [
                      Text(
                        onProviderOrder!.provider.disPrice == "" || onProviderOrder!.provider.disPrice == "0"
                            ? '${amountShow(amount: onProviderOrder!.provider.price.toString())} × ${onProviderOrder!.quantity.toStringAsFixed(2)}'
                            : '${amountShow(amount: onProviderOrder!.provider.disPrice.toString())} × ${onProviderOrder!.quantity.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isDarkMode(context) ? Colors.white : Colors.black,
                          fontFamily: "Poppinsm",
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(
                        width: 10,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Discount".tr() +
                                " ${discountType == 'Percentage' || onProviderOrder!.discountType == 'Percent' ? "(${discountLable}%)" : "(${amountShow(amount: discountLable)})"}",
                            style: TextStyle(
                              color: isDarkMode(context) ? Colors.white : Colors.black,
                              fontFamily: "Poppinsm",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          offerCode.isEmpty
                              ? SizedBox()
                              : Text(
                                  offerCode, // onProviderOrder!.couponCode.toString(),
                                  style: TextStyle(
                                    color: isDarkMode(context) ? Colors.white : Colors.black,
                                    //fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                        ],
                      ),
                      Text(
                        '(- ${amountShow(amount: discountAmount.toString())})',
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
            itemCount: onProviderOrder!.taxModel!.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              TaxModel taxModel = onProviderOrder!.taxModel![index];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${taxModel.title.toString()} (${taxModel.type == "fix" ? amountShow(amount: taxModel.tax) : "${taxModel.tax}%"})",
                            style: TextStyle(
                              fontFamily: "Poppinsm",
                              fontWeight: FontWeight.w500,
                              color: isDarkMode(context) ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        Text(
                          amountShow(amount: getTaxValue(amount: (double.parse(subTotal.toString())).toString(), taxModel: taxModel).toString()),
                          style: TextStyle(
                            fontFamily: "Poppinsm",
                            fontWeight: FontWeight.w500,
                            color: isDarkMode(context) ? Colors.white : Colors.black,
                          ),
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
          Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Amount",
                    style: TextStyle(
                      color: isDarkMode(context) ? Colors.white : Colors.black,
                      fontFamily: "Poppinsm",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    amountShow(amount: totalAmount.toString()),
                    style: TextStyle(
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

  TextEditingController cancelBookingController = TextEditingController();

  Widget showCancelBookingDialog(OnProviderOrderModel onProviderOrder) {
    return AlertDialog(
      title: Text('Please give reason for canceling this Booking',
          style: TextStyle(
            fontSize: 16,
            fontFamily: "Poppinsm",
            fontWeight: FontWeight.w500,
          )),
      content: TextFormField(
          controller: cancelBookingController,
          textAlignVertical: TextAlignVertical.center,
          textInputAction: TextInputAction.next,
          validator: validateEmptyField,
          keyboardType: TextInputType.text,
          cursorColor: Color(COLOR_PRIMARY),
          maxLines: 5,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            hintText: "Specify your reason here".tr(),
            hintStyle: TextStyle(
              color: isDarkMode(context) ? Colors.white : const Color(0Xff333333),
              fontFamily: "Poppinsm",
              fontWeight: FontWeight.w500,
            ),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
              borderRadius: BorderRadius.circular(7.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
              borderRadius: BorderRadius.circular(7.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(7.0),
            ),
          )),
      actions: <Widget>[
        TextButton(
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.red),
          ).tr(),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text(
            'Continue',
            style: TextStyle(color: Colors.green),
          ).tr(),
          onPressed: () async {
            if (cancelBookingController.text.toString() == "") {
              SnackBar snack = SnackBar(
                content: const Text(
                  'This field is required.',
                  style: TextStyle(color: Colors.white),
                ).tr(),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.red,
              );
              ScaffoldMessenger.of(context).showSnackBar(snack);
            } else {
              showProgress(context, 'Please wait...', false);

              if (onProviderOrder.provider.priceUnit == "Fixed") {
                double total = 0.0;

                if (onProviderOrder.provider.disPrice == "" || onProviderOrder.provider.disPrice == "0") {
                  total += onProviderOrder.quantity * double.parse(onProviderOrder.provider.price.toString());
                } else {
                  total += onProviderOrder.quantity * double.parse(onProviderOrder.provider.disPrice.toString());
                }

                if (taxList != null) {
                  for (var element in taxList!) {
                    total = total + getTaxValue(amount: (subTotal).toString(), taxModel: element);
                  }
                }

                double adminComm = (onProviderOrder.adminCommissionType!.toLowerCase() == 'Percentage'.toLowerCase() ||
                        onProviderOrder.adminCommissionType!.toLowerCase() == 'Percent'.toLowerCase())
                    ? (total * double.parse(onProviderOrder.adminCommission!)) / 100
                    : double.parse(onProviderOrder.adminCommission!);

                if (onProviderOrder.payment_method.toLowerCase() != 'cod') {
                  TopupTranHistoryModel wallet = TopupTranHistoryModel(
                      amount: total.toDouble(),
                      order_id: onProviderOrder.id,
                      serviceType: 'ondemand-service',
                      id: Uuid().v4(),
                      user_id: MyAppState.currentUser!.userID,
                      date: Timestamp.now(),
                      isTopup: true,
                      payment_method: "wallet",
                      payment_status: "success",
                      transactionUser: "customer",
                      note: 'Booking Amount Refund');

                  await FireStoreUtils.firestore.collection("wallet").doc(wallet.id).set(wallet.toJson()).then((value) async {
                    await FireStoreUtils.updateOtherWalletAmount(userId: onProviderOrder.author.userID, amount: total.toDouble());
                  });

                  if (onProviderOrder.status == ORDER_STATUS_ACCEPTED) {
                    TopupTranHistoryModel historyModel = TopupTranHistoryModel(
                        amount: total,
                        id: Uuid().v4(),
                        order_id: onProviderOrder.id,
                        user_id: onProviderOrder.provider.author.toString(),
                        date: Timestamp.now(),
                        isTopup: false,
                        payment_method: "Wallet",
                        payment_status: "success",
                        serviceType: 'ondemand-service',
                        note: 'Booking Amount refund',
                        transactionUser: "provider");

                    await FireStoreUtils.firestore.collection("wallet").doc(historyModel.id).set(historyModel.toJson());
                    await FireStoreUtils.updateOtherWalletAmount(amount: -total, userId: onProviderOrder.provider.author.toString());
                  }
                }

                if (onProviderOrder.status == ORDER_STATUS_ACCEPTED) {
                  TopupTranHistoryModel adminCommission = TopupTranHistoryModel(
                      amount: adminComm,
                      id: Uuid().v4(),
                      order_id: onProviderOrder.id,
                      user_id: onProviderOrder.provider.author.toString(),
                      date: Timestamp.now(),
                      isTopup: true,
                      payment_method: "Wallet",
                      payment_status: "success",
                      transactionUser: "provider",
                      note: 'Admin commission refund',
                      serviceType: 'ondemand-service');

                  await FireStoreUtils.firestore.collection("wallet").doc(adminCommission.id).set(adminCommission.toJson());
                  await FireStoreUtils.updateOtherWalletAmount(amount: adminComm, userId: onProviderOrder.provider.author.toString());
                }
              }

              onProviderOrder.status = ORDER_STATUS_CANCELLED;
              onProviderOrder.reason = cancelBookingController.text.toString();

              User? providerUser = await FireStoreUtils.getCurrentUser(onProviderOrder.provider.author.toString());
              if (providerUser != null) {
                Map<String, dynamic> payLoad = <String, dynamic>{"type": 'provider_order', "orderId": onProviderOrder.id};
                await SendNotification.sendFcmMessage(providerBookingCancel, providerUser.fcmToken.toString(), payLoad);
              }
              await FireStoreUtils.updateOnDemandOrder(onProviderOrder);
              hideProgress();
              Navigator.of(context).pop();
            }
          },
        ),
      ],
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
                      discountType = couponList[index].discountTypeOffer.toString();
                      discountLable = couponList[index].discountOffer.toString();
                      offerCode = couponList[index].offerCode.toString();
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

  TextEditingController couponTextFieldController = TextEditingController(text: '');

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
                                  print("=====>${couponTextFieldController.text.toString()}");
                                  print("=====>${couponModel.offerCode!.toString()}");
                                  if (couponTextFieldController.text.toLowerCase().toString() == couponModel.offerCode!.toLowerCase().toString()) {
                                    discountType = couponModel.discountTypeOffer.toString();
                                    discountLable = couponModel.discountOffer.toString();
                                    offerCode = couponModel.offerCode.toString();
                                    setState(() {});
                                    break;
                                  } else {
                                    ShowToastDialog.showToast("Applied coupon not valid.");
                                  }
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
              ]);
            }));
  }

  String? getDate(String date) {
    final format = DateFormat("MMM dd, yyyy");
    String formattedDate = format.format(DateTime.parse(date));
    return formattedDate;
  }
}
