
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/cab_service/cab_intercity_service_screen.dart';
import 'package:emartconsumer/cab_service/cab_service_screen.dart';
import 'package:emartconsumer/ecommarce_service/ecommarce_dashboard.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/CurrencyModel.dart';
import 'package:emartconsumer/model/SectionModel.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/onDemand_dashboard.dart';
import 'package:emartconsumer/parcel_delivery/parcel_dashboard.dart';
import 'package:emartconsumer/rental_service/rental_service_dash_board.dart';
import 'package:emartconsumer/ui/StoreSelection/blogs/blogprovider.dart';
import 'package:emartconsumer/ui/StoreSelection/carouselsliderservice.dart';
import 'package:emartconsumer/ui/StoreSelection/drawerservice.dart';
import 'package:emartconsumer/ui/container/ContainerScreen.dart';
import 'package:emartconsumer/ui/profile/ProfileScreen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';


import '../../constants.dart';
import '../../model/User.dart';
import '../../services/FirebaseHelper.dart';
import '../../services/helper.dart';
import '../../services/localDatabase.dart';
import '../auth/AuthScreen.dart';
enum StoreDrawerSelection { Dashboard, Home, Order, Profile, Wallet, provideInbox, workerInbox, favoriteService, termsCondition, privacyPolicy, chooseLanguage, Logout, referral, giftCard, driver, Orders }

class StoreSelection extends StatefulWidget {
  const StoreSelection({Key? key}) : super(key: key);

  @override
  StoreSelectionState createState() => StoreSelectionState();
}

class StoreSelectionState extends State<StoreSelection> {
  late Future<List<SectionModel>> _sectionsFuture;
  late CartDatabase cartDatabase;
  int cartCount = 0;
   final fireStoreUtils = FireStoreUtils();
   List<SectionModel> preSectionList = [];
  

  @override
  void initState() {
        _sectionsFuture = fireStoreUtils.getSections();
    super.initState();

    getLanguages();
    setCurrency();
  }

  setCurrency() async {
    await FireStoreUtils().getCurrency().then((value) {
      print("---->" + value.toString());
    
      if (value != null) {
        currencyData = value;
      } else {
        currencyData = CurrencyModel(id: "", code: "USD", decimal: 2, isactive: true, name: "US Dollar", symbol: "\$", symbolatright: false);
      }
    });

    List<Placemark> placeMarks = await placemarkFromCoordinates(MyAppState.selectedPosotion.location!.latitude, MyAppState.selectedPosotion.location!.longitude);
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
  //drawer
  

 
  
  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  StoreDrawerSelection _drawerSelection = StoreDrawerSelection.Home; // Default selection



 


  

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final timegap = DateTime.now().difference(pre_backpress);
        final cantExit = timegap >= const Duration(seconds: 2);
        pre_backpress = DateTime.now();
        if (cantExit) {
          SnackBar snack = SnackBar(
            content: Text(
              "back-button".tr(),
              style: const TextStyle(color: Colors.white),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.black,
          );
          ScaffoldMessenger.of(context).showSnackBar(snack);
          return false; // false will do nothing when back press
        } else {
          return true; // true will exit the app
        }
      },
      child:
       ChangeNotifierProvider.value(
        value: MyAppState.currentUser,
        child: 
        Consumer<User?>(
          builder: (context, user, _) {
          
           
            
            return
     Scaffold(
  drawer: user == null 
    ? null 
    : CustomDrawer(
        drawerSelection: _drawerSelection,
        onDrawerSelectionChanged: (StoreDrawerSelection selection) {
          setState(() {
            _drawerSelection = selection;
          });
        },
      ),
  appBar: AppBar(
    backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
    leading: Padding(
      padding: const EdgeInsets.only(left: 27),
      child: Container(
        height: 55,
        width: 55,
        child: Builder(
          builder: (context) {
            return IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              icon: Image.asset(
                'assets/images/drawer_icon.jpg',
                height: 45,
                width: 45,
                fit: BoxFit.cover,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          }
        ),
      ),
    ),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Center(
            child: Image.asset(
              "assets/images/app_logo_new.png",
              height: 45,
            ),
          ),
        ),
        IconButton(
          padding: const EdgeInsets.only(left: 20),
          icon: Stack(
            clipBehavior: Clip.none,
            children: const [
              Icon(Icons.person),
            ],
          ),
          onPressed: () {
            if (user != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AuthScreen()));
            }
          },
        ),
      ],
    ),
    centerTitle: true,
  ),
  body: SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 15),
                child: Text(
                  "Welcome".tr() + " ${MyAppState.currentUser == null ? '' : MyAppState.currentUser!.firstName}",
                  style: TextStyle(
                    fontSize: 30,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              MainSliders(),
            ],
          ),
        ),
        SizedBox(
          child: Container(
           // color: Theme.of(context).backgroundColor,
            height: 15,
          ),
        ),
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          margin: const EdgeInsets.only(left: 8, right: 8, top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Text(
                  "Our Services",
                  style: TextStyle(
                    fontSize: 22,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<SectionModel>>(
                future: _sectionsFuture,
                initialData: const [],
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final allItems = [null, ...snapshot.data!];

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: allItems.length,
                      itemBuilder: (context, index) {
                        if (allItems[index] == null) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CabInterCityServiceScreen()),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.all(5),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      child: Image.asset('assets/images/INTERCITY ICON PNG.png'),
                                      height: 75,
                                      width: 75,
                                    ),
                                    Text(
                                      "Outstation",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          return buildCuisineCell(allItems[index]!);
                        }
                      },
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        mainAxisExtent: 150,
                      ),
                    );
                  }

                  return showEmptyState('No Categories'.tr(), context);
                },
              ),
            ],
          ),
        ),
        BlogsProvider(),
      ],
    ),
  ),
);

        })));
  }

Widget buildCuisineCell(SectionModel sectionModel) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8,right: 12),
    child: GestureDetector(
      onTap: () async {
        try {
          // Set primary color if needed
         // COLOR_PRIMARY = int.parse(sectionModel.color!.replaceFirst("#", "0xff"));

          // Check and log RIDESORDER and orderId
          assert(RIDESORDER.isNotEmpty, 'RIDESORDER must not be empty');
          print('RIDESORDER: $RIDESORDER');
          print("Section tapped: ${sectionModel.serviceTypeFlag}");

          // Check if the user is authenticated
          if (auth.FirebaseAuth.instance.currentUser != null && MyAppState.currentUser != null) {
            print(" the user you want is Current user ID: ${MyAppState.currentUser!.userID}");
            if (MyAppState.currentUser?.userID == null || MyAppState.currentUser!.userID.isEmpty)
             {
            throw Exception('User ID is null or empty');
              }

             User? user = await FireStoreUtils.getCurrentUser(MyAppState.currentUser!.userID);

            print("User authenticated: ${user != null}");

            if (user == null) {
              throw Exception("User not found in Firestore");
            }

            if (user.role != USER_ROLE_CUSTOMER) {
              throw Exception("User is not a customer");
            }

            print("User is customer");

            // Set user properties
            user.active = true;
            user.role = USER_ROLE_CUSTOMER;
            sectionConstantModel = sectionModel;

            // Get the FCM token
            user.fcmToken = await FireStoreUtils.firebaseMessaging.getToken() ?? '';
            await FireStoreUtils.updateCurrentUser(user);

            print("Section Type: ${sectionConstantModel?.serviceTypeFlag}");

            if (sectionConstantModel?.serviceTypeFlag == null) {
              throw Exception("serviceTypeFlag is null");
            }

            // Navigate based on service type
            switch (sectionConstantModel!.serviceTypeFlag) {
              case "cab-service":
              case "Bike Service":
                print("Navigating to CabServiceScreen");
                push(context, CabServiceScreen());
                break;
              case "rental-service":
                push(context, RentalServiceDashBoard(user: user));
                break;
              case "parcel_delivery":
                push(context, ParcelDahBoard(user: user));
                break;
              case "ondemand-service":
                push(context, OnDemandDahBoard(user: user));
                break;
              default:
                print("Default case - container screen");
                var cartProducts = await Provider.of<CartDatabase>(context, listen: false).allCartProducts;
                if (cartProducts.isNotEmpty) {
                  showAlertDialog(context, user, sectionModel);
                } else {
                  push(context, ContainerScreen(user: user));
                }
            }
          } else {
            handleSkipLogin(context, sectionModel);
          }
        } catch (e, stackTrace) {
          print("Error in buildCuisineCell: $e");
          print("Stack trace: $stackTrace");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("An error occurred: $e"))
          );
        }
      },




          
         child: Container(
  margin: const EdgeInsets.all(5),
  child: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
       // Image loading from Firebase Firestore and Firebase Storage
        Image.network(
          (sectionModel.sectionImage == null || sectionModel.sectionImage!.isEmpty) 
              ? placeholderImage // Fallback image if sectionImage is null or empty
              : sectionModel.sectionImage.toString(), // Display the actual image
          height: 75,
          width: 75,
          fit: BoxFit.contain, // Contain the image within the given dimensions
        ),
        const SizedBox(
          height: 15, // Space between the image and text
        ),
        Text(
          sectionModel.name.toString(), // Display section name
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ).tr(), // Assuming you are using a localization package for translation
      
    ]),
  ),
)
)
);
}
  Future<void> getLanguages() async {
    await FireStoreUtils.firestore.collection(Setting).doc("languages").get().then((value) {
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
      content: const Text("If you select this Section/Service, your previously added items will be removed from the cart."),
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
  
void handleSkipLogin(BuildContext context, SectionModel sectionModel) {
  print("isSkipLogin: $isSkipLogin");
  if (isSkipLogin) {
    sectionConstantModel = sectionModel;
    if (sectionConstantModel?.serviceTypeFlag == null) {
      print("Error: serviceTypeFlag is null in skip login flow");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred. Please try again."))
      );
      return;
    }
    switch (sectionConstantModel!.serviceTypeFlag) {
      case "Bike Service":
      case "cab-service":
        print("Skipping login, navigating to CabServiceScreen");
        push(context, CabServiceScreen());
        break;
      case "rental-service":
        push(context, RentalServiceDashBoard(user: null));
        break;
      case "parcel_delivery":
        push(context, ParcelDahBoard(user: null));
        break;
      case "ondemand-service":
        push(context, OnDemandDahBoard(user: null));
        break;
      default:
        push(context, ContainerScreen(user: null));
    }
  } else {
    pushReplacement(context, const AuthScreen());
  }
}
}
