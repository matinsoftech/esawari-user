// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/onDemand_service/onDemand_model/provider_serivce_model.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/home_screen/ondemand_home_screen.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProviderScreen extends StatefulWidget {
  final String providerId;

  const ProviderScreen({super.key, required this.providerId});

  @override
  State<ProviderScreen> createState() => _ProviderScreenState();
}

class _ProviderScreenState extends State<ProviderScreen> {
  User? userModel = User();
  Stream<List<ProviderServiceModel>>? providerStram;
  final fireStoreUtils = FireStoreUtils();
  bool isLoading = true;

  @override
  void initState() {
    getProvider();
    super.initState();
  }

  List<ProviderServiceModel> providerList = [];

  getProvider() async {
    await FireStoreUtils.getCurrentUser(widget.providerId.toString()).then((value) {
      setState(() {
        userModel = value;
      });
    });

    providerStram = fireStoreUtils.getProviderServiceByProvideId(widget.providerId.toString()).asBroadcastStream();

    providerStram!.listen((event) {
      setState(() {
        providerList = event;
      });
    });

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Colors.black : const Color(0xffFBFBFB),
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: isLoading == true
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: userModel!.profilePictureURL != ""
                        ? CircleAvatar(backgroundImage: NetworkImage(userModel!.profilePictureURL.toString()), radius: 50.0)
                        : CircleAvatar(backgroundImage: NetworkImage(placeholderImage), radius: 50.0),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    userModel!.fullName().toString(),
                    style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontFamily: "Poppinsm", fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/icons/ic_mail.svg", color: isDarkMode(context) ? Colors.white : Colors.black),
                      SizedBox(
                        width: 6,
                      ),
                      Text(
                        userModel!.email.toString(),
                        style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontFamily: "Poppinsm", fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/icons/ic_mobile.svg", color: isDarkMode(context) ? Colors.white : Colors.black),
                      SizedBox(
                        width: 6,
                      ),
                      Text(
                        userModel!.phoneNumber.toString(),
                        style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontFamily: "Poppinsm", fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(color: Color(SemanticColorWarning06), borderRadius: BorderRadius.all(Radius.circular(16))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            userModel!.reviewsCount != 0 ? ((userModel!.reviewsSum) / (userModel!.reviewsCount ?? 0.0)).toStringAsFixed(1) : 0.toString(),
                            style: const TextStyle(
                              letterSpacing: 0.5,
                              fontSize: 12,
                              fontFamily: "Poppinsm",
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(),
                  SizedBox(
                    height: 10,
                  ),
                  providerList.isEmpty
                      ? showEmptyState('No service Found'.tr(), context)
                      : Expanded(
                          child: ListView.builder(
                            itemCount: providerList.length,
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            // physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              ProviderServiceModel data = providerList[index];
                              return ServiceWidget(
                                providerList: data,
                                lstFav: [],
                              );
                            },
                          ),
                        )
                ],
              ),
            ),
    );
  }
}
