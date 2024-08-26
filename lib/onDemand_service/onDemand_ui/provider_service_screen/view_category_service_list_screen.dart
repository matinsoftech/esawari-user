import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/onDemand_service/onDemand_model/provider_serivce_model.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/home_screen/ondemand_home_screen.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:flutter/material.dart';

class ViewCategoryServiceListScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryTitle;

  const ViewCategoryServiceListScreen({Key? key, this.categoryId, this.categoryTitle}) : super(key: key);

  @override
  _ViewCategoryServiceListScreenState createState() => _ViewCategoryServiceListScreenState();
}

class _ViewCategoryServiceListScreenState extends State<ViewCategoryServiceListScreen> {
  List<ProviderServiceModel> providerList = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Stream<List<ProviderServiceModel>>? providerStram;

  Future<void> getData() async {
    providerStram = FireStoreUtils().getProvider(categoryId: widget.categoryId.toString()).asBroadcastStream();

    providerStram!.listen((event) {
      setState(() {
        providerList = event;
      });
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? const Color(DARK_BG_COLOR) : const Color(0xffF9F9F9),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: isDarkMode(context) ? const Color(DARK_BG_COLOR) : Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0.0,
        title: Text(
          widget.categoryTitle.toString(),
          style: TextStyle(
            fontFamily: "Poppinsm",
            color: isDarkMode(context) ? Colors.white : Colors.black,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Center(
            child: Divider(
              color: Colors.grey.shade300,
            ),
          ),
          providerList.isEmpty
              ? showEmptyState('No service Found'.tr(), context)
              : SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ListView.builder(
                      itemCount: providerList.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.vertical,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        ProviderServiceModel providerModel = providerList[index];
                        return ServiceWidget(
                          providerList: providerModel,
                          lstFav: [],
                        );
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
