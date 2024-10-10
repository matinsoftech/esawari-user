import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/cab_service/dashboard_cab_service.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/User.dart';
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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'as auth;

class CustomDrawer extends StatelessWidget {
  final StoreDrawerSelection drawerSelection;
  final Function(StoreDrawerSelection) onDrawerSelectionChanged;

  CustomDrawer({
    required this.drawerSelection,
    required this.onDrawerSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final user = Provider.of<User>(context); // Assuming you're using a User model with Provider

    return Drawer(
      child: Container(
        color: isDarkMode(context) ? Colors.black : null, // Conditional color based on theme
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
                          displayCircleImage(user.profilePictureURL, 75, false), // Display user image
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        user.fullName(), // Display user full name
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        user.email, // Display user email
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  !themeChange.darkTheme
                                      ? const Icon(Icons.light_mode_sharp)
                                      : const Icon(Icons.nightlight),
                                  Switch(
                                    splashRadius: 50.0,
                                    value: themeChange.darkTheme,
                                    onChanged: (value) =>
                                        themeChange.darkTheme = value, // Toggle theme mode
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: Color(COLOR_PRIMARY),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                    );
                  }),
                  // List of Drawer options
                  ListTileTheme(
                    style: ListTileStyle.drawer,
                    selectedColor: Color(COLOR_PRIMARY),
                    child: ListTile(
                      selected: drawerSelection == DrawerSelection.Home,
                      title: const Text('Home').tr(),
                      onTap: () {
                        Navigator.pop(context);
                        onDrawerSelectionChanged(DrawerSelection.Home as StoreDrawerSelection); // Handle navigation
                      },
                      leading: const Icon(CupertinoIcons.home),
                    ),
                  ),
                
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: drawerSelection == DrawerSelection.Orders,
                                  title: const Text('Booking').tr(),
                                  onTap: () {
                                    
                                     
                                    
                                  
                                  },
                                  leading: const Icon(CupertinoIcons.list_bullet),
                                ),
                              ),
                             
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: drawerSelection == DrawerSelection.Profile,
                                  leading: const Icon(CupertinoIcons.person),
                                  title: const Text("Profile").tr(),
                                  onTap: () {
                                     Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen()));
                                                                    
                                    
                                 
                                  },
                                ),
                              ),
                              Visibility(
                                visible: UserPreference.getWalletData() ?? false,
                                child: ListTileTheme(
                                  style: ListTileStyle.drawer,
                                  selectedColor: Color(COLOR_PRIMARY),
                                  child: ListTile(
                                    selected: drawerSelection == DrawerSelection.Wallet,
                                    leading: const Icon(Icons.account_balance_wallet_outlined),
                                    title: const Text('Wallet').tr(),
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>WalletScreen()));
                                                                          
                                
                                    },
                                  ),
                                ),
                              ),
                            
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: drawerSelection == DrawerSelection.workerInbox,
                                  leading: const Icon(CupertinoIcons.chat_bubble_2_fill),
                                  title: const Text('Worker Inbox').tr(),
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>InboxWorkerScreen()));
                                    
                                                               
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: drawerSelection == DrawerSelection.referral,
                                  leading: Image.asset(
                                    'assets/images/refer.png',
                                    width: 28,
                                    color: Colors.grey,
                                  ),
                                  title: const Text('Refer a friend').tr(),
                                  onTap: () async {
                                    Navigator.push(
                               context,
                                MaterialPageRoute(builder: (context) => ReferralScreen()),
                               );

                                    
                                   
                                    }
                                
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                    selected: drawerSelection == DrawerSelection.giftCard,
                                    title: Text('Gift Card').tr(),
                                    leading: Icon(Icons.card_giftcard),
                                    onTap: () async {
                                      push(context, const GiftCardScreen());
                                    }),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: drawerSelection == DrawerSelection.termsCondition,
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
                                  selected: drawerSelection == DrawerSelection.privacyPolicy,
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
                                  selected: drawerSelection == DrawerSelection.Logout,
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
                  // Add more ListTiles for other selections here...
                  
                ],
              
            
           
            ),
      )
      );

  }
}
