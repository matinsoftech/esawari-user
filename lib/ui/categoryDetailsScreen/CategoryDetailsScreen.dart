import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/AppGlobal.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/model/VendorCategoryModel.dart';
import 'package:emartconsumer/model/VendorModel.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/ui/dineInScreen/dine_in_restaurant_details_screen.dart';
import 'package:emartconsumer/ui/vendorProductsScreen/NewVendorProductsScreen.dart';
import 'package:flutter/material.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final VendorCategoryModel category;
  final bool isDineIn;

  const CategoryDetailsScreen(
      {Key? key, required this.category, required this.isDineIn})
      : super(key: key);

  @override
  _CategoryDetailsScreenState createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  Stream<List<VendorModel>>? categoriesFuture;
  final FireStoreUtils fireStoreUtils = FireStoreUtils();

  @override
  void initState() {
    super.initState();
    print(widget.category.id);
    categoriesFuture = fireStoreUtils.getVendorsByCuisineID(
        widget.category.id.toString(),
        isDinein: widget.isDineIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppGlobal.buildSimpleAppBar(
          context, widget.category.title.toString()),
      body: StreamBuilder<List<VendorModel>>(
        stream: categoriesFuture,
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
              ),
            );
          }
          if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
            return Center(
              child: showEmptyState('No Vendors'.tr(), context),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) =>
                  buildVendorItem(snapshot.data![index]),
            );
          }
        },
      ),
    );
  }

  buildVendorItem(VendorModel vendorModel) {
    return GestureDetector(
      onTap: () {
        if (widget.isDineIn) {
          push(
            context,
            DineInRestaurantDetailsScreen(vendorModel: vendorModel),
          );
        } else {
          push(
            context,
            NewVendorProductsScreen(vendorModel: vendorModel),
          );
        }
      },
      child: Card(
        elevation: 0.5,
        color: isDarkMode(context) ? Colors.grey.shade900 : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          height: 200,

          // padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          // margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            // mainAxisSize: MainAxisSize.max,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: getImageVAlidUrl(vendorModel.photo),
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover)),
                  ),
                  placeholder: (context, url) => Center(
                      child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                  )),
                  errorWidget: (context, url, error) => ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        placeholderImage,
                        fit: BoxFit.fitWidth,
                        width: MediaQuery.of(context).size.width,
                      )),
                  fit: BoxFit.cover,
                ),
              ),
              // SizedBox(height: 8),
              ListTile(
                title: Text(vendorModel.title,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 16,
                    )),
                subtitle: Text(vendorModel.location,
                    maxLines: 1,

                    // filters.keys
                    //     .where(
                    //         (element) => vendorModel.filters[element] == 'Yes')
                    //     .take(2)
                    //     .join(', '),

                    style: const TextStyle()),
                trailing: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.star,
                              size: 20,
                              color: Color(COLOR_PRIMARY),
                            ),
                            Text(
                              (vendorModel.reviewsCount != 0)
                                  ? (vendorModel.reviewsSum /
                                          vendorModel.reviewsCount)
                                      .toStringAsFixed(1)
                                  : "0",
                              style: const TextStyle(),
                            ),
                            Visibility(
                                visible: vendorModel.reviewsCount != 0,
                                child: Text(
                                    "(${vendorModel.reviewsCount.toStringAsFixed(1)})")),
                          ]),
                    ],
                  ),
                ),
              ),
              // SizedBox(height: 4),

              // SizedBox(height: 4),
              // Visibility(
              //   visible: vendorModel.reviewsCount != 0,
              //   child: RichText(
              //     text: TextSpan(
              //       style: TextStyle(
              //           color: isDarkMode(context)
              //               ? Colors.grey.shade200
              //               : Colors.black),
              //       children: [
              //         TextSpan(
              //             text:
              //                 '${double.parse((vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(decimal))} '),
              //         WidgetSpan(
              //           child: Icon(
              //             Icons.star,
              //             size: 20,
              //             color: Color(COLOR_PRIMARY),
              //           ),
              //         ),
              //         TextSpan(text: ' (${vendorModel.reviewsCount})'),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
