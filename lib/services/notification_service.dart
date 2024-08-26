import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/cab_service/cab_order_detail_screen.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/order_screen/ondemand_order_details_screen.dart';
import 'package:emartconsumer/parcel_delivery/parcel_ui/parcel_order_detail_screen.dart';
import 'package:emartconsumer/rental_service/renatal_summary_screen.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/ui/chat_screen/chat_screen.dart';
import 'package:emartconsumer/ui/container/ContainerScreen.dart';
import 'package:emartconsumer/ui/dineInScreen/my_booking_screen.dart';
import 'package:emartconsumer/ui/orderDetailsScreen/OrderDetailsScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> firebaseMessageBackgroundHandle(RemoteMessage message) async {
  log("BackGround Message :: ${message.messageId}");
}

class NotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  initInfo() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    var request = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (request.authorizationStatus == AuthorizationStatus.authorized || request.authorizationStatus == AuthorizationStatus.provisional) {
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      var iosInitializationSettings = const DarwinInitializationSettings();
      final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: iosInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (payload) {});
      setupInteractedMessage();
    }
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      FirebaseMessaging.onBackgroundMessage((message) => firebaseMessageBackgroundHandle(message));
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("::::::::::::onMessage:::::::::::::::::");
      if (message.notification != null) {
        log(message.notification.toString());
        display(message);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("::::::::::::MessageOpenedApp:::::::::::::::::");
      print(message);
      if (message.notification != null) {
        // display(message);

        log(message.data.toString());
        String orderId = message.data['orderId'];
        if (message.data['type'] == 'vendor_order') {
          push(navigatorKey.currentContext!, OrderDetailsScreen(orderId: orderId));
        } else if (message.data['type'] == 'cab_order') {
          push(navigatorKey.currentContext!, CabOrderDetailScreen(orderId: orderId));
        } else if (message.data['type'] == 'parcel_order') {
          push(navigatorKey.currentContext!, ParcelOrderDetailScreen(orderId: orderId));
        } else if (message.data['type'] == 'rental_order') {
          push(navigatorKey.currentContext!, RenatalSummaryScreen(orderId: orderId));
        } else if (message.data['type'] == 'provider_order') {
          push(navigatorKey.currentContext!, OnDemandOrderDetailsScreen(orderId: orderId));
        } else if (message.data['type'] == 'cab_parcel_chat' || message.data['type'] == 'vendor_chat' || message.data['type'] == 'provider_chat') {
          push(
              navigatorKey.currentContext!,
              ChatScreens(
                orderId: orderId,
                customerId: message.data['customerId'],
                customerName: message.data['customerName'],
                customerProfileImage: message.data['customerProfileImage'],
                restaurantId: message.data['restaurantId'],
                restaurantName: message.data['restaurantName'],
                restaurantProfileImage: message.data['restaurantProfileImage'],
                token: message.data['token'],
                chatType: message.data['chatType'],
                type: message.data['type'],
              ));
        } else if (message.data['type'] == 'dine_in') {
          pushReplacement(
              navigatorKey.currentContext!,
              ContainerScreen(
                user: MyAppState.currentUser,
                drawerSelection: DrawerSelection.MyBooking,
                appBarTitle: 'Dine-In Bookings'.tr(),
                currentWidget: MyBookingScreen(),
              ));
        } else {
          /// receive message through inbox
          push(
              navigatorKey.currentContext!,
              ChatScreens(
                orderId: orderId,
                customerId: message.data['customerId'],
                customerName: message.data['customerName'],
                customerProfileImage: message.data['customerProfileImage'],
                restaurantId: message.data['restaurantId'],
                restaurantName: message.data['restaurantName'],
                restaurantProfileImage: message.data['restaurantProfileImage'],
                token: message.data['token'],
                chatType: message.data['chatType'],
              ));
        }
      }
    });
    log("::::::::::::Permission authorized:::::::::::::::::");
    await FirebaseMessaging.instance.subscribeToTopic("eMart_customer");
  }

  static getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    return token!;
  }

  display(RemoteMessage message) async {
    log('Got a message whilst in the foreground!');
    log('Message title: ${message.notification!.title.toString()}');
    log('Message data: ${message.notification!.body.toString()}');

    try {
      // final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      AndroidNotificationChannel channel = const AndroidNotificationChannel(
        "01",
        "emart_customer",
        description: 'Show Emart Notification',
        importance: Importance.max,
      );
      AndroidNotificationDetails notificationDetails = AndroidNotificationDetails(channel.id, channel.name,
          channelDescription: 'your channel Description', importance: Importance.high, priority: Priority.high, ticker: 'ticker');
      const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);
      NotificationDetails notificationDetailsBoth = NotificationDetails(android: notificationDetails, iOS: darwinNotificationDetails);
      await FlutterLocalNotificationsPlugin().show(
        0,
        message.notification!.title,
        message.notification!.body,
        notificationDetailsBoth,
        payload: jsonEncode(message.data),
      );
    } on Exception catch (e) {
      log(e.toString());
    }
  }
}
