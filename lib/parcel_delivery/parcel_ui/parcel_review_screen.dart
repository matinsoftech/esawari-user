import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/AppGlobal.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/Ratingmodel.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/parcel_delivery/parcel_model/parcel_order_model.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ParcelReviewScreen extends StatefulWidget {
  final ParcelOrderModel order;

  const ParcelReviewScreen({Key? key, required this.order}) : super(key: key);

  @override
  _ParcelReviewScreenState createState() => _ParcelReviewScreenState();
}

class _ParcelReviewScreenState extends State<ParcelReviewScreen> with TickerProviderStateMixin {
  late Future<RatingModel?> ratingproduct;

  RatingModel? ratingModel;
  final _formKey = GlobalKey<FormState>();
  FireStoreUtils fireStoreUtils = FireStoreUtils();
  final comment = TextEditingController();
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  double? ratings = 0.0;
  var futureCount, futureSum;

  late Future<User?> photofuture;

  // RatingModel? rating;
  @override
  void dispose() {
    comment.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    ratingproduct = fireStoreUtils.getReviewsbyID(widget.order.id);
    ratingproduct.then((value) {
      if (value != null) {
        ratingModel = value;
        updatevendor();
      }
    });
    photofuture = FireStoreUtils.getCurrentUser(widget.order.driverID.toString());

    updatevendor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Colors.black : const Color(0XFFFDFEFE),
      appBar: AppGlobal.buildSimpleAppBar(context, "Update Review".tr()),
      body: SingleChildScrollView(
          child: Container(
              // color: Color(0XFFF1F142),
              // 0XFFF1F142
              // 0XFFF1F4F7
              padding: const EdgeInsets.only(top: 20, left: 20),
              child: Form(
                key: _formKey,
                child: FutureBuilder<RatingModel?>(
                    future: ratingproduct,
                    // initialData: ratingModel,
                    builder: (BuildContext context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator.adaptive(
                            valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                          ),
                        );
                      }
                      if (snapshot.hasData) {
                        comment.text.isEmpty ? comment.text = snapshot.data!.comment.toString() : null;
                        ratings = snapshot.data!.rating;
                        return Column(
                          children: [
                            Card(
                                color: isDarkMode(context) ? const Color(0xff35363A) : const Color(0XFFFDFEFE),
                                elevation: 1,
                                margin: const EdgeInsets.only(right: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                child: SizedBox(
                                    height: 150,
                                    child: Column(children: [
                                      Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.only(top: 15),
                                          child: Text(
                                            "Rate For".tr(),
                                            style: const TextStyle(color: Color(0XFF7C848E), fontSize: 17),
                                          )),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      RatingBar.builder(
                                        initialRating: snapshot.data!.rating ?? 0.0,
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemPadding: const EdgeInsets.symmetric(horizontal: 6.0),
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: Color(COLOR_PRIMARY),
                                        ),
                                        onRatingUpdate: (double rate) {
                                          ratings = rate;
                                          // print(ratings);
                                        },
                                      ),
                                    ]))),

                            // SizedBox(height: 20,),
                            Card(
                                color: isDarkMode(context) ? const Color(0xff35363A) : const Color(0XFFFDFEFE),
                                elevation: 1,
                                margin: const EdgeInsets.only(top: 10, right: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                child: Container(
                                    height: 140,
                                    padding: const EdgeInsets.only(top: 15, bottom: 15, right: 20, left: 20),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 0.5,
                                            color: const Color(0XFFD1D1E4),
                                          ),
                                          borderRadius: BorderRadius.circular(5)),
                                      constraints: const BoxConstraints(maxHeight: 100),
                                      child: SingleChildScrollView(
                                        child: Container(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: TextFormField(
                                              validator: validateEmptyField,
                                              controller: comment,
                                              textInputAction: TextInputAction.next,
                                              decoration: InputDecoration(
                                                  hintText: 'Type comment....'.tr(), hintStyle: const TextStyle(color: Color(0XFF8A8989)), border: InputBorder.none),
                                              maxLines: null,
                                            )),
                                      ),
                                    ))),
                          ],
                        );
                      }
                      //////add rate
                      return Column(
                        children: [
                          Card(
                              color: isDarkMode(context) ? const Color(0xff35363A) : const Color(0XFFFDFEFE),
                              elevation: 1,
                              margin: const EdgeInsets.only(right: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: SizedBox(
                                  height: 150,
                                  child: Column(children: [
                                    Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.only(top: 15),
                                        child: Text(
                                          "Rate For Driver".tr(),
                                          style: const TextStyle(color: Color(0XFF7C848E), fontSize: 17),
                                        )),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    RatingBar.builder(
                                      initialRating: 0,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemPadding: const EdgeInsets.symmetric(horizontal: 6.0),
                                      itemBuilder: (context, _) => Icon(
                                        Icons.star,
                                        color: Color(COLOR_PRIMARY),
                                      ),
                                      onRatingUpdate: (double rate) {
                                        ratings = rate;
                                        print(ratings);
                                      },
                                    ),
                                  ]))),

                          // SizedBox(height: 20,),
                          Card(
                              color: isDarkMode(context) ? const Color(0xff35363A) : const Color(0XFFFDFEFE),
                              elevation: 1,
                              margin: const EdgeInsets.only(top: 10, right: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: Container(
                                  height: 170,
                                  padding: const EdgeInsets.only(top: 15, bottom: 15, right: 20, left: 20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 0.5,
                                          color: const Color(0XFFD1D1E4),
                                        ),
                                        borderRadius: BorderRadius.circular(5)),
                                    constraints: const BoxConstraints(maxHeight: 100),
                                    child: SingleChildScrollView(
                                      child: Container(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: TextField(
                                            controller: comment,
                                            textInputAction: TextInputAction.send,
                                            decoration:
                                                InputDecoration(hintText: 'Type comment....'.tr(), hintStyle: const TextStyle(color: Color(0XFF8A8989)), border: InputBorder.none),
                                            maxLines: null,
                                          )),
                                    ),
                                  ))),
                        ],
                      );
                    }),
              ))),
      bottomNavigationBar: FutureBuilder<RatingModel?>(
          future: ratingproduct,
          // initialData: ratingModel,
          builder: (BuildContext context, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    backgroundColor: Color(COLOR_PRIMARY),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    await showProgress(context, 'Updating data to database...'.tr(), false);
                    //  if(_mediaFiles is File){

                    User? user = widget.order.driver;
                    if (user != null) {
                      user.reviewsCount = futureCount + 1;
                      user.reviewsSum = futureSum + ratings;
                    }

                    RatingModel ratingproduct = RatingModel(
                      comment: comment.text,
                      photos: [],
                      rating: ratings,
                      customerId: snapshot.data!.customerId,
                      id: snapshot.data!.id,
                      orderId: snapshot.data!.orderId,
                      vendorId: snapshot.data!.vendorId,
                      driverId: snapshot.data!.driverId,
                      uname: MyAppState.currentUser!.firstName + MyAppState.currentUser!.lastName,
                      profile: MyAppState.currentUser!.profilePictureURL,
                      createdAt: Timestamp.now(),
                    );
                    await FireStoreUtils.updateReviewbyId(ratingproduct);
                    await updateProgress("Review Update Successful".tr());
                    await hideProgress();
                    await FireStoreUtils.updateReviewbyId(ratingproduct);
                    await hideProgress();
                    Navigator.pop(context);
                  },
                  child: Text(
                    "UPDATE REVIEW".tr(),
                    style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontSize: 17),
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  backgroundColor: Color(COLOR_PRIMARY),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  savereview();
                },
                child: Text(
                  "SUBMIT REVIEW".tr(),
                  style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontSize: 17),
                ),
              ),
            );
          }),
      //
    );
  }

  savereview() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      await showProgress(context, "Saving data to database...", false);
      User? user = widget.order.driver;
      if (user != null) {
        user.reviewsCount = futureCount + 1;
        user.reviewsSum = futureSum + ratings;
      }

      //  widget.order.products.first.
      DocumentReference documentReference = firestore.collection(Order_Rating).doc();
      print(documentReference.id);
      print(ratings);
      RatingModel rate = RatingModel(
        id: documentReference.id,
        comment: comment.text,
        photos: [],
        rating: ratings,
        orderId: widget.order.id,
        vendorId: "",
        driverId: widget.order.driverID.toString(),
        customerId: MyAppState.currentUser!.userID,
        uname: MyAppState.currentUser!.firstName + " " + MyAppState.currentUser!.lastName,
        profile: MyAppState.currentUser!.profilePictureURL,
        createdAt: Timestamp.now(),
      );
      await FireStoreUtils.updateReviewbyId(rate);

      await hideProgress();
      Navigator.pop(context);
    }
  }

  showAlertDialog(BuildContext context, String title, String content, bool addOkButton) {
    // set up the AlertDialog
    Widget? okButton;
    if (addOkButton) {
      okButton = TextButton(
        child: const Text("OK").tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      );
    }

    if (Platform.isIOS) {
      CupertinoAlertDialog alert = CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [if (okButton != null) okButton],
      );
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return alert;
          });
    } else {
      AlertDialog alert = AlertDialog(title: Text(title), content: Text(content), actions: [if (okButton != null) okButton]);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }
  }

  updatevendor() {
    return photofuture.then((value) {
      if (ratingModel != null) {
        futureCount = value!.reviewsCount - 1;
        futureSum = value.reviewsSum - num.parse(ratingModel!.rating.toString());
      } else {
        futureCount = value!.reviewsCount;
        futureSum = value.reviewsSum;
      }

      print("total  $futureCount after tsum $futureSum is null ${(ratingModel != null)}");
      //  print(data +data2);
    });
  }
}
