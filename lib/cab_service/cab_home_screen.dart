// ignore_for_file: unused_local_variable
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/cab_service/cab_intercity_service_screen.dart';
import 'package:emartconsumer/cab_service/cab_service_screen.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/ecommarce_service/ecommarce_dashboard.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/BannerModel.dart';
import 'package:emartconsumer/model/SectionModel.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/model/referral_model.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/onDemand_dashboard.dart';
import 'package:emartconsumer/parcel_delivery/parcel_dashboard.dart';
import 'package:emartconsumer/rental_service/rental_service_dash_board.dart';
import 'package:emartconsumer/rental_service/rental_service_home_screen.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/services/localDatabase.dart';
import 'package:emartconsumer/ui/auth/AuthScreen.dart';
import 'package:emartconsumer/ui/container/ContainerScreen.dart';
import 'package:emartconsumer/ui/referral_screen/referral_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:provider/provider.dart';

class CabHomeScreen extends StatefulWidget {
  final User? user;

  const CabHomeScreen({Key? key, this.user}) : super(key: key);

  @override
  State<CabHomeScreen> createState() => _CabHomeScreenState();
}

class _CabHomeScreenState extends State<CabHomeScreen> {
  final PageController _controller =
      PageController(viewportFraction: 0.8, keepPage: true);

  @override
  void initState() {
    // getBanner();
    getReferralCode();
    super.initState();
  }

  List<BannerModel> bannerTopHome = [];
  bool isHomeBannerLoading = true;

  final Location currentLocation = Location();
//get banner is commented in initState
  getBanner() async {
    LocationData location = await currentLocation.getLocation();
    await FireStoreUtils().getHomeTopBanner().then((value) {
      setState(() {
        bannerTopHome = value;
        isHomeBannerLoading = false;
      });
    });
  }

  ReferralModel? referralModel = ReferralModel();
  bool isLoading = true;
  getReferralCode() async {
    await FireStoreUtils.getReferralUserBy().then((value) {
      if (value != null) {
        setState(() {
          isLoading = false;
          referralModel = value;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  List images = [
    'https://cdn.pixabay.com/photo/2023/06/07/04/23/road-8046167_1280.jpg',
    'https://cdn.pixabay.com/photo/2014/12/16/09/18/rental-bikes-570111_960_720.jpg',
    'https://cdn.pixabay.com/photo/2021/08/19/14/00/field-6558125_1280.jpg',
    'https://cdn.pixabay.com/photo/2021/08/19/14/00/field-6558125_1280.jpg',
    'https://cdn.pixabay.com/photo/2014/12/16/09/18/rental-bikes-570111_960_720.jpg',
    'https://cdn.pixabay.com/photo/2016/07/08/18/32/bike-1505039_1280.jpg',
  ];
  final fireStoreUtils = FireStoreUtils();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.red.withOpacity(0.04),
          // appBar: AppBar(
          //   leading: Padding(
          //     padding: EdgeInsets.only(right: 10),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         InkWell(
          //           onTap: () {
          //             Scaffold.of(context).openDrawer();
          //           },
          //           child: Padding(
          //             padding: const EdgeInsets.symmetric(
          //                 horizontal: 14, vertical: 15),
          //             child: Image.asset(
          //               "assets/icons/ic_side_menu.png",
          //               color: Colors.black,
          //               height: 26,
          //               width: 26,
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Welcome" +
                              " ${MyAppState.currentUser == null ? '' : MyAppState.currentUser!.fullName()}",
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ).tr(),
                      ),
                      SizedBox(height: 30),

                      // Image.asset('assets/images/cab_home_image.png'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 210,
                          // width: 1000,
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: 600.0,
                              viewportFraction: 0.90,
                              // disableCenter: false,
                              enableInfiniteScroll: true,
                              reverse: false,
                              autoPlay: true,
                              autoPlayInterval: Duration(seconds: 3),
                              autoPlayAnimationDuration:
                                  Duration(milliseconds: 800),
                              autoPlayCurve: Curves.fastOutSlowIn,
                            ),
                            items: images.map((i) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        '${i}',
                                        fit: BoxFit.cover,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
                // our services section
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    'Our Services',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDarkMode(context) ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontFamily: "Poppinsm",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    margin: const EdgeInsets.only(left: 0, right: 10, top: 15),
                    width: MediaQuery.of(context).size.width,
                    child: FutureBuilder<List<SectionModel>>(
                        future: fireStoreUtils.getSections(),
                        initialData: const [],
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator.adaptive(
                                valueColor: AlwaysStoppedAnimation(
                                    Color(COLOR_PRIMARY)),
                              ),
                            );
                          }

                          if (snapshot.hasData ||
                              (snapshot.data?.isNotEmpty ?? false)) {
                            return Container(
                              padding: EdgeInsets.only(
                                left: 8,
                                right: 8,
                                top: 16,
                                bottom: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.symmetric(
                                  horizontal: BorderSide(
                                    width: 1.0,
                                    color: isDarkMode(context)
                                        ? const Color(DarkContainerBorderColor)
                                        : Colors.grey.shade200,
                                  ),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Wrap(
                                    spacing: MediaQuery.of(context).size.width *
                                        0.08,
                                    runSpacing: 4,
                                    children: snapshot.data != null
                                        ? [
                                            ...snapshot.data!.map((data) =>
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          3 -
                                                      50,
                                                  child: buildCuisineCell(data),
                                                )),
                                            // Adding the extra item
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3 -
                                                  50,
                                              child:
                                                  buildExtraItem(), // Replace with your custom widget
                                            ),
                                          ]
                                        : [
                                            showEmptyState(
                                                'No Categories', context),
                                            // Adding the extra item in case of empty state
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3 -
                                                  50,
                                              child:
                                                  buildExtraItem(), // Replace with your custom widget
                                            ),
                                          ],
                                  ),
                                  // Center(
                                  //   child: Wrap(
                                  //     spacing:
                                  //         MediaQuery.of(context).size.width * 0.08,
                                  //     runSpacing: 4,
                                  //     children: snapshot.data != null
                                  //         ? snapshot.data!
                                  //             .map((data) => SizedBox(
                                  //                   width: MediaQuery.of(context)
                                  //                               .size
                                  //                               .width /
                                  //                           3 -
                                  //                       50,
                                  //                   child: buildCuisineCell(data),
                                  //                 ))
                                  //             .toList()
                                  //         : [
                                  //             showEmptyState(
                                  //                 'No Categories'.tr(), context)
                                  //           ],
                                  //   ),
                                  // ),
                                ],
                              ),
                            );

                            //  GridView.builder(
                            //   shrinkWrap: true,
                            //   physics: const NeverScrollableScrollPhysics(),
                            //   itemCount: snapshot.data!.length,
                            //   itemBuilder: (context, index) {
                            //     if (snapshot.data != null) {
                            //       preSectionList.clear();
                            //       preSectionList.addAll(snapshot.data!);
                            //     }
                            //     return snapshot.data != null
                            //         ? buildCuisineCell(snapshot.data![index])
                            //         : showEmptyState('No Categories'.tr(), context);
                            //   },
                            //   gridDelegate:
                            //       const SliverGridDelegateWithFixedCrossAxisCount(
                            //           crossAxisCount: 2,
                            //           mainAxisSpacing: 0,
                            //           crossAxisSpacing: 8,
                            //           mainAxisExtent: 200),
                            // );
                          }
                          return const CircularProgressIndicator();
                        }),
                  ),
                ),
                SizedBox(height: 24),
                //?invites friends
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    'Invite Friends & Get Discount',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDarkMode(context) ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontFamily: "Poppinsm",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // SizedBox(height: 24),
                Container(
                  height: 400,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: 1,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: MediaQuery.of(context).size.height,
                          child: Card(
                            child: Column(
                              // mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //images
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Image.asset(
                                      'assets/images/Invites.png',
                                      height: 180,
                                      width: 180,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Text(
                                            'Refer your Friends',
                                            style: TextStyle(
                                              color: isDarkMode(context)
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontSize: 16,
                                              fontFamily: "Poppinsm",
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6.0),
                                          child: Text(
                                            "Invite Friend to sign up using your code and you’ll get" +
                                                " ${sectionConstantModel!.referralAmount}"
                                                    " after successfully order complete.",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: isDarkMode(context)
                                                  ? Colors.white
                                                  : Colors.grey.shade500,
                                              fontSize: 14,
                                              fontFamily: "Poppinsm",
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Share this code',
                                          style: TextStyle(
                                            color: isDarkMode(context)
                                                ? Colors.white
                                                : Colors.grey.shade500,
                                            fontSize: 14,
                                            fontFamily: "Poppinsm",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                //? referel code
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        width: 0.3,
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        isLoading == true
                                            ? const Center(
                                                child: CircularProgressIndicator
                                                    .adaptive(
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                          Colors.red),
                                                ),
                                              )
                                            : referralModel == null
                                                ? Center(
                                                    child: Text(
                                                        "Something want wrong"),
                                                  )
                                                : Text(
                                                    '${referralModel!.referralCode}'),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                          iconSize: 16,
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(
                                                    text: referralModel!
                                                        .referralCode
                                                        .toString()))
                                                .then(
                                              (value) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "Coupon code copied",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.copy_outlined,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ), //? buttons
                                //buttons
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          child: Text(
                                            "Invites",
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            // : Colors.red,
                                            foregroundColor: Colors.red,
                                            side: BorderSide(
                                              color: Colors.red,
                                            ),
                                          ),
                                          onPressed: () async {
                                            await FlutterShare.share(
                                              title: 'E-sawari',
                                              text: "Hey there, thanks for choosing E-sawari. Hope you love our product. If you do, share it with your friends using code" +
                                                  " ${referralModel!.referralCode.toString()} " +
                                                  "and get" +
                                                  " ${sectionConstantModel!.referralAmount}"
                                                      // " ${amountShow(amount: sectionConstantModel!.referralAmount.toString())} " +
                                                      "when order completed",
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: ElevatedButton(
                                          child: Text("Details"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            elevation: 0,
                                          ),
                                          onPressed: () {
                                            Get.to(() => ReferralScreen());
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          )),
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

  Widget buildCuisineCell(SectionModel sectionModel) {
    return InkWell(
      onTap: () async {
        // COLOR_PRIMARY =
        //     int.parse(sectionModel.color!.replaceFirst("#", "0xff"));

        print("=========>");
        // print(sectionModel.serviceType!);
        if (auth.FirebaseAuth.instance.currentUser != null &&
            MyAppState.currentUser != null) {
          User? user = await FireStoreUtils.getCurrentUser(
              MyAppState.currentUser!.userID);

          if (user!.role == USER_ROLE_CUSTOMER) {
            user.active = true;
            user.role = USER_ROLE_CUSTOMER;
            sectionConstantModel = sectionModel;

            user.fcmToken =
                await FireStoreUtils.firebaseMessaging.getToken() ?? '';
            await FireStoreUtils.updateCurrentUser(user);
            if (sectionConstantModel!.serviceTypeFlag == "ecommerce-service") {
              await Provider.of<CartDatabase>(context, listen: false)
                  .allCartProducts
                  .then((value) {
                if (value.isNotEmpty) {
                  showAlertDialog(context, user, sectionModel);
                } else {
                  push(context, EcommeceDashBoardScreen(user: user));
                }
              });
            } else if (sectionConstantModel!.serviceTypeFlag == "cab-service") {
              // push(context, DashBoardCabService(user: user));
              push(context, const CabServiceScreen());
              print('cabfsdservice');
            } else if (sectionConstantModel!.serviceTypeFlag ==
                "rental-service") {
              // push(context, RentalServiceDashBoard(user: user));
              push(
                context,
                RentalServiceHomeScreen(user: user),
              );
            } else if (sectionConstantModel!.serviceTypeFlag ==
                "parcel_delivery") {
              push(context, ParcelDahBoard(user: user));
            } else if (sectionConstantModel!.serviceTypeFlag ==
                "ondemand-service") {
              push(context, OnDemandDahBoard(user: user));
            } else {
              await Provider.of<CartDatabase>(context, listen: false)
                  .allCartProducts
                  .then((value) {
                if (value.isNotEmpty) {
                  showAlertDialog(context, user, sectionConstantModel!);
                } else {
                  push(context, ContainerScreen(user: user));
                }
              });
            }
          } else {
            pushReplacement(context, const AuthScreen());
          }
        } else {
          if (isSkipLogin) {
            sectionConstantModel = sectionModel;

            if (sectionConstantModel!.serviceTypeFlag == "ecommerce-service") {
              push(context, EcommeceDashBoardScreen(user: null));
            } else if (sectionConstantModel!.serviceTypeFlag == "cab-service") {
              // push(context, DashBoardCabService(user: null));
              push(context, const CabServiceScreen());
            } else if (sectionConstantModel!.serviceTypeFlag ==
                "rental-service") {
              push(context, RentalServiceHomeScreen(user: null));
            } else if (sectionConstantModel!.serviceTypeFlag ==
                "parcel_delivery") {
              push(context, ParcelDahBoard(user: null));
            } else if (sectionConstantModel!.serviceTypeFlag ==
                "ondemand-service") {
              // push(context, OnDemandDahBoard(user: null));
              push(context, const CabServiceScreen());
            } else {
              push(context, ContainerScreen(user: null));
            }
          } else {
            pushReplacement(context, const AuthScreen());
          }
        }
      },
      child: Container(
        // width: MediaQuery.of(context).size.width * 0.3,
        // height: MediaQuery.of(context).size.height * 0.13,
        // decoration: BoxDecoration(
        //   shape: BoxShape.circle,
        //   //   borderRadius: BorderRadius.circular(10),
        //   border: Border.all(
        //       color: isDarkMode(context)
        //           ? const Color(DarkContainerBorderColor)
        //           : Colors.grey.shade100,
        //       width: 1),
        //   color: isDarkMode(context)
        //       ? const Color(DarkContainerColor)
        //       : Colors.white,
        //   boxShadow: [
        //     isDarkMode(context)
        //         ? const BoxShadow()
        //         : BoxShadow(
        //             color: Colors.grey.withOpacity(0.5),
        //             blurRadius: 5,
        //           ),
        //   ],
        // ),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              (sectionModel.sectionImage == null ||
                      sectionModel.sectionImage!.isEmpty)
                  ? placeholderImage
                  : sectionModel.sectionImage.toString(),
              height: 60,
              width: 60,
              fit: BoxFit.contain,
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              sectionModel.name.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
              ),
            ).tr(),
          ],
        ),
      ),
    );
  }

  Widget buildExtraItem() {
    return InkWell(
      onTap: () {
        push(context, const CabInterCityServiceScreen());
      },
      child: SizedBox(
        child: Container(
          // color: Colors.blueAccent,
          child: Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/car_icon.png',
                  color: Colors.red,
                  height: 60,
                  width: 60,
                ),
                Text(
                  'Intercity\n Outstation',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context, User? user, SectionModel sectionModel) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () async {
        if (sectionModel.serviceTypeFlag == "ecommerce-service") {
          Provider.of<CartDatabase>(context, listen: false).deleteAllProducts();
          push(context, EcommeceDashBoardScreen(user: user));
        } else {
          Provider.of<CartDatabase>(context, listen: false).deleteAllProducts();
          push(context, ContainerScreen(user: user));
        }
      },
    );

    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Alert!"),
      content: const Text(
          "If you select this Section/Service, your previously added items will be removed from the cart."),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
