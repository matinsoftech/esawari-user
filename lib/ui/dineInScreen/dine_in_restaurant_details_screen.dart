import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/BookTableModel.dart';
import 'package:emartconsumer/model/Ratingmodel.dart';
import 'package:emartconsumer/model/VendorModel.dart';
import 'package:emartconsumer/model/offer_model.dart';
import 'package:emartconsumer/send_notification.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/ui/auth/AuthScreen.dart';
import 'package:emartconsumer/ui/fullScreenImageViewer/FullScreenImageViewer.dart';
import 'package:emartconsumer/ui/vendorProductsScreen/photos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../vendorProductsScreen/newVendorProductsScreen.dart';

class DineInRestaurantDetailsScreen extends StatefulWidget {
  final VendorModel vendorModel;

  const DineInRestaurantDetailsScreen({Key? key, required this.vendorModel}) : super(key: key);

  @override
  State<DineInRestaurantDetailsScreen> createState() => _DineInRestaurantDetailsScreenState();
}

class _DineInRestaurantDetailsScreenState extends State<DineInRestaurantDetailsScreen> {
  final fireStoreUtils = FireStoreUtils();

  String _selectedOccasion = "";
  bool? isFirstTime = false;
  TextEditingController reqController = TextEditingController(text: '');

  String userDisFName = '', userDisLName = '', userDisPhone = '', userDisEmail = '';

  var position = const LatLng(23.12, 70.22);
  late Future<List<RatingModel>> ratingproduct;

  Stream<List<OfferModel>>? lstOfferData;
  var tags = [];
  List occasionList = ["Birthday".tr(), "Anniversary".tr()];
  List<Timestamp> dateList = [];
  List timeSlotList = [];
  DateTime startTime = DateTime.now().add(const Duration(hours: 9));
  DateTime endTime = DateTime.now().add(const Duration(hours: 21));
  String selectedTimeSlot = '6:00 PM';

  void _getUserLocation() async {
    setState(() {
      setState(() {
        position = LatLng(MyAppState.selectedPosotion.location!.latitude, MyAppState.selectedPosotion.location!.longitude);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();

    for (int i = 0; i < 10; i++) {
      dateList.add(Timestamp.fromDate(DateTime.now().add(Duration(days: i))));
    }

    if (widget.vendorModel.openDineTime.isNotEmpty) {
      startTime = stringToDate(widget.vendorModel.openDineTime);
    }

    if (widget.vendorModel.closeDineTime.isNotEmpty) {
      endTime = stringToDate(widget.vendorModel.closeDineTime);
    }

    for (DateTime time = startTime; time.isBefore(endTime); time = time.add(const Duration(minutes: 30))) {
      timeSlotList.add(time);
    }

    selectedTimeSlot = DateFormat('hh:mm a').format(timeSlotList[0]);

    ratingproduct = fireStoreUtils.getReviewsbyVendorID(widget.vendorModel.id);
    fireStoreUtils.getVendorCusions(widget.vendorModel.id).then((value) {
      tags.addAll(value);
      setState(() {});
    });
    if (MyAppState.currentUser != null) {
      userDisFName = MyAppState.currentUser!.firstName;
      userDisLName = MyAppState.currentUser!.lastName;
      userDisEmail = MyAppState.currentUser!.email;
      userDisPhone = MyAppState.currentUser!.phoneNumber;
    }
  }

  @override
  Widget build(BuildContext context) {
    double distanceInMeters = Geolocator.distanceBetween(widget.vendorModel.latitude, widget.vendorModel.longitude, position.latitude, position.longitude);
    double kilometer = distanceInMeters / 1000;
    double minutes = 1.2;
    double value = minutes * kilometer;
    final int hour = value ~/ 60;
    final double minute = value % 60;
    return Scaffold(
      body: SingleChildScrollView(
          child: Container(
              color: isDarkMode(context) ? Colors.black : const Color(0xffFFFFFF),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Stack(children: [
                  Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      decoration: const BoxDecoration(
                        boxShadow: <BoxShadow>[BoxShadow(color: Colors.white38, blurRadius: 25.0, offset: Offset(0.0, 0.75))],
                      ),
                      width: MediaQuery.of(context).size.width * 1,
                      child: CachedNetworkImage(
                        imageUrl: getImageVAlidUrl(widget.vendorModel.photo),
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                        placeholder: (context, url) => Center(
                            child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                        )),
                        errorWidget: (context, url, error) => Image.network(
                          placeholderImage,
                          fit: BoxFit.fitWidth,
                        ),
                        fit: BoxFit.fitWidth,
                      )),
                  Positioned(
                      top: MediaQuery.of(context).size.height * 0.033,
                      left: MediaQuery.of(context).size.width * 0.03,
                      child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          radius: 20,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 25,
                            ),
                          ))),
                  Positioned(
                      bottom: MediaQuery.of(context).size.height * 0.009,
                      right: MediaQuery.of(context).size.width * 0.03,
                      child: IconButton(
                          icon: const Image(
                            image: AssetImage(
                              "assets/images/img.png",
                            ),
                            height: 35,
                          ),
                          onPressed: () {
                            push(context, StorePhotos(vendorModel: widget.vendorModel));
                          }))
                ]),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Text(widget.vendorModel.title,
                              maxLines: 2, style: TextStyle(fontSize: 18, letterSpacing: 0.5, color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff2A2A2A))),
                        ),
                        resttiming()
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 3.0, right: 10),
                      child: Row(children: [
                        const ImageIcon(
                          AssetImage('assets/images/location3x.png'),
                          size: 18,
                          color: Color(0xff9091A4),
                        ),
                        const SizedBox(width: 5),
                        Container(
                            constraints: const BoxConstraints(maxWidth: 230),
                            child: Text(
                              widget.vendorModel.location,
                              maxLines: 2,
                              style: const TextStyle(letterSpacing: 0.5, color: Color(0xFF9091A4)),
                            ))
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 10, right: 10),
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade100, width: 0.1),
                              boxShadow: [
                                BoxShadow(color: Colors.grey.shade300, blurRadius: 3.0, spreadRadius: 0.6, offset: const Offset(0.1, 0.5)),
                              ],
                              color: Colors.white),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(children: [
                                  Image(
                                    image: const AssetImage("assets/images/location.png"),
                                    color: Color(COLOR_PRIMARY),
                                    height: 25,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "${kilometer.toDouble().toStringAsFixed(currencyData!.decimal)} km",
                                    style: const TextStyle(letterSpacing: 0.5, color: Color(0xff565764)),
                                  ).tr()
                                ]),
                                Column(children: [
                                  Image(
                                    image: const AssetImage("assets/images/price.png"),
                                    color: Color(COLOR_PRIMARY),
                                    height: 25,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    widget.vendorModel.vendorCost == 0 ? "" : '${amountShow(amount: widget.vendorModel.vendorCost.toString())} for two',
                                    // "${minute.toDouble()} min",
                                    style: const TextStyle(letterSpacing: 0.5, color: Color(0xff565764)),
                                  )
                                ]),
                                Column(children: [
                                  Image(
                                    image: const AssetImage("assets/images/rate.png"),
                                    color: Color(COLOR_PRIMARY),
                                    height: 25,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    widget.vendorModel.reviewsCount == 0
                                        ? '0' ' Rate'.tr()
                                        : ' ${double.parse((widget.vendorModel.reviewsSum / widget.vendorModel.reviewsCount).toStringAsFixed(1))}'
                                            ' Rate',
                                    style: const TextStyle(letterSpacing: 0.5, color: Color(0xff565764)),
                                  ).tr()
                                ]),
                                InkWell(
                                    onTap: () async {
                                      await FlutterShare.share(title: widget.vendorModel.title, text: "${widget.vendorModel.location}", linkUrl: widget.vendorModel.photo);
                                    },
                                    child: Column(children: [
                                      Image(
                                        image: const AssetImage("assets/images/share.png"),
                                        color: Color(COLOR_PRIMARY),
                                        height: 25,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Share".tr(),
                                        style: const TextStyle(letterSpacing: 0.5, color: Color(0xff565764)),
                                      ).tr()
                                    ])),
                              ],
                            ),
                          )),
                    ),
                    // Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    //   FutureBuilder<List<RatingModel>>(
                    //       future: ratingproduct,
                    //       builder: (BuildContext context, snapshot) {
                    //         if (snapshot.connectionState == ConnectionState.waiting) {
                    //           return Center(
                    //             child: CircularProgressIndicator.adaptive(
                    //               valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                    //             ),
                    //           );
                    //         }
                    //         if (snapshot.hasData) {
                    //           return InkWell(
                    //             onTap: () => push(
                    //               context,
                    //               Review(
                    //                 vendorModel: widget.vendorModel,
                    //               ),
                    //             ),
                    //             child: Container(
                    //                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    //                 decoration: BoxDecoration(
                    //                     borderRadius: BorderRadius.circular(3),
                    //                     border: Border.all(color: Colors.grey.shade100, width: 0.1),
                    //                     boxShadow: [
                    //                       BoxShadow(color: Colors.grey.shade300, blurRadius: 3.0, spreadRadius: 0.6, offset: const Offset(0.1, 0.5)),
                    //                     ],
                    //                     color: Colors.white),
                    //                 width: MediaQuery.of(context).size.width * 0.9,
                    //                 margin: const EdgeInsets.only(top: 10),
                    //                 child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    //                   Text(snapshot.data!.length.toString() + " reviews".tr(),
                    //                       style: const TextStyle(
                    //
                    //                         letterSpacing: 0.5,
                    //                         color: Color(0XFF676771),
                    //                       )),
                    //                   Image(
                    //                     image: const AssetImage("assets/images/review.png"),
                    //                     color: Color(COLOR_PRIMARY),
                    //                     width: 20,
                    //                   )
                    //                 ])),
                    //           );
                    //         } else {
                    //           return const CircularProgressIndicator();
                    //         }
                    //       }),
                    // ]),
                    Card(
                      elevation: 2,
                      color: isDarkMode(context) ? const Color(DARK_BG_COLOR) : const Color(0XFFFFFFFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.black12, width: 1),
                      ),
                      margin: const EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 15),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 10),
                        child: Row(
                          children: [
                            const Image(
                              image: AssetImage("assets/images/food_delivery.png"),
                              height: 32,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15, right: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Available food delivery".tr(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        )).tr(),
                                    Text("In".tr() + " ${hour.toString().padLeft(2, "0")}h ${minute.toStringAsFixed(0).padLeft(2, "0")}${"min".tr()}", style: const TextStyle())
                                        .tr()
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                push(context, NewVendorProductsScreen(vendorModel: widget.vendorModel));
                              },
                              child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(100), border: Border.all(width: 1, color: isDarkMode(context) ? Color(COLOR_PRIMARY) : Colors.black54)),
                                    child: Icon(
                                      Icons.keyboard_arrow_right,
                                      color: isDarkMode(context) ? Color(COLOR_PRIMARY) : Colors.black54,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 2,
                      color: isDarkMode(context) ? const Color(DARK_BG_COLOR) : const Color(0XFFFFFFFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.black12, width: 1),
                      ),
                      margin: const EdgeInsets.only(left: 15, right: 15),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 10),
                        child: Row(
                          children: [
                            const Image(
                              image: AssetImage("assets/images/book_table.png"),
                              height: 32,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15, right: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Book a Table".tr(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        )).tr(),
                                    Text("Get instant conformation".tr(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w300,
                                        )).tr()
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (MyAppState.currentUser == null) {
                                  push(context, const AuthScreen());
                                } else {
                                  bookTableSheet();
                                }
                              },
                              child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(100), border: Border.all(width: 1, color: isDarkMode(context) ? Color(COLOR_PRIMARY) : Colors.black54)),
                                    child: Icon(
                                      Icons.keyboard_arrow_right,
                                      color: isDarkMode(context) ? Color(COLOR_PRIMARY) : Colors.black54,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Menus".tr(), style: const TextStyle(fontSize: 16)),
                                widget.vendorModel.vendorMenuPhotos.isEmpty
                                    ? Container()
                                    : GestureDetector(
                                        onTap: () {
                                          push(context, StoreMenuPhoto(vendorMenuPhotos: widget.vendorModel.vendorMenuPhotos));
                                        },
                                        child: Text('View All'.tr(), style: TextStyle(color: Color(COLOR_PRIMARY))),
                                      )
                              ],
                            ),
                          ),
                          widget.vendorModel.vendorMenuPhotos.isEmpty
                              ? showEmptyState(
                                  'No Menu Photos'.tr(),
                                  context,
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.12,
                                    child: ListView.builder(
                                      itemCount: widget.vendorModel.vendorMenuPhotos.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            push(context, FullScreenImageViewer(imageUrl: widget.vendorModel.vendorMenuPhotos[index]));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: CachedNetworkImage(
                                                height: 80,
                                                width: 80,
                                                imageUrl: getImageVAlidUrl(widget.vendorModel.vendorMenuPhotos[index]),
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
                                                    )),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0, left: 10, right: 10),
                      child: Divider(color: Colors.black26),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image(
                                image: const AssetImage("assets/images/time.png"),
                                color: Color(COLOR_PRIMARY),
                                height: 24,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 15, right: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Timings".tr(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        )).tr(),
                                    Text("${widget.vendorModel.openDineTime == '' ? "10:00 AM" : widget.vendorModel.openDineTime.toString()} to ${widget.vendorModel.closeDineTime == '' ? "10:00 PM" : widget.vendorModel.closeDineTime.toString()}",
                                            style: const TextStyle())
                                        .tr()
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image(
                                  image: const AssetImage("assets/images/price.png"),
                                  color: Color(COLOR_PRIMARY),
                                  height: 24,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15, right: 15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Cost".tr(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          )).tr(),
                                      Text(
                                              widget.vendorModel.vendorCost == 0
                                                  ? "Approx cost is not added".tr()
                                                  : "Cost for two".tr() + " ${amountShow(amount: widget.vendorModel.vendorCost.toString())} " + "(Approx)".tr(),

                                              // widget.vendorModel.vendorCost == 0 ? "Approx cost is not added".tr() : "Cost for two".tr() + "$symbol${widget.vendorModel.vendorCost} (Approx)",
                                              style: const TextStyle())
                                          .tr()
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image(
                                  image: const AssetImage("assets/images/location.png"),
                                  color: Color(COLOR_PRIMARY),
                                  height: 24,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15, right: 15),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Location".tr(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            )).tr(),
                                        Text(widget.vendorModel.location, style: const TextStyle()).tr()
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    launchUrl(createCoordinatesUrl(widget.vendorModel.latitude, widget.vendorModel.longitude, widget.vendorModel.title));
                                  },
                                  child: Text("Direction".tr(),
                                      style: TextStyle(
                                        color: Color(COLOR_PRIMARY),
                                      )).tr(),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0, left: 10, right: 10),
                      child: Divider(color: Colors.black26),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Cuisines".tr(), style: TextStyle(color: isDarkMode(context) ? Colors.white : const Color(0xFF000000), fontSize: 16)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
                            child: Wrap(
                              spacing: 5.0,
                              runSpacing: 3.0,
                              children: <Widget>[
                                ...tags
                                    .map((tag) => FilterChip(
                                          labelStyle: TextStyle(color: Color(COLOR_PRIMARY)),
                                          label: Text("$tag"),
                                          onSelected: (bool value) {},
                                        ))
                                    .toList()
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ]))),
    );
  }

  resttiming() {
    if (widget.vendorModel.reststatus == true) {
      return Container(
          height: 35,
          decoration: const BoxDecoration(color: Color(0XFFF1F4F7), borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))),
          padding: const EdgeInsets.only(right: 40, left: 10),
          child: Row(children: [
            const Icon(
              Icons.circle,
              color: Color(0XFF3dae7d),
              size: 13,
            ),
            const SizedBox(
              width: 10,
            ),
            Text("Open".tr(), style: const TextStyle(fontSize: 16, color: Color(0XFF3dae7d)))
          ]));
    } else {
      return Container(
          height: 35,
          decoration: const BoxDecoration(color: Color(0XFFF1F4F7), borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))),
          padding: const EdgeInsets.only(right: 40, left: 10),
          child: Row(children: [
            const Icon(
              Icons.circle,
              color: Colors.redAccent,
              size: 13,
            ),
            const SizedBox(
              width: 10,
            ),
            Text("Close".tr(), style: TextStyle(fontSize: 16, letterSpacing: 0.5, color: Colors.redAccent))
          ]));
    }
  }

  buildOfferItem() {
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
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
              ),
              margin: const EdgeInsets.only(top: 4),
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
                          "${"Fix Price".tr() == "Fix Price".tr() ? "\$" : ""}${100}${"Percentage".tr() == "Percentage".tr() ? "% OFF".tr() : " OFF".tr()}",
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
                        "USE100".tr(),
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, letterSpacing: 0.5),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 15, right: 15, top: 3),
                        height: 15,
                        width: 1,
                        color: const Color(COUPON_DASH_COLOR),
                      ),
                      Text("valid till ".tr() + "Nov 31,2022", style: TextStyle(letterSpacing: 0.5))
                    ],
                  ),
                ],
              )),
        ),
      ),
    );
  }

  bookTableSheet() {
    final size = MediaQuery.of(context).size;

    return showModalBottomSheet(
        elevation: 5,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        context: context,
        constraints: BoxConstraints(maxHeight: size.height * 0.8),
        isScrollControlled: true,
        builder: (context) {
          return Scaffold(
            body: StatefulBuilder(builder: (context, setState) {
              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Text(
                          "Book A Table".tr(),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                        ),
                        child: Card(
                          elevation: 0,
                          color: isDarkMode(context) ? Colors.black38 : Colors.grey.shade100,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.vendorModel.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Opacity(
                                  opacity: 0.7,
                                  child: Text(
                                    widget.vendorModel.location,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0, top: 8, right: 10),
                              child: Text(
                                'Select Day'.tr(),
                                style: const TextStyle(),
                              ),
                            ),
                            SizedBox(
                              height: 80,
                              child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: dateList.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    bool isSelected = selectedDate == dateList[index] ? true : false;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedDate = dateList[index];
                                          });
                                        },
                                        child: Card(
                                          elevation: 5,
                                          color: isSelected ? Color(COLOR_PRIMARY) : Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: SizedBox(
                                              height: 60,
                                              width: 120,
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Text(
                                                      calculateDifference(dateList[index].toDate()) == 0
                                                          ? "Today".tr()
                                                          : calculateDifference(dateList[index].toDate()) == 1
                                                              ? "Tomorrow".tr()
                                                              : DateFormat('EEE', 'en_US').format(dateList[index].toDate()),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: isSelected ? Colors.white : Colors.black38,
                                                      ),
                                                    ),
                                                    Text(
                                                      DateFormat('d MMM').format(dateList[index].toDate()).toString(),
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: isSelected ? Colors.white : Colors.black54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0, top: 8, right: 10),
                              child: Text(
                                'How Many People?'.tr(),
                                style: const TextStyle(),
                              ),
                            ),
                            SizedBox(
                              height: 60,
                              child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: noOfPeople.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    bool isSelected = selectedPeople == noOfPeople[index] ? true : false;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedPeople = noOfPeople[index];
                                          });
                                        },
                                        child: Card(
                                          elevation: 5,
                                          color: isSelected ? Color(COLOR_PRIMARY) : Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: SizedBox(
                                            height: 50,
                                            width: 70,
                                            child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  noOfPeople[index],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: isSelected ? Colors.white : Colors.black54,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0, top: 8, right: 10),
                              child: Text(
                                'What Time?'.tr(),
                                style: const TextStyle(),
                              ),
                            ),
                            SizedBox(
                              height: 60,
                              child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: timeSlotList.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    bool isSelected = selectedTimeSlot == DateFormat('hh:mm a').format(timeSlotList[index]) ? true : false;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedTimeSlot = DateFormat('hh:mm a').format(timeSlotList[index]);
                                          });
                                        },
                                        child: Card(
                                          elevation: 5,
                                          color: isSelected ? Color(COLOR_PRIMARY) : Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 5),
                                              child: Text(
                                                DateFormat('hh:mm a').format(timeSlotList[index]).toString(),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: isSelected ? Colors.white : Colors.black54,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                        ),
                        child: Card(
                          color: isDarkMode(context) ? Colors.black38 : Colors.grey.shade100,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4.0),
                                      child: Text(
                                        "Personal Details".tr(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Opacity(
                                      opacity: 0.7,
                                      child: Text(
                                        "$userDisFName $userDisLName",
                                        style: const TextStyle(),
                                      ),
                                    ),
                                    Opacity(
                                      opacity: 0.7,
                                      child: Text(
                                        userDisPhone,
                                        style: const TextStyle(),
                                      ),
                                    ),
                                    Opacity(
                                      opacity: 0.7,
                                      child: Text(
                                        userDisEmail,
                                        style: const TextStyle(),
                                      ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () {
                                    showCustomDialog(context, userDisFName, userDisLName, userDisPhone, userDisEmail, () {
                                      setState(() {});
                                    });
                                  },
                                  child: Text(
                                    "CHANGE".tr(),
                                    style: TextStyle(color: Color(COLOR_PRIMARY), fontSize: 12),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 8, right: 10),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            'Special Occasion'.tr(),
                            style: const TextStyle(),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          for (int i = 0; i < occasionList.length; i++)
                            ListTile(
                              title: Text(
                                '${occasionList[i]}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: i == 5
                                        ? isDarkMode(context)
                                            ? Colors.white
                                            : Colors.black38
                                        : isDarkMode(context)
                                            ? Colors.white
                                            : Colors.black),
                              ),
                              leading: Radio<String>(
                                value: occasionList[i],
                                groupValue: _selectedOccasion,
                                activeColor: Color(COLOR_PRIMARY),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedOccasion = occasionList[i];
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, right: 8),
                        child: CheckboxListTile(
                          title: const Text("Is this your first visit?").tr(),
                          value: isFirstTime,
                          onChanged: (newValue) {
                            setState(() {
                              isFirstTime = newValue;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 8, right: 10),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            'Additional Requests'.tr(),
                            style: const TextStyle(),
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 10.0, top: 8, right: 10),
                          child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(12)),
                              child: Container(
                                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                                  color: isDarkMode(context) ? const Color(0XFF0e0b08) : const Color(0XFFF1F4F7),
                                  // height: 120,
                                  alignment: Alignment.center,
                                  child: TextFormField(
                                    textAlign: TextAlign.center,
                                    controller: reqController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Write Any Additional Requests'.tr(),
                                      hintStyle: const TextStyle(color: Color(0XFF9091A4)),
                                      labelStyle: const TextStyle(color: Color(0XFF333333)),
                                    ),
                                  )))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
                        child: MaterialButton(
                          minWidth: size.width * 0.95,
                          height: 50,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          color: Color(COLOR_PRIMARY),
                          onPressed: () async {
                            if (selectedDate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: const Text("Select Day").tr(),
                                backgroundColor: Colors.red,
                              ));
                              return;
                            }
                            DateTime dt = selectedDate!.toDate();
                            String hour =
                                DateFormat("kk:mm").format(DateFormat('hh:mm a').parse((Intl.getCurrentLocale() == "en_US") ? selectedTimeSlot : selectedTimeSlot.toLowerCase()));
                            dt = DateTime(dt.year, dt.month, dt.day, int.parse(hour.split(":")[0]), int.parse(hour.split(":")[1]), dt.second, dt.millisecond, dt.microsecond);
                            selectedDate = Timestamp.fromDate(dt);
                            FireStoreUtils fireStoreUtils = FireStoreUtils();
                            showProgress(context, 'Sending Table Request...'.tr(), false);
                            VendorModel vendorModel = await fireStoreUtils.getVendorByVendorID(widget.vendorModel.id);
                            BookTableModel bookTablemodel = BookTableModel(
                                author: MyAppState.currentUser,
                                authorID: MyAppState.currentUser!.userID,
                                createdAt: Timestamp.now(),
                                date: selectedDate,
                                status: ORDER_STATUS_PLACED,
                                vendor: vendorModel,
                                section_id: sectionConstantModel!.id,
                                specialRequest: reqController.text.isEmpty ? "" : reqController.text,
                                vendorID: widget.vendorModel.id,
                                guestEmail: userDisEmail,
                                guestFirstName: userDisFName,
                                guestLastName: userDisLName,
                                guestPhone: userDisPhone,
                                occasion: _selectedOccasion,
                                totalGuest: int.parse(selectedPeople),
                                firstVisit: isFirstTime!);

                            await fireStoreUtils.bookTable(bookTablemodel);

                            Map<String, dynamic> payLoad = <String, dynamic>{"type": "dine_in", "orderId": bookTablemodel.id};

                            await SendNotification.sendFcmMessage(dineInPlaced, widget.vendorModel.fcmToken, payLoad);
                            log("||||{}" + bookTablemodel.toJson().toString());
                            reqController.text = "";
                            _selectedOccasion = "";
                            selectedPeople = "2";
                            selectedTimeSlot = DateFormat('hh:mm a').format(timeSlotList[0]);
                            selectedDate = null;
                            isFirstTime = false;
                            hideProgress();
                            Navigator.pop(context);
                          },
                          child: Text(
                            "BOOK NOW".tr(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }

  int calculateDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day).difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  Timestamp? selectedDate;

  String selectedPeople = "2";
  List noOfPeople = ['2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22'];

  // List timeSlotList = [
  //   '6:00 PM',
  //   '6:30 PM',
  //   '7:00 PM',
  //   '7:30 PM',
  //   '8:00 PM',
  //   '8:30 PM',
  //   '9:00 PM',
  //   '9:30 PM',
  //   '10:00 PM',
  // ];

  void showCustomDialog(BuildContext context, String firstName, String lastName, String phoneNumber, String email, VoidCallback? action) {
    GlobalKey<FormState> _key = GlobalKey();
    AutovalidateMode _validate = AutovalidateMode.disabled;
    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (_, __, ___) {
        return Container(
          margin: const EdgeInsets.only(left: 10, right: 10),
          child: Form(
            key: _key,
            autovalidateMode: _validate,
            child: Center(
              child: Material(
                child: Padding(
                  padding: MediaQuery.of(context).padding,
                  child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: ListTile.divideTiles(context: context, tiles: [
                        ListTile(
                          title: Text(
                            'firstName'.tr(),
                            style: TextStyle(
                              color: isDarkMode(context) ? Colors.white : Colors.black,
                            ),
                          ).tr(),
                          trailing: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 100),
                            child: TextFormField(
                              onSaved: (String? val) {
                                userDisFName = val!;
                              },
                              validator: validateName,
                              textInputAction: TextInputAction.next,
                              textAlign: TextAlign.end,
                              initialValue: firstName,
                              style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black),
                              cursorColor: const Color(COLOR_ACCENT),
                              textCapitalization: TextCapitalization.words,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(border: InputBorder.none, hintText: 'firstName'.tr(), contentPadding: const EdgeInsets.symmetric(vertical: 5)),
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'lastName'.tr(),
                            style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
                          ).tr(),
                          trailing: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 100),
                            child: TextFormField(
                              onSaved: (String? val) {
                                userDisLName = val!;
                              },
                              validator: validateName,
                              textInputAction: TextInputAction.next,
                              textAlign: TextAlign.end,
                              initialValue: lastName,
                              style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black),
                              cursorColor: const Color(COLOR_ACCENT),
                              textCapitalization: TextCapitalization.words,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(border: InputBorder.none, hintText: 'lastName'.tr(), contentPadding: const EdgeInsets.symmetric(vertical: 5)),
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'emailAddress'.tr(),
                            style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
                          ).tr(),
                          trailing: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: TextFormField(
                              onSaved: (String? val) {
                                userDisEmail = val!;
                              },
                              validator: validateEmail,
                              textInputAction: TextInputAction.next,
                              initialValue: email,
                              textAlign: TextAlign.end,
                              style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black),
                              cursorColor: const Color(COLOR_ACCENT),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(border: InputBorder.none, hintText: 'emailAddress'.tr(), contentPadding: const EdgeInsets.symmetric(vertical: 5)),
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'phoneNumber'.tr(),
                            style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
                          ).tr(),
                          trailing: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: TextFormField(
                              onSaved: (String? val) {
                                userDisPhone = val!;
                              },
                              validator: validateMobile,
                              textInputAction: TextInputAction.done,
                              initialValue: phoneNumber,
                              textAlign: TextAlign.end,
                              style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black),
                              cursorColor: const Color(COLOR_ACCENT),
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(border: InputBorder.none, hintText: 'phoneNumber'.tr(), contentPadding: const EdgeInsets.only(bottom: 2)),
                            ),
                          ),
                        ),
                        MaterialButton(
                          minWidth: MediaQuery.of(context).size.width * 0.95,
                          height: 50,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          onPressed: () async {
                            if (_key.currentState?.validate() ?? false) {
                              _key.currentState!.save();
                              action!.call();
                              setState(() {});
                            } else {
                              action!.call();
                              setState(() {
                                _validate = AutovalidateMode.onUserInteraction;
                              });
                            }
                            Navigator.pop(context);
                          },
                          child: Text(
                            "CHANGE".tr(),
                            style: TextStyle(color: Color(COLOR_PRIMARY)),
                          ),
                        )
                      ]).toList()),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        Tween<Offset> tween;
        if (anim.status == AnimationStatus.reverse) {
          tween = Tween(begin: const Offset(0, 1), end: Offset.zero);
        } else {
          tween = Tween(begin: const Offset(0, -1), end: Offset.zero);
        }

        return SlideTransition(
          position: tween.animate(anim),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
  }

  DateTime stringToDate(String openDineTime) {
    return DateFormat('HH:mm').parse(DateFormat('HH:mm').format(DateFormat("hh:mm a").parse((Intl.getCurrentLocale() == "en_US") ? openDineTime : openDineTime.toLowerCase())));
  }
}
