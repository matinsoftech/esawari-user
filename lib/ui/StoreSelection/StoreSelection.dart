import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/cab_service/cab_intercity_service_screen.dart';
import 'package:emartconsumer/cab_service/cab_service_screen.dart';
import 'package:emartconsumer/cab_service/dashboard_cab_service.dart';
import 'package:emartconsumer/ecommarce_service/ecommarce_dashboard.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/CurrencyModel.dart';
import 'package:emartconsumer/model/SectionModel.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/onDemand_dashboard.dart';
import 'package:emartconsumer/parcel_delivery/parcel_dashboard.dart';
import 'package:emartconsumer/rental_service/rental_service_dash_board.dart';
import 'package:emartconsumer/ui/QrCodeScanner/QrCodeScanner.dart';
import 'package:emartconsumer/ui/container/ContainerScreen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../model/User.dart';
import '../../services/FirebaseHelper.dart';
import '../../services/helper.dart';
import '../../services/localDatabase.dart';
import '../auth/AuthScreen.dart';

class StoreSelection extends StatefulWidget {
  const StoreSelection({Key? key}) : super(key: key);

  @override
  StoreSelectionState createState() => StoreSelectionState();
}

class StoreSelectionState extends State<StoreSelection> {
  late CartDatabase cartDatabase;
  int cartCount = 0;
  final fireStoreUtils = FireStoreUtils();
  // List<SectionModel> preSectionList = [];

  @override
  void initState() {
    super.initState();

    getLanguages();
    setCurrency();
  }

  setCurrency() async {
    await FireStoreUtils().getCurrency().then((value) {
      print("---->" + value.toString());
      /*for (var element in value) {
        if (element.isactive = true) {
          currencyData = element;
        }
      }*/
      if (value != null) {
        currencyData = value;
      } else {
        currencyData = CurrencyModel(
            id: "",
            code: "USD",
            decimal: 2,
            isactive: true,
            name: "US Dollar",
            symbol: "\$",
            symbolatright: false);
      }
    });

    List<Placemark> placeMarks = await placemarkFromCoordinates(
        MyAppState.selectedPosotion.location!.latitude,
        MyAppState.selectedPosotion.location!.longitude);
    country = placeMarks.first.country;

    await FireStoreUtils().getRazorPayDemo();
    await FireStoreUtils.getPaypalSettingData();
    await FireStoreUtils.getStripeSettingData();
    await FireStoreUtils.getPayStackSettingData();
    await FireStoreUtils.getFlutterWaveSettingData();
    await FireStoreUtils.getPaytmSettingData();
    await FireStoreUtils.getPayFastSettingData();
    await FireStoreUtils.getWalletSettingData();
    await FireStoreUtils.getMercadoPagoSettingData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cartDatabase = Provider.of<CartDatabase>(context);
  }

  DateTime pre_backpress = DateTime.now();
  List images = [
    'https://cdn.pixabay.com/photo/2023/06/07/04/23/road-8046167_1280.jpg',
    'https://cdn.pixabay.com/photo/2014/12/16/09/18/rental-bikes-570111_960_720.jpg',
    'https://cdn.pixabay.com/photo/2021/08/19/14/00/field-6558125_1280.jpg',
    'https://cdn.pixabay.com/photo/2021/08/19/14/00/field-6558125_1280.jpg',
    'https://cdn.pixabay.com/photo/2014/12/16/09/18/rental-bikes-570111_960_720.jpg',
    'https://cdn.pixabay.com/photo/2016/07/08/18/32/bike-1505039_1280.jpg',
  ];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //draer and user current location
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on,
                  size: 15,
                ),
                Container(
                  width: MediaQuery.of(context).size.width - (28 + 90),
                  child: Text(
                    MyAppState.selectedPosotion
                        .getFullAddress()
                        .toString()
                        .tr(),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDarkMode(context) ? Colors.white : Colors.black,
                      fontSize: 14,
                      fontFamily: "Poppinsm",
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down)
              ],
            ),
          ),
          SizedBox(height: 10),
          //? welcome note to the user
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              "Welcome".tr() +
                  " ${MyAppState.currentUser == null ? '' : MyAppState.currentUser!.firstName ?? ''}",
              style: const TextStyle(fontSize: 22, color: Colors.black),
            ).tr(),
          ),
          SizedBox(height: 10),
          // caroulse
          SizedBox(
            height: 200,
            child: CarouselSlider(
              options: CarouselOptions(
                height: 400.0,
                enableInfiniteScroll: true,
                reverse: false,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
              ),
              items: images.map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(color: Colors.grey.shade200),
                      child: Image.network(
                        '${i}',
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
          // GestureDetector(
          //   onTap: () {},
          //   child: Banner_Url.isEmpty
          //       ? Container()
          //       : Container(
          //           margin: const EdgeInsets.all(10),
          //           width: MediaQuery.of(context).size.width,
          //           height: MediaQuery.of(context).size.width / 2.5,
          //           decoration: BoxDecoration(
          //               borderRadius: BorderRadius.circular(10),
          //               border: Border.all(
          //                   color: isDarkMode(context)
          //                       ? const Color(DarkContainerBorderColor)
          //                       : Colors.grey.shade100,
          //                   width: 1),
          //               color: isDarkMode(context)
          //                   ? const Color(DarkContainerColor)
          //                   : Colors.white,
          //               boxShadow: [
          //                 isDarkMode(context)
          //                     ? const BoxShadow()
          //                     : BoxShadow(
          //                         color: Colors.grey.withOpacity(0.5),
          //                         blurRadius: 5,
          //                       ),
          //               ],
          //               image: DecorationImage(
          //                   image: NetworkImage(Banner_Url),
          //                   fit: BoxFit.cover,
          //                   colorFilter: ColorFilter.mode(
          //                       Colors.black.withOpacity(0.5),
          //                       BlendMode.darken))),
          //         ),
          // ),
          // our services section
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              'Our Services',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode(context) ? Colors.white : Colors.black,
                fontSize: 18,
                fontFamily: "Poppinsm",
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10, top: 15),
            child: FutureBuilder<List<SectionModel>>(
                future: fireStoreUtils.getSections(),
                initialData: const [],
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator.adaptive(
                        valueColor:
                            AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
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
                          Center(
                            child: Wrap(
                              spacing: MediaQuery.of(context).size.width * 0.08,
                              runSpacing: 4,
                              children: snapshot.data != null
                                  ? [
                                      ...snapshot.data!.map((data) => SizedBox(
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3 -
                                                50,
                                            child: buildCuisineCell(data),
                                          )),
                                      // Adding the extra item
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    3 -
                                                50,
                                        child:
                                            buildExtraItem(), // Replace with your custom widget
                                      ),
                                    ]
                                  : [
                                      showEmptyState(
                                          'No Categories'.tr(), context),
                                      // Adding the extra item in case of empty state
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    3 -
                                                50,
                                        child:
                                            buildExtraItem(), // Replace with your custom widget
                                      ),
                                    ],
                            ),
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
          )
        ],
      ),
    );
  }

  Widget buildCuisineCell(SectionModel sectionModel) {
    return GestureDetector(
      onTap: () async {
        COLOR_PRIMARY =
            int.parse(sectionModel.color!.replaceFirst("#", "0xff"));

        print("=========>");
        print(sectionModel.adminCommision!.toJson());
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
              push(context, DashBoardCabService(user: user));
            } else if (sectionConstantModel!.serviceTypeFlag ==
                "rental-service") {
              push(context, RentalServiceDashBoard(user: user));
            } else if (sectionConstantModel!.serviceTypeFlag ==
                "parcel_delivery") {
              push(context, ParcelDahBoard(user: user));
            } else if (sectionConstantModel!.serviceTypeFlag ==
                "ondemand-service") {
              push(
                  context,
                  OnDemandDahBoard(
                    user: user,
                  ));
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
              push(context, RentalServiceDashBoard(user: null));
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

        // if (sectionModel.serviceTypeFlag == "cab-service") {
        //   auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
        //   if (firebaseUser != null) {
        //     User? user = await FireStoreUtils.getCurrentUser(firebaseUser.uid);
        //
        //     if (user!.role == USER_ROLE_CUSTOMER) {
        //       user.active = true;
        //       user.role = USER_ROLE_CUSTOMER;
        //       SELECTED_CATEGORY = sectionModel.id.toString();
        //       SELECTED_SECTION_NAME = sectionModel.name.toString();
        //       serviceTypeFlag = sectionModel.serviceTypeFlag.toString();
        //       isDineEnable = sectionModel.dineInActive!;
        //       COLOR_PRIMARY = int.parse(sectionModel.color!.replaceFirst("#", "0xff"));
        //       user.fcmToken = await FireStoreUtils.firebaseMessaging.getToken() ?? '';
        //       await FireStoreUtils.updateCurrentUser(user);
        //       push(context, DashBoardCabService(user: user));
        //     } else {
        //       pushReplacement(context, const AuthScreen());
        //     }
        //   } else {
        //     if (isSkipLogin) {
        //       SELECTED_CATEGORY = sectionModel.id.toString();
        //       SELECTED_SECTION_NAME = sectionModel.name.toString();
        //       isDineEnable = sectionModel.dineInActive!;
        //       serviceTypeFlag = sectionModel.serviceTypeFlag.toString();
        //       COLOR_PRIMARY = int.parse(sectionModel.color!.replaceFirst("#", "0xff"));
        //       push(context, DashBoardCabService(user: null));
        //     } else {
        //       pushReplacement(context, const AuthScreen());
        //     }
        //   }
        // }
        // else if (sectionModel.serviceTypeFlag == "parcel_delivery") {
        //   auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
        //   if (firebaseUser != null) {
        //     User? user = await FireStoreUtils.getCurrentUser(firebaseUser.uid);
        //
        //     if (user != null && user.role == USER_ROLE_CUSTOMER) {
        //       user.active = true;
        //       user.role = USER_ROLE_CUSTOMER;
        //       SELECTED_CATEGORY = sectionModel.id.toString();
        //       SELECTED_SECTION_NAME = sectionModel.name.toString();
        //       isDineEnable = sectionModel.dineInActive!;
        //       serviceTypeFlag = sectionModel.serviceTypeFlag.toString();
        //       COLOR_PRIMARY = int.parse(sectionModel.color!.replaceFirst("#", "0xff"));
        //       user.fcmToken = await FireStoreUtils.firebaseMessaging.getToken() ?? '';
        //       await FireStoreUtils.updateCurrentUser(user);
        //       push(context, ParcelDahBoard(user: user));
        //     } else {
        //       pushReplacement(context, const AuthScreen());
        //     }
        //   } else {
        //     if (isSkipLogin) {
        //       SELECTED_CATEGORY = sectionModel.id.toString();
        //       SELECTED_SECTION_NAME = sectionModel.name.toString();
        //       serviceTypeFlag = sectionModel.serviceTypeFlag.toString();
        //       isDineEnable = sectionModel.dineInActive!;
        //       COLOR_PRIMARY = int.parse(sectionModel.color!.replaceFirst("#", "0xff"));
        //       push(context, ParcelDahBoard(user: null));
        //     } else {
        //       pushReplacement(context, const AuthScreen());
        //     }
        //   }
        // }
        // else if (sectionModel.serviceTypeFlag == "rental-service") {
        //   auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
        //   if (firebaseUser != null) {
        //     User? user = await FireStoreUtils.getCurrentUser(firebaseUser.uid);
        //
        //     if (user!.role == USER_ROLE_CUSTOMER) {
        //       user.active = true;
        //       user.role = USER_ROLE_CUSTOMER;
        //       SELECTED_CATEGORY = sectionModel.id.toString();
        //       SELECTED_SECTION_NAME = sectionModel.name.toString();
        //       serviceTypeFlag = sectionModel.serviceTypeFlag.toString();
        //       isDineEnable = sectionModel.dineInActive!;
        //       COLOR_PRIMARY = int.parse(sectionModel.color!.replaceFirst("#", "0xff"));
        //       user.fcmToken = await FireStoreUtils.firebaseMessaging.getToken() ?? '';
        //       await FireStoreUtils.updateCurrentUser(user);
        //       push(context, RentalServiceDashBoard(user: user));
        //     } else {
        //       pushReplacement(context, const AuthScreen());
        //     }
        //   } else {
        //     if (isSkipLogin) {
        //       SELECTED_CATEGORY = sectionModel.id.toString();
        //       SELECTED_SECTION_NAME = sectionModel.name.toString();
        //       serviceTypeFlag = sectionModel.serviceTypeFlag.toString();
        //       isDineEnable = sectionModel.dineInActive!;
        //       COLOR_PRIMARY = int.parse(sectionModel.color!.replaceFirst("#", "0xff"));
        //       push(context, RentalServiceDashBoard(user: null));
        //     } else {
        //       pushReplacement(context, const AuthScreen());
        //     }
        //   }
        // } else {
        //
        // }
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

  Future<void> getLanguages() async {
    await FireStoreUtils.firestore
        .collection(Setting)
        .doc("languages")
        .get()
        .then((value) {
      List list = value.data()!["list"];
      isLanguageShown = (list.isNotEmpty);
    });
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
}
