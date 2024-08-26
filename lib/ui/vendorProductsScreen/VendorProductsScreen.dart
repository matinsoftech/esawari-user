// class VendorProductsScreen extends StatefulWidget {
//   final VendorModel vendorModel;
//
//   const VendorProductsScreen({Key? key, required this.vendorModel}) : super(key: key);
//
//   @override
//   _VendorProductsScreenState createState() => _VendorProductsScreenState();
// }
//
// class _VendorProductsScreenState extends State<VendorProductsScreen> with TickerProviderStateMixin {
//   final FireStoreUtils fireStoreUtils = FireStoreUtils();
//
//   // late String data;
//   List a = [];
//   bool vegSwitch = false;
//   bool nonVegSwitch = false;
//
//   List<ProductModel> productModel = [];
//
//   //  quen;
//   var position = const LatLng(23.12, 70.22);
//
//   String? foodType;
//
//   Stream<List<OfferModel>>? lstOfferData;
//
//   void _getUserLocation() async {
//     setState(() {
//       position = LatLng(MyAppState.selectedPosition.latitude, MyAppState.selectedPosition.longitude);
//     });
//   }
//   ///rating review
//   var isAnother = 0;
//
//   getProducts() async {
//     // await fireStoreUtils.getVendorProducts(widget.vendorModel.id).then((value) {
//     //   productModel.addAll(value);
//     //   getVendorCategoryById();
//     //   setState(() {});
//     // });
//     lstOfferData = fireStoreUtils.getOfferStreamByVendorID(widget.vendorModel.id);
//   }
//
//   ScrollController scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     getFoodType();
//     getProducts();
//     _getUserLocation();
//     statusCheck();
//     scrollController = ScrollController()
//       ..addListener(() {
//         setState(() {});
//       });
//   }
//
//   void getFoodType() async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     foodType = sp.getString("foodType") ?? "Delivery";
//
//     print("------->${foodType}");
//     if (foodType == "Takeaway") {
//       await fireStoreUtils.getVendorProductsTakeAWay(widget.vendorModel.id).then((value) {
//         productModel.clear();
//         productModel.addAll(value);
//         getVendorCategoryById();
//         setState(() {});
//       });
//     } else {
//       await fireStoreUtils.getVendorProductsDelivery(widget.vendorModel.id).then((value) {
//         productModel.clear();
//         productModel.addAll(value);
//         getVendorCategoryById();
//         setState(() {});
//       });
//     }
//   }
//
//   List<VendorCategoryModel> vendorCateoryModel = [];
//
//   getVendorCategoryById() async {
//     vendorCateoryModel.clear();
//     await Future.delayed(const Duration(seconds: 1));
//
//     for (int i = 0; i < productModel.length; i++) {
//       if (a.isNotEmpty && a.contains(productModel[i].categoryID)) {
//       } else if (!a.contains(productModel[i].categoryID)) {
//         a.add(productModel[i].categoryID);
//
//         await fireStoreUtils.getVendorCategoryById(productModel[i].categoryID).then((value) {
//           if (value != null) {
//             setState(() {
//               vendorCateoryModel.add(value);
//             });
//           }
//         });
//       }
//     }
//   }
//
//   // count() {
//   //   FutureBuilder<List<ProductModel>>(
//   //       future: productsFuture,
//   //       initialData: const [],
//   //       builder: (context, snapshot) {
//   //         return ListView.builder(
//   //             shrinkWrap: true,
//   //             physics: const ClampingScrollPhysics(),
//   //             itemCount: snapshot.data!.length,
//   //             itemBuilder: (context, index) {
//   //               data1 = snapshot.data![index].categoryID;
//   //               return const Center();
//   //             });
//   //       });
//   // }
//
//   @override
//   void didChangeDependencies() {
//     cartDatabase = Provider.of<CartDatabase>(context);
//     super.didChangeDependencies();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var _width = MediaQuery.of(context).size.width;
//     var _height = MediaQuery.of(context).size.height;
//
//     double distanceInMeters = Geolocator.distanceBetween(widget.vendorModel.latitude, widget.vendorModel.longitude, position.latitude, position.longitude);
//     double kilometer = distanceInMeters / 1000;
//
//     double minutes = 1.2;
//     double value = minutes * kilometer;
//     final int hour = value ~/ 60;
//     final double minute = value % 60;
//
//     return DefaultTabController(
//         initialIndex: 0,
//         length: vendorCateoryModel.length,
//         child: Scaffold(
//           // backgroundColor: Color(0xffF1F4F7),
//           body: Container(
//               color: isDarkMode(context) ? Colors.black : const Color(0xffFFFFFF),
//               child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//                 Stack(children: [
//                   Container(
//                       height: _height * 0.3,
//                       decoration: const BoxDecoration(
//                         boxShadow: <BoxShadow>[BoxShadow(color: Colors.white38, blurRadius: 25.0, offset: Offset(0.0, 0.75))],
//                       ),
//                       width: _width * 1,
//                       child: CachedNetworkImage(
//                         imageUrl: getImageVAlidUrl(widget.vendorModel.photo),
//                         imageBuilder: (context, imageProvider) => Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(0),
//                             image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
//                           ),
//                         ),
//                         placeholder: (context, url) => Center(
//                             child: CircularProgressIndicator.adaptive(
//                           valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
//                         )),
//                         errorWidget: (context, url, error) => Image.asset(
//                           placeholderImage,
//                           fit: BoxFit.fitWidth,
//                         ),
//                         fit: BoxFit.fitWidth,
//                       )),
//                   Positioned(
//                       top: _height * 0.033,
//                       left: _width * 0.03,
//                       child: CircleAvatar(
//                           backgroundColor: Colors.black54,
//                           radius: 20,
//                           child: IconButton(
//                             onPressed: () => Navigator.pop(context),
//                             icon: const Icon(
//                               Icons.arrow_back,
//                               color: Colors.white,
//                               size: 25,
//                             ),
//                           ))),
//                   Positioned(
//                       bottom: _height * 0.009,
//                       right: _width * 0.03,
//                       child: IconButton(
//                           icon: const Image(
//                             image: AssetImage(
//                               "assets/images/img.png",
//                             ),
//                             height: 35,
//                           ),
//                           onPressed: () {
//                             push(context, StorePhotos(vendorModel: widget.vendorModel));
//                           }))
//                 ]),
//                 Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
//                   Container(
//                       constraints: const BoxConstraints(maxWidth: 250),
//                       padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
//                       child: Text(widget.vendorModel.title,
//                           maxLines: 2,
//                           style: TextStyle(
//
//                               fontSize: 20,
//                               letterSpacing: 0.5,
//                               color: isDarkMode(context) ? const Color(0xffFFFFFF) : const Color(0xff2A2A2A)))),
//                   resttiming()
//                 ]),
//                 // SizedBox(height: 10,),
//                 Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
//                   Container(
//                       padding: const EdgeInsets.only(left: 15, right: 15),
//                       child: Row(children: [
//                         const ImageIcon(
//                           AssetImage('assets/images/location3x.png'),
//                           size: 18,
//                           color: Color(0xff9091A4),
//                         ),
//                         const SizedBox(width: 5),
//                         Container(
//                             constraints: const BoxConstraints(maxWidth: 230),
//                             child: Text(
//                               widget.vendorModel.location,
//                               maxLines: 2,
//                               style: const TextStyle( letterSpacing: 0.5, color: Color(0xFF9091A4)),
//                             ))
//                       ])),
//                   InkWell(
//                       onTap: () {
//                         showModalBottomSheet(
//                           isScrollControlled: true,
//                           isDismissible: true,
//                           context: context,
//                           backgroundColor: Colors.transparent,
//                           enableDrag: true,
//                           builder: (context) => showTiming(context),
//                         );
//                       },
//                       child: Container(
//                           padding: const EdgeInsets.only(
//                             right: 2,
//                             left: 2,
//                           ),
//                           child: Text(
//                             "View Timing",
//                             style: TextStyle(
//                               color: Color(COLOR_PRIMARY),
//
//                               letterSpacing: 0.5,
//                             ),
//                           ).tr()))
//                 ]),
//                 Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.grey.shade100, width: 0.1),
//                         boxShadow: [
//                           BoxShadow(color: Colors.grey.shade300, blurRadius: 3.0, spreadRadius: 0.6, offset: const Offset(0.1, 0.5)),
//                         ],
//                         color: Colors.white),
//                     child: Padding(
//                         padding: const EdgeInsets.only(top: 10, left: 15, right: 10, bottom: 10),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Column(children: [
//                               Image(
//                                 image: const AssetImage("assets/images/location.png"),
//                                 color: Color(COLOR_PRIMARY),
//                                 height: 25,
//                               ),
//                               const SizedBox(
//                                 height: 10,
//                               ),
//                               Text(
//                                 "${kilometer.toDouble().toStringAsFixed(decimal)} km",
//                                 style: const TextStyle( letterSpacing: 0.5, color: Color(0xff565764)),
//                               ).tr()
//                             ]),
//                             Column(children: [
//                               Image(
//                                 image: const AssetImage("assets/images/time.png"),
//                                 color: Color(COLOR_PRIMARY),
//                                 height: 25,
//                               ),
//                               const SizedBox(
//                                 height: 10,
//                               ),
//                               Text(
//                                 '${hour.toString().padLeft(2, "0")}h ${minute.toStringAsFixed(0).padLeft(2, "0")}m',
//                                 // "${minute.toDouble()} min",
//                                 style: const TextStyle( letterSpacing: 0.5, color: Color(0xff565764)),
//                               )
//                             ]),
//                             // SizedBox(
//                             //  width: 40,
//                             // ),
//                             InkWell(
//                               onTap: () {
//                                 push(
//                                   context,
//                                   Review(
//                                     vendorModel: widget.vendorModel,
//                                   ),
//                                 );
//                               },
//                               child: Column(children: [
//                                 Image(
//                                   image: const AssetImage("assets/images/rate.png"),
//                                   color: Color(COLOR_PRIMARY),
//                                   height: 25,
//                                 ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 Text(
//                                   widget.vendorModel.reviewsCount == 0
//                                       ? '0' ' Rate'
//                                       : ' ${double.parse((widget.vendorModel.reviewsSum / widget.vendorModel.reviewsCount).toStringAsFixed(1))}'
//                                           ' Rate',
//                                   style: const TextStyle( letterSpacing: 0.5, color: Color(0xff565764)),
//                                 ).tr()
//                               ]),
//                             ),
//                             // SizedBox(
//                             //   width: 35,
//                             // ),
//                             InkWell(
//                                 onTap: () async {
//                                   // Share.shareFiles(
//                                   //     ['${widget.vendorModel.photo}'],
//                                   //     text:
//                                   //         '${widget.vendorModel.title}');
//                                   Share.share("${widget.vendorModel.title}\n${widget.vendorModel.location}\n\n${widget.vendorModel.photo}");
//                                 },
//                                 child: Column(children: [
//                                   Image(
//                                     image: const AssetImage("assets/images/share.png"),
//                                     color: Color(COLOR_PRIMARY),
//                                     height: 25,
//                                   ),
//                                   const SizedBox(
//                                     height: 10,
//                                   ),
//                                   const Text(
//                                     "Share",
//                                     style: TextStyle( letterSpacing: 0.5, color: Color(0xff565764)),
//                                   ).tr()
//                                 ])),
//                           ],
//                         ))),
//                 Builder(builder: (context) {
//                   return StreamBuilder<List<OfferModel>>(
//                       stream: lstOfferData,
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState == ConnectionState.waiting) {
//                           return const Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         }
//                         if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
//                           return Container();
//                         } else {
//                           return SizedBox(
//                             height: 77,
//                             child: ListView.builder(
//                                 itemCount: snapshot.data!.length,
//                                 scrollDirection: Axis.horizontal,
//                                 itemBuilder: (context, index) {
//                                   return GestureDetector(
//                                     onTap: () {
//                                       FlutterClipboard.copy(snapshot.data![index].offerCode!).then((value) => print('copied'));
//
//                                       showModalBottomSheet(
//                                         isScrollControlled: true,
//                                         isDismissible: true,
//                                         context: context,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(20.0),
//                                         ),
//                                         backgroundColor: Colors.transparent,
//                                         enableDrag: true,
//                                         builder: (context) => openCouponCode(context, snapshot.data![index]),
//                                       );
//                                     },
//                                     child: buildOfferItem(snapshot, index),
//                                   );
//                                 }),
//                           );
//                         }
//                       });
//                 }),
//
//                 Expanded(
//                   child: ScrollableListTabView(
//                     tabs: List.generate(
//                       vendorCateoryModel.length,
//                       (index) {
//                         return ScrollableListTab(
//                           tab: ListTab(
//                             onTap: () {
//                               Future.delayed(const Duration(seconds: 1));
//                               setState(() {});
//                             },
//                             activeBackgroundColor: Color(COLOR_PRIMARY),
//                             label: Text(
//                               vendorCateoryModel[index].title.toString(),
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                           ),
//                           body: ListView.builder(
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               itemCount: 1,
//                               padding: EdgeInsets.zero,
//                               itemBuilder: (_, i) {
//                                 bool veg = false;
//                                 bool nonveg = false;
//                                 isAnother = 0;
//                                 return Column(
//                                   children: [
//                                     Visibility(
//                                       visible: isDineEnable,
//                                       child: const SizedBox(height: 5),
//                                     ),
//                                     Visibility(
//                                       visible: isDineEnable,
//                                       child: productModel.isEmpty ? Container() : buildVeg(veg, nonveg),
//                                     ),
//                                     const Padding(
//                                       padding: EdgeInsets.symmetric(horizontal: 15),
//                                       child: Divider(
//                                         color: Color(0xffE4E8EB),
//                                         thickness: 1,
//                                       ),
//                                     ),
//                                     ListView.builder(
//                                       shrinkWrap: true,
//                                       physics: const ClampingScrollPhysics(),
//                                       itemCount: productModel.length,
//                                       controller: scrollController,
//                                       padding: EdgeInsets.zero,
//                                       itemBuilder: (context, inx) {
//                                         return productModel[inx].categoryID == vendorCateoryModel[index].id && productModel[inx].publish == true
//                                             ? buildRow(productModel[inx], veg, nonveg, productModel[inx].categoryID, (inx == (productModel.length - 1)))
//                                             : (isAnother == 0 && (inx == (productModel.length - 1)))
//                                                 ? showEmptyState("No Item are available.")
//                                                 : Container();
//                                       },
//                                     ),
//                                   ],
//                                 );
//                               }),
//                         );
//                       },
//                     ),
//                   ),
//                 )
//
//                 // Container(
//                 //   color: isDarkMode(context) ? Colors.black : const Color(0xffFFFFFF),
//                 //   // Color(0XFFF1F4F7),
//                 //   child: Stack(
//                 //     children: [
//                 //       TabBar(
//                 //           onTap: (value) {
//                 //             setState(() {
//                 //               value = tabController.index;
//                 //             });
//                 //           },
//                 //           isScrollable: true,
//                 //           indicatorColor: Color(COLOR_PRIMARY),
//                 //           labelColor: Color(COLOR_PRIMARY),
//                 //           unselectedLabelColor: const Color(0xff9394a1),
//                 //           labelStyle: const TextStyle(fontSize: 16),
//                 //           unselectedLabelStyle: const TextStyle(),
//                 //           labelPadding: const EdgeInsets.only(right: 20, left: 20),
//                 //           tabs: List.generate(
//                 //               vendorCateoryModel.length,
//                 //               (index) => Tab(
//                 //                     child: Text(
//                 //                       vendorCateoryModel[index].title.toString(),
//                 //                     ).tr(),
//                 //                   )))
//                 //     ],
//                 //   ),
//                 // ),
//                 // Container(
//                 //     color: isDarkMode(context) ? Colors.black : const Color(0xffffffff), //Color(0xffFFFFFF),
//                 //     // Color(0XFFFFFFFF),
//                 //     width: MediaQuery.of(context).size.width * 1,
//                 //     height: 600,
//                 //     child: TabBarView(
//                 //         children: List.generate(
//                 //       vendorCateoryModel.length,
//                 //       (index) => FutureBuilder<List<ProductModel>>(
//                 //           future: productsFuture,
//                 //           initialData: const [],
//                 //           builder: (context, snapshot) {
//                 //             bool veg = false;
//                 //             bool nonveg = false;
//                 //             isAnother = 0;
//                 //             return SingleChildScrollView(
//                 //               physics: const ClampingScrollPhysics(),
//                 //               child: Column(
//                 //                 mainAxisSize: MainAxisSize.max,
//                 //                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 //                 mainAxisAlignment: MainAxisAlignment.start,
//                 //                 children: [
//                 //                   Visibility(
//                 //                     visible: isDineEnable,
//                 //                     child: const SizedBox(height: 5),
//                 //                   ),
//                 //                   Visibility(
//                 //                     visible: isDineEnable,
//                 //                     child: snapshot.data!.isEmpty ? Container() : buildVeg(veg, nonveg),
//                 //                   ),
//                 //                   const Divider(color: Color(0xffE4E8EB)),
//                 //                   ListView.builder(
//                 //                     shrinkWrap: true,
//                 //                     padding: EdgeInsets.zero,
//                 //                     physics: const ClampingScrollPhysics(),
//                 //                     itemCount: snapshot.data!.length,
//                 //                     itemBuilder: (context, inx) {
//                 //                       return snapshot.data![inx].categoryID == vendorCateoryModel[index].id && snapshot.data![inx].publish == true
//                 //                           ? buildRow(snapshot.data![inx], veg, nonveg, snapshot.data![inx].categoryID, (inx == (snapshot.data!.length - 1)))
//                 //                           : (isAnother == 0 && (inx == (snapshot.data!.length - 1)))
//                 //                               ? showEmptyState("", 'No Food are available.')
//                 //                               : Container();
//                 //                     },
//                 //                   ),
//                 //                 ],
//                 //               ),
//                 //             );
//                 //           }),
//                 //     ))),
//               ])),
//           // bottomNavigationBar: InkWell(
//           //   onTap: () => {
//           //     if (MyAppState.currentUser == null)
//           //       {push(context, const AuthScreen())}
//           //     else
//           //       {
//           //         pushAndRemoveUntil(
//           //             context,
//           //             ContainerScreen(
//           //               user: MyAppState.currentUser!,
//           //               drawerSelection: DrawerSelection.Cart,
//           //               currentWidget: const CartScreen(
//           //                 fromContainer: true,
//           //               ),
//           //               appBarTitle: 'Your Cart',
//           //             ),
//           //             false)
//           //       }
//           //   },
//           //   child: Container(
//           //     color: Color(COLOR_PRIMARY),
//           //     height: 60,
//           //     padding: const EdgeInsets.only(left: 20, right: 20),
//           //     child: Row(
//           //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           //       children: [
//           //         Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
//           //           Text(
//           //             cartCount.toString() + " Items",
//           //             style: const TextStyle( color: Colors.white, fontSize: 16),
//           //           ).tr(),
//           //           const SizedBox(
//           //             width: 15,
//           //           ),
//           //           const Text("|", style: TextStyle(color: Colors.white, fontSize: 16)),
//           //           const SizedBox(
//           //             width: 15,
//           //           ),
//           //           Text(
//           //             symbol + total.toDouble().toStringAsFixed(decimal),
//           //             style: const TextStyle(  color: Colors.white, fontSize: 16),
//           //           ),
//           //         ]),
//           //         Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
//           //           const Text(
//           //             "VIEW CART",
//           //             style: TextStyle( color: Colors.white, fontSize: 16),
//           //           ).tr(),
//           //           const SizedBox(
//           //             width: 10,
//           //           ),
//           //           const Image(
//           //             image: AssetImage("assets/images/cart2.png"),
//           //             height: 21,
//           //             color: Colors.white,
//           //           )
//           //         ])
//           //       ],
//           //     ),
//           //   ),
//           // ),
//         ));
//   }
//
//   Widget buildOfferItem(AsyncSnapshot<List<OfferModel>> snapshot, int index) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(7, 10, 7, 10),
//       height: 85,
//       child: DottedBorder(
//         borderType: BorderType.RRect,
//         radius: const Radius.circular(2),
//         padding: const EdgeInsets.all(2),
//         color: const Color(COUPON_DASH_COLOR),
//         strokeWidth: 2,
//         dashPattern: const [5],
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
//           child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(2),
//               ),
//               margin: const EdgeInsets.only(top: 4),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       const Image(
//                         image: AssetImage('assets/images/offer_icon.png'),
//                         height: 25,
//                         width: 25,
//                       ),
//                       const SizedBox(
//                         width: 10,
//                       ),
//                       Container(
//                         margin: const EdgeInsets.only(top: 3),
//                         child: Text(
//                           "${snapshot.data![index].discountTypeOffer == "Fix Price" ? symbol : ""}${snapshot.data![index].discountOffer}${snapshot.data![index].discountTypeOffer == "Percentage" ? "% OFF" : " OFF"}",
//                           style: const TextStyle(color: Color(GREY_TEXT_COLOR), fontWeight: FontWeight.bold, letterSpacing: 0.7),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 5,
//                   ),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Text(
//                         snapshot.data![index].offerCode!,
//                         textAlign: TextAlign.left,
//                         style: const TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.normal, letterSpacing: 0.5, color: Color(GREY_TEXT_COLOR)),
//                       ),
//                       Container(
//                         margin: const EdgeInsets.only(left: 15, right: 15, top: 3),
//                         width: 1,
//                         color: const Color(COUPON_DASH_COLOR),
//                       ),
//                       Text("valid till " + getDate(snapshot.data![index].expireOfferDate!.toDate().toString())!,
//                           style: const TextStyle( letterSpacing: 0.5, color: Color(0Xff696A75)))
//                     ],
//                   ),
//                 ],
//               )),
//         ),
//       ),
//     );
//   }
//
//   //  database(CartProduct cartProduct){
//   //          data =cartProduct.id ;
//
//   //         //  quen = cartProduct.quantity;
//   //          return Container();
//   //  }
//   buildVeg(veg, nonveg) {
//     // var vegSwitch,nonVegSwitch = false;
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         Container(
//           height: 35,
//           width: MediaQuery.of(context).size.width / 2.1,
//           alignment: Alignment.center,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Switch(
//                 value: vegSwitch,
//                 onChanged: (bool isOn) {
//                   setState(() {
//                     vegSwitch = isOn;
//                     // vegSwitch == false
//                     //     ? nonVegSwitch = true
//                     //     : nonVegSwitch = false;
//                   });
//                 },
//                 activeColor: Colors.green,
//                 activeTrackColor: const Color(0xffCAD1D8),
//                 inactiveTrackColor: const Color(0xffCAD1D8),
//                 inactiveThumbColor: const Color(0xff9091A4),
//               ),
//               Text(
//                 "Veg".tr(),
//                 style: const TextStyle(
//
//                   color: Color(0xff9091A4),
//                   letterSpacing: 0.5,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const Text(
//           '|',
//           style: TextStyle(color: Color(0xffCAD1D8)),
//         ),
//         SizedBox(
//           height: 35,
//           width: MediaQuery.of(context).size.width / 2.1,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Switch(
//                 value: nonVegSwitch,
//                 onChanged: (bool isOn) {
//                   setState(() {
//                     nonVegSwitch = isOn;
//                   });
//                 },
//                 activeColor: Colors.red,
//                 activeTrackColor: const Color(0xffCAD1D8),
//                 inactiveTrackColor: const Color(0xffCAD1D8),
//                 inactiveThumbColor: const Color(0xff9091A4),
//               ),
//               Text(
//                 "Non-Veg".tr(),
//                 style: const TextStyle(
//
//                   color: Color(0xff9091A4),
//                   letterSpacing: 0.5,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   buildRow(ProductModel productModel, veg, nonveg, inx, bool index) {
//     var price = double.parse(productModel.price);
//     var cate = 0;
//     assert(price is double);
//     if (vegSwitch == true && productModel.veg == true) {
//       isAnother++;
//       return datarow(productModel);
//     } else if (nonVegSwitch == true && productModel.veg == false) {
//       isAnother++;
//       return datarow(productModel);
//     } else if (vegSwitch != true && nonVegSwitch != true) {
//       isAnother++;
//       return datarow(productModel);
//     } else if (nonVegSwitch == true && productModel.nonveg == true) {
//       isAnother++;
//       return datarow(productModel);
//     } else if (inx == productModel.categoryID) {
//       cate++;
//       return (isAnother == 0 && index) ? showEmptyState("No Food are available.") : Container();
//     }
//     // else Center();
//   }
//
//   late CartDatabase cartDatabase;
//   late List<CartProduct> cartProducts = [];
//
//   datarow(ProductModel productModel) {
//     // var quen=productModel.quantity ?? 0 ;
//     Future.delayed(const Duration(milliseconds: 500), () {
//       //setState(() {
//       //     quen == 0 ?
//       //  productModel.quantity = quen:null;
//       //});
//     });
//     var price = double.parse('${productModel.price}');
//     assert(price is double);
//     return GestureDetector(
//       behavior: HitTestBehavior.translucent,
//       onTap: () async {
//         // await Navigator.of(context)
//         //     .push(MaterialPageRoute(builder: (context) => ProductDetailsScreen(productModel: productModel, vendorModel: widget.vendorModel)))
//         //     .whenComplete(() => {setState(() {})});
//
//         // showModalBottomSheet(
//         //   isScrollControlled: true,
//         //   isDismissible: true,
//         //   context: context,
//         //   backgroundColor: Colors.transparent,
//         //   enableDrag: true,
//         //   builder: (context) => ProductDetailsScreen(productModel: productModel, vendorModel: widget.vendorModel),
//         // ).whenComplete(() => {setState(() {})})
//       },
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         margin: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: Colors.grey.shade100, width: 0.1),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.shade300,
//                 blurRadius: 4.0,
//                 spreadRadius: 0.2,
//                 offset: const Offset(0.2, 0.2),
//               ),
//             ],
//             color: Colors.white),
//         child: Row(children: [
//           StreamBuilder<List<CartProduct>>(
//               stream: cartDatabase.watchProducts,
//               initialData: [],
//               builder: (context, snapshot) {
//                 cartProducts = snapshot.data!;
//                 print("cart pro copre  " + cartProducts.length.toString());
//                 print(cartProducts.toString());
//                 print("cart pro co " + productModel.quantity.toString());
//                 Future.delayed(const Duration(milliseconds: 300), () {
//                   productModel.quantity = 0;
//                   if (cartProducts.isNotEmpty) {
//                     for (CartProduct cartProduct in cartProducts) {
//                       if (cartProduct.id == productModel.id) {
//                         productModel.quantity = cartProduct.quantity;
//                       }
//                     }
//                   }
//                 });
//                 return const SizedBox(
//                   height: 0,
//                   width: 0,
//                 );
//               }),
//           Stack(children: [
//             CachedNetworkImage(
//                 height: 80,
//                 width: 80,
//                 imageUrl: getImageVAlidUrl(productModel.photo),
//                 imageBuilder: (context, imageProvider) => Container(
//                       // width: 100,
//                       // height: 100,
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           image: DecorationImage(
//                             image: imageProvider,
//                             fit: BoxFit.cover,
//                           )),
//                     ),
//                 errorWidget: (context, url, error) => ClipRRect(
//                     borderRadius: BorderRadius.circular(15),
//                     child: Image.asset(
//                       placeholderImage,
//                       fit: BoxFit.cover,
//                       width: MediaQuery.of(context).size.width,
//                       height: MediaQuery.of(context).size.height,
//                     ))),
//             Visibility(
//               visible: isDineEnable,
//               child: Positioned(
//                 left: 5,
//                 top: 5,
//                 child: Icon(
//                   Icons.circle,
//                   color: productModel.veg == true ? const Color(0XFF3dae7d) : Colors.redAccent,
//                   size: 13,
//                 ),
//               ),
//             )
//           ]),
//           const Spacer(
//             flex: 1,
//           ),
//           Expanded(
//               flex: 15,
//               child: Container(
//                 padding: const EdgeInsets.only(top: 5),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     Text(
//                       productModel.name,
//                       style: const TextStyle(fontSize: 16, letterSpacing: 0.5, color: Color(0XFF2A2A2A)),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: <Widget>[
//                         (productModel.disPrice == "" || productModel.disPrice == "0")
//                             ? Text(
//                                 symbol + price.toDouble().toStringAsFixed(decimal),
//                                 style: TextStyle(fontSize: 18,  letterSpacing: 0.5, color: Color(COLOR_PRIMARY)),
//                               )
//                             : Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     symbol + price.toDouble().toStringAsFixed(decimal),
//                                     style: const TextStyle(
//                                          letterSpacing: 0.5, color: Colors.grey, decoration: TextDecoration.lineThrough),
//                                   ),
//                                   Text(
//                                     symbol + double.parse(productModel.disPrice.toString()).toDouble().toStringAsFixed(decimal),
//                                     style: TextStyle(  letterSpacing: 0.5, color: Color(COLOR_PRIMARY)),
//                                   ),
//                                 ],
//                               ),
//                         TextButton.icon(
//                           onPressed: () async {
//                             await Navigator.of(context)
//                                 .push(
//                                     MaterialPageRoute(builder: (context) => ProductDetailsScreen(productModel: productModel, vendorModel: widget.vendorModel)))
//                                 .whenComplete(() => {setState(() {})});
//                           },
//                           icon: Icon(
//                             Icons.add,
//                             color: Color(COLOR_PRIMARY),
//                             size: 18,
//                           ),
//                           label: Text(
//                             'ADD'.tr(),
//                             style: TextStyle( color: Color(COLOR_PRIMARY)),
//                           ),
//                           style: TextButton.styleFrom(
//                             side: BorderSide(color: Colors.grey.shade300, width: 2),
//                           ),
//                         )
//                         // productModel.quantity == 0
//                         //     ? isOpen != true
//                         //         ? const Center()
//                         //         : Padding(
//                         //             padding: const EdgeInsets.only(right: 15),
//                         //             child: SizedBox(
//                         //                 height: 33,
//                         //                 // width: 80,
//                         //                 // alignment:Alignment.center,
//                         //                 child: Center(
//                         //                   // height: 10,
//                         //                   //  width: 80,
//                         //                   child: TextButton.icon(
//                         //                     onPressed: () {
//                         //                       if (MyAppState.currentUser == null) {
//                         //                         push(context, const AuthScreen());
//                         //                       } else {
//                         //                         setState(() {
//                         //                           productModel.quantity = 1;
//                         //                           // productModel.price = productModel.disPrice == "" || productModel.disPrice == "0"?productModel.price:productModel.disPrice;
//                         //                           addtocard(productModel, productModel.quantity);
//                         //                         });
//                         //                       }
//                         //                     },
//                         //                     icon: Icon(Icons.add, size: 18, color: Color(COLOR_PRIMARY)),
//                         //                     label: Text(
//                         //                       'ADD'.tr(),
//                         //                       style: TextStyle(height: 1.2, letterSpacing: 0.5, color: Color(COLOR_PRIMARY)),
//                         //                     ),
//                         //                     style: TextButton.styleFrom(
//                         //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//                         //                       side: const BorderSide(color: Color(0XFFC3C5D1), width: 1.5),
//                         //                     ),
//                         //                   ),
//                         //                 )))
//                         //     : Row(
//                         //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         //         crossAxisAlignment: CrossAxisAlignment.center,
//                         //         children: [
//                         //           IconButton(
//                         //               onPressed: () {
//                         //                 if (productModel.quantity != 0) {
//                         //                   setState(() {
//                         //                     productModel.quantity--;
//                         //                     if (productModel.quantity >= 0) {
//                         //                       // productModel.price = productModel.disPrice == "" || productModel.disPrice == "0"?productModel.price:productModel.disPrice;
//                         //                       removetocard(productModel, productModel.quantity);
//                         //                     } else {
//                         //                       // addtocard(productModel);
//                         //                       //removeQuntityFromCartProduct(productModel);
//                         //
//                         //                     }
//                         //
//                         //                     //: addtocard(productModel);
//                         //                   });
//                         //                 }
//                         //                 //   productModel.quantity >=1?
//                         //                 //   removetocard(productModel, productModel.quantity)
//                         //                 //  :null;
//                         //                 // },
//                         //                 // );
//                         //               },
//                         //               icon: Image(
//                         //                 image: const AssetImage("assets/images/minus.png"),
//                         //                 color: Color(COLOR_PRIMARY),
//                         //                 height: 28,
//                         //               )),
//                         //           const SizedBox(
//                         //             width: 5,
//                         //           ),
//                         //
//                         //           // cartData( productModel.id)== null?
//                         //
//                         //           StreamBuilder<List<CartProduct>>(
//                         //               stream: cartDatabase.watchProducts,
//                         //               initialData: const [],
//                         //               builder: (context, snapshot) {
//                         //                 cartProducts = snapshot.data!;
//                         //                 return SizedBox(
//                         //                     height: 25,
//                         //                     width: 0,
//                         //                     child: Column(children: [
//                         //                       Expanded(
//                         //                           child: ListView.builder(
//                         //                               itemCount: cartProducts.length,
//                         //                               itemBuilder: (context, index) {
//                         //                                 cartProducts[index].id == productModel.id ? productModel.quantity = cartProducts[index].quantity : null;
//                         //                                 // print('yahaaaaa');
//                         //                                 if (cartProducts[index].id == productModel.id) {
//                         //                                   return const Center();
//                         //                                 } else {
//                         //                                   return Container();
//                         //                                 }
//                         //                                 //  return Center();
//                         //
//                         //                                 // print(quen);
//                         //                               }))
//                         //                     ]));
//                         //               }),
//                         //           Text(
//                         //             '${productModel.quantity}'.tr(),
//                         //             style: const TextStyle(
//                         //               fontSize: 20,
//                         //               color: Colors.black,
//                         //               letterSpacing: 0.5,
//                         //             ),
//                         //           ),
//                         //           //  Text("null"),
//                         //           const SizedBox(
//                         //             width: 5,
//                         //           ),
//                         //           IconButton(
//                         //               onPressed: () {
//                         //                 setState(() {
//                         //                   if (productModel.quantity != 0) {
//                         //                     productModel.quantity++;
//                         //                   }
//                         //                   //productModel.price = productModel.disPrice == "" || productModel.disPrice == "0"?productModel.price:productModel.disPrice;
//                         //                   addtocard(productModel, productModel.quantity);
//                         //                 });
//                         //               },
//                         //               icon: Image(
//                         //                 image: const AssetImage("assets/images/plus.png"),
//                         //                 color: Color(COLOR_PRIMARY),
//                         //                 height: 28,
//                         //               ))
//                         //         ],
//                         //       )
//                       ],
//                     ),
//                   ],
//                 ),
//               )),
//         ]),
//       ),
//     );
//   }
//
// //   addtocard(productModel, quantity) async {
// //     if (productModel.quantity == 0) {
// //       productModel.quantity = 1;
// //     }
// //     //List<CartProduct> cartProducts = await cartDatabase.allCartProducts;
// //     /*
// //     if (cartProducts.length > 0) {
// //       for (int a = 0; a < cartProducts.length; a++) {
// //         print("***+++ADDTOCART" +
// //             cartProducts[a].vendorID.toString() +
// //             "  " +
// //             productModel.vendorID.toString());
// //         if (cartProducts[a].vendorID != productModel.vendorID) {
// //           print("***+++ADDTOCART");
// //           cartDatabase.addProduct(productModel);
// //           print("***+++ADDTOCARTFinal1");
// //         } else {
// //           print("***+++REMOVETOCARTBEFORE...");
// //           cartProducts[a].quantity++;
// //           cartDatabase.updateProduct(cartProducts[a]);
// //           print("***+++REMOVETOCART");
// //         }
// //       }
// //     } else {
// //
// //         print("***+++ADDTOCARTELSE");
// //         cartDatabase.addProduct(productModel);
// //         print("***+++ADDTOCARTFinal1ELSE");
// //
// //     }*/
// //
// //     /*if (cartProducts
// //         .where((element) => element.vendorID != productModel.vendorID)
// //         .isEmpty) {
// //       print("***+++ADDTOCART");
// //       cartDatabase.addProduct(productModel);
// //       print("***+++ADDTOCARTFinal1");
// //     } else {
// //       {
// //         print("***+++REMOVETOCARTBEFORE...");
// //         cartDatabase.updateProduct(productModel);
// //         print("***+++REMOVETOCART");
// //       }
// //     }
// // */
// //     /*  if (cartProducts
// //         .where((element) => element.vendorID != productModel.vendorID)
// //         .isEmpty) {
// //       print("***+++ADDTOCART");
// //       cartDatabase.addProduct(productModel);
// //       print("***+++ADDTOCARTFinal1");
// //     } else {
// //       {
// //         print("***+++REMOVETOCARTBEFORE...");
// //         cartDatabase.updateProduct(productModel);
// //         print("***+++REMOVETOCART");
// //       }
// //     }*/
// //     List<AddAddonsDemo> lstTemp = [];
// //     SharedPreferences sp = await SharedPreferences.getInstance();
// //     final String musicsString = sp.getString('musics_key') != null ? sp.getString('musics_key')! : "";
// //
// //     if (musicsString.isNotEmpty && musicsString != null) {
// //       lstTemp = AddAddonsDemo.decode(musicsString);
// //     }
// //     double AddOnVal = 0;
// //     for (int i = 0; i < lstTemp.length; i++) {
// //       AddAddonsDemo addAddonsDemo = lstTemp[i];
// //       if (addAddonsDemo.categoryID == productModel.id) {
// //         AddOnVal = AddOnVal + double.parse(addAddonsDemo.price!);
// //       }
// //     }
// //     List<CartProduct> cartProducts = await cartDatabase.allCartProducts;
// //     /*List<CartProduct> cartProducts = await cartDatabase.allCartProducts;
// //     if (cartProducts
// //         .where((element) => element.vendorID != productModel.vendorID)
// //         .isEmpty) {
// //       print("====PDAdd");
// //       print(productModel);
// //       cartDatabase.addProduct(productModel);
// //       print("====PDAdd=Done");
// //     } else {
// //       {
// //         print("====PDUpdate");
// //         await cartDatabase.updateProduct(productModel);
// //         print("====PDUpdateDone");
// //       }
// //     }*/
// //
// //     if (quantity > 1) {
// //       var joinTitleString = "";
// //       String mainPrice = "";
// //       var joinSizeString = "";
// //       List<AddAddonsDemo> lstAddOns = [];
// //       List<String> lstAddOnsTemp = [];
// //       double extras_price = 0.0;
// //
// //       List<AddSizeDemo> lstAddSize = [];
// //       List<String> lstAddSizeTemp = [];
// //       List<String> lstSizeTemp = [];
// //       String addOns = sp.getString("musics_key") != null ? sp.getString('musics_key')! : "";
// //       String addSize = sp.getString("addsize") != null ? sp.getString('addsize')! : "";
// //
// //       bool isAddSame = false;
// //       if (addSize.isNotEmpty && addSize != null) {
// //         lstAddSize = AddSizeDemo.decode(addSize);
// //
// //         for (int a = 0; a < lstAddSize.length; a++) {
// //           if (lstAddSize[a].categoryID == productModel.id) {
// //             isAddSame = true;
// //             lstAddSizeTemp.add(lstAddSize[a].price!);
// //             lstSizeTemp.add(lstAddSize[a].name!);
// //             mainPrice = ((lstAddSize[a].price!));
// //           }
// //         }
// //         joinSizeString = lstSizeTemp.join(",");
// //       }
// //
// //       if (!isAddSame) {
// //         if (productModel.disPrice != null && productModel.disPrice!.isNotEmpty && double.parse(productModel.disPrice!) != 0) {
// //           mainPrice = productModel.disPrice!;
// //         } else {
// //           mainPrice = productModel.price;
// //         }
// //       }
// //
// //       if (addOns.isNotEmpty && addOns != null) {
// //         lstAddOns = AddAddonsDemo.decode(addOns);
// //         for (int a = 0; a < lstAddOns.length; a++) {
// //           AddAddonsDemo newAddonsObject = lstAddOns[a];
// //           if (newAddonsObject.categoryID == productModel.id) {
// //             if (newAddonsObject.isCheck == true) {
// //               lstAddOnsTemp.add(newAddonsObject.name!);
// //               extras_price += (double.parse(newAddonsObject.price!));
// //             }
// //           }
// //         }
// //
// //         joinTitleString = lstAddOnsTemp.join(",");
// //       }
// //
// //       await cartDatabase.updateProduct(CartProduct(
// //         id: productModel.id,
// //         name: productModel.name,
// //         photo: productModel.photo,
// //         price: mainPrice,
// //         discountPrice: productModel.disPrice,
// //         vendorID: productModel.vendorID,
// //         quantity: quantity,
// //         extras_price: extras_price.toString(),
// //         extras: joinTitleString,
// //         size: joinSizeString,
// //       ));
// //     } else {
// //       if (cartProducts.isEmpty) {
// //         cartDatabase.addProduct(productModel);
// //       } else {
// //         if (cartProducts[0].vendorID == widget.vendorModel.id) {
// //           cartDatabase.addProduct(productModel);
// //         } else {
// //           cartDatabase.deleteAllProducts();
// //           cartDatabase.addProduct(productModel);
// //         }
// //       }
// //     }
// //     updatePrice(productModel);
// //   }
// //
// //   removetocard(productModel, qun) async {
// //     if (qun >= 1) {
// //       //  setState(() async {
// //       cartDatabase.allCartProducts.then((products) {
// //         for (CartProduct element in products) {
// //           if (element.id == productModel.id) {
// //             CartProduct cartProduct = element;
// //             cartProduct.quantity = qun;
// //             if (cartProduct.extras == null) {
// //               cartProduct.extras = List<String>.empty();
// //             } else {
// //               if (cartProduct.extras is String) {
// //                 if (cartProduct.extras == '[]') {
// //                   cartProduct.extras = List<String>.empty();
// //                 } else {
// //                   String extraDecode = cartProduct.extras.toString().replaceAll("[", "").replaceAll("]", "").replaceAll("\"", "");
// //                   if (extraDecode.contains(",")) {
// //                     cartProduct.extras = extraDecode.split(",");
// //                   } else {
// //                     cartProduct.extras = [extraDecode];
// //                   }
// //                 }
// //               }
// //               if (cartProduct.extras is List) {
// //                 cartProduct.extras = cartProduct.extras.cast<String>();
// //               }
// //             }
// //             cartDatabase.updateProduct(cartProduct);
// //           }
// //         }
// //       });
// //       // });
// //     } else {
// //       cartDatabase.removeProduct(productModel.id);
// //     }
// //   }
// //
// //   removeQuntityFromCartProduct(productModel) async {
// //     List<CartProduct> cartProducts = await cartDatabase.allCartProducts;
// //     if (cartProducts.isNotEmpty) {
// //       for (int a = 0; a < cartProducts.length; a++) {
// //         if (cartProducts[a].vendorID != productModel.vendorID) {
// //           cartDatabase.addProduct(productModel);
// //         } else {
// //           cartProducts[a].quantity--;
// //           cartDatabase.updateProduct(cartProducts[a]);
// //         }
// //       }
// //     } else {
// //       cartDatabase.addProduct(productModel);
// //     }
// //   }
//
//   showTiming(BuildContext context) {
//     List<WorkingHoursModel> workingHours = widget.vendorModel.workingHours;
//     return Container(
//         decoration: BoxDecoration(
//             color: isDarkMode(context) ? const Color(DARK_BG_COLOR) : Colors.white,
//             borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
//         child: Stack(children: [
//           SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 Container(
//                     child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
//                   Container(
//                       alignment: Alignment.center,
//                       padding: const EdgeInsets.only(top: 15),
//                       child: Text(
//                         'Store Timing'.tr(),
//                         style: TextStyle(fontSize: 18,  color: isDarkMode(context) ? const Color(0XFFdadada) : const Color(0XFF252525)),
//                       )),
//                 ])),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 ListView.builder(
//                     shrinkWrap: true,
//                     physics: const BouncingScrollPhysics(),
//                     itemCount: workingHours.length,
//                     itemBuilder: (context, dayIndex) {
//                       print(workingHours[dayIndex].day.toString());
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
//                         child: Card(
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
//                             color: isDarkMode(context) ? const Color(0XFFdadada).withOpacity(0.1) : Colors.grey.shade100,
//                             elevation: 2,
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 4),
//                               child: Column(
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Padding(
//                                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                                         child: Text(
//                                           workingHours[dayIndex].day.toString(),
//                                           style: TextStyle(
//                                               fontSize: 16,
//
//                                               color: isDarkMode(context) ? const Color(0XFFdadada) : const Color(0XFF252525)),
//                                         ),
//                                       ),
//                                       Visibility(
//                                         visible: workingHours[dayIndex].timeslot!.isEmpty,
//                                         child: Padding(
//                                           padding: const EdgeInsets.symmetric(horizontal: 15),
//                                           child: Container(
//                                               height: 35,
//                                               decoration: BoxDecoration(
//                                                   border: Border.all(color: Colors.grey.shade400, width: 1.5),
//                                                   color: isDarkMode(context) ? Colors.white : Colors.white,
//                                                   borderRadius: BorderRadius.circular(10)),
//                                               padding: const EdgeInsets.only(right: 15, left: 10),
//                                               child: Row(children: [
//                                                 const Icon(
//                                                   Icons.circle,
//                                                   color: Colors.redAccent,
//                                                   size: 11,
//                                                 ),
//                                                 const SizedBox(
//                                                   width: 5,
//                                                 ),
//                                                 Text("Closed".tr(), style: const TextStyle(  color: Colors.redAccent))
//                                               ])),
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                   Visibility(
//                                     visible: workingHours[dayIndex].timeslot!.isNotEmpty,
//                                     child: ListView.builder(
//                                         physics: const BouncingScrollPhysics(),
//                                         shrinkWrap: true,
//                                         itemCount: workingHours[dayIndex].timeslot!.length,
//                                         itemBuilder: (context, slotIndex) {
//                                           return buildTimeCard(timeslot: workingHours[dayIndex].timeslot![slotIndex]);
//                                         }),
//                                   ),
//                                 ],
//                               ),
//                             )),
//                       );
//                     }),
//                 const SizedBox(
//                   height: 10,
//                 ),
//               ],
//             ),
//           ),
//           Positioned(
//               right: 10,
//               top: 5,
//               child: InkWell(
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                   child:
//                       // Padding(padding: EdgeInsets.only(right: 5,top: 5,left: 15,bottom: 20),
//                       // child:
//                       const CircleAvatar(
//                           radius: 17,
//                           backgroundColor: Color(0XFFF1F4F7),
//                           child: Image(
//                             image: AssetImage("assets/images/cancel.png"),
//                             height: 35,
//                           ))))
//         ]));
//   }
//
//   buildTimeCard({required Timeslot timeslot}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Card(
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(6),
//             side: BorderSide(
//               color: isDarkMode(context) ? const Color(0XFF3c3a2e) : const Color(0XFFC3C5D1),
//               width: 1,
//             ),
//           ),
//           child: Padding(
//               padding: const EdgeInsets.only(top: 7, bottom: 7, left: 20, right: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Text("From ".tr(), style: TextStyle( color: isDarkMode(context) ? const Color(0XFFa5a292) : const Color(0xff5A5D6D))),
//                   //  SizedBox(height: 5,),
//                   Text(timeslot.from.toString(),
//                       style: TextStyle( color: isDarkMode(context) ? const Color(0XFFa5a292) : const Color(0XFF5A5D6D)))
//                 ],
//               )),
//         ),
//         const SizedBox(
//           width: 20,
//         ),
//         Card(
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(6),
//             side: BorderSide(
//               color: isDarkMode(context) ? const Color(0XFF3c3a2e) : const Color(0XFFC3C5D1),
//               width: 1,
//             ),
//           ),
//           child: Padding(
//               padding: const EdgeInsets.only(top: 7, bottom: 7, left: 20, right: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Text("To ".tr(), style: TextStyle( color: isDarkMode(context) ? const Color(0XFFa5a292) : const Color(0xff5A5D6D))),
//                   //  SizedBox(height: 5,),
//                   Text(timeslot.to.toString(),
//                       style: TextStyle( color: isDarkMode(context) ? const Color(0XFFa5a292) : const Color(0XFF5A5D6D)))
//                 ],
//               )),
//         ),
//       ],
//     );
//   }
//
//   bool isOpen = false;
//
//   statusCheck() {
//     final now = new DateTime.now();
//     var day = DateFormat('EEEE', 'en_US').format(now);
//     var date = DateFormat('dd-MM-yyyy').format(now);
//     widget.vendorModel.workingHours.forEach((element) {
//       print("===>");
//       print(element);
//       if (day == element.day.toString()) {
//         print("---->1" + element.day.toString());
//         if (element.timeslot!.isNotEmpty) {
//           element.timeslot!.forEach((element) {
//             print("===>2");
//             print(element);
//             var start = DateFormat("dd-MM-yyyy HH:mm").parse(date + " " + element.from.toString());
//             var end = DateFormat("dd-MM-yyyy HH:mm").parse(date + " " + element.to.toString());
//             if (isCurrentDateInRange(start, end)) {
//               print("===>1");
//               setState(() {
//                 isOpen = true;
//                 print("===>");
//                 print(isOpen);
//               });
//             }
//           });
//         }
//       }
//     });
//   }
//
//   bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
//     print(startDate);
//     print(endDate);
//     final currentDate = DateTime.now();
//     print(currentDate);
//     return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
//   }
//
//   resttiming() {
//     if (isOpen == true) {
//       return Container(
//           height: 35,
//           decoration:
//               const BoxDecoration(color: Color(0XFFF1F4F7), borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))),
//           padding: const EdgeInsets.only(right: 40, left: 10),
//           child: Row(children: [
//             const Icon(
//               Icons.circle,
//               color: Color(0XFF3dae7d),
//               size: 13,
//             ),
//             const SizedBox(
//               width: 10,
//             ),
//             Text("Open".tr(), style: const TextStyle(  fontSize: 16, color: Color(0XFF3dae7d)))
//           ]));
//     } else {
//       return Container(
//           height: 35,
//           decoration:
//               const BoxDecoration(color: Color(0XFFF1F4F7), borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))),
//           padding: const EdgeInsets.only(right: 40, left: 10),
//           child: Row(children: [
//             const Icon(
//               Icons.circle,
//               color: Colors.redAccent,
//               size: 13,
//             ),
//             const SizedBox(
//               width: 10,
//             ),
//             Text("Close".tr(), style: const TextStyle(  fontSize: 16, letterSpacing: 0.5, color: Colors.redAccent))
//           ]));
//     }
//   }
//
//   String? getDate(String date) {
//     final format = DateFormat("MMM dd, yyyy");
//     String formattedDate = format.format(DateTime.parse(date));
//     return formattedDate;
//   }
//
//   openCouponCode(
//     BuildContext context,
//     OfferModel offerModel,
//   ) {
//     return Container(
//       height: 250,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         color: Colors.white,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//               margin: const EdgeInsets.only(
//                 left: 40,
//                 right: 40,
//               ),
//               padding: const EdgeInsets.only(
//                 left: 50,
//                 right: 50,
//               ),
//               decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/offer_code_bg.png"))),
//               child: Padding(
//                 padding: const EdgeInsets.all(15.0),
//                 child: Text(
//                   offerModel.offerCode!,
//                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, letterSpacing: 0.9),
//                 ),
//               )),
//           GestureDetector(
//             onTap: () {
//               FlutterClipboard.copy(offerModel.offerCode!).then((value) {
//                 SnackBar snackBar = SnackBar(
//                   content: Text(
//                     "Coupon code copied".tr(),
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                   backgroundColor: Colors.black38,
//                 );
//                 ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                 return Navigator.pop(context);
//               });
//             },
//             child: Container(
//               margin: const EdgeInsets.only(top: 30, bottom: 30),
//               child: Text(
//                 "COPY CODE".tr(),
//                 style: TextStyle(color: Color(COLOR_PRIMARY), fontWeight: FontWeight.w500, letterSpacing: 0.1),
//               ),
//             ),
//           ),
//           Container(
//             margin: const EdgeInsets.only(bottom: 30),
//             child: RichText(
//               text: TextSpan(
//                 text: "Use code ".tr(),
//                 style: const TextStyle(fontSize: 16.0, color: Colors.grey, fontWeight: FontWeight.w700),
//                 children: <TextSpan>[
//                   TextSpan(
//                     text: offerModel.offerCode,
//                     style: TextStyle(color: Color(COLOR_PRIMARY), fontWeight: FontWeight.w500, letterSpacing: 0.1),
//                   ),
//                   TextSpan(
//                     text:
//                         " & get ${offerModel.discountTypeOffer == "Fix Price" ? symbol : ""}${offerModel.discountOffer}${offerModel.discountTypeOffer == "Percentage" ? "% off" : " off"} ",
//                     style: const TextStyle(fontSize: 16.0, color: Colors.grey, fontWeight: FontWeight.w700),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
