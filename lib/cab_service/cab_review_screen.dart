import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/CabOrderModel.dart';
import 'package:emartconsumer/model/Ratingmodel.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/widget/my_separator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CabReviewScreen extends StatefulWidget {
  final CabOrderModel order;

  const CabReviewScreen({Key? key, required this.order}) : super(key: key);

  @override
  _CabReviewScreenState createState() => _CabReviewScreenState();
}

class _CabReviewScreenState extends State<CabReviewScreen> with TickerProviderStateMixin {
  RatingModel? ratingModel;
  final _formKey = GlobalKey<FormState>();
  FireStoreUtils fireStoreUtils = FireStoreUtils();
  final comment = TextEditingController();
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  double? ratings = 0.0;
  var futureCount, futureSum;

  User? driverUser;

  // RatingModel? rating;
  @override
  void dispose() {
    comment.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getReview();
  }

  getReview() async {
    print(widget.order.id);
    await fireStoreUtils.getReviewsbyID(widget.order.id).then((value) {
      if (value != null) {
        setState(() {
          ratingModel = value;
          ratings = value.rating;
          comment.text = value.comment.toString();
        });
      }
    });

    await FireStoreUtils.getCurrentUser(widget.order.driverID.toString()).then((value) {
      driverUser = value;
      if (value != null) {
        if (ratingModel != null) {
          futureCount = value.reviewsCount - 1;
          futureSum = value.reviewsSum - num.parse(ratingModel!.rating.toString());
        } else {
          futureCount = value.reviewsCount;
          futureSum = value.reviewsSum;
        }
        setState(() {});
      }
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(COLOR_PRIMARY),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: Text(ratingModel != null ? "Update Review".tr() : "Add Review".tr(), style: const TextStyle(color: Colors.white)).tr(),
      ),
      body: Form(
          key: _formKey,
          child: driverUser == null
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Colors.white,
                ))
              : Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 42, bottom: 20),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 65),
                            child: Column(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text("${widget.order.driver!.firstName} ${widget.order.driver!.lastName}",
                                          style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black87, fontWeight: FontWeight.w600, fontSize: 18)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                                      child: RatingBar.builder(
                                        initialRating: driverUser!.reviewsCount != 0 ? (driverUser!.reviewsSum / driverUser!.reviewsCount) : 0.0,
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemSize: 22,
                                        tapOnlyMode: false,
                                        updateOnDrag: false,
                                        ignoreGestures: true,
                                        itemBuilder: (context, _) => const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        onRatingUpdate: (double value) {},
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(driverUser!.carNumber.toUpperCase().toString(),
                                        style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text("${driverUser!.carName} ${driverUser!.carMakes}",
                                          style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black38, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: MySeparator(color: Colors.grey),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Text(
                                    'How is your trip?'.tr(),
                                    style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.bold, letterSpacing: 2),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Your feedback  will help us improve \n driving experience better'.tr(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black.withOpacity(0.60), letterSpacing: 0.8),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Text(
                                    'Rate for'.tr(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black.withOpacity(0.60), letterSpacing: 0.8),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    "${widget.order.driver!.firstName} ${widget.order.driver!.lastName}",
                                    style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.bold, letterSpacing: 2),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: RatingBar.builder(
                                    initialRating: ratings ?? 0.0,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {
                                      ratings = rating;
                                    },
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
                                    child: TextFormField(
                                      controller: comment,
                                      textInputAction: TextInputAction.send,
                                      style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black.withOpacity(0.60)),
                                      decoration: InputDecoration(
                                          counterText: "",
                                          contentPadding: const EdgeInsets.all(8),
                                          fillColor: Colors.white,
                                          filled: true,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 0.7),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 0.7),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 0.7),
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 0.7),
                                          ),
                                          hintText: "Type comment....".tr(),
                                          hintStyle: TextStyle(color: Colors.black.withOpacity(0.60))),
                                      maxLines: 5,
                                    )),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
                                  child: MaterialButton(
                                    onPressed: () {
                                      savereview();
                                    },
                                    height: 42,
                                    minWidth: MediaQuery.of(context).size.width,
                                    elevation: 0.5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    color: Color(COLOR_PRIMARY),
                                    child: Text(
                                      ratingModel != null ? "Update Review".tr() : "Add Review".tr(),
                                      style: TextStyle(color: isDarkMode(context) ? Colors.black : Colors.white, fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              blurRadius: 8,
                              spreadRadius: 6,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: CachedNetworkImage(
                              imageUrl: driverUser!.profilePictureURL,
                              height: 110,
                              width: 110,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.network(
                                    placeholderImage,
                                    fit: BoxFit.cover,
                                    height: 110,
                                    width: 110,
                                  ))),
                        ),
                      ),
                    ),
                  ],
                )
          // : Column(
          //     children: [
          //       Card(
          //           color: isDarkMode(context) ? const Color(0xff35363A) : const Color(0XFFFDFEFE),
          //           elevation: 1,
          //           margin: const EdgeInsets.only(right: 15),
          //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          //           child: SizedBox(
          //               height: 150,
          //               child: Column(children: [
          //                 Container(
          //                     alignment: Alignment.center,
          //                     padding: const EdgeInsets.only(top: 15),
          //                     child: Text(
          //                       "Rate For Driver".tr(),
          //                       style: const TextStyle(color: Color(0XFF7C848E), fontSize: 17),
          //                     )),
          //                 const SizedBox(
          //                   height: 15,
          //                 ),
          //                 RatingBar.builder(
          //                   initialRating: 0,
          //                   minRating: 1,
          //                   direction: Axis.horizontal,
          //                   allowHalfRating: true,
          //                   itemCount: 5,
          //                   itemPadding: const EdgeInsets.symmetric(horizontal: 6.0),
          //                   itemBuilder: (context, _) => Icon(
          //                     Icons.star,
          //                     color: Color(COLOR_PRIMARY),
          //                   ),
          //                   onRatingUpdate: (double rate) {
          //                     ratings = rate;
          //                     print(ratings);
          //                   },
          //                 ),
          //               ]))),
          //       Card(
          //           color: isDarkMode(context) ? const Color(0xff35363A) : const Color(0XFFFDFEFE),
          //           elevation: 1,
          //           margin: const EdgeInsets.only(top: 10, right: 15),
          //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          //           child: Container(
          //               height: 170,
          //               padding: const EdgeInsets.only(top: 15, bottom: 15, right: 20, left: 20),
          //               child: Container(
          //                 decoration: BoxDecoration(
          //                     border: Border.all(
          //                       width: 0.5,
          //                       color: const Color(0XFFD1D1E4),
          //                     ),
          //                     borderRadius: BorderRadius.circular(5)),
          //                 constraints: const BoxConstraints(maxHeight: 100),
          //                 child: SingleChildScrollView(
          //                   child: Container(
          //                       padding: const EdgeInsets.only(left: 10),
          //                       child: TextField(
          //                         controller: comment,
          //                         textInputAction: TextInputAction.send,
          //                         decoration: InputDecoration(
          //                             hintText: 'Type comment....'.tr(),
          //                             hintStyle: const TextStyle(color: const Color(0XFF8A8989)),
          //                             border: InputBorder.none),
          //                         maxLines: null,
          //                       )),
          //                 ),
          //               ))),
          //     ],
          //   )
          ),
      // bottomNavigationBar: ratingModel != null
      //     ? Padding(
      //         padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25),
      //         child: ElevatedButton(
      //           style: ElevatedButton.styleFrom(
      //             padding: const EdgeInsets.all(12),
      //             backgroundColor: Color(COLOR_PRIMARY),
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(8),
      //             ),
      //           ),
      //           onPressed: () async {
      //             await showProgress(context, 'Updating data to database...'.tr(), false);
      //             //  if(_mediaFiles is File){
      //
      //             User? user = await FireStoreUtils.getCurrentUser(widget.order.driverID.toString());
      //             if (user != null) {
      //               user.reviewsCount = futureCount + 1;
      //               user.reviewsSum = futureSum + ratings;
      //             }
      //
      //             RatingModel ratingproduct = RatingModel(
      //               comment: comment.text,
      //               photos: [],
      //               rating: ratings,
      //               customerId: ratingModel!.customerId,
      //               id: ratingModel!.id,
      //               orderId: ratingModel!.orderId,
      //               vendorId: ratingModel!.vendorId,
      //               driverId: ratingModel!.driverId,
      //               createdAt: Timestamp.now(),
      //               uname: MyAppState.currentUser!.firstName + MyAppState.currentUser!.lastName,
      //               profile: MyAppState.currentUser!.profilePictureURL,
      //             );
      //             await FireStoreUtils.updateReviewbyId(ratingproduct);
      //             await updateProgress("Review Update Successful".tr());
      //             await hideProgress();
      //             String? errorMessage = await FireStoreUtils.firebaseCreateNewReview(ratingproduct);
      //
      //             var error = await FireStoreUtils.updateCurrentUser(user!);
      //             if (errorMessage == null && error != null) {
      //               await hideProgress();
      //               Navigator.pop(context);
      //             } else {}
      //           },
      //           child: Text(
      //             'UPDATE REVIEW'.tr(),
      //             style: TextStyle( color: isDarkMode(context) ? Colors.white : Colors.black, fontSize: 17),
      //           ),
      //         ),
      //       )
      //     : Container(),
      //
    );
  }

  savereview() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      //  widget.order.products.first.
      if (ratingModel != null) {
        await showProgress(context, 'Updating data to database...'.tr(), false);
        //  if(_mediaFiles is File){

        User? user = await FireStoreUtils.getCurrentUser(widget.order.driverID.toString());
        if (user != null) {
          user.reviewsCount = futureCount + 1;
          user.reviewsSum = futureSum + ratings;
        }

        RatingModel ratingproduct = RatingModel(
          comment: comment.text,
          photos: [],
          rating: ratings,
          customerId: ratingModel!.customerId,
          id: ratingModel!.id,
          orderId: ratingModel!.orderId,
          vendorId: ratingModel!.vendorId,
          driverId: ratingModel!.driverId,
          createdAt: Timestamp.now(),
          uname: MyAppState.currentUser!.firstName + MyAppState.currentUser!.lastName,
          profile: MyAppState.currentUser!.profilePictureURL,
        );
        await FireStoreUtils.updateReviewbyId(ratingproduct).then((value) async {
          await hideProgress();
          Navigator.pop(context);
        });
        await FireStoreUtils.updateCurrentUser(user!);
      } else {
        await showProgress(context, 'Saving data to database...'.tr(), false);
        User? user = await FireStoreUtils.getCurrentUser(widget.order.driverID.toString());
        if (user != null) {
          user.reviewsCount = futureCount + 1;
          user.reviewsSum = futureSum + ratings;
        }
        DocumentReference documentReference = firestore.collection(Order_Rating).doc();
        RatingModel rate = RatingModel(
          id: documentReference.id,
          comment: comment.text,
          photos: [],
          rating: ratings,
          orderId: widget.order.id,
          driverId: widget.order.driverID.toString(),
          customerId: MyAppState.currentUser!.userID,
          uname: MyAppState.currentUser!.firstName + MyAppState.currentUser!.lastName,
          profile: MyAppState.currentUser!.profilePictureURL,
          createdAt: Timestamp.now(),
        );
        await FireStoreUtils.updateReviewbyId(rate).then((value) async {
          await hideProgress();
          Navigator.pop(context);
        });
        await FireStoreUtils.updateCurrentUser(user!);
      }
    }
  }

  showAlertDialog(BuildContext context, String title, String content, bool addOkButton) {
    // set up the AlertDialog
    Widget? okButton;
    if (addOkButton) {
      okButton = TextButton(
        child: const Text('OK').tr(),
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
}
