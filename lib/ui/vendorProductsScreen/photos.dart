import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/model/VendorModel.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/ui/fullScreenImageViewer/FullScreenImageViewer.dart';
import 'package:flutter/material.dart';

import '../../AppGlobal.dart';
import '../../constants.dart';

class StorePhotos extends StatefulWidget {
  final VendorModel vendorModel;

  const StorePhotos({Key? key, required this.vendorModel}) : super(key: key);

  @override
  _StorePhotosState createState() => _StorePhotosState();
}

class _StorePhotosState extends State<StorePhotos> {
  late Future<VendorModel> photofuture;
  final FireStoreUtils fireStoreUtils = FireStoreUtils();

  @override
  void initState() {
    super.initState();
    photofuture = fireStoreUtils.getVendorByVendorID(widget.vendorModel.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppGlobal.buildSimpleAppBar(context, "Photos".tr()),
        body: SingleChildScrollView(
          child: Container(
              // first tab bar view widget
              padding: const EdgeInsets.only(top: 0),
              child: FutureBuilder<VendorModel>(
                future: photofuture,
                // initialData: [],
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.waiting && snapshot.data!.photos.isEmpty) {
                    if (snapshot.data!.photo.isNotEmpty) {
                      snapshot.data!.photos.add(snapshot.data!.photo);
                    }
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                      ),
                    );
                  } else if (snapshot.data!.photos.isEmpty) {
                    return Center(child: showEmptyState("No images are available.".tr(), context));
                  }
                  return GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 5 / 4,
                      padding: const EdgeInsets.all(10.0),
                      children: List.generate(snapshot.data!.photos.length, (index) {
                        if (snapshot.data!.hidephotos == false) {
                          return InkWell(
                            onTap: () {
                              push(context, FullScreenImageViewer(imageUrl: snapshot.data!.photos[index]));
                            },
                            child: Card(
                                color: const Color(0xffE7EAED),
                                elevation: 0.5,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0), side: const BorderSide(color: Color(0xffDEE3ED))),
                                child: CachedNetworkImage(
                                    height: 70,
                                    width: 100,
                                    imageUrl: snapshot.data!.photos[index],
                                    imageBuilder: (context, imageProvider) => Container(
                                          width: 70,
                                          height: 100,
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),
                                        ),
                                    errorWidget: (context, url, error) => ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.network(
                                          placeholderImage,
                                          fit: BoxFit.cover,
                                          width: MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context).size.height,
                                        )))),
                          );
                        } else {
                          return Container();
                        }
                      }));
                },
              )),
        ));
  }
}

class StoreMenuPhoto extends StatefulWidget {
  final List<dynamic> vendorMenuPhotos;

  const StoreMenuPhoto({Key? key, required this.vendorMenuPhotos}) : super(key: key);

  @override
  State<StoreMenuPhoto> createState() => _StoreMenuPhotoState();
}

class _StoreMenuPhotoState extends State<StoreMenuPhoto> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppGlobal.buildSimpleAppBar(context, "Menus".tr()),
        body: SingleChildScrollView(
            child: Container(
                // first tab bar view widget
                padding: const EdgeInsets.only(top: 0),
                child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 5 / 4,
                    padding: const EdgeInsets.all(10.0),
                    children: List.generate(widget.vendorMenuPhotos.length, (index) {
                      return InkWell(
                        onTap: () {
                          push(context, FullScreenImageViewer(imageUrl: widget.vendorMenuPhotos[index]));
                        },
                        child: Card(
                            color: const Color(0xffE7EAED),
                            elevation: 0.5,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0), side: const BorderSide(color: const Color(0xffDEE3ED))),
                            child: CachedNetworkImage(
                                height: 70,
                                width: 100,
                                imageUrl: getImageVAlidUrl(widget.vendorMenuPhotos[index]),
                                imageBuilder: (context, imageProvider) => Container(
                                      width: 70,
                                      height: 100,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),
                                    ),
                                errorWidget: (context, url, error) => ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      placeholderImage,
                                      fit: BoxFit.cover,
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.height,
                                    )))),
                      );
                    })))));
  }
}
