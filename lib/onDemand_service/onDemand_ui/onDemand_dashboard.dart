import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/favorite_screen/ondemand_favorite_screen.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/home_screen/ondemand_home_screen.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/order_screen/ondemand_order_screen.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/services/localDatabase.dart';
import 'package:emartconsumer/ui/Language/language_choose_screen.dart';
import 'package:emartconsumer/ui/StoreSelection/StoreSelection.dart';
import 'package:emartconsumer/ui/auth/AuthScreen.dart';
import 'package:emartconsumer/ui/chat_screen/inbox_provider_screen.dart';
import 'package:emartconsumer/ui/chat_screen/inbox_worker_screen.dart';
import 'package:emartconsumer/ui/gift_card/gift_card_screen.dart';
import 'package:emartconsumer/ui/privacy_policy/privacy_policy.dart';
import 'package:emartconsumer/ui/profile/ProfileScreen.dart';
import 'package:emartconsumer/ui/referral_screen/referral_screen.dart';
import 'package:emartconsumer/ui/termsAndCondition/terms_and_codition.dart';
import 'package:emartconsumer/ui/wallet/walletScreen.dart';
import 'package:emartconsumer/userPrefrence.dart';
import 'package:emartconsumer/utils/DarkThemeProvider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum DrawerSelection { Dashboard, Home, Order, Profile, Wallet, provideInbox, workerInbox, favoriteService, termsCondition, privacyPolicy, chooseLanguage, Logout, referral, giftCard }

class OnDemandDahBoard extends StatefulWidget {
  final User? user;
  final Widget currentWidget;
  final String appBarTitle;
  final DrawerSelection drawerSelection;

  OnDemandDahBoard({Key? key, required this.user, currentWidget, appBarTitle, this.drawerSelection = DrawerSelection.Home})
      : appBarTitle = appBarTitle ?? 'Home'.tr(),
        currentWidget = currentWidget ??
            OnDemandHomeScreen(
              user: MyAppState.currentUser,
            ),
        super(key: key);

  @override
  _OnDemandServiceDrawer createState() {
    return _OnDemandServiceDrawer();
  }
}

var key = GlobalKey<ScaffoldState>();

class _OnDemandServiceDrawer extends State<OnDemandDahBoard> {
  late CartDatabase cartDatabase;
  late User user;
  late String _appBarTitle;
  final fireStoreUtils = FireStoreUtils();

  late Widget _currentWidget;
  late DrawerSelection _drawerSelection;

  int cartCount = 0;
  bool? isWalletEnable;

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    if (widget.user != null) {
      user = widget.user!;
    } else {
      user = User();
    }
    _currentWidget = widget.currentWidget;
    _appBarTitle = widget.appBarTitle;
    _drawerSelection = widget.drawerSelection;

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
        if (_currentWidget is! OnDemandHomeScreen) {
          setState(() {
            _drawerSelection = DrawerSelection.Home;
            _appBarTitle = 'Home'.tr();
            _currentWidget = OnDemandHomeScreen(
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
              extendBodyBehindAppBar: _drawerSelection == DrawerSelection.Wallet ? true : false,
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      displayCircleImage(user.profilePictureURL, 75, false),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: Text(
                                                    user.fullName(),
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                                Padding(
                                                    padding: const EdgeInsets.only(top: 4.0),
                                                    child: Text(
                                                      user.email,
                                                      style: const TextStyle(color: Colors.white),
                                                    )),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              !themeChange.darkTheme ? const Icon(Icons.light_mode_sharp) : const Icon(Icons.nightlight),
                                              Switch(
                                                splashRadius: 50.0,
                                                value: themeChange.darkTheme,
                                                onChanged: (value) => setState(() => themeChange.darkTheme = value),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  decoration:
                                      BoxDecoration(color: Color(COLOR_PRIMARY), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(0), bottomRight: Radius.circular(40))),
                                );
                              }),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.Dashboard,
                                  title: const Text('Dashboard').tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    pushAndRemoveUntil(context, const StoreSelection(), false);
                                  },
                                  leading: Image.asset(
                                    'assets/images/dashboard.png',
                                    color: _drawerSelection == DrawerSelection.Dashboard
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
                                  selected: _drawerSelection == DrawerSelection.Home,
                                  title: const Text('OnDemand').tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _drawerSelection = DrawerSelection.Home;
                                      _appBarTitle = 'OnDemand'.tr();
                                      _currentWidget = OnDemandHomeScreen(
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
                                  selected: _drawerSelection == DrawerSelection.Order,
                                  title: const Text('Booking').tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      if (MyAppState.currentUser == null) {
                                        Navigator.pop(context);
                                        push(context, const AuthScreen());
                                      } else {
                                        setState(() {
                                          _drawerSelection = DrawerSelection.Order;
                                          _appBarTitle = 'Booking'.tr();
                                          _currentWidget = OnDemandOrderScreen();
                                        });
                                      }
                                    });
                                  },
                                  leading: const Icon(CupertinoIcons.list_bullet),
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.favoriteService,
                                  title: const Text('Favourite Service').tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    if (MyAppState.currentUser == null) {
                                      push(context, const AuthScreen());
                                    } else {
                                      setState(() {
                                        _drawerSelection = DrawerSelection.favoriteService;
                                        _appBarTitle = 'Favourite Service'.tr();
                                        _currentWidget = const OndemandFavouriteServiceScreen();
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
                                  selected: _drawerSelection == DrawerSelection.Profile,
                                  leading: const Icon(CupertinoIcons.person),
                                  title: const Text("Profile").tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    if (MyAppState.currentUser == null) {
                                      push(context, const AuthScreen());
                                    } else {
                                      setState(() {
                                        _drawerSelection = DrawerSelection.Profile;
                                        _appBarTitle = "My Profile".tr();
                                        _currentWidget = const ProfileScreen();
                                      });
                                    }
                                  },
                                ),
                              ),
                              Visibility(
                                visible: UserPreference.getWalletData() ?? false,
                                child: ListTileTheme(
                                  style: ListTileStyle.drawer,
                                  selectedColor: Color(COLOR_PRIMARY),
                                  child: ListTile(
                                    selected: _drawerSelection == DrawerSelection.Wallet,
                                    leading: const Icon(Icons.account_balance_wallet_outlined),
                                    title: const Text('Wallet').tr(),
                                    onTap: () {
                                      Navigator.pop(context);
                                      if (MyAppState.currentUser == null) {
                                        push(context, const AuthScreen());
                                      } else {
                                        setState(() {
                                          _drawerSelection = DrawerSelection.Wallet;
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
                                  selected: _drawerSelection == DrawerSelection.provideInbox,
                                  leading: const Icon(CupertinoIcons.chat_bubble_2_fill),
                                  title: const Text('Provider Inbox').tr(),
                                  onTap: () {
                                    if (MyAppState.currentUser == null) {
                                      Navigator.pop(context);
                                      push(context, const AuthScreen());
                                    } else {
                                      Navigator.pop(context);
                                      setState(() {
                                        _drawerSelection = DrawerSelection.provideInbox;
                                        _appBarTitle = 'Provider Inbox'.tr();
                                        _currentWidget = const InboxProviderScreen();
                                      });
                                    }
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.workerInbox,
                                  leading: const Icon(CupertinoIcons.chat_bubble_2_fill),
                                  title: const Text('Worker Inbox').tr(),
                                  onTap: () {
                                    if (MyAppState.currentUser == null) {
                                      Navigator.pop(context);
                                      push(context, const AuthScreen());
                                    } else {
                                      Navigator.pop(context);
                                      setState(() {
                                        _drawerSelection = DrawerSelection.workerInbox;
                                        _appBarTitle = 'Worker Inbox'.tr();
                                        _currentWidget = const InboxWorkerScreen();
                                      });
                                    }
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.referral,
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
                                    selected: _drawerSelection == DrawerSelection.giftCard,
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
                                  selected: _drawerSelection == DrawerSelection.termsCondition,
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
                                  selected: _drawerSelection == DrawerSelection.privacyPolicy,
                                  leading: const Icon(Icons.privacy_tip),
                                  title: const Text('Privacy policy').tr(),
                                  onTap: () async {
                                    push(context, const PrivacyPolicyScreen());
                                  },
                                ),
                              ),
                              Visibility(
                                visible: isLanguageShown,
                                child: ListTileTheme(
                                  style: ListTileStyle.drawer,
                                  selectedColor: Color(COLOR_PRIMARY),
                                  child: ListTile(
                                    selected: _drawerSelection == DrawerSelection.chooseLanguage,
                                    leading: Icon(
                                      Icons.language,
                                      color: _drawerSelection == DrawerSelection.chooseLanguage
                                          ? Color(COLOR_PRIMARY)
                                          : isDarkMode(context)
                                              ? Colors.grey.shade200
                                              : Colors.grey.shade600,
                                    ),
                                    title: const Text("Language").tr(),
                                    onTap: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        _drawerSelection = DrawerSelection.chooseLanguage;
                                        _appBarTitle = "Language".tr();
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
                                  selected: _drawerSelection == DrawerSelection.Logout,
                                  leading: const Icon(Icons.logout),
                                  title: Text((MyAppState.currentUser == null) ? 'Log In'.tr() : 'Log Out'.tr()),
                                  onTap: () async {
                                    if (MyAppState.currentUser == null) {
                                      pushAndRemoveUntil(context, const AuthScreen(), false);
                                    } else {
                                      Navigator.pop(context);
                                      //user.active = false;
                                      user.lastOnlineTimestamp = Timestamp.now();
                                      user.fcmToken = "";
                                      await FireStoreUtils.updateCurrentUser(user);
                                      await auth.FirebaseAuth.instance.signOut();
                                      MyAppState.currentUser = null;
                                      Provider.of<CartDatabase>(context, listen: false).deleteAllProducts();
                                      pushAndRemoveUntil(context, const AuthScreen(), false);
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
              appBar: _drawerSelection == DrawerSelection.Home
                  ? null
                  : AppBar(
                      backgroundColor: isDarkMode(context) ? const Color(DARK_BG_COLOR) : Colors.white,
                      elevation: _drawerSelection == DrawerSelection.Wallet ? 0 : 0,
                      centerTitle: _drawerSelection == DrawerSelection.Wallet ? true : false,
                      leading: IconButton(
                          visualDensity: const VisualDensity(horizontal: -4),
                          padding: const EdgeInsets.only(right: 5),
                          icon: Image(
                            image: const AssetImage("assets/images/menu.png"),
                            width: 20,
                            color: isDarkMode(context) ? Colors.white : Colors.black,
                          ),
                          onPressed: () => key.currentState!.openDrawer()),
                      title: Text(
                        _appBarTitle,
                        style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.normal),
                      ),
                    ),
              body: _currentWidget,
            );
          },
        ),
      ),
    );
  }
}
