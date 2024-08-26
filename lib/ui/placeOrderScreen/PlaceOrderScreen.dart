import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/ecommarce_service/ecommarce_dashboard.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/OrderModel.dart';
import 'package:emartconsumer/send_notification.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/services/localDatabase.dart';
import 'package:emartconsumer/ui/StoreSelection/StoreSelection.dart';
import 'package:emartconsumer/ui/container/ContainerScreen.dart';
import 'package:emartconsumer/ui/ordersScreen/OrdersScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaceOrderScreen extends StatefulWidget {
  final OrderModel orderModel;

  const PlaceOrderScreen({Key? key, required this.orderModel}) : super(key: key);

  @override
  _PlaceOrderScreenState createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  FireStoreUtils fireStoreUtils = FireStoreUtils();
  late Timer timer;

  @override
  void initState() {
    timer = Timer(const Duration(seconds: 3), () => animateOut());
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: BoxDecoration(
        color: isDarkMode(context) ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Placing Order...'.tr(),
              style: TextStyle(color: isDarkMode(context) ? Colors.grey.shade300 : Colors.grey.shade800, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            trailing: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
              ),
            ),
          ),
          Visibility(
            visible: widget.orderModel.takeAway == false,
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 40),
                  title: Text(
                    '${widget.orderModel.address!.getFullAddress()}',
                    style: TextStyle(color: isDarkMode(context) ? Colors.grey.shade300 : Colors.grey.shade800, fontWeight: FontWeight.w500, fontSize: 17),
                  ),
                  subtitle: const Text('Deliver to door').tr(),
                  leading: Icon(
                    CupertinoIcons.checkmark_alt,
                    color: Color(COLOR_PRIMARY),
                  ),
                ),
                const Divider(indent: 40, endIndent: 40),
              ],
            ),
          ),

          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 40),
            title: Text(
              'Your order, {}'.tr(args: ['${widget.orderModel.author.fullName()}']),
              style: TextStyle(
                color: isDarkMode(context) ? Colors.grey.shade300 : Colors.grey.shade800,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            leading: Icon(
              CupertinoIcons.checkmark_alt,
              color: Color(COLOR_PRIMARY),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsetsDirectional.only(start: 56),
              itemCount: widget.orderModel.products.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade200,
                      padding: const EdgeInsets.all(6),
                      child: Text('${index + 1}'),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.orderModel.products[index].name,
                      style: TextStyle(
                        color: isDarkMode(context) ? Colors.grey.shade300 : Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          // RaisedButton(onPressed: () => deleteOrder(), child: Text('Undo'))
        ],
      ),
    );
  }

  animateOut() async{
    Map<String,dynamic>  payLoad =  <String, dynamic>{
      "type":"vendor_order",
      "orderId":widget.orderModel.id

    };

    if (widget.orderModel.scheduleTime != null) {
      await SendNotification.sendFcmMessage(scheduleOrder, widget.orderModel.vendor.fcmToken,payLoad);
    } else {
      await SendNotification.sendFcmMessage(orderPlaced, widget.orderModel.vendor.fcmToken,payLoad);
    }

   await FireStoreUtils.sendOrderEmail(orderModel: widget.orderModel);

    Provider.of<CartDatabase>(context, listen: false).deleteAllProducts();

    if (sectionConstantModel!.id == null  || sectionConstantModel!.id == "") {
      pushAndRemoveUntil(context, const StoreSelection(), false);
    } else {
      if (sectionConstantModel!.serviceTypeFlag == "ecommerce-service") {
        pushAndRemoveUntil(
            context,
            EcommeceDashBoardScreen(
              user: MyAppState.currentUser!,
              currentWidget: OrdersScreen(isAnimation: true),
              appBarTitle: 'Orders'.tr(),
              drawerSelection: DrawerSelectionEcommarce.Orders,
            ),
            false);
      } else {
        pushAndRemoveUntil(
            context,
            ContainerScreen(
              user: MyAppState.currentUser!,
              currentWidget: OrdersScreen(isAnimation: true),
              appBarTitle: 'Orders'.tr(),
              drawerSelection: DrawerSelection.Orders,
            ),
            false);
      }
    }
  }
}
