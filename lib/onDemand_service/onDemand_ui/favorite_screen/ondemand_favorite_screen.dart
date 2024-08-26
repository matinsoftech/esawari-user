import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/favorite_ondemand_service_model.dart';
import 'package:emartconsumer/onDemand_service/onDemand_model/provider_serivce_model.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/home_screen/ondemand_home_screen.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:flutter/material.dart';

class OndemandFavouriteServiceScreen extends StatefulWidget {
  const OndemandFavouriteServiceScreen({Key? key}) : super(key: key);

  @override
  _OndemandFavouriteServiceScreenState createState() => _OndemandFavouriteServiceScreenState();
}

class _OndemandFavouriteServiceScreenState extends State<OndemandFavouriteServiceScreen> {
  final fireStoreUtils = FireStoreUtils();
  List<FavouriteOndemandServiceModel> lstFavourite = [];
  bool showLoader = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: showLoader
            ? Center(
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                ),
              )
            : lstFavourite.isEmpty
                ? showEmptyState('No Favourite Service'.tr(), context)
                : ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(15),
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    itemCount: lstFavourite.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<List<ProviderServiceModel>>(
                          future: fireStoreUtils.getCurrentProviderService(lstFavourite[index]),
                          builder: (context, snapshot) {
                            return snapshot.data != null
                                ? ServiceWidget(
                                    providerList: snapshot.data![0],
                                    lstFav: lstFavourite,
                                    fromListing: true,
                                  )
                                : Container();
                          });
                    }));
  }

  Future<void> getData() async {
    await fireStoreUtils.getFavouritesServiceList(MyAppState.currentUser!.userID).then((value) {
      setState(() {
        lstFavourite.clear();
        lstFavourite.addAll(value);
        Future.delayed(Duration(seconds: 2), () {
          getData();
        });
      });
    });
    showLoader = false;
  }
}
