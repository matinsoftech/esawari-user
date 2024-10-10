// ignore_for_file: unused_local_variable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/cab_service/cab_intercity_service_screen.dart';
import 'package:emartconsumer/cab_service/cab_service_screen.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/BannerModel.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class CabHomeScreen extends StatefulWidget {
  final User? user;

  const CabHomeScreen({Key? key, this.user}) : super(key: key);

  @override
  State<CabHomeScreen> createState() => _CabHomeScreenState();
}

class _CabHomeScreenState extends State<CabHomeScreen> {
  final PageController _controller = PageController(viewportFraction: 0.8, keepPage: true);

  @override
  void initState() {
    getBanner();
    super.initState();
  }

  List<BannerModel> bannerTopHome = [];
  bool isHomeBannerLoading = true;

  final Location currentLocation = Location();

  getBanner() async {
    LocationData location = await currentLocation.getLocation();

    await FireStoreUtils().getHomeTopBanner().then((value) {
      setState(() {
        bannerTopHome = value;
        isHomeBannerLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Image.asset('assets/images/cab_home_image.png'),
        Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.04, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                  child: Image.asset(
                    "assets/icons/ic_side_menu.png",
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text("WelCome".tr() + " ${MyAppState.currentUser == null ? '' : MyAppState.currentUser!.firstName ?? ''}",
                          style: const TextStyle(fontSize: 22, color: Colors.black))
                      .tr(),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 320),
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Visibility(
                      visible: bannerTopHome.isNotEmpty,
                      child: Container(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: isHomeBannerLoading
                              ? const Center(child: CircularProgressIndicator())
                              : SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.20,
                                  child: PageView.builder(
                                      padEnds: false,
                                      itemCount: bannerTopHome.length,
                                      scrollDirection: Axis.horizontal,
                                      controller: _controller,
                                      itemBuilder: (context, index) => buildBestDealPage(bannerTopHome[index])))),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Choose Your Ride".tr(),
                      style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                push(context, const CabServiceScreen());
                              },
                              child: Stack(children: [
                                Image.asset('assets/images/ride_bg.png'),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        "Ride".tr(),
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Image.asset('assets/images/ride_image.png'),
                                    ],
                                  ),
                                )
                              ]),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                push(context, const CabInterCityServiceScreen());
                              },
                              child: Stack(children: [
                                Image.asset('assets/images/intercity_bg.png'),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        "Intercity / Outstation".tr(),
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Image.asset('assets/images/intercity_image.png'),
                                    ],
                                  ),
                                )
                              ]),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    )

        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 20),
        //   child: Column(
        //     children: [
        //       GestureDetector(
        //         onTap: () {},
        //         child: Banner_Url.isEmpty
        //             ? Container()
        //             : Container(
        //                 width: MediaQuery.of(context).size.width,
        //                 height: MediaQuery.of(context).size.width / 2.5,
        //                 decoration: BoxDecoration(
        //                     borderRadius: BorderRadius.circular(10),
        //                     border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
        //                     color: isDarkMode(context) ? const Color(DarkContainerColor) : Colors.white,
        //                     boxShadow: [
        //                       isDarkMode(context)
        //                           ? const BoxShadow()
        //                           : BoxShadow(
        //                               color: Colors.grey.withOpacity(0.5),
        //                               blurRadius: 5,
        //                             ),
        //                     ],
        //                     image: DecorationImage(image: NetworkImage(Banner_Url), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken))),
        //               ),
        //       ),
        //       const SizedBox(
        //         height: 20,
        //       ),
        //       Row(
        //         children: [
        //           Expanded(
        //             child: InkWell(
        //               onTap: () {
        //                 push(context, const CabServiceScreen());
        //               },
        //               child: Container(
        //                 height: 80,
        //                 decoration: BoxDecoration(
        //                   color: Colors.white,
        //                   borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        //                   boxShadow: [
        //                     BoxShadow(
        //                       color: Colors.grey.withOpacity(0.5),
        //                       spreadRadius: 5,
        //                       blurRadius: 7,
        //                       offset: const Offset(0, 3), // changes position of shadow
        //                     ),
        //                   ],
        //                 ),
        //                 child: const Text("Cab"),
        //               ),
        //             ),
        //           ),
        //           const SizedBox(
        //             width: 10,
        //           ),
        //           Expanded(
        //             child: InkWell(
        //               onTap: () {
        //                 push(context, const CabInterCityServiceScreen());
        //               },
        //               child: Container(
        //                 height: 80,
        //                 decoration: BoxDecoration(
        //                   color: Colors.white,
        //                   borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        //                   boxShadow: [
        //                     BoxShadow(
        //                       color: Colors.grey.withOpacity(0.5),
        //                       spreadRadius: 5,
        //                       blurRadius: 7,
        //                       offset: const Offset(0, 3), // changes position of shadow
        //                     ),
        //                   ],
        //                 ),
        //                 child: const Text("Intercity / OutStation "),
        //               ),
        //             ),
        //           )
        //         ],
        //       )
        //     ],
        //   ),
        // ),
        );
  }

  Widget buildBestDealPage(BannerModel categoriesModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
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
}
