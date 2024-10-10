import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/firebase_options.dart';
import 'package:emartconsumer/model/AddressModel.dart';
import 'package:emartconsumer/model/CurrencyModel.dart';
import 'package:emartconsumer/model/mail_setting.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/services/localDatabase.dart';
import 'package:emartconsumer/services/notification_service.dart';
import 'package:emartconsumer/ui/StoreSelection/StoreSelection.dart';
import 'package:emartconsumer/ui/auth/AuthScreen.dart';
import 'package:emartconsumer/ui/location_permission_screen.dart';
import 'package:emartconsumer/ui/onBoarding/OnBoardingScreen.dart';
import 'package:emartconsumer/userPrefrence.dart';
import 'package:emartconsumer/utils/Styles.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/User.dart';
import 'utils/DarkThemeProvider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("initilizing ");
//  if (Firebase.apps.isEmpty) {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//   }
}

// void main() async {
  void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  

  // Log the number of Firebase apps already initialized
  print('Number of Firebase apps before initialization: ${Firebase.apps.length}');
    try {
    // Ensure Firebase is only initialized once
    if (Firebase.apps.isEmpty) {
      print("firebase is empty and not initilize");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
        
      );
        print('Firebase initialized successfully.');
    } else {
      print("Firebase is already initialized. No action taken.");
    }
    
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Handle the error, e.g., by showing a message to the user or logging it
   // Exit early if Firebase initialization fails
  }
await EasyLocalization.ensureInitialized();
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest,
  );
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );



 FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //SharedPreferences sp = await SharedPreferences.getInstance();
 // await UserPreference.init();



  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

   await UserPreference.init();
  runApp(
    MultiProvider(
      providers: [
        Provider<CartDatabase>(
          create: (_) => CartDatabase(),
        )
      ],
      child: EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ar'), Locale('nl')],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          saveLocale: false,
          useOnlyLangCode: true,
          useFallbackTranslations: true,
          child: const MyApp()),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  static User? currentUser;
  static AddressModel selectedPosotion = AddressModel();

  //  late Stream<StripeKeyModel> futureStirpe;
  //  String? data,d;

  // Define an async function to initialize FlutterFire
  NotificationService notificationService = NotificationService();

notificationInit() {
    notificationService.initInfo().then(
      (value) async {
        await Future.delayed(Duration(seconds: 2));
        String token = await NotificationService.getToken();
        log(":::::::TOKEN:::::: $token");
        if (currentUser != null) {
          log(":::::::TOKEN:::::: $token");
          await FireStoreUtils.firestore
              .collection("users")
              .doc(MyAppState.currentUser!.userID)
              .set({'fcmToken': token}, SetOptions(merge: true)).then((_) {
            print("FCM token updated successfully");
          }).catchError((error) {
            print("Failed to update FCM token: $error");
          });
        }
   },
);
}

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

      final FlutterExceptionHandler? originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails errorDetails) async {
        await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
        originalOnError!(errorDetails);
      };
      await FirebaseFirestore.instance.collection(Setting).doc("emailSetting").get().then((value) {
        if (value.exists) {
          mailSettings = MailSettings.fromJson(value.data()!);
        }
      });
      await FirebaseFirestore.instance.collection(Setting).doc("Version").get().then((value) {
        print(value.data());
        appVersion = value.data()!['app_version'].toString();
      });

      await FirebaseFirestore.instance.collection(Setting).doc("googleMapKey").get().then((value) {
        print(value.data());
        GOOGLE_API_KEY = value.data()!['key'].toString();
      });

      await FirebaseFirestore.instance.collection(Setting).doc("notification_setting").get().then((value) {
        print(value.data());
        senderId = value.data()!['senderId'].toString();
        jsonNotificationFileURL = value.data()!['serviceJson'].toString();
      });

      await FirebaseFirestore.instance.collection(Setting).doc("placeHolderImage").get().then((value) {
        print(value.data());
        placeholderImage = value.data()!['image'].toString();
      });

      await FirebaseFirestore.instance.collection(Setting).doc("globalSettings").get().then((value) {
        print(value.data());
        Banner_Url = value.data()!['home_banner'].toString();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (context, value, child) {
          return MaterialApp(
              navigatorKey: notificationService.navigatorKey,
              localizationsDelegates: context.localizationDelegates,
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              debugShowCheckedModeBanner: false,
              theme: Styles.themeData(themeChangeProvider.darkTheme, context),
              builder: EasyLoading.init(),
              home: const OnBoarding());
        },
      ),
    );
  }

  late StreamSubscription eventBusStream;

  @override
  void initState() {
    notificationInit();
    initializeFlutterFire();
    WidgetsBinding.instance.addObserver(this);
    getCurrentAppTheme();

    super.initState();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme = await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}
}

class OnBoarding extends StatefulWidget {
  const OnBoarding({Key? key}) : super(key: key);

  @override
  State createState() {
    return OnBoardingState();
  }
}

class OnBoardingState extends State<OnBoarding> {
  late Future<List<CurrencyModel>> futureCurrency;

  Future hasFinishedOnBoarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool finishedOnBoarding = (prefs.getBool(FINISHED_ON_BOARDING) ?? false);

    if (finishedOnBoarding) {
      auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        User? user = await FireStoreUtils.getCurrentUser(firebaseUser.uid);
        if (user != null && user.role == USER_ROLE_CUSTOMER) {
          if (user.active) {
            user.active = true;
            user.role = USER_ROLE_CUSTOMER;
            user.fcmToken = await FireStoreUtils.firebaseMessaging.getToken() ?? '';
            await FireStoreUtils.updateCurrentUser(user);
            MyAppState.currentUser = user;
            isSkipLogin = false;

            if (MyAppState.currentUser!.shippingAddress != null && MyAppState.currentUser!.shippingAddress!.isNotEmpty) {
              if (MyAppState.currentUser!.shippingAddress!.where((element) => element.isDefault == true).isNotEmpty) {
                MyAppState.selectedPosotion = MyAppState.currentUser!.shippingAddress!.where((element) => element.isDefault == true).single;
              } else {
                MyAppState.selectedPosotion = MyAppState.currentUser!.shippingAddress!.first;
              }
              pushReplacement(context, const StoreSelection());
            } else {
              pushAndRemoveUntil(context, LocationPermissionScreen(), false);
            }
          } else {
            user.lastOnlineTimestamp = Timestamp.now();
            user.fcmToken = "";
            await FireStoreUtils.updateCurrentUser(user);
            await auth.FirebaseAuth.instance.signOut();
            MyAppState.currentUser = null;
            pushReplacement(context, const AuthScreen());
          }

          //UserPreference.setUserId(userID: user.userID);
          //
        } else {
          pushReplacement(context, const AuthScreen());
        }
      } else {
        pushReplacement(context, const AuthScreen());
      }
    } else {
      pushReplacement(context, const OnBoardingScreen());
    }
  }

  @override
  void initState() {
    super.initState();

    hasFinishedOnBoarding();
    // futureCurrency= FireStoreUtils().getCurrency();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor: Color(0xFFF9F9F9),

      body: Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
        ),
      ),
    );
  }
}
