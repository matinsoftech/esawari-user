// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/OrderModel.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/services/localDatabase.dart';
import 'package:emartconsumer/ui/orderDetailsScreen/OrderDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  bool? isAnimation = true;

  OrdersScreen({super.key, this.isAnimation});

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Stream<List<OrderModel>> ordersFuture;
  final FireStoreUtils _fireStoreUtils = FireStoreUtils();
  List<OrderModel> ordersList = [];
  late CartDatabase cartDatabase;

  @override
  void initState() {
    super.initState();
    ordersFuture = _fireStoreUtils.getOrders(MyAppState.currentUser!.userID);
    print(MyAppState.currentUser!.userID);

    Future.delayed(const Duration(seconds: 7), () {
      setState(() {
        widget.isAnimation = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    cartDatabase = Provider.of<CartDatabase>(context, listen: false);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    FireStoreUtils().closeOrdersStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Colors.black : const Color(0xffFFFFFF),
      // Color(0XFFF1F4F7),
      body: widget.isAnimation == true
          ? Center(
              child: Image.asset(
                'assets/order_place_gif.gif',
              ),
            )
          : StreamBuilder<List<OrderModel>>(
              stream: ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                  return Center(
                    child: showEmptyState('No Previous Orders'.tr(), context),
                  );
                } else {
                  // ordersList = snapshot.data!;
                  return ListView.builder(
                      itemCount: snapshot.data!.length, padding: const EdgeInsets.all(12), itemBuilder: (context, index) => buildOrderItem(snapshot.data![index]));
                }
              }),
    );
  }

  Widget buildOrderItem(OrderModel orderModel) {
    print(orderModel.takeAway.toString() + "---");
    double total = 0.0;
    orderModel.products.forEach((element) {
      try {
        if (element.extras_price!.isNotEmpty && double.parse(element.extras_price!) != 0.0) {
          total += element.quantity * double.parse(element.extras_price!);
        }
        total += element.quantity * double.parse(element.price);
      } catch (ex) {}
    });
    total = total - orderModel.discount!;

    print(total.toString() + "----Total");

    return Card(
        color: isDarkMode(context) ? const Color(0xff35363A) : const Color(0xffFFFFFF),
        margin: const EdgeInsets.only(bottom: 30, right: 5, left: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 15, right: 10, left: 10),
          child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => push(
                  context,
                  OrderDetailsScreen(
                    orderModel: orderModel,
                  )),
              child: Column(children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage((orderModel.products.first.photo.isNotEmpty) ? orderModel.products.first.photo : placeholderImage),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ORDER ID:'.tr(),
                              style: TextStyle(
                                fontSize: 16,
                                letterSpacing: 0.5,
                                color: isDarkMode(context) ? Colors.grey.shade300 : const Color(0xff9091A4),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              orderModel.id,
                              style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.grey.shade200 : const Color(0XFF000000)),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: orderModel.products.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Padding(
                                  padding: const EdgeInsets.only(top: 00),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(
                                      orderModel.products[index].name,
                                      style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.grey.shade200 : const Color(0XFF000000)),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(orderModel.status.tr(), style: TextStyle(color: isDarkMode(context) ? Colors.grey.shade200 : const Color(0XFF555353))),
                                        const SizedBox(width: 3),
                                        const Image(
                                          image: AssetImage("assets/images/verti_divider.png"),
                                          height: 10,
                                          width: 10,
                                          color: Color(0XFF555353),
                                        ),
                                        Text(orderDate(orderModel.createdAt), style: TextStyle(color: isDarkMode(context) ? Colors.grey.shade200 : const Color(0XFF555353))),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    getPriceTotalText(orderModel.products[index])
                                  ]));
                            }),
                      ],
                    )),
                  ],
                ),
                // const SizedBox(height: 20),
                // InkWell(
                //   child: Container(
                //       padding: const EdgeInsets.only(top: 8, bottom: 8),
                //       decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(width: 0.8, color: Color(COLOR_PRIMARY))),
                //       child: Center(
                //         child: Text(
                //           'REORDER'.tr(),
                //           style: TextStyle(color: isDarkMode(context) ? const Color(0xffFFFFFF) : Colors.black,  fontSize: 15),
                //         ),
                //       )),
                //   onTap: () {
                //     cartDatabase.deleteAllProducts();
                //     for (CartProduct productModel in orderModel.products) {
                //        cartDatabase.reAddProduct(CartProduct(
                //           id: productModel.id + "~" + (productModel.variant_info != null ? productModel.variant_info!.variant_id.toString() : ""),
                //           name: productModel.name,
                //           photo: productModel.photo,
                //           price: productModel.price,
                //           discountPrice: productModel.discountPrice,
                //           vendorID: productModel.vendorID,
                //           quantity: productModel.quantity,
                //           extras_price: productModel.extras_price,
                //           extras: productModel.extras,
                //           category_id: productModel.category_id,
                //           variant_info: productModel.variant_info));
                //       // cartDatabase.reAddProduct(productModel);
                //       print("---->${productModel}");
                //     }
                //
                //     if (serviceTypeFlag == "ecommerce-service") {
                //       pushAndRemoveUntil(
                //           context,
                //           EcommeceDashBoardScreen(
                //             user: MyAppState.currentUser!,
                //             currentWidget: const CartScreen(
                //             ),
                //             appBarTitle: 'Your Cart'.tr(),
                //             drawerSelection: DrawerSelectionEcommarce.Cart,
                //           ),
                //           false);
                //     } else {
                //       pushAndRemoveUntil(
                //           context,
                //           ContainerScreen(
                //             user: MyAppState.currentUser!,
                //             currentWidget: const CartScreen(
                //             ),
                //             appBarTitle: 'Your Cart'.tr(),
                //             drawerSelection: DrawerSelection.Cart,
                //           ),
                //           false);
                //     }
                //   },
                // )
              ])),
        ));
  }

  String? getPrice(OrderModel product, CartProduct cartProduct) {
    /*double.parse(product.price)
        .toStringAsFixed(decimal)*/
    double subTotal;
    var price = cartProduct.extras_price == "" || cartProduct.extras_price == null || cartProduct.extras_price == "0.0" ? 0.0 : cartProduct.extras_price;
    var tipValue = product.tipValue.toString() == "" || product.tipValue == null ? 0.0 : product.tipValue.toString();
    var dCharge = product.deliveryCharge == null || product.deliveryCharge.toString().isEmpty ? 0.0 : double.parse(product.deliveryCharge.toString());
    var dis = product.discount.toString() == "" || product.discount == null ? 0.0 : product.discount.toString();

    subTotal = double.parse(price.toString()) + double.parse(tipValue.toString()) + double.parse(dCharge.toString()) - double.parse(dis.toString());

    print(price.toString() + "-=--" + tipValue.toString() + " == " + dCharge.toString() + "==" + dis.toString());
    return subTotal.toString();
  }

  String? getPriceTotal(String price, int quantity) {
    double ans = double.parse(price) * double.parse(quantity.toString());
    print(ans.toString() + "===ANS");
    return ans.toString();
  }

  getPriceTotalText(CartProduct s) {
    double total = 0.0;

    if (s.extras_price != null && s.extras_price!.isNotEmpty && double.parse(s.extras_price!) != 0.0) {
      total += s.quantity * double.parse(s.extras_price!);
    }
    total += s.quantity * double.parse(s.price);

    // getPrice(ordermodel, s);
    // double total = 0.0;
    // var discount;
    // orderModel.products.forEach((element) {
    //   if (element.extras_price != null && element.extras_price!.isNotEmpty && double.parse(element.extras_price!) != 0.0) {
    //     total += element.quantity * double.parse(element.extras_price!);
    //   } else {
    //     total += element.quantity * double.parse(element.price);
    //   }
    //   //     var price =  (element.extras_price == null || element.extras_price == "" || element.extras_price == "0.0")
    //   //     ? ((element.discountPrice == "" || element.discountPrice == "0" || element.discountPrice == null)
    //   //         ? element.price
    //   //         : element.discountPrice)
    //   //     : element.extras_price;
    //   // total += element.quantity * double.parse(price!);
    //   discount = orderModel.discount;
    // });
    // double tipValue = orderModel.tipValue!.isEmpty ? 0.0 : double.parse(orderModel.tipValue!);
    // double specialDiscountAmount = 0.0;
    // String taxAmount = "0.0";
    // if (orderModel.specialDiscount!.isNotEmpty) {
    //   specialDiscountAmount = double.parse(orderModel.specialDiscount!['special_discount'].toString());
    // }

    // //var taxAmount = (widget.orderModel.taxModel == null) ? 0 : getTaxValue(widget.orderModel.taxModel, total - discount - specialDiscountAmount);

    // if (orderModel.taxModel != null) {
    //   for (var element in orderModel.taxModel!) {
    //     taxAmount = (double.parse(taxAmount) + getTaxValue(amount: (total - discount - specialDiscountAmount).toString(), taxModel: element)).toString();
    //   }
    // }

    // var totalamount = orderModel.deliveryCharge == null || orderModel.deliveryCharge!.isEmpty
    //     ? total + double.parse(taxAmount) - discount - specialDiscountAmount
    //     : total + double.parse(taxAmount) + double.parse(orderModel.deliveryCharge!) + tipValue - discount - specialDiscountAmount;

    return Text(
      // amountShow(amount: totalamount.toString()),
      amountShow(amount: total.toString()),
      style: TextStyle(fontSize: 20, color: isDarkMode(context) ? Colors.grey.shade200 : Color(COLOR_PRIMARY)),
    );
  }
}
