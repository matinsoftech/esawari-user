import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/Ratingmodel.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/onDemand_service/onDemand_model/onprovider_order_model.dart';
import 'package:emartconsumer/onDemand_service/onDemand_model/provider_serivce_model.dart';
import 'package:emartconsumer/onDemand_service/onDemand_model/worker_model.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class OnDemandReviewScreen extends StatefulWidget {
  final OnProviderOrderModel order;
  final String reviewFor;

  const OnDemandReviewScreen({Key? key, required this.order, required this.reviewFor}) : super(key: key);

  @override
  _OnDemandReviewScreenState createState() => _OnDemandReviewScreenState();
}

class _OnDemandReviewScreenState extends State<OnDemandReviewScreen> with TickerProviderStateMixin {
  RatingModel? ratingModel;
  final _formKey = GlobalKey<FormState>();
  FireStoreUtils fireStoreUtils = FireStoreUtils();
  final comment = TextEditingController();
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  double? ratings = 0.0;
  var providerReviewCount, providerReviewSum;
  var serviceReviewCount, serviceReviewSum;
  var workerReviewCount, workerReviewSum;

  User? provider;

  ProviderServiceModel? providerServiceModel;
  WorkerModel? workerModel;

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
    if (widget.reviewFor == "Provider") {
      await fireStoreUtils.getReviewsbyProviderID(widget.order.id, widget.order.provider.author.toString()).then((value) {
        if (value != null) {
          setState(() {
            ratingModel = value;
            ratings = value.rating;
            comment.text = value.comment.toString();
          });
        }
      });
    } else {
      await fireStoreUtils.getReviewsbyWorkerID(widget.order.id, widget.order.workerId.toString()).then((value) {
        if (value != null) {
          setState(() {
            ratingModel = value;
            ratings = value.rating;
            comment.text = value.comment.toString();
          });
        }
      });
    }
    //Worker
    if (widget.reviewFor == "Worker") {
      await FireStoreUtils.getWorker(widget.order.workerId.toString())!.then((value) {
        workerModel = value;
        if (value != null) {
          if (ratingModel != null) {
            workerReviewCount = value.reviewsCount! - 1;
            workerReviewSum = value.reviewsSum! - num.parse(ratingModel!.rating.toString());
          } else {
            workerReviewCount = value.reviewsCount;
            workerReviewSum = value.reviewsSum;
          }
          setState(() {});
        }
      });
    } else {
      await FireStoreUtils.getCurrentUser(widget.order.provider.author.toString()).then((value) {
        provider = value;
        if (value != null) {
          if (ratingModel != null) {
            providerReviewCount = value.reviewsCount - 1;
            providerReviewSum = value.reviewsSum - num.parse(ratingModel!.rating.toString());
          } else {
            providerReviewCount = value.reviewsCount;
            providerReviewSum = value.reviewsSum;
          }
          setState(() {});
        }
      });
      await FireStoreUtils.getCurrentProvider(widget.order.provider.id.toString()).then((value) {
        providerServiceModel = value;
        if (ratingModel != null) {
          serviceReviewCount = value!.reviewsCount ?? 0 - 1;
          serviceReviewSum = value.reviewsSum ?? 0 - num.parse(ratingModel!.rating.toString());
        } else {
          serviceReviewCount = value!.reviewsCount;
          serviceReviewSum = value.reviewsSum;
        }
      });
    }
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
          child: Icon(
            Icons.arrow_back_ios,
            color: isDarkMode(context) ? Colors.white : Colors.black,
          ),
        ),
        title: Text(ratingModel != null ? "Update Review".tr() : "Add Review".tr(), style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black)).tr(),
      ),
      body: Form(
          key: _formKey,
          child: (widget.reviewFor == "Worker" && workerModel == null)
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : (widget.reviewFor == "Provider" && provider == null)
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: Colors.white,
                    ))
                  : Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Stack(
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
                                        children: [
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
                                              widget.reviewFor == "Provider" ? "${widget.order.provider.authorName}" : "${workerModel!.fullName()}",
                                              style:
                                                  TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.bold, letterSpacing: 2),
                                            ),
                                          ),
                                        ],
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
                                            style: TextStyle(color: Colors.black),
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
                                            if (widget.reviewFor == "Provider") {
                                              //Provider review
                                              reviewSubmit();
                                            } else {
                                              //   Worker review
                                              workerReviewSubmit();
                                            }
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
                                            style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontSize: 16),
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
                                    imageUrl: widget.reviewFor == "Provider" ? widget.order.provider.authorProfilePic.toString() : workerModel!.profilePictureURL.toString(),
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
                      ),
                    )),
      //
    );
  }

  reviewSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      if (ratingModel != null) {
        print("Update data");
        await showProgress(context, 'Updating data to database...'.tr(), false);

        providerServiceModel!.reviewsCount = serviceReviewCount + 1;
        providerServiceModel!.reviewsSum = serviceReviewSum + ratings;

        provider!.reviewsCount = providerReviewCount + 1;
        provider!.reviewsSum = providerReviewSum + ratings;

        RatingModel ratingProduct = RatingModel(
          productId: ratingModel!.productId,
          comment: comment.text,
          photos: [],
          rating: ratings,
          customerId: ratingModel!.customerId,
          id: ratingModel!.id,
          orderId: ratingModel!.orderId,
          vendorId: ratingModel!.vendorId!,
          createdAt: Timestamp.now(),
          uname: MyAppState.currentUser!.firstName + MyAppState.currentUser!.lastName,
          profile: MyAppState.currentUser!.profilePictureURL,
        );

        await FireStoreUtils.updateReviewbyId(ratingProduct);

        await FireStoreUtils.updateCurrentUser(provider!);
        await FireStoreUtils.updateProvider(providerServiceModel!);

        await hideProgress();
        Navigator.pop(context);
      } else {
        print("Submit data");
        await showProgress(context, 'Saving data to database...'.tr(), false);

        providerServiceModel!.reviewsCount = serviceReviewCount + 1;
        providerServiceModel!.reviewsSum = serviceReviewSum + ratings;

        provider!.reviewsCount = providerReviewCount + 1;
        provider!.reviewsSum = providerReviewSum + ratings;

        DocumentReference documentReference = firestore.collection(Order_Rating).doc();
        RatingModel rate = RatingModel(
          id: documentReference.id,
          productId: widget.order.provider.id,
          comment: comment.text,
          photos: [],
          rating: ratings,
          orderId: widget.order.id,
          vendorId: widget.order.provider.author.toString(),
          customerId: MyAppState.currentUser!.userID,
          uname: MyAppState.currentUser!.firstName + MyAppState.currentUser!.lastName,
          profile: MyAppState.currentUser!.profilePictureURL,
          createdAt: Timestamp.now(),
        );
        await FireStoreUtils.updateReviewbyId(rate);
        await FireStoreUtils.updateCurrentUser(provider!);
        await FireStoreUtils.updateProvider(providerServiceModel!);
        await hideProgress();
        Navigator.pop(context);
      }
    }
  }

  workerReviewSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      if (ratingModel != null) {
        print("Update data");
        await showProgress(context, 'Updating data to database...'.tr(), false);

        workerModel!.reviewsCount = workerReviewCount + 1;
        workerModel!.reviewsSum = workerReviewSum + ratings;

        RatingModel ratingProduct = RatingModel(
          productId: ratingModel!.productId,
          comment: comment.text,
          photos: [],
          rating: ratings,
          customerId: ratingModel!.customerId,
          id: ratingModel!.id,
          orderId: ratingModel!.orderId,
          driverId: ratingModel!.driverId!,
          createdAt: Timestamp.now(),
          uname: MyAppState.currentUser!.firstName + MyAppState.currentUser!.lastName,
          profile: MyAppState.currentUser!.profilePictureURL,
        );
        await FireStoreUtils.updateReviewbyId(ratingProduct);
        await FireStoreUtils.updateWorker(workerModel!);

        await hideProgress();
        Navigator.pop(context);
      } else {
        print("Submit data");
        await showProgress(context, 'Saving data to database...'.tr(), false);

        workerModel!.reviewsCount = workerReviewCount + 1;
        workerModel!.reviewsSum = workerReviewSum + ratings;

        DocumentReference documentReference = firestore.collection(Order_Rating).doc();
        RatingModel rate = RatingModel(
          id: documentReference.id,
          productId: widget.order.provider.id,
          comment: comment.text,
          photos: [],
          rating: ratings,
          orderId: widget.order.id,
          driverId: widget.order.workerId.toString(),
          customerId: MyAppState.currentUser!.userID,
          uname: MyAppState.currentUser!.firstName + MyAppState.currentUser!.lastName,
          profile: MyAppState.currentUser!.profilePictureURL,
          createdAt: Timestamp.now(),
        );
        await FireStoreUtils.updateReviewbyId(rate);
        var error = await FireStoreUtils.updateWorker(workerModel!);
        await hideProgress();
        Navigator.pop(context);
      }
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
}
