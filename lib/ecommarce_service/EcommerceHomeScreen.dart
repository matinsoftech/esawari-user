import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/ecommarce_service/view_all_category_product_screen.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/AddressModel.dart';
import 'package:emartconsumer/model/BannerModel.dart';
import 'package:emartconsumer/model/BrandsModel.dart';
import 'package:emartconsumer/model/FavouriteModel.dart';
import 'package:emartconsumer/model/ProductModel.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/model/VendorCategoryModel.dart';
import 'package:emartconsumer/model/VendorModel.dart';
import 'package:emartconsumer/model/offer_model.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/ui/cuisinesScreen/CuisinesScreen.dart';
import 'package:emartconsumer/ui/home/view_all_new_arrival_store_screen.dart';
import 'package:emartconsumer/ui/home/view_all_popular_store_screen.dart';
import 'package:emartconsumer/ui/home/view_all_restaurant.dart';
import 'package:emartconsumer/ui/productDetailsScreen/ProductDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ui/vendorProductsScreen/newVendorProductsScreen.dart';
import 'view_all_brand_product_screen.dart';

class EcommerceHomeScreen extends StatefulWidget {
  final User? user;
  final String vendorId;

  EcommerceHomeScreen({
    Key? key,
    required this.user,
    vendorId,
  })  : vendorId = vendorId ?? "",
        super(key: key);

  @override
  _EcommerceHomeScreenState createState() => _EcommerceHomeScreenState();
}

class _EcommerceHomeScreenState extends State<EcommerceHomeScreen> {
  final fireStoreUtils = FireStoreUtils();
  late Future<List<VendorCategoryModel>>? cuisinesFuture;

  late Future<List<ProductModel>> productsFuture;
  final PageController _controller = PageController(viewportFraction: 0.8, keepPage: true);
  List<VendorModel> vendors = [];
  List<VendorModel> popularRestaurantLst = [];
  List<VendorModel> newArrivalLst = [];
  VendorModel? popularNearFoodVendorModel;
  Stream<List<VendorModel>>? lstNewArrivalRestaurant;
  Stream<List<VendorModel>>? lstAllRestaurant;
  bool showLoader = true;

  late Future<List<FavouriteModel>> lstFavourites;
  List<String> lstFav = [];

  String? name = "";

  String? currentLocation = "";

  String? selctedOrderTypeValue = "Delivery".tr();

  loc.Location location = loc.Location();

  bool isLoading = true;

  getLocationData() async {
    AddressModel addressModel = AddressModel();
    await getCurrentLocation().then((value) async {
      await placemarkFromCoordinates(value.latitude, value.longitude).then((valuePlaceMaker) {
        Placemark placeMark = valuePlaceMaker[0];

        setState(() {
          addressModel.location = UserLocation(latitude: value.latitude, longitude: value.longitude);
          currentLocation = "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.postalCode}, ${placeMark.country}";
          addressModel.locality = currentLocation;
        });
      }).catchError((error) {
        debugPrint("------>${error.toString()}");
      });

      getData();
      setState(() {
        isLoading = false;
      });
    }).onError((error, stackTrace) {
      setState(() {
        isLoading = false;
      });
      getPermission();
    });

    MyAppState.selectedPosotion = addressModel;
    setState(() {
      isLoading = false;
    });
  }

  getPermission() async {
    setState(() {
      isLoading = false;
    });
    loc.PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        getData();
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  // Database db;

  @override
  void initState() {
    super.initState();
    getLocationData();
    cuisinesFuture = fireStoreUtils.getCuisines();
    getBanner();
    saveFoodTypeValue();
    FireStoreUtils().getRazorPayDemo();
    FireStoreUtils.getPaypalSettingData();
    FireStoreUtils.getStripeSettingData();
    FireStoreUtils.getPayStackSettingData();
    FireStoreUtils.getFlutterWaveSettingData();
    FireStoreUtils.getPaytmSettingData();
    FireStoreUtils.getWalletSettingData();
    FireStoreUtils.getPayFastSettingData();
    FireStoreUtils.getMercadoPagoSettingData();
    // if (isLocationPermissionAllowed == false) {

    getHomePageCategoryProduct();
    //} else {}
  }

  List<VendorCategoryModel> categoryWiseProductList = [];
  List<BrandsModel> brandModelList = [];
  List<OfferModel> offerList = [];

  getHomePageCategoryProduct() async {
    await fireStoreUtils.getHomePageShowCategory().then((value) {
      setState(() {
        categoryWiseProductList = value;
      });
    });

    await FireStoreUtils.getBrands().then((value) {
      setState(() {
        brandModelList = value;
      });
    });

    await FireStoreUtils().getPublicCoupons().then((value) {
      setState(() {
        offerList = value;
      });
    });
  }

  List<BannerModel> bannerTopHome = [];
  List<BannerModel> bannerMiddleHome = [];

  bool isHomeBannerLoading = true;
  bool isHomeBannerMiddleLoading = true;

  getBanner() async {
    print("-------->");
    await fireStoreUtils.getHomeTopBanner().then((value) {
      setState(() {
        print(value);
        bannerTopHome = value;
        isHomeBannerLoading = false;
      });
    });

    await fireStoreUtils.getHomeMiddleBanner().then((value) {
      setState(() {
        print(value);
        bannerMiddleHome = value;
        isHomeBannerMiddleLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: isDarkMode(context) ? const Color(DARK_BG_COLOR) : const Color(0xffFFFFFF),
        body: isLoading == true
            ? Center(child: CircularProgressIndicator())
            : (MyAppState.selectedPosotion.location!.latitude == 0 && MyAppState.selectedPosotion.location!.longitude == 0)
                ? Center(
                    child: showEmptyState("We don't have your location.".tr(), context, description: "Set your location to started searching for restaurants in your area".tr(),
                        action: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlacePicker(
                            apiKey: GOOGLE_API_KEY,
                            onPlacePicked: (result) {
                              setState(() {
                                AddressModel addressModel = AddressModel();
                                addressModel.location = UserLocation(latitude: result.geometry!.location.lat, longitude: result.geometry!.location.lng);
                                MyAppState.selectedPosotion = addressModel;

                                currentLocation = result.formattedAddress;
                                getData();
                              });

                              Navigator.of(context).pop();
                            },
                            initialPosition: LatLng(-33.8567844, 151.213108),
                            useCurrentLocation: true,
                            selectInitialPosition: true,
                            usePinPointingSearch: true,
                            usePlaceDetailSearch: true,
                            zoomGesturesEnabled: true,
                            zoomControlsEnabled: true,
                            initialMapType: MapType.terrain,
                            resizeToAvoidBottomInset: false, // only works in page mode, less flickery, remove if wrong offsets
                          ),
                        ),
                      );
                    }, buttonTitle: 'Select'.tr()),
                  )
                : SingleChildScrollView(
                    child: Container(
                      color: isDarkMode(context) ? Colors.black : const Color(0xffFFFFFF),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Visibility(
                            visible: bannerTopHome.isNotEmpty,
                            child: Container(
                                color: isDarkMode(context) ? Colors.black : const Color(0xffFFFFFF),
                                padding: const EdgeInsets.only(bottom: 10),
                                child: isHomeBannerLoading
                                    ? const Center(child: CircularProgressIndicator())
                                    : SizedBox(
                                        height: MediaQuery.of(context).size.height * 0.23,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: PageView.builder(
                                              padEnds: false,
                                              itemCount: bannerTopHome.length,
                                              scrollDirection: Axis.horizontal,
                                              controller: _controller,
                                              itemBuilder: (context, index) => buildBestDealPage(bannerTopHome[index])),
                                        ))),
                          ),
                          Container(
                            color: isDarkMode(context) ? Colors.black : const Color(0xffFFFFFF),
                            child: FutureBuilder<List<VendorCategoryModel>>(
                                future: cuisinesFuture,
                                initialData: [],
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator.adaptive(
                                        valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                                      ),
                                    );
                                  }

                                  if (snapshot.hasData) {
                                    return snapshot.data!.isEmpty
                                        ? SizedBox()
                                        : Column(
                                            children: [
                                              buildTitleRow(
                                                titleValue: "Top Categories".tr(),
                                                onClick: () {
                                                  push(
                                                    context,
                                                    const CuisinesScreen(
                                                      isPageCallFromHomeScreen: true,
                                                    ),
                                                  );
                                                },
                                              ),
                                              Container(
                                                  padding: const EdgeInsets.only(left: 10),
                                                  child: GridView.count(
                                                    crossAxisCount: 4,
                                                    crossAxisSpacing: 0,
                                                    mainAxisSpacing: 0,
                                                    shrinkWrap: true,
                                                    padding: EdgeInsets.zero,
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    children:
                                                        List.generate(snapshot.data!.length >= 8 ? 8 : snapshot.data!.length, (index) => buildCategoryItem(snapshot.data![index])),
                                                  )),
                                            ],
                                          );
                                  } else {
                                    return showEmptyState('No Categories'.tr(), context);
                                  }
                                }),
                          ),
                          StreamBuilder<List<VendorModel>>(
                              stream: lstNewArrivalRestaurant,
                              initialData: [],
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator.adaptive(
                                      valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                                    ),
                                  );
                                }

                                if ((snapshot.hasData || (snapshot.data?.isNotEmpty ?? false)) && mounted) {
                                  newArrivalLst = snapshot.data!;

                                  return newArrivalLst.isEmpty
                                      ? Container()
                                      : Column(
                                          children: [
                                            buildTitleRow(
                                              titleValue: "New Arrivals".tr(),
                                              onClick: () {
                                                push(
                                                  context,
                                                  const ViewAllNewArrivalStoreScreen(),
                                                );
                                              },
                                            ),
                                            SizedBox(
                                                height: MediaQuery.of(context).size.height * 0.12,
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                                  child: ListView.builder(
                                                      shrinkWrap: true,
                                                      padding: EdgeInsets.zero,
                                                      scrollDirection: Axis.horizontal,
                                                      physics: const BouncingScrollPhysics(),
                                                      itemCount: newArrivalLst.length >= 15 ? 15 : newArrivalLst.length,
                                                      itemBuilder: (context, index) => buildNewArrivalItem(newArrivalLst[index])),
                                                )),
                                          ],
                                        );
                                } else {
                                  return showEmptyState('No Vendors'.tr(), context);
                                }
                              }),
                          Visibility(
                            visible: popularRestaurantLst.isNotEmpty,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: buildTitleRow(
                                    titleValue: "Popular".tr() + " ${sectionConstantModel!.name} " + "Store".tr(),
                                    onClick: () {
                                      push(
                                        context,
                                        const ViewAllPopularStoreScreen(),
                                      );
                                    },
                                  ),
                                ),
                                popularRestaurantLst.isEmpty
                                    ? showEmptyState('No Popular Store'.tr(), context)
                                    : SizedBox(
                                        width: MediaQuery.of(context).size.width,
                                        height: MediaQuery.of(context).size.height * 0.28,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              padding: EdgeInsets.zero,
                                              physics: const BouncingScrollPhysics(),
                                              itemCount: popularRestaurantLst.length >= 5 ? 5 : popularRestaurantLst.length,
                                              itemBuilder: (context, index) => buildPopularsItem(popularRestaurantLst[index])),
                                        )),
                              ],
                            ),
                          ),
                          buildTitleRow(
                            titleValue: "Brands".tr(),
                            onClick: () {},
                            isViewAll: true,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 130,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: ListView.builder(
                                itemCount: brandModelList.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: GestureDetector(
                                      onTap: () async {
                                        push(context, ViewAllBrandProductScreen(brandModel: brandModelList[index]));
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 40,
                                            child: CachedNetworkImage(
                                              imageUrl: getImageVAlidUrl(brandModelList[index].photo.toString()),
                                              imageBuilder: (context, imageProvider) => Container(
                                                decoration: BoxDecoration(
                                                  color: isDarkMode(context) ? Colors.white : Color(COLOR_PRIMARY),
                                                  borderRadius: BorderRadius.circular(60),
                                                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                ),
                                              ),
                                              placeholder: (context, url) => Center(
                                                  child: CircularProgressIndicator.adaptive(
                                                valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                                              )),
                                              errorWidget: (context, url, error) => ClipRRect(
                                                borderRadius: BorderRadius.circular(60),
                                                child: Image.network(
                                                  placeholderImage,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(brandModelList[index].title.toString(),
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: isDarkMode(context) ? Colors.white : const Color(0xff000000),
                                              )).tr(),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Visibility(
                            visible: bannerMiddleHome.isNotEmpty,
                            child: Container(
                                color: isDarkMode(context) ? Colors.black : const Color(0xffFFFFFF),
                                padding: const EdgeInsets.only(bottom: 10, top: 10),
                                child: isHomeBannerMiddleLoading
                                    ? const Center(child: CircularProgressIndicator())
                                    : SizedBox(
                                        height: MediaQuery.of(context).size.height * 0.23,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: PageView.builder(
                                              padEnds: false,
                                              itemCount: bannerMiddleHome.length,
                                              scrollDirection: Axis.horizontal,
                                              controller: _controller,
                                              itemBuilder: (context, index) => buildBestDealPage(bannerMiddleHome[index])),
                                        ))),
                          ),
                          ListView.builder(
                            itemCount: categoryWiseProductList.length,
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              return FutureBuilder<List<ProductModel>>(
                                future: FireStoreUtils.getProductListByCategoryId(categoryWiseProductList[index].id.toString()),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator.adaptive(
                                        valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                                      ),
                                    );
                                  }
                                  if ((snapshot.hasData || (snapshot.data?.isNotEmpty ?? false)) && mounted) {
                                    return snapshot.data!.isEmpty
                                        ? Container()
                                        : Column(
                                            children: [
                                              buildTitleRow(
                                                titleValue: categoryWiseProductList[index].title.toString(),
                                                onClick: () {
                                                  push(
                                                    context,
                                                    ViewAllCategoryProductScreen(
                                                      vendorCategoryModel: categoryWiseProductList[index],
                                                    ),
                                                  );
                                                },
                                                isViewAll: false,
                                              ),
                                              SizedBox(
                                                  width: MediaQuery.of(context).size.width,
                                                  height: MediaQuery.of(context).size.height * 0.28,
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      scrollDirection: Axis.horizontal,
                                                      physics: const BouncingScrollPhysics(),
                                                      padding: EdgeInsets.zero,
                                                      itemCount: snapshot.data!.length,
                                                      itemBuilder: (context, index) {
                                                        ProductModel productModel = snapshot.data![index];
                                                        return Container(
                                                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                          child: GestureDetector(
                                                            onTap: () async {
                                                              VendorModel? vendorModel = await FireStoreUtils.getVendor(productModel.vendorID);
                                                              if (vendorModel != null) {
                                                                push(
                                                                  context,
                                                                  ProductDetailsScreen(
                                                                    vendorModel: vendorModel,
                                                                    productModel: productModel,
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                            child: SizedBox(
                                                              width: MediaQuery.of(context).size.width * 0.38,
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  border: Border.all(
                                                                      color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
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
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Expanded(
                                                                          child: CachedNetworkImage(
                                                                        imageUrl: getImageVAlidUrl(productModel.photo),
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
                                                                            width: MediaQuery.of(context).size.width * 0.75,
                                                                            fit: BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                        fit: BoxFit.cover,
                                                                      )),
                                                                      const SizedBox(height: 8),
                                                                      Text(productModel.name,
                                                                          maxLines: 1,
                                                                          style: TextStyle(
                                                                            fontSize: 16,
                                                                            fontWeight: FontWeight.w600,
                                                                            color: isDarkMode(context) ? Colors.white : const Color(0xff000000),
                                                                          )).tr(),
                                                                      const SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Container(
                                                                            decoration: BoxDecoration(
                                                                              color: Colors.green,
                                                                              borderRadius: BorderRadius.circular(5),
                                                                            ),
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                                              child: Row(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                  Text(
                                                                                      productModel.reviewsCount != 0
                                                                                          ? (productModel.reviewsSum / productModel.reviewsCount).toStringAsFixed(1)
                                                                                          : 0.toString(),
                                                                                      style: const TextStyle(
                                                                                        letterSpacing: 0.5,
                                                                                        fontSize: 12,
                                                                                        color: Colors.white,
                                                                                      )),
                                                                                  const SizedBox(width: 3),
                                                                                  const Icon(
                                                                                    Icons.star,
                                                                                    size: 16,
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          productModel.disPrice == "" || productModel.disPrice == "0"
                                                                              ? Text(
                                                                                  amountShow(amount: productModel.price),
                                                                                  style: TextStyle(
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontSize: 14,
                                                                                    color: Color(COLOR_PRIMARY),
                                                                                  ),
                                                                                )
                                                                              : Column(
                                                                                  children: [
                                                                                    Text(
                                                                                      "${amountShow(amount: productModel.disPrice)}",
                                                                                      style: TextStyle(
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontSize: 14,
                                                                                        color: Color(COLOR_PRIMARY),
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      '${amountShow(amount: productModel.price)}',
                                                                                      style: const TextStyle(
                                                                                          fontWeight: FontWeight.bold,
                                                                                          fontSize: 12,
                                                                                          color: Colors.grey,
                                                                                          decoration: TextDecoration.lineThrough),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  )),
                                            ],
                                          );
                                  } else {
                                    return showEmptyState('No Categories'.tr(), context);
                                  }
                                },
                              );
                            },
                          ),
                          buildTitleRow(
                            titleValue: "All Store".tr(),
                            onClick: () {},
                            isViewAll: true,
                          ),
                          vendors.isEmpty
                              ? showEmptyState('No Store Found'.tr(), context)
                              : Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      padding: EdgeInsets.zero,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: vendors.length > 15 ? 15 : vendors.length,
                                      itemBuilder: (context, index) {
                                        VendorModel vendorModel = vendors[index];
                                        return buildAllRestaurantsData(vendorModel);
                                      },
                                    ),
                                  ),
                                ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height * 0.06,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(COLOR_PRIMARY),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(
                                        color: Color(COLOR_PRIMARY),
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'See All store around you',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
                                  ).tr(),
                                  onPressed: () {
                                    push(
                                      context,
                                      const ViewAllRestaurant(),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
  }

  Widget buildVendorItemData(
    BuildContext context,
    ProductModel product,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
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
      width: MediaQuery.of(context).size.width * 0.8,
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: getImageVAlidUrl(product.photo),
              height: 100,
              width: 100,
              memCacheHeight: 100,
              memCacheWidth: 100,
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
                  cacheHeight: 100,
                  cacheWidth: 100,
                ),
              ),
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xff000000),
                  ),
                  maxLines: 1,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  product.description,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xff9091A4),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "${amountShow(amount: product.price)}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(COLOR_PRIMARY),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildAllRestaurantsData(VendorModel vendorModel) {
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
                              discountAmountTempList.reduce(min).toStringAsFixed(currencyData!.decimal) + "% off".tr(),
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
                          // GestureDetector(
                          //   onTap: () {
                          //     if (MyAppState.currentUser == null) {
                          //       push(context, const AuthScreen());
                          //     } else {
                          //       setState(() {
                          //         if (lstFav.contains(vendorModel.id) == true) {
                          //           FavouriteModel favouriteModel =
                          //               FavouriteModel(section_id: SELECTED_CATEGORY, store_id: vendorModel.id, user_id: MyAppState.currentUser!.userID);
                          //           lstFav.removeWhere((item) => item == vendorModel.id);
                          //           FireStoreUtils().removeFavouriteStore(favouriteModel);
                          //         } else {
                          //           FavouriteModel favouriteModel =
                          //               FavouriteModel(section_id: SELECTED_CATEGORY, store_id: vendorModel.id, user_id: MyAppState.currentUser!.userID);
                          //           FireStoreUtils().setFavouriteStore(favouriteModel);
                          //           lstFav.add(vendorModel.id);
                          //         }
                          //       });
                          //     }
                          //   },
                          //   child: lstFav.contains(vendorModel.id) == true
                          //       ? Icon(
                          //           Icons.favorite,
                          //           color: Color(COLOR_PRIMARY),
                          //         )
                          //       : Icon(
                          //           Icons.favorite_border,
                          //           color: isDarkMode(context) ? Colors.white38 : Colors.black38,
                          //         ),
                          // )
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
                          Text(vendorModel.reviewsCount != 0 ? '${(vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1)}' : 0.toString(),
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

  buildCategoryItem(VendorCategoryModel model) {
    return GestureDetector(
      onTap: () {
        push(
          context,
          ViewAllCategoryProductScreen(
            vendorCategoryModel: model,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CachedNetworkImage(
            imageUrl: getImageVAlidUrl(model.photo.toString()),
            imageBuilder: (context, imageProvider) => Container(
              height: MediaQuery.of(context).size.height * 0.08,
              width: MediaQuery.of(context).size.width * 0.18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
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
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  )),
                ),
              ),
            ),
            placeholder: (context, url) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.08,
              width: MediaQuery.of(context).size.width * 0.18,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  placeholderImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            errorWidget: (context, url, error) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.08,
              width: MediaQuery.of(context).size.width * 0.18,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    placeholderImage,
                    fit: BoxFit.cover,
                  )),
            ),
          ),
          // displayCircleImage(model.photo, 90, false),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Center(child: Text(model.title.toString(), style: TextStyle(color: isDarkMode(context) ? Colors.white : const Color(0xFF000000), fontSize: 12)).tr()),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose

    // ImageCache _imageCache = PaintingBinding.instance.imageCache;
    // _imageCache.clear();
    // _imageCache.clearLiveImages();

    fireStoreUtils.closeOfferStream();
    fireStoreUtils.closeVendorStream();
    fireStoreUtils.closeNewArrivalStream();
    super.dispose();
  }

  Widget buildBestDealPage(BannerModel categoriesModel) {
    return InkWell(
      onTap: () async {
        if (categoriesModel.redirect_type == "store") {
          VendorModel? vendorModel = await FireStoreUtils.getVendor(categoriesModel.redirect_id.toString());
          push(
            context,
            NewVendorProductsScreen(vendorModel: vendorModel!),
          );
        } else if (categoriesModel.redirect_type == "product") {
          ProductModel? productModel = await fireStoreUtils.getProductByProductID(categoriesModel.redirect_id.toString());
          VendorModel? vendorModel = await FireStoreUtils.getVendor(productModel.vendorID);

          if (vendorModel != null) {
            push(
              context,
              ProductDetailsScreen(
                vendorModel: vendorModel,
                productModel: productModel,
              ),
            );
          }
        } else if (categoriesModel.redirect_type == "external_link") {
          final uri = Uri.parse(categoriesModel.redirect_id.toString());
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            throw 'Could not launch'.tr() + '${categoriesModel.redirect_id.toString()}';
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: CachedNetworkImage(
          imageUrl: getImageVAlidUrl(categoriesModel.photo.toString()),
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          color: Colors.black.withOpacity(0.5),
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
    );
  }

  Widget buildNewArrivalItem(VendorModel vendorModel) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: GestureDetector(
        onTap: () => push(
          context,
          NewVendorProductsScreen(vendorModel: vendorModel),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.70,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
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
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: getImageVAlidUrl(vendorModel.photo),
                    width: MediaQuery.of(context).size.width * 0.18,
                    height: MediaQuery.of(context).size.width * 0.18,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                    placeholder: (context, url) => Center(
                        child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                    )),
                    errorWidget: (context, url, error) => ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          placeholderImage,
                          width: MediaQuery.of(context).size.width * 0.18,
                          height: MediaQuery.of(context).size.width * 0.18,
                          fit: BoxFit.cover,
                        )),
                    fit: BoxFit.cover,
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(vendorModel.title,
                              maxLines: 1,
                              style: TextStyle(
                                letterSpacing: 0.5,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDarkMode(context) ? Colors.white : Colors.black,
                              )).tr(),
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
                              Text(vendorModel.reviewsCount != 0 ? '${(vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1)}' : 0.toString(),
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
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPopularsItem(VendorModel vendorModel) {
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: GestureDetector(
        onTap: () => push(
          context,
          NewVendorProductsScreen(vendorModel: vendorModel),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.38,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
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
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: getImageVAlidUrl(vendorModel.photo),
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
                            width: MediaQuery.of(context).size.width * 0.75,
                            fit: BoxFit.cover,
                          ),
                        ),
                        fit: BoxFit.cover,
                      ),
                      if (discountAmountTempList.isNotEmpty)
                        Positioned(
                          bottom: -8,
                          left: -1,
                          child: Container(
                            decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/offer_badge.png'))),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    discountAmountTempList.isNotEmpty ? discountAmountTempList.reduce(min).toStringAsFixed(currencyData!.decimal) + "% off".tr() : "0",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                    ],
                  )),
                  const SizedBox(height: 8),
                  Text(vendorModel.title,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode(context) ? Colors.white : const Color(0xff000000),
                      )).tr(),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 20,
                        color: Color(COLOR_PRIMARY),
                      ),
                      const SizedBox(width: 3),
                      Text(vendorModel.reviewsCount != 0 ? '${(vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1)}' : 0.toString(),
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
            ),
          ),
        ),
      ),
    );
  }

  Future<void> saveFoodTypeValue() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('foodType', "Delivery");
  }

  getFoodType() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        selctedOrderTypeValue = sp.getString("foodType") == "" || sp.getString("foodType") == null ? "Delivery".tr() : sp.getString("foodType");
      });
    }
    if (selctedOrderTypeValue == "Takeaway") {
      productsFuture = fireStoreUtils.getAllTakeAWayProducts();
    } else {
      productsFuture = fireStoreUtils.getAllProducts();
    }
  }

  void getData() {
    print("data calling ");
    if (!mounted) {
      return;
    }
    lstAllRestaurant = fireStoreUtils.getAllStores().asBroadcastStream();
    lstNewArrivalRestaurant = fireStoreUtils.getVendorsForNewArrival().asBroadcastStream();

    getFoodType();
    if (MyAppState.currentUser != null) {
      lstFavourites = fireStoreUtils.getFavouriteStore(MyAppState.currentUser!.userID);
      lstFavourites.then((event) {
        lstFav.clear();
        for (int a = 0; a < event.length; a++) {
          lstFav.add(event[a].store_id!);
        }
      });
      name = toBeginningOfSentenceCase(widget.user!.firstName);
    }

    lstAllRestaurant!.listen((event) {
      popularRestaurantLst.clear();
      vendors.clear();
      vendors.addAll(event);
      allstoreList.clear();
      allstoreList.addAll(event);

      popularRestaurantLst.addAll(event);

      List<VendorModel> temp5 = popularRestaurantLst.where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) == 5).toList();
      List<VendorModel> temp5_ = popularRestaurantLst
          .where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) > 4 && num.parse((element.reviewsSum / element.reviewsCount).toString()) < 5)
          .toList();
      List<VendorModel> temp4 = popularRestaurantLst
          .where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) > 3 && num.parse((element.reviewsSum / element.reviewsCount).toString()) < 4)
          .toList();
      List<VendorModel> temp3 = popularRestaurantLst
          .where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) > 2 && num.parse((element.reviewsSum / element.reviewsCount).toString()) < 3)
          .toList();
      List<VendorModel> temp2 = popularRestaurantLst
          .where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) > 1 && num.parse((element.reviewsSum / element.reviewsCount).toString()) < 2)
          .toList();
      List<VendorModel> temp1 = popularRestaurantLst.where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) == 1).toList();
      List<VendorModel> temp0 = popularRestaurantLst.where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) == 0).toList();
      List<VendorModel> temp0_ = popularRestaurantLst.where((element) => element.reviewsSum == 0 && element.reviewsCount == 0).toList();

      popularRestaurantLst.clear();
      popularRestaurantLst.addAll(temp5);
      popularRestaurantLst.addAll(temp5_);
      popularRestaurantLst.addAll(temp4);
      popularRestaurantLst.addAll(temp3);
      popularRestaurantLst.addAll(temp2);
      popularRestaurantLst.addAll(temp1);
      popularRestaurantLst.addAll(temp0);
      popularRestaurantLst.addAll(temp0_);

      // popularRestaurantLst.sort((a, b) =>(a.reviewsSum / a.reviewsCount).compareTo(b.reviewsSum / b.reviewsCount));
      // for (int a = 0; a < (event.length >= 5 ?5:event.length); a++) {
      //   if ((event[a].reviewsSum / event[a].reviewsCount) >= 4.0) {
      //     popularRestaurantLst.add(event[a]);
      //   } else if ((event[a].reviewsSum / event[a].reviewsCount) >= 3.0) {
      //     popularRestaurantLst.add(event[a]);
      //   } else if ((event[a].reviewsSum / event[a].reviewsCount) >= 2.0) {
      //     popularRestaurantLst.add(event[a]);
      //   } else if ((event[a].reviewsSum / event[a].reviewsCount) >= 1.0) {
      //     popularRestaurantLst.add(event[a]);
      //   } else {
      //     popularRestaurantLst.add(event[a]);
      //   }
      // }
      setState(() {});
    });
  }
}

class buildTitleRow extends StatelessWidget {
  final String titleValue;
  final Function? onClick;
  final bool? isViewAll;

  const buildTitleRow({
    Key? key,
    required this.titleValue,
    this.onClick,
    this.isViewAll = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDarkMode(context) ? Colors.black : const Color(0xffFFFFFF),
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(titleValue.tr(), style: TextStyle(color: isDarkMode(context) ? Colors.white : const Color(0xFF000000), fontSize: 18)),
              isViewAll!
                  ? Container()
                  : GestureDetector(
                      onTap: () {
                        onClick!.call();
                      },
                      child: Text('See All'.tr(), style: TextStyle(color: Color(COLOR_PRIMARY))),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
