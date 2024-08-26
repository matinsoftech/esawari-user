import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/ecommarce_service/EcommerceHomeScreen.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/services/localDatabase.dart';
import 'package:emartconsumer/ui/Language/language_choose_screen.dart';
import 'package:emartconsumer/ui/QrCodeScanner/QrCodeScanner.dart';
import 'package:emartconsumer/ui/StoreSelection/StoreSelection.dart';
import 'package:emartconsumer/ui/auth/AuthScreen.dart';
import 'package:emartconsumer/ui/cartScreen/CartScreen.dart';
import 'package:emartconsumer/ui/chat_screen/inbox_driver_screen.dart';
import 'package:emartconsumer/ui/chat_screen/inbox_screen.dart';
import 'package:emartconsumer/ui/cuisinesScreen/CuisinesScreen.dart';
import 'package:emartconsumer/ui/dineInScreen/dine_in_screen.dart';
import 'package:emartconsumer/ui/dineInScreen/my_booking_screen.dart';
import 'package:emartconsumer/ui/gift_card/gift_card_screen.dart';
import 'package:emartconsumer/ui/home/favourite_item.dart';
import 'package:emartconsumer/ui/home/favourite_store.dart';
import 'package:emartconsumer/ui/ordersScreen/OrdersScreen.dart';
import 'package:emartconsumer/ui/privacy_policy/privacy_policy.dart';
import 'package:emartconsumer/ui/profile/ProfileScreen.dart';
import 'package:emartconsumer/ui/referral_screen/referral_screen.dart';
import 'package:emartconsumer/ui/searchScreen/SearchScreen.dart';
import 'package:emartconsumer/ui/termsAndCondition/terms_and_codition.dart';
import 'package:emartconsumer/ui/wallet/walletScreen.dart';
import 'package:emartconsumer/userPrefrence.dart';
import 'package:emartconsumer/utils/DarkThemeProvider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum DrawerSelectionEcommarce {
  Dashboard,
  Home,
  Wallet,
  dineIn,
  Cuisines,
  Search,
  Cart,
  referral,
  Profile,
  Orders,
  MyBooking,
  chooseLanguage,
  termsCondition,
  privacyPolicy,
  inbox,
  driver,
  Logout,
  LikedStore,
  LikedProduct,
  giftCard
}

class EcommeceDashBoardScreen extends StatefulWidget {
  final User? user;
  final Widget currentWidget;
  final String vendorId;
  final String appBarTitle;
  final DrawerSelectionEcommarce drawerSelection;

  EcommeceDashBoardScreen(
      {Key? key,
      required this.user,
      currentWidget,
      vendorId,
      appBarTitle,
      this.drawerSelection = DrawerSelectionEcommarce.Home})
      : appBarTitle = appBarTitle ?? 'Home'.tr(),
        vendorId = vendorId ?? "",
        currentWidget = currentWidget ??
            EcommerceHomeScreen(
              user: MyAppState.currentUser,
              vendorId: vendorId,
            ),
        super(key: key);

  @override
  _EcommeceDashBoardScreen createState() {
    return _EcommeceDashBoardScreen();
  }
}

class _EcommeceDashBoardScreen extends State<EcommeceDashBoardScreen> {
  var key = GlobalKey<ScaffoldState>();

  late CartDatabase cartDatabase;
  late User user;
  late String _appBarTitle;
  final fireStoreUtils = FireStoreUtils();

  late Widget _currentWidget;
  late DrawerSelectionEcommarce _drawerSelection;

  int cartCount = 0;
  bool? isWalletEnable;

  @override
  void initState() {
    super.initState();
    FireStoreUtils.getWalletSettingData();
    //FireStoreUtils.walletSettingData().then((value) => isWalletEnable = value);
    if (widget.user != null) {
      user = widget.user!;
    } else {
      user = User();
    }
    _currentWidget = widget.currentWidget;
    _appBarTitle = widget.appBarTitle;
    _drawerSelection = widget.drawerSelection;
    //getKeyHash();
    /// On iOS, we request notification permissions, Does nothing and returns null on Android
    FireStoreUtils.firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    getTaxList();
  }

  getTaxList() async {
    await FireStoreUtils().getTaxList(sectionConstantModel!.id).then((value) {
      if (value != null) {
        taxList = value;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cartDatabase = Provider.of<CartDatabase>(context);
  }

  DateTime pre_backpress = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        if (_currentWidget is! EcommerceHomeScreen) {
          setState(() {
            _drawerSelection = DrawerSelectionEcommarce.Home;
            _appBarTitle = 'Store'.tr();
            _currentWidget = EcommerceHomeScreen(
              user: MyAppState.currentUser,
            );
          });
          return false;
        } else {
          pushAndRemoveUntil(context, const StoreSelection(), false);
          return true;
        }
      },
      child: ChangeNotifierProvider.value(
        value: user,
        child: Consumer<User>(
          builder: (context, user, _) {
            return Scaffold(
              extendBodyBehindAppBar:
                  _drawerSelection == DrawerSelectionEcommarce.Wallet
                      ? true
                      : false,
              key: key,
              drawer: Drawer(
                child: Container(
                    color: isDarkMode(context) ? Colors.black : null,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              Consumer<User>(builder: (context, user, _) {
                                return DrawerHeader(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      displayCircleImage(
                                          user.profilePictureURL, 75, false),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0),
                                                  child: Text(
                                                    user.fullName(),
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8.0),
                                                    child: Text(
                                                      user.email,
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    )),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              !themeChange.darkTheme
                                                  ? const Icon(
                                                      Icons.light_mode_sharp)
                                                  : const Icon(
                                                      Icons.nightlight),
                                              Switch(
                                                // thumb color (round icon)
                                                splashRadius: 50.0,
                                                // activeThumbImage: const AssetImage('https://lists.gnu.org/archive/html/emacs-devel/2015-10/pngR9b4lzUy39.png'),
                                                // inactiveThumbImage: const AssetImage('http://wolfrosch.com/_img/works/goodies/icon/vim@2x'),

                                                value: themeChange.darkTheme,
                                                onChanged: (value) => setState(
                                                    () => themeChange
                                                        .darkTheme = value),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(COLOR_PRIMARY),
                                  ),
                                );
                              }),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection ==
                                      DrawerSelectionEcommarce.Dashboard,
                                  title: const Text('Dashboard').tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    pushAndRemoveUntil(
                                        context, const StoreSelection(), false);
                                  },
                                  leading: Image.asset(
                                    'assets/images/dashboard.png',
                                    color: _drawerSelection ==
                                            DrawerSelectionEcommarce.Cuisines
                                        ? Color(COLOR_PRIMARY)
                                        : isDarkMode(context)
                                            ? Colors.grey.shade200
                                            : Colors.grey.shade600,
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection ==
                                      DrawerSelectionEcommarce.Home,
                                  title: const Text('Stores').tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _drawerSelection =
                                          DrawerSelectionEcommarce.Home;
                                      _appBarTitle = 'Stores'.tr();
                                      _currentWidget = EcommerceHomeScreen(
                                        user: MyAppState.currentUser,
                                      );
                                    });
                                  },
                                  leading: const Icon(CupertinoIcons.home),
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                    selected: _drawerSelection ==
                                        DrawerSelectionEcommarce.Cuisines,
                                    leading: Image.asset(
                                      'assets/images/category.png',
                                      color: _drawerSelection ==
                                              DrawerSelectionEcommarce.Cuisines
                                          ? Color(COLOR_PRIMARY)
                                          : isDarkMode(context)
                                              ? Colors.grey.shade200
                                              : Colors.grey.shade600,
                                      width: 24,
                                      height: 24,
                                    ),
                                    title: const Text('Categories').tr(),
                                    onTap: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        _drawerSelection =
                                            DrawerSelectionEcommarce.Cuisines;
                                        _appBarTitle = 'Categories'.tr();
                                        _currentWidget = const CuisinesScreen();
                                      });
                                    }),
                              ),
                              Visibility(
                                visible: sectionConstantModel!.dineInActive!,
                                child: ListTileTheme(
                                  style: ListTileStyle.drawer,
                                  selectedColor: Color(COLOR_PRIMARY),
                                  child: ListTile(
                                      selected: _drawerSelection ==
                                          DrawerSelectionEcommarce.dineIn,
                                      leading: const Icon(Icons.restaurant),
                                      title: const Text('Dine-in').tr(),
                                      onTap: () {
                                        Navigator.pop(context);

                                        setState(() {
                                          _drawerSelection =
                                              DrawerSelectionEcommarce.dineIn;
                                          _appBarTitle = 'Dine-In'.tr();
                                          _currentWidget = DineInScreen(
                                            user: MyAppState.currentUser!,
                                          );
                                        });
                                      }),
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                    selected: _drawerSelection ==
                                        DrawerSelectionEcommarce.Search,
                                    title: const Text('Search').tr(),
                                    leading: const Icon(Icons.search),
                                    onTap: () async {
                                      push(context, const SearchScreen());
                                      // Navigator.pop(context);
                                      // setState(() {
                                      //   _drawerSelection = DrawerSelectionEcommarce.Search;
                                      //   _appBarTitle = 'search'.tr();
                                      //   _currentWidget = SearchScreen();
                                      // });
                                      // await Future.delayed(const Duration(seconds: 1), () {
                                      //   setState(() {});
                                      // });
                                    }),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection ==
                                      DrawerSelectionEcommarce.LikedStore,
                                  title: const Text('Favourite Stores').tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    if (MyAppState.currentUser == null) {
                                      push(context, const AuthScreen());
                                    } else {
                                      setState(() {
                                        _drawerSelection =
                                            DrawerSelectionEcommarce.LikedStore;
                                        _appBarTitle = 'Favourite Stores'.tr();
                                        _currentWidget =
                                            const FavouriteStoreScreen();
                                      });
                                    }
                                  },
                                  leading: const Icon(CupertinoIcons.heart),
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection ==
                                      DrawerSelectionEcommarce.LikedProduct,
                                  title: const Text('Favourite Item').tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    if (MyAppState.currentUser == null) {
                                      push(context, const AuthScreen());
                                    } else {
                                      setState(() {
                                        _drawerSelection =
                                            DrawerSelectionEcommarce
                                                .LikedProduct;
                                        _appBarTitle = 'Favourite Item'.tr();
                                        _currentWidget =
                                            const FavouriteItemScreen();
                                      });
                                    }
                                  },
                                  leading: const Icon(CupertinoIcons.heart),
                                ),
                              ),
                              Visibility(
                                visible:
                                    UserPreference.getWalletData() ?? false,
                                child: ListTileTheme(
                                  style: ListTileStyle.drawer,
                                  selectedColor: Color(COLOR_PRIMARY),
                                  child: ListTile(
                                    selected: _drawerSelection ==
                                        DrawerSelectionEcommarce.Wallet,
                                    leading: const Icon(
                                        Icons.account_balance_wallet_outlined),
                                    title: const Text('Wallet').tr(),
                                    onTap: () {
                                      Navigator.pop(context);
                                      if (MyAppState.currentUser == null) {
                                        push(context, const AuthScreen());
                                      } else {
                                        setState(() {
                                          _drawerSelection =
                                              DrawerSelectionEcommarce.Wallet;
                                          _appBarTitle = 'Wallet'.tr();
                                          _currentWidget = const WalletScreen();
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection ==
                                      DrawerSelectionEcommarce.Cart,
                                  leading: const Icon(CupertinoIcons.cart),
                                  title: const Text('Cart').tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    if (MyAppState.currentUser == null) {
                                      push(context, const AuthScreen());
                                    } else {
                                      setState(() {
                                        _drawerSelection =
                                            DrawerSelectionEcommarce.Cart;
                                        _appBarTitle = 'Your Cart'.tr();
                                        _currentWidget = const CartScreen();
                                      });
                                    }
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                    selected: _drawerSelection ==
                                        DrawerSelectionEcommarce.giftCard,
                                    title: Text('Gift Card').tr(),
                                    leading: Icon(Icons.card_giftcard),
                                    onTap: () async {
                                      key.currentState!.openEndDrawer();
                                      push(context, const GiftCardScreen());
                                    }),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection ==
                                      DrawerSelectionEcommarce.referral,
                                  leading: Image.asset(
                                    'assets/images/refer.png',
                                    width: 28,
                                    color: Colors.grey,
                                  ),
                                  title: const Text('Refer a friend').tr(),
                                  onTap: () async {
                                    if (MyAppState.currentUser == null) {
                                      Navigator.pop(context);
                                      push(context, const AuthScreen());
                                    } else {
                                      Navigator.pop(context);
                                      push(context, const ReferralScreen());
                                    }
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection ==
                                      DrawerSelectionEcommarce.Profile,
                                  leading: const Icon(CupertinoIcons.person),
                                  title: const Text('Profile').tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    if (MyAppState.currentUser == null) {
                                      push(context, const AuthScreen());
                                    } else {
                                      setState(() {
                                        _drawerSelection =
                                            DrawerSelectionEcommarce.Profile;
                                        _appBarTitle = 'My Profile'.tr();
                                        _currentWidget = const ProfileScreen();
                                      });
                                    }
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection ==
                                      DrawerSelectionEcommarce.Orders,
                                  leading: Image.asset(
                                    'assets/images/truck.png',
                                    color: _drawerSelection ==
                                            DrawerSelectionEcommarce.Orders
                                        ? Color(COLOR_PRIMARY)
                                        : isDarkMode(context)
                                            ? Colors.grey.shade200
                                            : Colors.grey.shade600,
                                    width: 24,
                                    height: 24,
                                  ),
                                  title: const Text('Orders').tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    if (MyAppState.currentUser == null) {
                                      push(context, const AuthScreen());
                                    } else {
                                      setState(() {
                                        _drawerSelection =
                                            DrawerSelectionEcommarce.Orders;
                                        _appBarTitle = 'Orders'.tr();
                                        _currentWidget = OrdersScreen();
                                      });
                                    }
                                  },
                                ),
                              ),
                              Visibility(
                                visible: sectionConstantModel!.dineInActive!,
                                child: ListTileTheme(
                                  style: ListTileStyle.drawer,
                                  selectedColor: Color(COLOR_PRIMARY),
                                  child: ListTile(
                                    selected: _drawerSelection ==
                                        DrawerSelectionEcommarce.MyBooking,
                                    leading: Image.asset(
                                      'assets/images/your_booking.png',
                                      color: _drawerSelection ==
                                              DrawerSelectionEcommarce.MyBooking
                                          ? Color(COLOR_PRIMARY)
                                          : isDarkMode(context)
                                              ? Colors.grey.shade200
                                              : Colors.grey.shade600,
                                      width: 24,
                                      height: 24,
                                    ),
                                    title: const Text('Dine-In Bookings').tr(),
                                    onTap: () {
                                      Navigator.pop(context);
                                      if (MyAppState.currentUser == null) {
                                        push(context, const AuthScreen());
                                      } else {
                                        setState(() {
                                          _drawerSelection =
                                              DrawerSelectionEcommarce
                                                  .MyBooking;
                                          _appBarTitle =
                                              'Dine-In Bookings'.tr();
                                          _currentWidget =
                                              const MyBookingScreen();
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: isLanguageShown,
                                child: ListTileTheme(
                                  style: ListTileStyle.drawer,
                                  selectedColor: Color(COLOR_PRIMARY),
                                  child: ListTile(
                                    selected: _drawerSelection ==
                                        DrawerSelectionEcommarce.chooseLanguage,
                                    leading: Icon(
                                      Icons.language,
                                      color: _drawerSelection ==
                                              DrawerSelectionEcommarce
                                                  .chooseLanguage
                                          ? Color(COLOR_PRIMARY)
                                          : isDarkMode(context)
                                              ? Colors.grey.shade200
                                              : Colors.grey.shade600,
                                    ),
                                    title: const Text('Language').tr(),
                                    onTap: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        _drawerSelection =
                                            DrawerSelectionEcommarce
                                                .chooseLanguage;
                                        _appBarTitle = 'Language'.tr();
                                        _currentWidget = LanguageChooseScreen(
                                          isContainer: true,
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection ==
                                      DrawerSelectionEcommarce.termsCondition,
                                  leading: const Icon(Icons.policy),
                                  title: const Text('Terms and Condition').tr(),
                                  onTap: () async {
                                    push(context, const TermsAndCondition());
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection ==
                                      DrawerSelectionEcommarce.privacyPolicy,
                                  leading: const Icon(Icons.privacy_tip),
                                  title: const Text('Privacy policy').tr(),
                                  onTap: () async {
                                    push(context, const PrivacyPolicyScreen());
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection ==
                                      DrawerSelectionEcommarce.inbox,
                                  leading: const Icon(
                                      CupertinoIcons.chat_bubble_2_fill),
                                  title: const Text('Store Inbox').tr(),
                                  onTap: () {
                                    if (MyAppState.currentUser == null) {
                                      Navigator.pop(context);
                                      push(context, const AuthScreen());
                                    } else {
                                      Navigator.pop(context);
                                      setState(() {
                                        _drawerSelection =
                                            DrawerSelectionEcommarce.inbox;
                                        _appBarTitle = 'Store Inbox'.tr();
                                        _currentWidget = const InboxScreen();
                                      });
                                    }
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection ==
                                      DrawerSelectionEcommarce.driver,
                                  leading: const Icon(
                                      CupertinoIcons.chat_bubble_2_fill),
                                  title: const Text('Driver Inbox').tr(),
                                  onTap: () {
                                    if (MyAppState.currentUser == null) {
                                      Navigator.pop(context);
                                      push(context, const AuthScreen());
                                    } else {
                                      Navigator.pop(context);
                                      setState(() {
                                        _drawerSelection =
                                            DrawerSelectionEcommarce.driver;
                                        _appBarTitle = 'Driver Inbox'.tr();
                                        _currentWidget =
                                            const InboxDriverScreen();
                                      });
                                    }
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection ==
                                      DrawerSelectionEcommarce.Logout,
                                  leading: const Icon(Icons.logout),
                                  title: Text((MyAppState.currentUser == null)
                                      ? 'Log In'.tr()
                                      : 'Log Out'.tr()),
                                  onTap: () async {
                                    if (MyAppState.currentUser == null) {
                                      pushAndRemoveUntil(
                                          context, const AuthScreen(), false);
                                    } else {
                                      Navigator.pop(context);
                                      //user.active = false;
                                      user.lastOnlineTimestamp =
                                          Timestamp.now();
                                      user.fcmToken = "";
                                      await FireStoreUtils.updateCurrentUser(
                                          user);
                                      await auth.FirebaseAuth.instance
                                          .signOut();
                                      MyAppState.currentUser = null;
                                      // COLOR_PRIMARY = 0xFF00B761;
                                      Provider.of<CartDatabase>(context,
                                              listen: false)
                                          .deleteAllProducts();
                                      pushAndRemoveUntil(
                                          context, const AuthScreen(), false);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("V : $appVersion"),
                        )
                      ],
                    )),
              ),
              appBar: AppBar(
                elevation:
                    _drawerSelection == DrawerSelectionEcommarce.Wallet ? 0 : 0,
                centerTitle: _drawerSelection == DrawerSelectionEcommarce.Wallet
                    ? true
                    : false,
                backgroundColor:
                    _drawerSelection == DrawerSelectionEcommarce.Wallet
                        ? Colors.transparent
                        : isDarkMode(context)
                            ? Colors.black
                            : Colors.white,
                //isDarkMode(context) ? Color(DARK_COLOR) : null,
                leading: IconButton(
                    visualDensity: const VisualDensity(horizontal: -4),
                    padding: const EdgeInsets.only(right: 5),
                    icon: Image(
                      image: const AssetImage("assets/images/menu.png"),
                      width: 20,
                      color: _drawerSelection == DrawerSelectionEcommarce.Wallet
                          ? Colors.white
                          : isDarkMode(context)
                              ? Colors.white
                              : Colors.black,
                    ),
                    onPressed: () => key.currentState!.openDrawer()),
                // iconTheme: IconThemeData(color: Colors.blue),
                title: Text(
                  _appBarTitle,
                  style: TextStyle(
                      fontSize: 18,
                      color: _drawerSelection == DrawerSelectionEcommarce.Wallet
                          ? Colors.white
                          : isDarkMode(context)
                              ? Colors.white
                              : Colors.black,
                      //isDarkMode(context) ? Colors.white : Colors.black,
                      fontWeight: FontWeight.normal),
                ),
                actions: _drawerSelection == DrawerSelectionEcommarce.Wallet ||
                        _drawerSelection == DrawerSelectionEcommarce.MyBooking
                    ? []
                    : _drawerSelection == DrawerSelectionEcommarce.dineIn
                        ? [
                            IconButton(
                                padding: const EdgeInsets.only(right: 20),
                                visualDensity:
                                    const VisualDensity(horizontal: -4),
                                tooltip: 'QrCode'.tr(),
                                icon: Image(
                                  image: const AssetImage(
                                      "assets/images/qrscan.png"),
                                  width: 20,
                                  color: isDarkMode(context)
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                onPressed: () {
                                  push(
                                    context,
                                    const QrCodeScanner(
                                      presectionList: [],
                                    ),
                                  );
                                }),
                            IconButton(
                                visualDensity:
                                    const VisualDensity(horizontal: -4),
                                padding: const EdgeInsets.only(right: 10),
                                icon: Image(
                                  image: const AssetImage(
                                      "assets/images/search.png"),
                                  width: 20,
                                  color:
                                      isDarkMode(context) ? Colors.white : null,
                                ),
                                onPressed: () {
                                  push(context, const SearchScreen());
                                }),
                          ]
                        : [
                            IconButton(
                                padding: const EdgeInsets.only(right: 20),
                                visualDensity:
                                    const VisualDensity(horizontal: -4),
                                tooltip: 'QrCode'.tr(),
                                icon: Image(
                                  image: const AssetImage(
                                      "assets/images/qrscan.png"),
                                  width: 20,
                                  color: isDarkMode(context)
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                onPressed: () {
                                  push(
                                    context,
                                    const QrCodeScanner(
                                      presectionList: [],
                                    ),
                                  );
                                }),
                            IconButton(
                                visualDensity:
                                    const VisualDensity(horizontal: -4),
                                padding: const EdgeInsets.only(right: 10),
                                icon: Image(
                                  image: const AssetImage(
                                      "assets/images/search.png"),
                                  width: 20,
                                  color:
                                      isDarkMode(context) ? Colors.white : null,
                                ),
                                onPressed: () {
                                  push(context, const SearchScreen());
                                }),
                            if (_currentWidget is! CartScreen ||
                                _currentWidget is! ProfileScreen)
                              IconButton(
                                  padding: const EdgeInsets.only(right: 20),
                                  visualDensity:
                                      const VisualDensity(horizontal: -4),
                                  tooltip: 'Cart'.tr(),
                                  icon: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Image(
                                        image: const AssetImage(
                                            "assets/images/cart.png"),
                                        width: 20,
                                        color: isDarkMode(context)
                                            ? Colors.white
                                            : null,
                                      ),
                                      StreamBuilder<List<CartProduct>>(
                                        stream: cartDatabase.watchProducts,
                                        builder: (context, snapshot) {
                                          cartCount = 0;
                                          if (snapshot.hasData) {
                                            snapshot.data!.forEach((element) {
                                              cartCount += element.quantity;
                                            });
                                          }
                                          return Visibility(
                                            visible: cartCount >= 1,
                                            child: Positioned(
                                              right: -6,
                                              top: -8,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(COLOR_PRIMARY),
                                                ),
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth: 12,
                                                  minHeight: 12,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    cartCount <= 99
                                                        ? '$cartCount'
                                                        : '+99',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      // fontSize: 10,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                  onPressed: () {
                                    if (MyAppState.currentUser == null) {
                                      push(context, const AuthScreen());
                                    } else {
                                      setState(() {
                                        _drawerSelection =
                                            DrawerSelectionEcommarce.Cart;
                                        _appBarTitle = 'Your Cart'.tr();
                                        _currentWidget = const CartScreen();
                                      });
                                    }
                                  }),
                          ],
              ),
              body: _currentWidget,
            );
          },
        ),
      ),
    );
  }

// Widget _buildSearchField() => TextField(
//       controller: searchController,
//       onChanged: _searchScreenStateKey.currentState == null
//           ? (str) {
//               setState(() {});
//             }
//           : _searchScreenStateKey.currentState!.onSearchTextChanged,
//       textInputAction: TextInputAction.search,
//       decoration: InputDecoration(
//         contentPadding: const EdgeInsets.all(10),
//         isDense: true,
//         fillColor: isDarkMode(context) ? Colors.grey[700] : Colors.grey[200],
//         filled: true,
//         prefixIcon: const Icon(
//           CupertinoIcons.search,
//           color: Colors.black,
//         ),
//         suffixIcon: IconButton(
//             icon: const Icon(
//               CupertinoIcons.clear,
//               color: Colors.black,
//             ),
//             onPressed: () {
//               setState(() {
//                 _searchScreenStateKey.currentState?.clearSearchQuery();
//               });
//             }),
//         focusedBorder: const OutlineInputBorder(
//             borderRadius: BorderRadius.all(
//               Radius.circular(10),
//             ),
//             borderSide: BorderSide(style: BorderStyle.none)),
//         enabledBorder: const OutlineInputBorder(
//             borderRadius: BorderRadius.all(
//               Radius.circular(10),
//             ),
//             borderSide: BorderSide(style: BorderStyle.none)),
//         hintText: tr('Search'),
//       ),
//     );
}
