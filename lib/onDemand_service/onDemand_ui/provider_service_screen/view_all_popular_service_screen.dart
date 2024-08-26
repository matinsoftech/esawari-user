import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/favorite_ondemand_service_model.dart';
import 'package:emartconsumer/onDemand_service/onDemand_model/provider_serivce_model.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/home_screen/ondemand_home_screen.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:flutter/material.dart';

class ViewAllPopularServiceScreen extends StatefulWidget {
  const ViewAllPopularServiceScreen({
    Key? key,
  }) : super(key: key);

  @override
  _ViewAllPopularServiceScreenState createState() => _ViewAllPopularServiceScreenState();
}

class _ViewAllPopularServiceScreenState extends State<ViewAllPopularServiceScreen> {
  List<ProviderServiceModel> providerList = [];
  List<ProviderServiceModel> allProviderList = [];
  TextEditingController searchTextFiledController = TextEditingController();
  List<FavouriteOndemandServiceModel> lstFav = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Stream<List<ProviderServiceModel>>? providerStram;

  Future<void> getData() async {
    providerStram = FireStoreUtils().getProvider().asBroadcastStream();

    providerStram!.listen((event) {
      setState(() {
        providerList = event;
        allProviderList = event;
      });
    });
    if (MyAppState.currentUser != null) {
      await FireStoreUtils()
          .getFavouritesServiceList(
        MyAppState.currentUser!.userID,
      )
          .then((value) {
        setState(() {
          lstFav = value;
        });
      });
    }
  }

  getFilterData(String value) async {
    if (value.toString().isNotEmpty) {
      providerList = allProviderList.where((e) => e.title!.toLowerCase().contains(value.toLowerCase().toString()) || e.title!.startsWith(value.toString())).toList();
    } else {
      providerList = allProviderList;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? const Color(DARK_BG_COLOR) : const Color(0xffF9F9F9),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: isDarkMode(context) ? const Color(DARK_BG_COLOR) : const Color(0xffFFFFFF),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0.0,
        title: Text('All Services',
            style: TextStyle(
              fontFamily: "Poppinsm",
              color: isDarkMode(context) ? Colors.white : Colors.black,
              fontSize: 18,
            )),
      ),
      body: Column(
        children: [
          Center(
            child: Divider(
              color: Colors.grey.shade300,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  TextFormField(
                    controller: searchTextFiledController,
                    onChanged: (value) {
                      getFilterData(searchTextFiledController.text.toString());

                      return null;
                    },
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        counterText: "",
                        contentPadding: const EdgeInsets.all(8),
                        fillColor: Colors.white,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 0.7),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 0.7),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 0.7),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 0.7),
                        ),
                        hintText: "Search Service".tr(),
                        hintStyle: TextStyle(color: Colors.black.withOpacity(0.60))),
                  ),
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
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              ProviderServiceModel data = providerList[index];
                              return ServiceWidget(
                                providerList: data,
                                lstFav: lstFav,
                                fromListing: true,
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
