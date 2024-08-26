import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/onDemand_service/onDemand_model/category_model.dart';
import 'package:emartconsumer/onDemand_service/onDemand_ui/provider_service_screen/view_category_service_list_screen.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final fireStoreUtils = FireStoreUtils();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: isDarkMode(context) ? Colors.black : const Color(0xffFBFBFB),
        appBar: AppBar(
          automaticallyImplyLeading: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Explore services".tr(),
                      style: TextStyle(
                        color: isDarkMode(context) ? Colors.white : Colors.black,
                        fontSize: 18,
                        fontFamily: "Poppinsm",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Explore services tailored for you—quick, easy, and personalized.".tr(),
                        style: TextStyle(
                          color: isDarkMode(context) ? Colors.white : Colors.black,
                          fontSize: 12,
                          fontFamily: "Poppinsm",
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 12,
              ),
              FutureBuilder<List<CategoryModel>>(
                  future: FireStoreUtils().getProviderCategory(),
                  initialData: const [],
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasData || (snapshot.data?.isNotEmpty ?? false)) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(5),
                        itemCount: snapshot.data!.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return snapshot.data != null ? categoriesCell(snapshot.data![index], index) : showEmptyState('No Categories'.tr(), context);
                        },
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                      );
                    }
                    return const CircularProgressIndicator();
                  }),
            ],
          ),
        ));
  }

  Widget categoriesCell(CategoryModel categoryModel, int index) {
    return GestureDetector(
      onTap: () {
        push(
            context,
            ViewCategoryServiceListScreen(
              categoryId: categoryModel.id,
              categoryTitle: categoryModel.title,
            ));
      },
      child: Center(
        child: Column(
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: colorList[index % colorList.length],
                borderRadius: BorderRadius.circular(50),
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CachedNetworkImage(
                    width: 5,
                    height: 5,
                    imageUrl: categoryModel.image.toString(),
                    // color: Colors.black,
                    errorWidget: (context, url, error) => ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        placeholderImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: 70,
              child: Center(
                child: Text(
                  categoryModel.title.toString(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    color: isDarkMode(context) ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontFamily: "Poppinsm",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
