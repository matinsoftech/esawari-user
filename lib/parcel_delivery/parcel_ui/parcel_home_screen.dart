import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/ParcelCategory.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/parcel_delivery/parcel_ui/book_parcel_screen.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/ui/auth/AuthScreen.dart';
import 'package:flutter/material.dart';

class ParcelHomeScreen extends StatefulWidget {
  final User? user;

  const ParcelHomeScreen({Key? key, this.user}) : super(key: key);

  @override
  State<ParcelHomeScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ParcelHomeScreen> {
  List<ParcelCategory> parcelCategory = [];
  bool isLoading = true;

  @override
  void initState() {
    getParcelCategory();
    // TODO: implement initState
    super.initState();
  }

  getParcelCategory() async {
    await FireStoreUtils().getParcelServiceCategory().then((value) {
      if (value != null) {
        setState(() {
          parcelCategory = value;
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome!!".tr(), style: TextStyle(color: Color(COLOR_PRIMARY), fontSize: 19)),
                  Text(MyAppState.currentUser != null ? "${MyAppState.currentUser!.firstName} ${MyAppState.currentUser!.lastName}" : "", style: const TextStyle(fontSize: 20)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(
                20.0,
              ),
              child: Center(
                  child: Image.asset(
                "assets/images/home_banner_image.png",
              )),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, bottom: 10),
              child: Text("What are you sending?".tr(), style: const TextStyle(fontSize: 18)),
            ),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, mainAxisExtent: 120),
                        itemCount: parcelCategory.length,
                        padding: const EdgeInsets.all(8),
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemBuilder: (context, index) {
                          return buildItems(item: parcelCategory[index]);
                        }),
                  )
          ],
        ),
      ),
    );
  }

  buildItems({required ParcelCategory item}) {
    return InkWell(
      splashColor: Color(COLOR_PRIMARY).withOpacity(0.5),
      onTap: () {
        if (MyAppState.currentUser != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BookParcelScreen(
                        parcelCategory: item,
                      )));
        } else {
          push(context, const AuthScreen());
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
          color: isDarkMode(context) ? const Color(DarkContainerColor) : Colors.white,
          boxShadow: [
            isDarkMode(context)
                ? const BoxShadow()
                : BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 5,
                  ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CachedNetworkImage(
              imageUrl: item.image.toString(),
              height: 60,
              width: 60,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => Center(
                  child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
              )),
              errorWidget: (context, url, error) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    height: 60,
                    width: 60,
                    placeholderImage,
                    fit: BoxFit.cover,
                  )),
              fit: BoxFit.cover,
            ),
            Text(item.title.toString()),
          ],
        ),
      ),
    );
  }
}
