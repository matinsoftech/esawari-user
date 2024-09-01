import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/model/SectionModel.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/model/VendorModel.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/ui/auth/AuthScreen.dart';
import 'package:emartconsumer/ui/container/ContainerScreen.dart';
import 'package:emartconsumer/ui/vendorProductsScreen/NewVendorProductsScreen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';

class QrCodeScanner extends StatefulWidget {
  const QrCodeScanner({Key? key, required this.presectionList}) : super(key: key);
  final List<SectionModel> presectionList;

  @override
  State<QrCodeScanner> createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner> {
  String? _qrInfo = 'Scan a QR/Bar code'.tr();
  bool _camState = false, isMainCall = false;

  _scanCode() {
    setState(() {
      _camState = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _scanCode();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            "QR Code Scanner".tr(),
            style: TextStyle(letterSpacing: 0.5, fontWeight: FontWeight.normal, color: isDarkMode(context) ? Colors.white : Colors.black),
          ),
          centerTitle: false,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: isDarkMode(context) ? Colors.white : Colors.black,
              size: 40,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ), //isDarkMode(context) ? Color(COLOR_DARK) : null,
        body: Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: _camState
                ? Center(
                    child: SizedBox(
                      height: 1000,
                      width: 500,
                      child: QRBarScannerCamera(
                        onError: (context, error) => Text(
                          error.toString(),
                          style: const TextStyle(color: Colors.red),
                        ),
                        qrCodeCallback: (code) {
                          // _qrCallback(code);
                          if (code != null && code.isNotEmpty) {
                            Map codeVal = jsonDecode(code);

                            if (codeVal.containsKey("sectionid")) {
                              String sectionId = codeVal["sectionid"];

                              if (widget.presectionList.isNotEmpty) {
                                for (SectionModel sectionModel in widget.presectionList) {
                                  if (sectionModel.id == sectionId && !isMainCall) {
                                    isMainCall = true;
                                    _camState = false;
                                    setState(() {});
                                    callMainScreen(sectionModel, codeVal["vendorid"]);
                                  }
                                }
                              } else {
                                if (sectionConstantModel!.id != null && sectionConstantModel!.id == sectionId) {
                                  if (allstoreList.isNotEmpty) {
                                    for (VendorModel storeModel in allstoreList) {
                                      if (storeModel.id == codeVal["vendorid"]) {
                                        isMainCall = true;
                                        _camState = false;
                                        setState(() {
                                          Navigator.of(context).pop();
                                          push(context, NewVendorProductsScreen(vendorModel: storeModel));
                                        });
                                      }
                                    }
                                  } else {
                                    isMainCall = true;
                                    _camState = false;
                                    setState(() {});
                                    showAlertDialog(context, "Error".tr(), "You search on wrong section".tr(), true);
                                  }
                                } else {
                                  isMainCall = true;
                                  _camState = false;
                                  setState(() {});
                                  showAlertDialog(context, "Error".tr(), "You search on wrong section".tr(), true);
                                }
                              }
                            }
                          }
                        },
                      ),
                    ),
                  )
                : Center(
                    child: Text(_qrInfo!),
                  )));
  }

  Future<void> callMainScreen(SectionModel sectionModel, String codeVal) async {
    auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      User? user = await FireStoreUtils.getCurrentUser(firebaseUser.uid);

      if (user != null && user.role == USER_ROLE_CUSTOMER) {
        user.active = true;
        user.role = USER_ROLE_CUSTOMER;
        sectionConstantModel = sectionModel;
        //SELECTED_CATEGORY = sectionModel.id.toString();
       // SELECTED_SECTION_NAME = sectionModel.name.toString();
       // isDineEnable = sectionModel.dineInActive!;
        COLOR_PRIMARY = int.parse(sectionModel.color!.replaceFirst("#", "0xff"));
        user.fcmToken = await FireStoreUtils.firebaseMessaging.getToken() ?? '';
        await FireStoreUtils.updateCurrentUser(user);
        Navigator.of(context).pop();
        pushReplacement(
            context,
            ContainerScreen(
              user: user,
              vendorId: codeVal,
            ));
      } else {
        pushReplacement(context, const AuthScreen());
      }
    } else {
      if (isSkipLogin) {
        sectionConstantModel = sectionModel;
        //SELECTED_CATEGORY = sectionModel.id.toString();
       // SELECTED_SECTION_NAME = sectionModel.name.toString();
       // isDineEnable = sectionModel.dineInActive!;
        COLOR_PRIMARY = int.parse(sectionModel.color!.replaceFirst("#", "0xff"));
        push(context, ContainerScreen(user: null));
      } else {
        pushReplacement(context, const AuthScreen());
      }
    }
  }
}
