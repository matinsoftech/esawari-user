import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/cab_service/cab_intercity_service_screen.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/CurrencyModel.dart';
import 'package:emartconsumer/model/SectionModel.dart';
import 'package:emartconsumer/ui/StoreSelection/blogs.dart';
import 'package:emartconsumer/ui/StoreSelection/carouselsliderservice.dart';
import 'package:emartconsumer/ui/StoreSelection/drawerservice.dart';
import 'package:emartconsumer/ui/StoreSelection/storeservices.dart';
import 'package:emartconsumer/ui/profile/ProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../model/User.dart';
import '../../services/FirebaseHelper.dart';
import '../../services/helper.dart';
import '../../services/localDatabase.dart';
import '../auth/AuthScreen.dart';

// Singleton class to manage section data
class SectionDataController {
  static final SectionDataController _instance = SectionDataController._internal();
  factory SectionDataController() => _instance;
  SectionDataController._internal();

  List<SectionModel>? _sectionList;
  bool _isLoading = false;
  
  Future<List<SectionModel>> getSections() async {
    if (_sectionList != null) return _sectionList!;
    if (_isLoading) {
      // Wait until the current loading is complete
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _sectionList ?? [];
    }
    
    try {
      _isLoading = true;
      final fireStoreUtils = FireStoreUtils();
      _sectionList = await fireStoreUtils.getSections();
      return _sectionList ?? [];
    } catch (e) {
      print('Error loading sections: $e');
      return [];
    } finally {
      _isLoading = false;
    }
  }

  void clearData() {
    _sectionList = null;
    _isLoading = false;
  }
}

enum StoreDrawerSelection {
  Dashboard,
  Home,
  Order,
  Profile,
  Wallet,
  provideInbox,
  workerInbox,
  favoriteService,
  termsCondition,
  privacyPolicy,
  chooseLanguage,
  Logout,
  referral,
  giftCard,
  driver,
  Orders
}

class StoreSelection extends StatefulWidget {
  const StoreSelection({Key? key}) : super(key: key);

  @override
  StoreSelectionState createState() => StoreSelectionState();
}

class StoreSelectionState extends State<StoreSelection> with AutomaticKeepAliveClientMixin {
  late CartDatabase cartDatabase;
  final fireStoreUtils = FireStoreUtils();
  //final SectionDataController _sectionController = SectionDataController();
  List<SectionModel> sectionList = [];
  bool isLoading = true;
  bool isLanguageShown = false;
  String? country;
  CurrencyModel? currencyData;
  
  DateTime pre_backpress = DateTime.now();
  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  StoreDrawerSelection _drawerSelection = StoreDrawerSelection.Home;

  bool _mounted = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

Future<void> _initializeData() async {
    try {
      await Future.wait([
        _loadSections(),
        _initializeCurrency(),
      ]);
    } catch (e) {
      print('Error initializing data: $e');
    } finally {
      if (_mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
    Future<void> _loadSections() async {
    try {
      final sections = await fireStoreUtils.getSections();
      if (mounted) {
        setState(() {
          sectionList = sections;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading sections: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _initializeCurrency() async {
    try {
      final value = await FireStoreUtils().getCurrency();
      if (_mounted) {
        setState(() {
          currencyData = value ?? CurrencyModel(
            id: "",
            code: "USD",
            decimal: 2,
            isactive: true,
            name: "US Dollar",
            symbol: "\$",
            symbolatright: false,
          );
        });
      }

      if (MyAppState.selectedPosotion.location != null) {
        List<Placemark> placeMarks = await placemarkFromCoordinates(
          MyAppState.selectedPosotion.location!.latitude,
          MyAppState.selectedPosotion.location!.longitude,
        );
        if (_mounted) {
          setState(() {
            country = placeMarks.first.country;
          });
        }
      }

      // Load payment settings sequentially instead of parallel
      await _loadPaymentSettings();
    } catch (e) {
      print('Error initializing currency: $e');
    }
  }

  Future<void> _loadPaymentSettings() async {
    try {
      // Load settings sequentially to avoid any potential race conditions
      await FireStoreUtils().getRazorPayDemo();
      await FireStoreUtils.getPaypalSettingData();
      await FireStoreUtils.getStripeSettingData();
      await FireStoreUtils.getPayStackSettingData();
      await FireStoreUtils.getFlutterWaveSettingData();
      await FireStoreUtils.getPaytmSettingData();
      await FireStoreUtils.getPayFastSettingData();
      await FireStoreUtils.getWalletSettingData();
      await FireStoreUtils.getMercadoPagoSettingData();
    } catch (e) {
      print('Error loading payment settings: $e');
    }
  }

  void _handleProfileNavigation(BuildContext context, User? user) {
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(),
          settings: const RouteSettings(name: 'ProfileScreen'),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AuthScreen(),
          settings: const RouteSettings(name: 'AuthScreen'),
        ),
      );
    }
  }

  Widget _buildServiceGrid() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
        ),
      );
    }

    if (sectionList.isEmpty) {
      return showEmptyState('No Categories'.tr(), context);
    }
   
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sectionList.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        mainAxisExtent: 150,
      ),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildOutstationCell();
        }

        return CuisineCell(sectionModel: sectionList[index - 1]);
      },
    );
  }

  Widget _buildOutstationCell() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CabInterCityServiceScreen(),
            settings: const RouteSettings(name: 'CabInterCityServiceScreen'),
          ),
        );
      },
      child: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 75,
                width: 75,
                child: Image.asset('assets/images/INTERCITY ICON PNG.png'),
              ),
              const Text(
                "Outstation",
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return WillPopScope(
      onWillPop: () async {
        final timegap = DateTime.now().difference(pre_backpress);
        final cantExit = timegap >= const Duration(seconds: 2);
        pre_backpress = DateTime.now();
        
        if (cantExit) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "back-button".tr(),
                style: const TextStyle(color: Colors.white),
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.black,
            ),
          );
          return false;
        }
        return true;
      },
      child: ChangeNotifierProvider.value(
        value: MyAppState.currentUser,
        child: Consumer<User?>(
          builder: (context, user, _) {
            return Scaffold(
              key: scaffoldkey,
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
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => scaffoldkey.currentState?.openDrawer(),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          "assets/images/app_logo_new.png",
                          height: 40,
                        ),
                      ),
                    ),
                    IconButton(
                      padding: const EdgeInsets.only(left: 20),
                      icon: const Icon(Icons.person),
                      onPressed: () => _handleProfileNavigation(context, user),
                    ),
                  ],
                ),
                centerTitle: true,
              ),
              body:
           
                 SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          "Welcome".tr() + " ${user?.firstName ?? ''}",
                          style: const TextStyle(fontSize: 22, color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 20),
                       MainSliders(),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          "Our Services",
                          style: const TextStyle(fontSize: 22, color: Colors.black),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        child: Container(
                          color: const Color(0xFFF9F9F9),
                          margin: const EdgeInsets.only(left: 8, right: 8, top: 12),
                          child: _buildServiceGrid(),
                        ),
                      ),
                      BlogsProvider(),
                    ],
                  ),
                ),
              );
  })
        ));
        }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cartDatabase = Provider.of<CartDatabase>(context);
  }
}