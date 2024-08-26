import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/AddressModel.dart';
import 'package:emartconsumer/model/BannerModel.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/model/favorite_ondemand_service_model.dart';
import 'package:emartconsumer/onDemand_service/onDemand_model/category_model.dart';
import 'package:emartconsumer/onDemand_service/onDemand_model/provider_serivce_model.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/category_screen/category_screen.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/onDemand_dashboard.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/ondemand_details_screen/ondemand_details_screen.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/provider_service_screen/view_all_popular_service_screen.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/provider_service_screen/view_category_service_list_screen.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/ui/auth/AuthScreen.dart';
import 'package:emartconsumer/ui/deliveryAddressScreen/DeliveryAddressScreen.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:location/location.dart' as loc;

class OnDemandHomeScreen extends StatefulWidget {
  final User? user;

  OnDemandHomeScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _OnDemandHomeScreenState createState() => _OnDemandHomeScreenState();
}

class _OnDemandHomeScreenState extends State<OnDemandHomeScreen> {
  final fireStoreUtils = FireStoreUtils();

  final PageController _controller = PageController(viewportFraction: 0.89, keepPage: true);

  String? currentLocation = "";

  loc.Location location = loc.Location();

  bool isLoading = true;

  late Future<List<CategoryModel>> categoriesSection;
  List<CategoryModel>? categoryVal = <CategoryModel>[];
  List<ProviderServiceModel> providerList = [];
  List<BannerModel> bannerModel = [];

  @override
  void initState() {
    super.initState();
    getJson();
  }

  getJson() async {
    await fireStoreUtils.getHomeTopBanner().then((value) {
      setState(() {
        bannerModel = value;
      });
    });
    await getData();

    isLoading = false;
    setState(() {});
  }

  Stream<List<ProviderServiceModel>>? providerStram;

  Future<void> getData() async {
    providerStram = fireStoreUtils.getProvider().asBroadcastStream();

    providerStram!.listen((event) {
      setState(() {
        providerList = event;
      });
    });

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: isDarkMode(context) ? const Color(DARK_BG_COLOR) : const Color(0xffF9F9F9),
        appBar: AppBar(
          backgroundColor: isDarkMode(context) ? const Color(DARK_BG_COLOR) : Colors.white,
          centerTitle: false,
          titleSpacing: 0,
          leading: IconButton(
              visualDensity: const VisualDensity(horizontal: -4),
              padding: const EdgeInsets.only(right: 5),
              icon: Image(
                image: const AssetImage("assets/images/menu.png"),
                width: 24,
                color: isDarkMode(context) ? Colors.white : Colors.black,
              ),
              onPressed: () => key.currentState!.openDrawer()),
          title: InkWell(
            onTap: () async {
              if (MyAppState.currentUser != null) {
                await Navigator.of(context).push(MaterialPageRoute(builder: (context) => DeliveryAddressScreen())).then((value) {
                  if (value != null) {
                    AddressModel addressModel = value;
                    MyAppState.selectedPosotion = addressModel;
                    setState(() {});
                    getData();
                  }
                });
              } else {
                checkPermission(() async {
                  await showProgress(context, "Please wait...".tr(), false);
                  AddressModel addressModel = AddressModel();
                  try {
                    await Geolocator.requestPermission();
                    await Geolocator.getCurrentPosition();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlacePicker(
                          apiKey: GOOGLE_API_KEY,
                          onPlacePicked: (result) async {
                            await hideProgress();
                            AddressModel addressModel = AddressModel();
                            addressModel.locality = result.formattedAddress!.toString();
                            addressModel.location = UserLocation(latitude: result.geometry!.location.lat, longitude: result.geometry!.location.lng);
                            MyAppState.selectedPosotion = addressModel;
                            setState(() {});
                            getData();
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
                  } catch (e) {
                    await placemarkFromCoordinates(19.228825, 72.854118).then((valuePlaceMaker) {
                      Placemark placeMark = valuePlaceMaker[0];
                      setState(() {
                        addressModel.location = UserLocation(latitude: 19.228825, longitude: 72.854118);
                        String currentLocation =
                            "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.postalCode}, ${placeMark.country}";
                        addressModel.locality = currentLocation;
                      });
                    });

                    MyAppState.selectedPosotion = addressModel;
                    await hideProgress();
                    getData();
                  }
                }, context);
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Location".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDarkMode(context) ? Colors.white : const Color(0xff636A75),
                    fontSize: 12,
                    fontFamily: "Poppinsm",
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.40,
                      child: Text(
                        MyAppState.selectedPosotion.getFullAddress().toString().tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDarkMode(context) ? Colors.white : Colors.black,
                          fontSize: 14,
                          fontFamily: "Poppinsm",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down)
                  ],
                ),
              ],
            ),
          ),
        ),
        body: isLoading == true
            ? Center(child: CircularProgressIndicator())
            : (MyAppState.selectedPosotion.location!.latitude == 0 && MyAppState.selectedPosotion.location!.longitude == 0)
                ? Center(
                    child: showEmptyState("We don't have your location.".tr(), context, description: "Set your location to started searching for restaurants in your area".tr(),
                        action: () async {
                      await showProgress(context, "Please wait...".tr(), false);

                      await Geolocator.requestPermission();
                      await Geolocator.getCurrentPosition();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlacePicker(
                            apiKey: GOOGLE_API_KEY,
                            onPlacePicked: (result) async {
                              await hideProgress();
                              AddressModel addressModel = AddressModel();
                              addressModel.locality = result.formattedAddress!.toString();
                              addressModel.location = UserLocation(latitude: result.geometry!.location.lat, longitude: result.geometry!.location.lng);
                              MyAppState.selectedPosotion = addressModel;
                              setState(() {});
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
                : isLoading == true
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              bannerModel.isEmpty
                                  ? SizedBox()
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
                                          color: isDarkMode(context) ? const Color(DarkContainerColor) : Colors.white,
                                        ),
                                        child: SizedBox(
                                          height: MediaQuery.of(context).size.height * 0.23,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                            child: PageView.builder(
                                                padEnds: false,
                                                itemCount: bannerModel.length,
                                                scrollDirection: Axis.horizontal,
                                                controller: _controller,
                                                itemBuilder: (context, index) => bannerWidget(bannerModel[index])),
                                          ),
                                        ),
                                      ),
                                    ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: MediaQuery.of(context).size.height * 0.12,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
                                  color: isDarkMode(context) ? const Color(DarkContainerColor) : Colors.white,
                                ),
                                child: FutureBuilder<List<CategoryModel>>(
                                  future: FireStoreUtils().getProviderCategory(),
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
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: ListView.builder(
                                                itemCount: snapshot.data!.length > 3 ? 3 : snapshot.data!.length,
                                                scrollDirection: Axis.horizontal,
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                    onTap: () {
                                                      push(
                                                          context,
                                                          ViewCategoryServiceListScreen(
                                                            categoryId: snapshot.data![index].id,
                                                            categoryTitle: snapshot.data![index].title,
                                                          ));
                                                    },
                                                    child: CategoryWidget(
                                                      category: snapshot.data![index],
                                                      index: index,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            Visibility(
                                              visible: snapshot.data!.length > 3,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        push(context, const CategoryScreen());
                                                      },
                                                      child: ClipOval(
                                                        child: Container(
                                                          width: 50,
                                                          height: 50,
                                                          color: isDarkMode(context) ? Colors.grey.shade900 : Colors.grey.shade100,
                                                          child: Center(
                                                            child: Icon(Icons.chevron_right),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Container(
                                                      width: 70,
                                                      child: Center(
                                                        child: Text(
                                                          "View All",
                                                          textAlign: TextAlign.center,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                            color: isDarkMode(context) ? Colors.white : Colors.black,
                                                            fontFamily: "Poppinsm",
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return showEmptyState('No Categories'.tr(), context);
                                    }
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Most Popular services".tr(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: isDarkMode(context) ? Colors.white : Colors.black,
                                              fontSize: 18,
                                              fontFamily: "Poppinsm",
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        push(context, ViewAllPopularServiceScreen());
                                      },
                                      child: Text(
                                        "View all".tr(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(COLOR_PRIMARY),
                                          fontSize: 14,
                                          fontFamily: "Poppinsm",
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              providerList.isEmpty
                                  ? showEmptyState('No service Found'.tr(), context)
                                  : ListView.builder(
                                      itemCount: providerList.length >= 6 ? 6 : providerList.length,
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        ProviderServiceModel data = providerList[index];
                                        return ServiceWidget(
                                          providerList: data,
                                          lstFav: [],
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ));
  }

  bannerWidget(BannerModel banners) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: CachedNetworkImage(
        imageUrl: getImageVAlidUrl(banners.photo.toString()),
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
              width: MediaQuery.of(context).size.width * 0.80,
              fit: BoxFit.fitWidth,
            )),
        fit: BoxFit.cover,
      ),
    );
  }
}

class ServiceWidget extends StatefulWidget {
  final ProviderServiceModel providerList;
  final List<FavouriteOndemandServiceModel> lstFav;
  final bool fromListing;

  ServiceWidget({super.key, required this.providerList, required this.lstFav, this.fromListing = false});

  @override
  State<ServiceWidget> createState() => _ServiceWidgetState();
}

class _ServiceWidgetState extends State<ServiceWidget> {
  bool isLoading = true;
  CategoryModel? categoryModel;

  @override
  void initState() {
    getCategory();
    super.initState();
  }

  getCategory() async {
    categoryModel = await FireStoreUtils().getCategoryById(widget.providerList.categoryId.toString());
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? SizedBox()
        : GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () async {
              push(context, OnDemandDetailsScreen(providerModel: widget.providerList));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
                  color: isDarkMode(context) ? Color(DarkContainerColor) : Colors.white,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), topLeft: Radius.circular(10)),
                      child: CachedNetworkImage(
                        imageUrl: getImageVAlidUrl(widget.providerList.photos.isNotEmpty ? widget.providerList.photos[0].toString() : ''),
                        height: MediaQuery.of(context).size.height * 0.16,
                        // height: 100,
                        width: 110,
                        // memCacheHeight: 110,
                        // memCacheWidth: 120,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator.adaptive(
                            valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                          ),
                        ),
                        errorWidget: (context, url, error) => ClipRRect(
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), topLeft: Radius.circular(10)),
                          child: Image.network(
                            placeholderImage,
                            fit: BoxFit.cover,
                            // cacheHeight: 100,
                            // cacheWidth: 100,
                          ),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.providerList.title.toString(),
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "Poppinsm",
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                      color: isDarkMode(context) ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                                if (widget.fromListing)
                                  GestureDetector(
                                    onTap: () {
                                      if (MyAppState.currentUser == null) {
                                        push(context, const AuthScreen());
                                      } else {
                                        var contain = widget.lstFav.where((element) => element.service_id == widget.providerList.id);
                                        setState(() {
                                          if (contain.isNotEmpty) {
                                            FavouriteOndemandServiceModel favouriteModel = FavouriteOndemandServiceModel(
                                                section_id: widget.providerList.sectionId, service_id: widget.providerList.id, user_id: MyAppState.currentUser!.userID);
                                            FireStoreUtils().removeFavouriteOndemandService(favouriteModel);
                                            widget.lstFav.removeWhere((item) => item.service_id == widget.providerList.id);
                                          } else {
                                            FavouriteOndemandServiceModel favouriteModel = FavouriteOndemandServiceModel(
                                                section_id: widget.providerList.sectionId, service_id: widget.providerList.id, user_id: MyAppState.currentUser!.userID);
                                            FireStoreUtils().setFavouriteOndemandSection(favouriteModel);
                                            widget.lstFav.add(favouriteModel);
                                          }
                                        });
                                      }
                                    },
                                    child: widget.lstFav.where((element) => element.service_id == widget.providerList.id).isNotEmpty
                                        ? Icon(
                                            Icons.favorite,
                                            size: 24,
                                            color: Color(COLOR_PRIMARY),
                                          )
                                        : Icon(
                                            Icons.favorite_border,
                                            size: 24,
                                            color: isDarkMode(context) ? Colors.white38 : Colors.black38,
                                          ),
                                  ),
                              ],
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            categoryModel != null
                                ? Text(
                                    categoryModel!.title!.toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: "Poppinsm",
                                      fontWeight: FontWeight.w400,
                                      color: isDarkMode(context) ? Colors.white : Colors.black,
                                    ),
                                  )
                                : Container(),
                            // FutureBuilder(
                            //     future: FireStoreUtils().getCategoryById(widget.providerList.categoryId.toString()),
                            //     builder: (context, snapshot) {
                            //       if (snapshot.connectionState == ConnectionState.waiting) {
                            //         return Center(child: Container());
                            //       } else {
                            //         if (snapshot.hasError) {
                            //           return Center(child: Text('Error: '.tr() + '${snapshot.error}'));
                            //         } else {
                            // return Text(
                            //   snapshot.data!.title.toString(),
                            //   style: TextStyle(
                            //     fontSize: 14,
                            //     fontFamily: "Poppinsm",
                            //     fontWeight: FontWeight.w400,
                            //     color: isDarkMode(context) ? Colors.white : Colors.black,
                            //   ),
                            // );
                            //         }
                            //       }
                            //     }),
                            SizedBox(
                              height: 5,
                            ),
                            widget.providerList.disPrice == "" || widget.providerList.disPrice == "0"
                                ? Text(
                                    widget.providerList.priceUnit == 'Fixed'
                                        ? amountShow(amount: widget.providerList.price)
                                        : '${amountShow(amount: widget.providerList.price)}/hr',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: "Poppinsm",
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode(context) ? Colors.white : Color(COLOR_PRIMARY),
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Text(
                                        widget.providerList.priceUnit == 'Fixed'
                                            ? amountShow(amount: widget.providerList.disPrice)
                                            : '${amountShow(amount: widget.providerList.disPrice)}/hr',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: "Poppinsm",
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode(context) ? Colors.white : Color(COLOR_PRIMARY),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          widget.providerList.priceUnit == 'Fixed'
                                              ? amountShow(amount: widget.providerList.price)
                                              : '${amountShow(amount: widget.providerList.price)}/hr',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey, decoration: TextDecoration.lineThrough),
                                        ),
                                      ),
                                    ],
                                  ),
                            SizedBox(
                              height: 5,
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
                                      widget.providerList.reviewsCount != 0
                                          ? ((widget.providerList.reviewsSum ?? 0.0) / (widget.providerList.reviewsCount ?? 0.0)).toStringAsFixed(1)
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
                            // Container(
                            //   decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(36), color: timeCheck(providerList) == true ? Colors.green.withOpacity(0.40) : Colors.red.withOpacity(0.20)),
                            //   child: Padding(
                            //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            //     child: Text(
                            //       timeCheck(providerList) == true ? "Open" : "Close",
                            //       textAlign: TextAlign.center,
                            //       style: TextStyle(
                            //         fontFamily: "Poppinsm",
                            //         fontWeight: FontWeight.bold,
                            //         color: timeCheck(providerList) == true ? Colors.white : Colors.white,
                            //         fontSize: 14,
                            //       ),
                            //     ),
                            //   ),
                            // ),
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

  bool timeCheck(ProviderServiceModel providerModel) {
    bool isOpen = false;
    final now = new DateTime.now();
    var day = DateFormat('EEEE', 'en_US').format(now);
    var date = DateFormat('dd-MM-yyyy').format(now);
    for (var element in providerModel.days) {
      if (day == element.toString()) {
        var start = DateFormat("dd-MM-yyyy HH:mm").parse(date + " " + providerModel.startTime.toString());
        var end = DateFormat("dd-MM-yyyy HH:mm").parse(date + " " + providerModel.endTime.toString());
        if (isCurrentDateInRange(start, end)) {
          isOpen = true;
        }
      }
    }
    return isOpen;
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    print(startDate);
    print(endDate);
    final currentDate = DateTime.now();
    print(currentDate);
    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }
}

class CategoryWidget extends StatelessWidget {
  final CategoryModel category;
  final int index;

  const CategoryWidget({super.key, required this.category, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: colorList[index % colorList.length],
              borderRadius: BorderRadius.circular(50),
            ),
            child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: CachedNetworkImage(
                  imageUrl: category.image.toString(),
                  // color: Colors.black,
                  errorWidget: (context, url, error) => ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.network(
                      placeholderImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Container(
            width: 70,
            child: Center(
              child: Text(
                category.title.toString(),
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  color: isDarkMode(context) ? Colors.white : Colors.black,
                  fontFamily: "Poppinsm",
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
