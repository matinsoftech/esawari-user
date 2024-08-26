import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/AppGlobal.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/FavouriteModel.dart';
import 'package:emartconsumer/model/VendorModel.dart';
import 'package:emartconsumer/model/offer_model.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/ui/auth/AuthScreen.dart';
import 'package:emartconsumer/ui/vendorProductsScreen/NewVendorProductsScreen.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

class ViewAllRestaurant extends StatefulWidget {
  const ViewAllRestaurant({Key? key}) : super(key: key);

  @override
  State<ViewAllRestaurant> createState() => _ViewAllRestaurantState();
}

class _ViewAllRestaurantState extends State<ViewAllRestaurant> {
  List<VendorModel> vendors = [];

  bool isLoading = true;
  List<OfferModel> offerList = [];

  getProducts() async {
    setState(() {
      isLoading = true;
    });
    var collectionReference = FireStoreUtils.firestore.collection(VENDORS).where("section_id", isEqualTo: sectionConstantModel!.id);

    GeoFirePoint center = GeoFlutterFire().point(latitude: MyAppState.selectedPosotion.location!.latitude, longitude: MyAppState.selectedPosotion.location!.longitude);
    String field = 'g';

    Stream<List<DocumentSnapshot>> stream = GeoFlutterFire().collection(collectionRef: collectionReference).within(center: center, radius: double.parse(sectionConstantModel!.nearByRadius.toString()), field: field, strictMode: true);
    stream.listen((documentList) {
      for (var document in documentList) {
        final data = document.data() as Map<String, dynamic>;
        setState(() {
          vendors.add(VendorModel.fromJson(data));
        });
      }
    });
    await FireStoreUtils().getPublicCoupons().then((value) {
      setState(() {
        offerList = value;
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  late Future<List<FavouriteModel>> lstFavourites;

  getData() {
    if (MyAppState.currentUser != null) {
      lstFavourites = FireStoreUtils().getFavouriteStore(MyAppState.currentUser!.userID);
      lstFavourites.then((event) {
        lstFav.clear();
        for (int a = 0; a < event.length; a++) {
          lstFav.add(event[a].store_id!);
        }
      });
    }
  }

  List<String> lstFav = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppGlobal.buildAppBar(context, "All Stores".tr()),
      body: Column(
        children: [
          Expanded(
            child: vendors.isEmpty
                ? Center(
                    child: const Text('No Data...').tr(),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: vendors.length,
                    itemBuilder: (context, index) =>
                        //buildVendorItem(vendors[index])

                        buildAllRestaurantsData(vendors[index]),
                  ),
          ),
          isLoading ? const CircularProgressIndicator() : Container()
        ],
      ),
    );
  }

  Widget buildAllRestaurantsData(VendorModel vendorModel) {
    // checkMemory();
    List<OfferModel> tempList = [];
    List<double> discountAmountTempList = [];
    offerList.forEach((element) {
      print("---------->${vendorModel.id} || ${element.storeId} || ${vendorModel.id == element.storeId}");
      print("---------->${element.expireOfferDate!.toDate()} || ${DateTime.now()}");
      if (vendorModel.id == element.storeId && element.expireOfferDate!.toDate().isAfter(DateTime.now())) {
        tempList.add(element);
        discountAmountTempList.add(double.parse(element.discountOffer.toString()));
        print("---------->${discountAmountTempList.length}");
      }
    });
    return GestureDetector(
      onTap: () => push(
        context,
        NewVendorProductsScreen(vendorModel: vendorModel),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
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
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: getImageVAlidUrl(vendorModel.photo),
                      height: 100,
                      width: 100,
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
                            cacheHeight: 100,
                            cacheWidth: 100,
                          )),
                      fit: BoxFit.cover,
                    ),
                    if (discountAmountTempList.isNotEmpty)
                      Positioned(
                        bottom: -6,
                        left: -1,
                        child: Container(
                          decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/offer_badge.png'))),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              discountAmountTempList.reduce(min).toStringAsFixed(currencyData!.decimal) + "% off",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              vendorModel.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode(context) ? Colors.white : Colors.black,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (MyAppState.currentUser == null) {
                                push(context, const AuthScreen());
                              } else {
                                setState(() {
                                  if (lstFav.contains(vendorModel.id) == true) {
                                    FavouriteModel favouriteModel = FavouriteModel(section_id: sectionConstantModel!.id, store_id: vendorModel.id, user_id: MyAppState.currentUser!.userID);
                                    lstFav.removeWhere((item) => item == vendorModel.id);
                                    FireStoreUtils().removeFavouriteStore(favouriteModel);
                                  } else {
                                    FavouriteModel favouriteModel = FavouriteModel(section_id: sectionConstantModel!.id, store_id: vendorModel.id, user_id: MyAppState.currentUser!.userID);
                                    FireStoreUtils().setFavouriteStore(favouriteModel);
                                    lstFav.add(vendorModel.id);
                                  }
                                });
                              }
                            },
                            child: lstFav.contains(vendorModel.id) == true
                                ? Icon(
                                    Icons.favorite,
                                    color: Color(COLOR_PRIMARY),
                                  )
                                : Icon(
                                    Icons.favorite_border,
                                    color: isDarkMode(context) ? Colors.white38 : Colors.black38,
                                  ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      // Text("Min".tr() + " ${discountAmountTempList.isNotEmpty ? discountAmountTempList.reduce(min).toStringAsFixed(0) : 0}% " + "off".tr(),
                      //     maxLines: 1,
                      //     style: TextStyle(
                      //
                      //       letterSpacing: 0.5,
                      //       color: isDarkMode(context) ? Colors.white60 : const Color(0xff555353),
                      //     )),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_pin,
                            size: 20,
                            color: Color(COLOR_PRIMARY),
                          ),
                          Expanded(
                            child: Text(
                              vendorModel.location,
                              maxLines: 1,
                              style: TextStyle(
                                color: isDarkMode(context) ? Colors.white70 : const Color(0xff9091A4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 20,
                            color: Color(COLOR_PRIMARY),
                          ),
                          const SizedBox(width: 3),
                          Text(vendorModel.reviewsCount != 0 ? (vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1) : 0.toString(),
                              style: TextStyle(
                                letterSpacing: 0.5,
                                color: isDarkMode(context) ? Colors.white : const Color(0xff000000),
                              )),
                          const SizedBox(width: 3),
                          Text('(${vendorModel.reviewsCount.toStringAsFixed(1)})',
                              style: TextStyle(
                                letterSpacing: 0.5,
                                color: isDarkMode(context) ? Colors.white60 : const Color(0xff666666),
                              )),
                          const SizedBox(width: 5),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    getRadius();
    getData();
  }

  getRadius() async {
    getProducts();
  }
}
