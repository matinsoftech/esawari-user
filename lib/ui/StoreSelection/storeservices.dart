// // import 'package:easy_localization/easy_localization.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:emartconsumer/cab_service/cab_service_screen.dart';
// import 'package:emartconsumer/constants.dart';
// import 'package:emartconsumer/ecommarce_service/ecommarce_dashboard.dart';
// import 'package:emartconsumer/main.dart';
// import 'package:emartconsumer/model/SectionModel.dart';
// import 'package:emartconsumer/model/User.dart';
// import 'package:emartconsumer/onDemand_service/onDemand_ui/onDemand_dashboard.dart';
// import 'package:emartconsumer/parcel_delivery/parcel_dashboard.dart';
// import 'package:emartconsumer/rental_service/rental_service_dash_board.dart';
// import 'package:emartconsumer/services/FirebaseHelper.dart';
// import 'package:emartconsumer/services/helper.dart';
// import 'package:emartconsumer/services/localDatabase.dart';
// import 'package:emartconsumer/ui/auth/AuthScreen.dart';
// import 'package:emartconsumer/ui/container/ContainerScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart' as auth;
// import 'package:provider/provider.dart';

// class CuisineCell extends StatefulWidget {
//   final SectionModel sectionModel;
//   const CuisineCell({Key? key, required this.sectionModel}) : super(key: key);

//   @override
//   _CuisineCellState createState() => _CuisineCellState();
// }

// class _CuisineCellState extends State<CuisineCell> {
//   late CartDatabase cartDatabase;
//   late SectionModel sectionModel;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Using listen: false to prevent unnecessary rebuilds
//     cartDatabase = Provider.of<CartDatabase>(context, listen: false);
//   }

//   @override
//   void initState() {
//     super.initState();
//     sectionModel = widget.sectionModel;
//   }

//   Future<void> handleOnTap() async {
//     try {
//       // Set primary color if needed
//       if (sectionModel.color != null) {
//         COLOR_PRIMARY = int.parse(sectionModel.color!.replaceFirst("#", "0xff"));
//       }

//       // Validate RIDESORDER
//       assert(RIDESORDER.isNotEmpty, 'RIDESORDER must not be empty');
//       print('RIDESORDER: $RIDESORDER');
//       print("Section tapped: ${sectionModel.serviceTypeFlag}");

//       if (auth.FirebaseAuth.instance.currentUser != null && MyAppState.currentUser != null) {
//         if (MyAppState.currentUser?.userID == null || MyAppState.currentUser!.userID.isEmpty) {
//           throw Exception('User ID is null or empty');
//         }

//         User? user = await FireStoreUtils.getCurrentUser(MyAppState.currentUser!.userID);
//         print("User authenticated: ${user != null}");

//         if (user == null) {
//           throw Exception("User not found in Firestore");
//         }

//         if (user.role != USER_ROLE_CUSTOMER) {
//           throw Exception("User is not a customer");
//         }

//         // Update user properties
//         user.active = true;
//         user.role = USER_ROLE_CUSTOMER;
//         sectionConstantModel = sectionModel;
//         user.fcmToken = await FireStoreUtils.firebaseMessaging.getToken() ?? '';
//         await FireStoreUtils.updateCurrentUser(user);

//         if (sectionConstantModel?.serviceTypeFlag == null) {
//           throw Exception("serviceTypeFlag is null");
//         }

//         // Navigate based on service type
//         if (mounted) {
//           switch (sectionConstantModel!.serviceTypeFlag) {
//             case "cab-service":
//             case "Bike Service":
//               print("Navigating to CabServiceScreen");
            
            
//               push(context, CabServiceScreen());
//               break;
//             case "rental-service":
//               push(context, RentalServiceDashBoard(user: user));
//               break;
//             case "parcel_delivery":
//               push(context, ParcelDahBoard(user: user));
//               break;
//             case "ondemand-service":
//               push(context, OnDemandDahBoard(user: user));
//               break;
//             default:
//               print("Default case - container screen");
//               var cartProducts = await cartDatabase.allCartProducts;
//               if (cartProducts.isNotEmpty) {
//                 showAlertDialog(context, user, sectionModel);
//               } else {
//                 push(context, ContainerScreen(user: user));
//               }
//           }
//         }
//       } else {
//         handleSkipLogin(context, sectionModel);
//       }
//     } catch (e, stackTrace) {
//       print("Error in handleOnTap: $e");
//       print("Stack trace: $stackTrace");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("An error occurred: $e"))
//         );
//       }
//     }
//   }

//   void handleSkipLogin(BuildContext context, SectionModel sectionModel) {
//     print("isSkipLogin: $isSkipLogin");
//     if (isSkipLogin) {
//       sectionConstantModel = sectionModel;
//       if (sectionConstantModel?.serviceTypeFlag == null) {
//         print("Error: serviceTypeFlag is null in skip login flow");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("An error occurred. Please try again."))
//         );
//         return;
//       }
      
//       if (mounted) {
//         switch (sectionConstantModel!.serviceTypeFlag) {
//           case "Bike Service":
//           case "cab-service":
//             print("Skipping login, navigating to CabServiceScreen");
//             push(context, CabServiceScreen());
//             break;
//           case "rental-service":
//             push(context, RentalServiceDashBoard(user: null));
//             break;
//           case "parcel_delivery":
//             push(context, ParcelDahBoard(user: null));
//             break;
//           case "ondemand-service":
//             push(context, OnDemandDahBoard(user: null));
//             break;
//           default:
//             push(context, ContainerScreen(user: null));
//         }
//       }
//     } else {
//       pushReplacement(context, const AuthScreen());
//     }
//   }

//   void showAlertDialog(BuildContext context, User? user, SectionModel sectionModel) {
//     Widget okButton = TextButton(
//       child: const Text("OK"),
//       onPressed: () async {
//         if (mounted) {
//           if (sectionModel.serviceTypeFlag == "ecommerce-service") {
//             await cartDatabase.deleteAllProducts();
//             push(context, EcommeceDashBoardScreen(user: user));
//           } else {
//             await cartDatabase.deleteAllProducts();
//             push(context, ContainerScreen(user: user));
//           }
//         }
//       },
//     );

//     Widget cancelButton = TextButton(
//       child: const Text("Cancel"),
//       onPressed: () {
//         if (mounted) Navigator.pop(context);
//       },
//     );

//     AlertDialog alert = AlertDialog(
//       title: const Text("Alert!"),
//       content: const Text("If you select this Section/Service, your previously added items will be removed from the cart."),
//       actions: [
//         cancelButton,
//         okButton,
//       ],
//     );

//     if (mounted) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) => alert,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return RepaintBoundary(
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 12),
//         child: GestureDetector(
//           onTap: handleOnTap,
//           child: Container(
//             margin: const EdgeInsets.all(5),
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Image.network(
//                     (sectionModel.sectionImage == null || sectionModel.sectionImage!.isEmpty) 
//                         ? placeholderImage 
//                         : sectionModel.sectionImage.toString(),
//                     height: 75,
//                     width: 75,
//                     fit: BoxFit.contain,
//                   ),
//                   const SizedBox(height: 15),
//                   Text(
//                     sectionModel.name.toString(),
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(fontSize: 18),
//                   ).tr(),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }