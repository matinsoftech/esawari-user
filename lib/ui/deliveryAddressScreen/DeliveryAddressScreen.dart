// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:foodie_customer/constants.dart';
// import 'package:foodie_customer/main.dart';
// import 'package:foodie_customer/model/AddressModel.dart';
// import 'package:foodie_customer/model/DeliveryChargeModel.dart';
// import 'package:foodie_customer/model/User.dart';
// import 'package:foodie_customer/model/VendorModel.dart';
// import 'package:foodie_customer/services/FirebaseHelper.dart';
// import 'package:foodie_customer/services/helper.dart';
// import 'package:foodie_customer/services/localDatabase.dart';
// import 'package:foodie_customer/ui/payment/PaymentScreen.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:place_picker/place_picker.dart';
//
// import '../../model/TaxModel.dart';
//
// class DeliveryAddressScreen extends StatefulWidget {
//   static final kInitialPosition = LatLng(-33.8567844, 151.213108);
//
//   final double total;
//   final double? discount;
//   final String? couponCode;
//   final String? couponId, notes;
//   final List<CartProduct> products;
//   final List<String>? extraAddons;
//   final String? extraSize;
//   final String? tipValue;
//   final String? deliveryCharge;
//   final bool? takeAway;
//   final List<TaxModel>? taxModel;
//   final Map<String, dynamic>? specialDiscountMap;
//   final Timestamp? scheduleTime;
//
//   const DeliveryAddressScreen(
//       {Key? key,
//       required this.total,
//       this.discount,
//       this.couponCode,
//       this.couponId,
//       required this.products,
//       this.extraAddons,
//       this.extraSize,
//       this.tipValue,
//       this.takeAway,
//       this.specialDiscountMap,
//       this.deliveryCharge,
//       this.taxModel,
//         this.scheduleTime,
//       this.notes})
//       : super(key: key);
//
//   @override
//   _DeliveryAddressScreenState createState() => _DeliveryAddressScreenState();
// }
//
// class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   String? country;
//   var street = TextEditingController();
//   var street1 = TextEditingController();
//   var landmark = TextEditingController();
//   var landmark1 = TextEditingController();
//   var zipcode = TextEditingController();
//   var zipcode1 = TextEditingController();
//   var city = TextEditingController();
//   var city1 = TextEditingController();
//   var cutries = TextEditingController();
//   var cutries1 = TextEditingController();
//   var lat;
//   var long;
//
//   AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
//
//   @override
//   void dispose() {
//     street.dispose();
//     landmark.dispose();
//     city.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // if(MyAppState.currentUser!.shippingAddress.country != ''){
//     //   country = MyAppState.currentUser!.shippingAddress.country;
//     // }
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Delivery Address'.tr(),
//           style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
//         ).tr(),
//       ),
//       body: Container(
//           color: isDarkMode(context) ? null : Color(0XFFF1F4F7),
//           child: Form(
//               key: _formKey,
//               autovalidateMode: _autoValidateMode,
//               child: SingleChildScrollView(
//                   child: Column(children: [
//                 SizedBox(
//                   height: 40,
//                 ),
//                 Card(
//                   elevation: 0.5,
//                   color: isDarkMode(context) ? Color(DARK_BG_COLOR) : Color(0XFFFFFFFF),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                   margin: EdgeInsets.only(left: 20, right: 20),
//                   child: Column(
//                     children: [
//                       Container(
//                         padding: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 10),
//                         child: TextFormField(
//                             // controller: street,
//                             controller: street1.text.isEmpty ? street : street1,
//                             textAlignVertical: TextAlignVertical.center,
//                             textInputAction: TextInputAction.next,
//                             validator: validateEmptyField,
//                             // onSaved: (text) => line1 = text,
//                             onSaved: (text) => street.text = text!,
//                             style: TextStyle(fontSize: 18.0),
//                             keyboardType: TextInputType.streetAddress,
//                             cursorColor: Color(COLOR_PRIMARY),
//                             // initialValue:
//                             //     MyAppState.currentUser!.shippingAddress.line1,
//                             decoration: InputDecoration(
//                               // contentPadding: EdgeInsets.symmetric(horizontal: 24),
//                               labelText: 'Street 1'.tr(),
//                               labelStyle: TextStyle(color: Color(0Xff696A75), fontSize: 17),
//                               hintStyle: TextStyle(color: Colors.grey.shade400),
//                               focusedBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
//                               ),
//                               errorBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                               focusedErrorBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                               enabledBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Color(0XFFB1BCCA)),
//                                 // borderRadius: BorderRadius.circular(8.0),
//                               ),
//                             )),
//                       ),
//                       // ListTile(
//                       //   contentPadding:
//                       //       const EdgeInsetsDirectional.only(start: 40, end: 30, top: 24),
//                       //   leading: Container(
//                       //     // width: 0,
//                       //     child: Text(
//                       //       'Street 2'.tr(),
//                       //       style: TextStyle(fontSize: 16),
//                       //     ),
//                       //   ),
//                       // ),
//                       Container(
//                         padding: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 10),
//                         child: TextFormField(
//                           // controller: _controller,
//                           controller: landmark1.text.isEmpty ? landmark : landmark1,
//                           textAlignVertical: TextAlignVertical.center,
//                           textInputAction: TextInputAction.next,
//                           validator: validateEmptyField,
//                           onSaved: (text) => landmark.text = text!,
//                           style: TextStyle(fontSize: 18.0),
//                           keyboardType: TextInputType.streetAddress,
//                           cursorColor: Color(COLOR_PRIMARY),
//                           // initialValue:
//                           //     MyAppState.currentUser!.shippingAddress.line2,
//                           decoration: InputDecoration(
//                             // contentPadding: EdgeInsets.symmetric(horizontal: 24),
//                             labelText: 'Landmark'.tr(),
//                             labelStyle: TextStyle(color: Color(0Xff696A75), fontSize: 17),
//                             hintStyle: TextStyle(color: Colors.grey.shade400),
//                             focusedBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
//                             ),
//                             errorBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                               borderRadius: BorderRadius.circular(8.0),
//                             ),
//                             focusedErrorBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                               borderRadius: BorderRadius.circular(8.0),
//                             ),
//                             enabledBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(color: Color(0XFFB1BCCA)),
//                               // borderRadius: BorderRadius.circular(8.0),
//                             ),
//                           ),
//                         ),
//                       ),
//                       // ListTile(
//                       //   contentPadding:
//                       //       const EdgeInsetsDirectional.only(start: 40, end: 30, top: 24),
//                       //   leading: Container(
//                       //     // width: 0,
//                       //     child: Text(
//                       //       'Zip Code'.tr(),
//                       //       style: TextStyle(fontSize: 16),
//                       //     ),
//                       //   ),
//                       // ),
//                       Container(
//                         padding: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 10),
//                         child: TextFormField(
//                           controller: zipcode1.text.isEmpty ? zipcode : zipcode1,
//                           textAlignVertical: TextAlignVertical.center,
//                           textInputAction: TextInputAction.next,
//                           validator: validateEmptyField,
//                           onSaved: (text) => zipcode.text = text!,
//                           style: TextStyle(fontSize: 18.0),
//                           keyboardType: TextInputType.phone,
//                           cursorColor: Color(COLOR_PRIMARY),
//                           // initialValue: MyAppState
//                           //     .currentUser!.shippingAddress.postalCode,
//                           decoration: InputDecoration(
//                             // contentPadding: EdgeInsets.symmetric(horizontal: 24),
//                             labelText: 'Zip Code'.tr(),
//                             labelStyle: TextStyle(color: Color(0Xff696A75), fontSize: 17),
//                             hintStyle: TextStyle(color: Colors.grey.shade400),
//                             focusedBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
//                             ),
//                             errorBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                               borderRadius: BorderRadius.circular(8.0),
//                             ),
//                             focusedErrorBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                               borderRadius: BorderRadius.circular(8.0),
//                             ),
//                             enabledBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(color: Color(0XFFB1BCCA)),
//                               // borderRadius: BorderRadius.circular(8.0),
//                             ),
//                           ),
//                         ),
//                       ),
//                       // ListTile(
//                       //   contentPadding:
//                       //       const EdgeInsetsDirectional.only(start: 40, end: 30, top: 24),
//                       //   leading: Container(
//                       //     // width: 0,
//                       //     child: Text(
//                       //       'City'.tr(),
//                       //       style: TextStyle(fontSize: 16),
//                       //     ),
//                       //   ),
//                       // ),
//                       Container(
//                           padding: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 10),
//                           child: TextFormField(
//                             controller: city1.text.isEmpty ? city : city1,
//                             textAlignVertical: TextAlignVertical.center,
//                             textInputAction: TextInputAction.next,
//                             validator: validateEmptyField,
//                             onSaved: (text) => city.text = text!,
//                             style: TextStyle(fontSize: 18.0),
//                             keyboardType: TextInputType.streetAddress,
//                             cursorColor: Color(COLOR_PRIMARY),
//                             // initialValue:
//                             //     MyAppState.currentUser!.shippingAddress.city,
//                             decoration: InputDecoration(
//                               // contentPadding: EdgeInsets.symmetric(horizontal: 24),
//                               labelText: 'City'.tr(),
//                               labelStyle: TextStyle(color: Color(0Xff696A75), fontSize: 17),
//                               hintStyle: TextStyle(color: Colors.grey.shade400),
//                               focusedBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
//                               ),
//                               errorBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                               focusedErrorBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                               enabledBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Color(0XFFB1BCCA)),
//                                 // borderRadius: BorderRadius.circular(8.0),
//                               ),
//                             ),
//                           )),
//
//                       Container(
//                           padding: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 10),
//                           child: TextFormField(
//                             controller: cutries1.text.isEmpty ? cutries : cutries1,
//                             textAlignVertical: TextAlignVertical.center,
//                             textInputAction: TextInputAction.next,
//                             validator: validateEmptyField,
//                             onSaved: (text) => cutries.text = text!,
//                             style: TextStyle(fontSize: 18.0),
//                             keyboardType: TextInputType.streetAddress,
//                             cursorColor: Color(COLOR_PRIMARY),
//                             // initialValue:
//                             //     MyAppState.currentUser!.shippingAddress.city,
//                             decoration: InputDecoration(
//                               // contentPadding: EdgeInsets.symmetric(horizontal: 24),
//                               labelText: 'Country'.tr(),
//                               labelStyle: TextStyle(color: Color(0Xff696A75), fontSize: 17),
//                               hintStyle: TextStyle(color: Colors.grey.shade400),
//                               focusedBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
//                               ),
//                               errorBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                               focusedErrorBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                               enabledBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Color(0XFFB1BCCA)),
//                                 // borderRadius: BorderRadius.circular(8.0),
//                               ),
//                             ),
//                           )),
//
//                       // ListTile(
//                       //   contentPadding:
//                       //       const EdgeInsetsDirectional.only(start: 40, end: 30, top: 24),
//                       //   leading: Container(
//                       //     // width: 0,
//                       //     child: Text(
//                       //       'Country'.tr(),
//                       //       style: TextStyle(fontSize: 16),
//                       //     ),
//                       //   ),
//                       // ),
//
//                       // ListTile(
//                       //     contentPadding: const EdgeInsetsDirectional.only(
//                       //         start: 5, end: 10),
//                       //     subtitle: Padding(
//                       //         padding: EdgeInsets.only(left: 16, right: 10),
//                       //         child: Divider(
//                       //           color: Color(0XFFB1BCCA),
//                       //           thickness: 1.5,
//                       //         )),
//                       //     title: ButtonTheme(
//                       //         alignedDropdown: true,
//                       //         child: DropdownButtonHideUnderline(
//                       //             child: DropdownButton<String>(
//                       //           icon: Icon(Icons.keyboard_arrow_down_outlined),
//                       //           hint: country == null
//                       //               ? Text('Country'.tr())
//                       //               : Text(
//                       //                   country!,
//                       //                   style: TextStyle(
//                       //                       color: Color(COLOR_PRIMARY)),
//                       //                 ),
//                       //           items: <String>[
//                       //             'USA',
//                       //             'UK',
//                       //             'India',
//                       //             'France',
//                       //             'Russia',
//                       //             'Japan',
//                       //             'UAE',
//                       //             'Qatar',
//                       //             'Netherland',
//                       //             'Canada'
//                       //           ].map((String value) {
//                       //             return DropdownMenuItem<String>(
//                       //               value: value,
//                       //               child: Text(value),
//                       //             );
//                       //           }).toList(),
//                       //           isExpanded: true,
//                       //           iconSize: 30.0,
//                       //           onChanged: (value) {
//                       //             setState(() {
//                       //               country = value;
//                       //             });
//                       //           },
//                       //         )))
//                       // ),
//                       // leading: Container(
//                       //   width: 60,
//                       //   child: Text(
//                       //     'Country'.tr(),
//                       //     style: TextStyle(fontWeight: FontWeight.bold),
//                       //   ),
//                       // ),
//                       // title: TextFormField(
//                       //   textAlignVertical: TextAlignVertical.center,
//                       //   textInputAction: TextInputAction.done,
//                       //   validator: validateEmptyField,
//                       //   onFieldSubmitted: (_) => validateForm(),
//                       //   maxLength: 2,
//                       //   onSaved: (text) => country = text,
//                       //   style: TextStyle(fontSize: 18.0),
//                       //   keyboardType: TextInputType.streetAddress,
//                       //   cursorColor: Color(COLOR_PRIMARY),
//                       //   initialValue: MyAppState.currentUser!.shippingAddress.country,
//                       //   decoration: InputDecoration(
//                       //     contentPadding: EdgeInsets.symmetric(horizontal: 24),
//                       //     hintText: 'UK'.tr(),
//                       //     hintStyle: TextStyle(color: Colors.grey.shade400),
//                       //     focusedBorder: OutlineInputBorder(
//                       //       borderRadius: BorderRadius.circular(8.0),
//                       //       borderSide:
//                       //           BorderSide(color: Color(COLOR_PRIMARY), width: 2.0),
//                       //     ),
//                       //     errorBorder: OutlineInputBorder(
//                       //       borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                       //       borderRadius: BorderRadius.circular(8.0),
//                       //     ),
//                       //     focusedErrorBorder: OutlineInputBorder(
//                       //       borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//                       //       borderRadius: BorderRadius.circular(8.0),
//                       //     ),
//                       //     enabledBorder: OutlineInputBorder(
//                       //       borderSide: BorderSide(color: Colors.grey.shade300),
//                       //       borderRadius: BorderRadius.circular(8.0),
//                       //     ),
//                       //   ),
//                       // ),
//                       Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: Card(
//                             child: ListTile(
//                                 leading: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     // ImageIcon(
//                                     //   AssetImage('assets/images/current_location1.png'),
//                                     //   size: 23,
//                                     //   color: Color(COLOR_PRIMARY),
//                                     // ),
//                                     Icon(
//                                       Icons.location_searching_rounded,
//                                       color: Color(COLOR_PRIMARY),
//                                     ),
//                                   ],
//                                 ),
//                                 title: Text(
//                                   "Current Location".tr(),
//                                   style: TextStyle(color: Color(COLOR_PRIMARY)),
//                                 ),
//                                 subtitle: Text(
//                                   "Using GPS".tr(),
//                                   style: TextStyle(color: Color(COLOR_PRIMARY)),
//                                 ),
//                                 onTap: () async {
//                                   LocationResult result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => PlacePicker(GOOGLE_API_KEY)));
//
//                                   street1.text = result.name.toString();
//                                   landmark1.text = result.subLocalityLevel1!.name == null ? result.subLocalityLevel2!.name.toString() : result.subLocalityLevel1!.name.toString();
//                                   city1.text = result.city!.name.toString();
//                                   cutries1.text = result.country!.name.toString();
//                                   zipcode1.text = result.postalCode.toString();
//                                   lat = result.latLng!.latitude;
//                                   long = result.latLng!.longitude;
//
//                                   // MyAppState.currentUser!.shippingAddress.location.latitude = result.latLng!.latitude;
//                                   // MyAppState.currentUser!.shippingAddress.location.longitude = result.latLng!.longitude;
//                                   getDeliveyData();
//                                   setState(() {});
//                                 })),
//                       ),
//
//                       SizedBox(
//                         height: 40,
//                       ),
//
//                       Visibility(
//                         child: Text("Your new delivery charge will be".tr() + " ${amountShow(amount: deliveryCharges.toString())}",
//                             style: TextStyle(
//                               fontFamily: "Poppinsm",
//                             )),
//                         visible: isLocationChange,
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox()
//               ])))),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25),
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.all(15),
//             backgroundColor: Color(COLOR_PRIMARY),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//           onPressed: () => validateForm(),
//           child: Text(
//             'CONTINUE'.tr(),
//             style: TextStyle(color: isDarkMode(context) ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
//           ),
//         ),
//       ),
//     );
//   }
//
//   VendorModel? vendorModel;
//   var deliveryCharges = "0.0";
//   bool isLocationChange = false;
//
//   getDeliveyData() async {
//     print("delivery called");
//     if (!widget.takeAway!) {
//       print("caen id ${widget.products.first.vendorID} ");
//       await FireStoreUtils().getVendorByVendorID(widget.products.first.vendorID).then((value) {
//         vendorModel = value;
//       });
//       num km = num.parse(getKm(Position.fromMap({'latitude': lat, 'longitude': long}), Position.fromMap({'latitude': vendorModel!.latitude, 'longitude': vendorModel!.longitude})));
//       await FireStoreUtils().getDeliveryCharges().then((value) {
//         if (value != null) {
//           DeliveryChargeModel deliveryChargeModel = value;
//
//           if (!deliveryChargeModel.vendorCanModify) {
//             if (km > deliveryChargeModel.minimumDeliveryChargesWithinKm) {
//               deliveryCharges = (km * deliveryChargeModel.deliveryChargesPerKm).toDouble().toString();
//               if (widget.deliveryCharge != deliveryCharges) {
//                 isLocationChange = true;
//               }
//               setState(() {});
//             } else {
//               deliveryCharges = deliveryChargeModel.minimumDeliveryCharges.toDouble().toString();
//               if (widget.deliveryCharge != deliveryCharges) {
//                 isLocationChange = true;
//               }
//               setState(() {});
//             }
//           } else {
//             if (vendorModel != null && vendorModel!.deliveryCharge != null) {
//               if (km > vendorModel!.deliveryCharge!.minimumDeliveryChargesWithinKm) {
//                 deliveryCharges = (km * vendorModel!.deliveryCharge!.deliveryChargesPerKm).toDouble().toString();
//                 if (widget.deliveryCharge != deliveryCharges) {
//                   isLocationChange = true;
//                 }
//                 setState(() {});
//               } else {
//                 deliveryCharges = vendorModel!.deliveryCharge!.minimumDeliveryCharges.toDouble().toString();
//                 if (widget.deliveryCharge != deliveryCharges) {
//                   isLocationChange = true;
//                 }
//                 setState(() {});
//               }
//               print("delivery charges ${widget.deliveryCharge!}  dd $deliveryCharges");
//             } else {
//               if (km > deliveryChargeModel.minimumDeliveryChargesWithinKm) {
//                 deliveryCharges = (km * deliveryChargeModel.deliveryChargesPerKm).toDouble().toString();
//                 if (widget.deliveryCharge != deliveryCharges) {
//                   isLocationChange = true;
//                 }
//                 setState(() {});
//               } else {
//                 deliveryCharges = deliveryChargeModel.minimumDeliveryCharges.toDouble().toString();
//                 if (widget.deliveryCharge != deliveryCharges) {
//                   isLocationChange = true;
//                 }
//                 setState(() {});
//               }
//             }
//           }
//         }
//       });
//     }
//   }
//
//   validateForm() async {
//     // if (_formKey.currentState?.validate() ?? false) {
//     //   _formKey.currentState!.save();
//       // if (country == null) {
//       //   showDialog(
//       //     context: context,
//       //     builder: (BuildContext context) => ShowDialogToDismiss(
//       //       title: 'Error'.tr(),
//       //       content: 'Please Select Country'.tr(),
//       //       buttonText: 'CLOSE'.tr(),
//       //     ),
//       //   );
//       // } else
//       // {
//       //   showProgress(context, 'Saving Address...'.tr(), false);
//       //
//       //   MyAppState.currentUser!.location = UserLocation(
//       //     latitude: lat == null
//       //         ? MyAppState.currentUser!.shippingAddress.location!.latitude == 0.01
//       //             ? showDialog(
//       //                 barrierDismissible: false,
//       //                 context: context,
//       //                 builder: (_) {
//       //                   return AlertDialog(
//       //                     content: Text("Please select current address using GPS location. Move pin to exact location".tr()),
//       //                     actions: [
//       //                       // FlatButton(
//       //                       //   onPressed: () => Navigator.pop(
//       //                       //       context, false), // passing false
//       //                       //   child: Text('No'),
//       //                       // ),
//       //                       TextButton(
//       //                         onPressed: () {
//       //                           hideProgress();
//       //                           Navigator.pop(context, true);
//       //                         }, // passing true
//       //                         child: Text('OK'.tr()),
//       //                       ),
//       //                     ],
//       //                   );
//       //                 }).then((exit) {
//       //                 if (exit == null) return;
//       //
//       //                 if (exit) {
//       //                   // user pressed Yes button
//       //                 } else {
//       //                   // user pressed No button
//       //                 }
//       //               })
//       //             : MyAppState.currentUser!.shippingAddress.location!.latitude
//       //         : lat,
//       //     longitude: long == null
//       //         ? MyAppState.currentUser!.shippingAddress.location!.longitude == 0.01
//       //             ? showDialog(
//       //                 barrierDismissible: false,
//       //                 context: context,
//       //                 builder: (_) {
//       //                   return AlertDialog(
//       //                     content: Text("Please select current address using GPS location. Move pin to exact location".tr()),
//       //                     actions: [
//       //                       // FlatButton(
//       //                       //   onPressed: () => Navigator.pop(
//       //                       //       context, false), // passing false
//       //                       //   child: Text('No'),
//       //                       // ),
//       //                       TextButton(
//       //                         onPressed: () {
//       //                           hideProgress();
//       //                           Navigator.pop(context, true);
//       //                         }, // passing true
//       //                         child: Text('OK'.tr()),
//       //                       ),
//       //                     ],
//       //                   );
//       //                 }).then((exit) {
//       //                 if (exit == null) return;
//       //
//       //                 if (exit) {
//       //                   // user pressed Yes button
//       //                 } else {
//       //                   // user pressed No button
//       //                 }
//       //               })
//       //             : MyAppState.currentUser!.shippingAddress.location!.longitude
//       //         : long,
//       //     // locationData!.longitude,
//       //   );
//       //
//       //   AddressModel userAddress = AddressModel(
//       //       postalCode: zipcode.text.toString(),
//       //       address: street.text.toString(),
//       //       landmark: landmark.text.toString(),
//       //       country: cutries.text.toString(),
//       //       city: city.text.toString(),
//       //       location: MyAppState.currentUser!.location);
//       //   MyAppState.currentUser!.shippingAddress = userAddress;
//       //   await FireStoreUtils.updateCurrentUserAddress(userAddress);
//       //   hideProgress();
//       //   debugPrint('==>-  $isLocationChange');
//       //   debugPrint(widget.total.toString());
//       //   debugPrint(isLocationChange ? deliveryCharges.toString() : widget.deliveryCharge);
//       //   debugPrint(widget.couponCode!);
//       //   debugPrint(widget.couponId!);
//       //   push(
//       //     context,
//       //     PaymentScreen(
//       //       total: isLocationChange ? ((widget.total - num.parse(widget.deliveryCharge!)) + num.parse(deliveryCharges)) : widget.total,
//       //       discount: widget.discount!,
//       //       couponCode: widget.couponCode!,
//       //       couponId: widget.couponId!,
//       //       products: widget.products,
//       //       extraAddons: widget.extraAddons,
//       //       tipValue: widget.tipValue,
//       //       takeAway: widget.takeAway,
//       //       deliveryCharge: isLocationChange ? deliveryCharges.toString() : widget.deliveryCharge,
//       //       notes: widget.notes,
//       //       specialDiscountMap: widget.specialDiscountMap,
//       //       taxModel: widget.taxModel,
//       //       scheduleTime: widget.scheduleTime,
//       //     ),
//       //   );
//       // }
//     // } else {
//     //   setState(() {
//     //     _autoValidateMode = AutovalidateMode.onUserInteraction;
//     //   });
//     // }
//   }
// }

import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/AddressModel.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/ui/auth/AuthScreen.dart';
import 'package:emartconsumer/ui/deliveryAddressScreen/add_address_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  @override
  void initState() {
    getListAddress();
    // TODO: implement initState
    super.initState();
  }

  List<AddressModel> shippingAddress = [];

  getListAddress() {
    setState(() {
      if (MyAppState.currentUser != null) {
        if(MyAppState.currentUser!.shippingAddress!= null){
          shippingAddress = MyAppState.currentUser!.shippingAddress!;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Delivery Address'.tr(),
          style: TextStyle(fontFamily: "Poppinsm", color: isDarkMode(context) ? Colors.white : Colors.black),
        ).tr(),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: InkWell(
              onTap: () async {
                if(MyAppState.currentUser != null){
                  await Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddAddressScreen())).then((value) {
                    getListAddress();
                  });
                }else{
                  Navigator.pop(context);
                  push(context, AuthScreen());
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  color: Color(COLOR_PRIMARY),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Add",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.add,
                        size: 18,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: shippingAddress.isEmpty
            ? Center(
          child: Text("No address found "),
        )
            : ListView.builder(
          itemCount: shippingAddress.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            AddressModel addressModel = shippingAddress[index];
            return InkWell(
              onTap: () {
                Navigator.pop(context, addressModel);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode(context) ? Color(DarkContainerColor) : Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.location_on_outlined),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: Text(
                                      "${addressModel.getFullAddress()}",
                                      style: TextStyle(fontFamily: "Poppinsm", color: isDarkMode(context) ? Colors.white : Colors.black.withOpacity(0.80)),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 32,
                                    decoration: BoxDecoration(color: Color(COLOR_PRIMARY), borderRadius: const BorderRadius.all(Radius.circular(20))),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Center(
                                        child: Text(
                                          addressModel.addressAs.toString(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  addressModel.isDefault == true
                                      ? Container(
                                    height: 32,
                                    decoration: BoxDecoration(color: Colors.green, borderRadius: const BorderRadius.all(Radius.circular(20))),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 30),
                                      child: Center(
                                        child: Text(
                                          "Default",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                      : SizedBox(),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                            onTap: () {
                              _showActionSheet(context, index);
                            },
                            child: Icon(Icons.more_vert)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showActionSheet(BuildContext context1, int index) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () async {
              showProgress(context, "Please wait", false);
              List<AddressModel> tempShippingAddress = [];
              shippingAddress.forEach((element) {
                AddressModel addressModel = element;
                if (addressModel.id == shippingAddress[index].id) {
                  addressModel.isDefault = true;
                } else {
                  addressModel.isDefault = false;
                }
                tempShippingAddress.add(element);
              });
              MyAppState.currentUser!.shippingAddress = tempShippingAddress;
              await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
              getListAddress();
              hideProgress();
              Navigator.pop(context);
            },
            child: const Text('Default', style: TextStyle(color: Colors.blue)),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              await Navigator.of(context)
                  .push(MaterialPageRoute(
                  builder: (context) => AddAddressScreen(
                    index: index,
                  )))
                  .then((value) {
                getListAddress();
              });
            },
            child: const Text('Edit', style: TextStyle(color: Colors.blue)),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              shippingAddress.removeAt(index);
              MyAppState.currentUser!.shippingAddress = shippingAddress;
              FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
              getListAddress();
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context, 'Cancel');
          },
        ),
      ),
    );
  }
}
