import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/Ratingmodel.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/model/favorite_ondemand_service_model.dart';
import 'package:emartconsumer/onDemand_service/onDemand_model/provider_serivce_model.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/booking_screen/booking_screen.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/provider_screen/provider_screen.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/ui/auth/AuthScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class OnDemandDetailsScreen extends StatefulWidget {
  final ProviderServiceModel providerModel;

  const OnDemandDetailsScreen({Key? key, required this.providerModel}) : super(key: key);

  @override
  State<OnDemandDetailsScreen> createState() => _OnDemandDetailsScreenState();
}

class _OnDemandDetailsScreenState extends State<OnDemandDetailsScreen> {
  ProviderServiceModel provider = ProviderServiceModel();
  User? userModel = User();
  String? subCategoryTitle = '';
  late List<RatingModel> ratingService = [];
  String? categoryTitle = '';
  bool? isLoading = true;
  List<FavouriteOndemandServiceModel> lstFav = [];

  @override
  void initState() {
    super.initState();
    provider = widget.providerModel;
    timeCheck();
    getData();
  }

  getData() async {
    getReviewList();
  }

  getReviewList() async {
    await FireStoreUtils().getCategoryById(provider.categoryId.toString()).then((value) {
      if (value != null) {
        categoryTitle = value.title.toString();
      }
    });

    await FireStoreUtils().getSubCategoryById(provider.subCategoryId.toString()).then((value) {
      if (value != null) {
        subCategoryTitle = value.title.toString();
      }
    });

    await FireStoreUtils().getReviewByProviderServiceId(provider.id.toString()).then((value) {
      setState(() {
        ratingService = value;
      });
    });

    await FireStoreUtils.getCurrentUser(provider.author.toString()).then((value) {
      setState(() {
        userModel = value;
      });
    });
    if (MyAppState.currentUser != null) {
      await FireStoreUtils()
          .getFavouritesServiceList(
        MyAppState.currentUser!.userID,
      )
          .then((value) {
        setState(() {
          lstFav = value;
        });
      });
    }

    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDarkMode(context) ? const Color(DARK_BG_COLOR) : const Color(0xffF9F9F9),
      body: isLoading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : buildSliverScrollView(provider),
      bottomNavigationBar: isOpen == false
          ? SizedBox()
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.only(top: 12, bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                          side: BorderSide(color: Color(COLOR_PRIMARY)),
                        ),
                        backgroundColor: Color(COLOR_PRIMARY)),
                    onPressed: () {
                      if (MyAppState.currentUser == null) {
                        push(context, const AuthScreen());
                      } else {
                        push(context, OnDemandBookingScreen(providerModel: widget.providerModel, categoryTitle: subCategoryTitle.toString()));
                      }
                    },
                    child: Text(
                      'Book Now'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "Poppinsm",
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  bool isOpen = false;

  timeCheck() {
    final now = new DateTime.now();
    var day = DateFormat('EEEE', 'en_US').format(now);
    var date = DateFormat('dd-MM-yyyy').format(now);
    for (var element in provider.days) {
      if (day == element.toString()) {
        var start = DateFormat("dd-MM-yyyy HH:mm").parse(date + " " + provider.startTime.toString());
        var end = DateFormat("dd-MM-yyyy HH:mm").parse(date + " " + provider.endTime.toString());
        if (isCurrentDateInRange(start, end)) {
          setState(() {
            isOpen = true;
          });
        }
      }
    }
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    print(startDate);
    print(endDate);
    final currentDate = DateTime.now();
    print(currentDate);
    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }

  Widget buildSliverScrollView(ProviderServiceModel providerModel) {
    var _width = MediaQuery.of(context).size.width;
    var _height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(22), bottomLeft: Radius.circular(22)),
                  child: Container(
                    height: _height * 0.45,
                    width: _width * 1,
                    child: CachedNetworkImage(
                      imageUrl: getImageVAlidUrl(provider.photos.isNotEmpty ? provider.photos.first.toString() : ""),
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
                    ),
                  )),
              Positioned(
                  top: _height * 0.05,
                  left: _width * 0.03,
                  child: ClipOval(
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.70), borderRadius: BorderRadius.all(Radius.circular(60))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )),
              Positioned(
                top: _height * 0.05,
                right: _width * 0.03,
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(40), color: isOpen == true ? Colors.green : Colors.red),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(
                      isOpen == true ? "Open" : "Close",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Poppinsm",
                        fontWeight: FontWeight.bold,
                        color: isOpen == true ? Colors.white : Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        provider.title.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Poppinsm",
                          fontWeight: FontWeight.bold,
                          color: isDarkMode(context) ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        provider.disPrice == "" || provider.disPrice == "0"
                            ? Text(
                                provider.priceUnit == 'Fixed' ? amountShow(amount: provider.price) : '${amountShow(amount: provider.price)}/hr',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: "Poppinsm",
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode(context) ? Colors.white : Color(COLOR_PRIMARY),
                                ),
                              )
                            : Row(
                                children: [
                                  Text(
                                    provider.priceUnit == 'Fixed' ? amountShow(amount: provider.disPrice) : '${amountShow(amount: provider.disPrice)}/hr',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "Poppinsm",
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode(context) ? Colors.white : Color(COLOR_PRIMARY),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      provider.priceUnit == 'Fixed' ? amountShow(amount: provider.price) : '${amountShow(amount: provider.price)}/hr',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey, decoration: TextDecoration.lineThrough),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          categoryTitle.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Poppinsm",
                            fontWeight: FontWeight.w400,
                            color: isDarkMode(context) ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Color(SemanticColorWarning06),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            provider.reviewsCount != 0 ? ((provider.reviewsSum ?? 0.0) / (provider.reviewsCount ?? 0.0)).toStringAsFixed(1) : 0.toString(),
                            style: const TextStyle(
                              letterSpacing: 0.5,
                              fontSize: 16,
                              fontFamily: "Poppinsm",
                              fontWeight: FontWeight.w500,
                              color: Color(SemanticColorWarning06),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "(${provider.reviewsCount} Reviews)",
                            style: TextStyle(
                              letterSpacing: 0.5,
                              fontSize: 16,
                              fontFamily: "Poppinsm",
                              fontWeight: FontWeight.w500,
                              color: isDarkMode(context) ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      subCategoryTitle != null && subCategoryTitle!.isNotEmpty
                          ? Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Color(COLOR_PRIMARY).withOpacity(0.20)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                child: Text(
                                  subCategoryTitle.toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Poppinsm",
                                    color: Color(COLOR_PRIMARY),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.green.withOpacity(0.20)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  isDismissible: true,
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  enableDrag: true,
                                  builder: (context) => showTiming(context),
                                );
                              },
                              child: Container(
                                  padding: const EdgeInsets.only(
                                    right: 2,
                                    left: 2,
                                  ),
                                  child: Text(
                                    "View Timing".tr(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      letterSpacing: 0.5,
                                    ),
                                  ).tr())),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),

                // Row(
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Row(
                //       children: [
                //         Text(
                //           "Start time : ",
                //           maxLines: 2,
                //           overflow: TextOverflow.ellipsis,
                //           style: TextStyle(
                //             fontFamily: "Poppinsm",
                //             fontWeight: FontWeight.w400,
                //             fontSize: 16,
                //             color: isDarkMode(context) ? Colors.white : Colors.black,
                //           ),
                //         ),
                //         Text(
                //           provider.startTime.toString(),
                //           overflow: TextOverflow.ellipsis,
                //           style: TextStyle(
                //             fontFamily: "Poppinsm",
                //             fontWeight: FontWeight.w400,
                //             color: isDarkMode(context) ? Colors.white : Colors.black,
                //           ),
                //         ),
                //       ],
                //     ),
                //     Row(
                //       children: [
                //         Text(
                //           "End time : ",
                //           maxLines: 2,
                //           overflow: TextOverflow.ellipsis,
                //           style: TextStyle(
                //             fontFamily: "Poppinsm",
                //             fontWeight: FontWeight.w400,
                //             fontSize: 16,
                //             color: isDarkMode(context) ? Colors.white : Colors.black,
                //           ),
                //         ),
                //         Text(
                //           provider.endTime.toString(),
                //           overflow: TextOverflow.ellipsis,
                //           style: TextStyle(
                //             fontFamily: "Poppinsm",
                //             fontWeight: FontWeight.w400,
                //             color: isDarkMode(context) ? Colors.white : Colors.black,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ],
                // ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: isDarkMode(context) ? Colors.white : Colors.black,
                      size: 20,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(
                        provider.address.toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: "Poppinsm",
                          fontWeight: FontWeight.w400,
                          color: isDarkMode(context) ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(),
                tabViewWidget(),
                tabString == "About"
                    ? aboutTabViewWidget(providerModel)
                    : tabString == "Gallery"
                        ? galleryTabViewWidget(providerModel)
                        : reviewTabViewWidget(),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String tabString = "About";

  tabViewWidget() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              tabString = "About";
            });
          },
          child: const Text('About').tr(),
          style: ButtonStyle(
              foregroundColor:
                  tabString == "About" ? MaterialStateProperty.all<Color>(Colors.white) : MaterialStateProperty.all<Color>(isDarkMode(context) ? Colors.white : Colors.black),
              backgroundColor: tabString == "About"
                  ? MaterialStateProperty.all<Color>(Color(COLOR_PRIMARY))
                  : MaterialStateProperty.all<Color>(isDarkMode(context) ? Color(DarkContainerColor) : Colors.white),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(
                    color: Colors.grey.withOpacity(0.30),
                  )))),
        ),
        const SizedBox(
          width: 10,
        ),
        provider.photos.isEmpty
            ? SizedBox()
            : ElevatedButton(
                onPressed: () {
                  setState(() {
                    tabString = "Gallery";
                  });
                },
                child: const Text('Gallery').tr(),
                style: ButtonStyle(
                    foregroundColor: tabString == "Gallery"
                        ? MaterialStateProperty.all<Color>(Colors.white)
                        : MaterialStateProperty.all<Color>(isDarkMode(context) ? Colors.white : Colors.black),
                    backgroundColor: tabString == "Gallery"
                        ? MaterialStateProperty.all<Color>(Color(COLOR_PRIMARY))
                        : MaterialStateProperty.all<Color>(isDarkMode(context) ? Color(DarkContainerColor) : Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(
                          color: Colors.grey.withOpacity(0.30),
                        )))),
              ),
        const SizedBox(
          width: 10,
        ),
        ratingService.isEmpty
            ? SizedBox()
            : ElevatedButton(
                onPressed: () {
                  setState(() {
                    tabString = "Review";
                  });
                },
                child: const Text('Review').tr(),
                style: ButtonStyle(
                    foregroundColor: tabString == "Review"
                        ? MaterialStateProperty.all<Color>(Colors.black)
                        : MaterialStateProperty.all<Color>(isDarkMode(context) ? Colors.white : Colors.black),
                    backgroundColor: tabString == "Review"
                        ? MaterialStateProperty.all<Color>(Color(COLOR_PRIMARY))
                        : MaterialStateProperty.all<Color>(isDarkMode(context) ? Color(DarkContainerColor) : Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(
                          color: Colors.grey.withOpacity(0.30),
                        )))),
              ),
      ],
    );
  }

  aboutTabViewWidget(ProviderServiceModel providerModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(providerModel.description.toString(),
              style: TextStyle(
                color: isDarkMode(context) ? Colors.white : Colors.black,
                fontSize: 14,
                fontFamily: "Poppinsm",
                fontWeight: FontWeight.w500,
              )),
          SizedBox(
            height: 10,
          ),
          userModel == null
              ? SizedBox()
              : InkWell(
                  onTap: () {
                    push(
                        context,
                        ProviderScreen(
                          providerId: userModel!.userID,
                        ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
                        color: isDarkMode(context) ? Color(DarkContainerColor) : Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  userModel!.profilePictureURL != ""
                                      ? CircleAvatar(backgroundImage: NetworkImage(userModel!.profilePictureURL.toString()), radius: 30.0)
                                      : CircleAvatar(backgroundImage: NetworkImage(placeholderImage), radius: 30.0),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userModel!.fullName().toString(),
                                          style: TextStyle(
                                              color: isDarkMode(context) ? Colors.white : Colors.black, fontFamily: "Poppinsm", fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          userModel!.email.toString(),
                                          style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontFamily: "Poppinsm", fontSize: 14),
                                        ),
                                        SizedBox(
                                          height: 10,
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
                                                  userModel!.reviewsCount != 0 ? ((userModel!.reviewsSum) / (userModel!.reviewsCount ?? 0.0)).toStringAsFixed(1) : 0.toString(),
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
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
          // Wrap(
          //   children: provider.days
          //       .map((item) {
          //         return Container(
          //           margin: EdgeInsets.only(left: 4, right: 4, top: 4),
          //           decoration: BoxDecoration(
          //             borderRadius: BorderRadius.circular(10),
          //             border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
          //             color: isDarkMode(context) ? Color(DarkContainerColor) : Colors.white,
          //             boxShadow: [
          //               isDarkMode(context)
          //                   ? const BoxShadow()
          //                   : BoxShadow(
          //                       color: Colors.grey.withOpacity(0.5),
          //                       blurRadius: 5,
          //                     ),
          //             ],
          //           ),
          //           child: Padding(
          //             padding: const EdgeInsets.all(12.0),
          //             child: Text(
          //               item.toString(),
          //               style: TextStyle(
          //                 fontSize: 14,
          //                 fontFamily: "Poppinsm",
          //                 fontWeight: FontWeight.w500,
          //                 color: isDarkMode(context) ? Colors.white : Colors.black,
          //               ),
          //             ),
          //           ),
          //         );
          //       })
          //       .toList()
          //       .cast<Widget>(),
          // ),
        ],
      ),
    );
  }

  galleryTabViewWidget(ProviderServiceModel providerModel) {
    return providerModel.photos.isEmpty
        ? Center(
            child: const Text("No Image Found").tr(),
          )
        : GridView.builder(
            itemCount: providerModel.photos.length,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 0, crossAxisSpacing: 8, mainAxisExtent: 180),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: providerModel.photos[index],
                    height: 60,
                    width: 60,
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
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          );
  }

  reviewTabViewWidget() {
    return ratingService.isEmpty
        ? Center(
            child: const Text("No review Found").tr(),
          )
        : ListView.builder(
            itemCount: ratingService.length,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: const Offset(0, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(ratingService[index].uname.toString(), style: const TextStyle(fontSize: 16, letterSpacing: 1, fontWeight: FontWeight.w600)),
                                Text(
                                  DateFormat('dd MMM').format(ratingService[index].createdAt!.toDate()),
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            RatingBar.builder(
                              initialRating: double.parse(ratingService[index].rating.toString()),
                              direction: Axis.horizontal,
                              itemSize: 20,
                              ignoreGestures: true,
                              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Color(COLOR_PRIMARY),
                              ),
                              onRatingUpdate: (double rate) {},
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(ratingService[index].comment.toString()),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  showTiming(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: isDarkMode(context) ? const Color(DARK_BG_COLOR) : Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Text(
              "Service Timing",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppinsm",
                color: Color(COLOR_PRIMARY),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: BorderSide(
                        color: isDarkMode(context) ? const Color(0XFF3c3a2e) : const Color(0XFFC3C5D1),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.only(top: 7, bottom: 7, left: 20, right: 20),
                        child: Row(
                          children: [
                            Text("Start Time : ", style: TextStyle(color: isDarkMode(context) ? const Color(0XFFa5a292) : const Color(0XFF5A5D6D))),
                            Text(provider.startTime.toString(), style: TextStyle(color: isDarkMode(context) ? const Color(0XFFa5a292) : const Color(0XFF5A5D6D))),
                          ],
                        )),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: BorderSide(
                        color: isDarkMode(context) ? const Color(0XFF3c3a2e) : const Color(0XFFC3C5D1),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.only(top: 7, bottom: 7, left: 20, right: 20),
                        child: Row(
                          children: [
                            Text("End Time : ", style: TextStyle(color: isDarkMode(context) ? const Color(0XFFa5a292) : const Color(0XFF5A5D6D))),
                            Text(provider.endTime.toString(), style: TextStyle(color: isDarkMode(context) ? const Color(0XFFa5a292) : const Color(0XFF5A5D6D))),
                          ],
                        )),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Text(
              "Service Days",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppinsm",
                color: Color(COLOR_PRIMARY),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: List.generate(
                provider.days.length,
                (i) {
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: BorderSide(
                        color: isDarkMode(context) ? const Color(0XFF3c3a2e) : const Color(0XFFC3C5D1),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.only(top: 7, bottom: 7, left: 20, right: 20),
                        child: Text(provider.days[i], style: TextStyle(color: isDarkMode(context) ? const Color(0XFFa5a292) : const Color(0XFF5A5D6D)))),
                  );
                },
              ).toList(),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
