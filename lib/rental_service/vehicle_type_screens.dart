import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/model/RentalVehicleType.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/rental_service/model/rental_order_model.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:flutter/material.dart';

import 'vehicle_details_screen.dart';

class VehicleTypeScreen extends StatefulWidget {
  RentalOrderModel? rentalOrderModel;

  VehicleTypeScreen({Key? key, this.rentalOrderModel}) : super(key: key);

  @override
  State<VehicleTypeScreen> createState() => _VehicleTypeScreenState();
}

class _VehicleTypeScreenState extends State<VehicleTypeScreen> {
  RentalOrderModel? rentalOrderModel;

  @override
  void initState() {
    getVehicleType();
    setState(() {
      rentalOrderModel = widget.rentalOrderModel;
    });
    print(rentalOrderModel!.toJson().toString());
    super.initState();
  }

  List<RentalVehicleType> vehicleType = [];

  getVehicleType() async {
    await FireStoreUtils.getRentalVehicleType().then((value) {
      setState(() {
        vehicleType = value;
      });
    });
    selectedVehicleType = vehicleType.first;
    getCompanyDriver(vehicleType.first.name.toString());
  }

  List<User> driverList = [];
  Stream<List<User>>? driverListStrem;

  getCompanyDriver(String vehicleType) async {
    driverListStrem =
        FireStoreUtils().getRentalCompanyDriver(widget.rentalOrderModel, vehicleType, rentalOrderModel!.pickupDateTime!, rentalOrderModel!.dropDateTime!).asBroadcastStream();
  }

  List<dynamic> calculateDaysInterval(DateTime startDate, DateTime endDate) {
    startDate = DateTime(startDate.year, startDate.month, startDate.day);
    endDate = DateTime(endDate.year, endDate.month, endDate.day);
    int noOFDay = (endDate.difference(startDate).inHours / 24).round();
    List<dynamic> days = [];
    for (int i = 0; i <= noOFDay; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  RentalVehicleType? selectedVehicleType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_rounded,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.18,
              child: ListView.builder(
                itemCount: vehicleType.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedVehicleType = vehicleType[index];
                        getCompanyDriver(vehicleType[index].name.toString());
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                  color: isDarkMode(context)
                                      ? Colors.grey.shade700
                                      : selectedVehicleType == vehicleType[index]
                                          ? Color(COLOR_PRIMARY)
                                          : Colors.black.withOpacity(0.10),
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20, top: 20),
                                child: CachedNetworkImage(
                                  height: 60,
                                  width: 100,
                                  imageUrl: getImageVAlidUrl(vehicleType[index].rentalVehicleIcon.toString()),
                                  imageBuilder: (context, imageProvider) => Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                    ),
                                  ),
                                  placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator.adaptive(
                                    valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                                  )),
                                  errorWidget: (context, url, error) => ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        placeholderImage,
                                        fit: BoxFit.cover,
                                      )),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 25),
                            child: Text(
                              vehicleType[index].name.toString(),
                              style: TextStyle(
                                color: isDarkMode(context) ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<List<User>>(
                  stream: driverListStrem,
                  initialData: const [],
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                        ),
                      );
                    }

                    print(snapshot.connectionState);
                    if (snapshot.data?.isNotEmpty ?? false) {
                      driverList.clear();
                      snapshot.data!.forEach((element) {
                        if (element.rentalBookingDate!.isNotEmpty) {
                          if (!(widget.rentalOrderModel!.pickupDateTime!.toDate().isAfter(element.rentalBookingDate!.first.toDate()) &&
                              widget.rentalOrderModel!.pickupDateTime!.toDate().isBefore(element.rentalBookingDate!.last.toDate()))) {
                            if (!(widget.rentalOrderModel!.dropDateTime!.toDate().isAfter(element.rentalBookingDate!.first.toDate()) &&
                                widget.rentalOrderModel!.dropDateTime!.toDate().isBefore(element.rentalBookingDate!.last.toDate()))) {
                              driverList.add(element);
                            }
                          }
                        } else {
                          driverList.add(element);
                        }

                        print(driverList.length);
                      });

                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          itemCount: driverList.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                print(widget.rentalOrderModel!.pickupLatLong!.toJson());
                                push(
                                    context,
                                    VehicleDetailsScreen(
                                      driverDetails: driverList[index],
                                      rentalOrderModel: widget.rentalOrderModel,
                                    ));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          child: CachedNetworkImage(
                                            height: MediaQuery.of(context).size.height * 0.14,
                                            imageUrl: driverList[index].carInfo!.carImage!.isEmpty ? "" : driverList[index].carInfo!.carImage!.first,
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
                                            errorWidget: (context, url, error) => Container(
                                              width: MediaQuery.of(context).size.width,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(20), image: DecorationImage(image: NetworkImage(placeholderImage), fit: BoxFit.cover)),
                                            ),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "${driverList[index].carName.toString()} ${driverList[index].carMakes.toString()}",
                                          style: const TextStyle(fontSize: 16, letterSpacing: 2, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.people, size: 16),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    "${driverList[index].carInfo!.passenger.toString()}" + "seater".tr(),
                                                    style: const TextStyle(letterSpacing: 2, fontWeight: FontWeight.w600),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Icon(Icons.star, color: Colors.orange.withOpacity(0.80), size: 16),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                      driverList[index].reviewsCount != 0
                                                          ? (driverList[index].reviewsSum / driverList[index].reviewsCount).toStringAsFixed(1)
                                                          : 0.toString(),
                                                      style: const TextStyle(
                                                        letterSpacing: 0.5,
                                                      )),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              amountShow(amount: driverList[index].carRate.toString()),
                                              style: TextStyle(color: Color(COLOR_PRIMARY), letterSpacing: 0.5, fontWeight: FontWeight.w900),
                                            ),
                                            Text(
                                              "/" + "day".tr(),
                                              style: const TextStyle(letterSpacing: 0.5, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return showEmptyState('No Driver Found'.tr(), context);
                    }
                  }),
            )

            // Expanded(
            //   child: driverList.isEmpty
            //       ? const Center(child: Text("Rental Car Not Found"))
            //       : ListView.builder(
            //           itemCount: driverList.length,
            //           shrinkWrap: true,
            //           itemBuilder: (context, index) {
            //             return InkWell(
            //               onTap: () {
            //                 print(widget.rentalOrderModel!.pickupLatLong!.toJson());
            //                 push(
            //                     context,
            //                     VehicleDetailsScreen(
            //                       driverDetails: driverList[index],
            //                       rentalOrderModel: widget.rentalOrderModel,
            //                     ));
            //               },
            //               child: Padding(
            //                 padding: const EdgeInsets.all(8.0),
            //                 child: Container(
            //                   decoration: BoxDecoration(
            //                     color: isDarkMode(context) ? Colors.grey.shade700 : Colors.white,
            //                     borderRadius: const BorderRadius.only(
            //                         topLeft: Radius.circular(10),
            //                         topRight: Radius.circular(10),
            //                         bottomLeft: Radius.circular(10),
            //                         bottomRight: Radius.circular(10)),
            //                     boxShadow: [
            //                       BoxShadow(
            //                         color: Colors.grey.withOpacity(0.5),
            //                         spreadRadius: 2,
            //                         blurRadius: 2,
            //                         offset: const Offset(0, 2), // changes position of shadow
            //                       ),
            //                     ],
            //                   ),
            //                   child: Padding(
            //                     padding: const EdgeInsets.all(8.0),
            //                     child: Column(
            //                       crossAxisAlignment: CrossAxisAlignment.start,
            //                       children: [
            //                         Padding(
            //                           padding: const EdgeInsets.symmetric(vertical: 10),
            //                           child: CachedNetworkImage(
            //                             height: MediaQuery.of(context).size.height * 0.14,
            //                             imageUrl: driverList[index].carInfo!.carImage!.isEmpty ? "" : driverList[index].carInfo!.carImage!.first,
            //                             imageBuilder: (context, imageProvider) => Container(
            //                               decoration: BoxDecoration(
            //                                 borderRadius: BorderRadius.circular(10),
            //                                 image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            //                               ),
            //                             ),
            //                             placeholder: (context, url) => Center(
            //                                 child: CircularProgressIndicator.adaptive(
            //                               valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
            //                             )),
            //                             errorWidget: (context, url, error) => Container(
            //                               width: MediaQuery.of(context).size.width,
            //                               decoration: BoxDecoration(
            //                                   borderRadius: BorderRadius.circular(20),
            //                                   image: DecorationImage(image: NetworkImage(placeholderImage), fit: BoxFit.cover)),
            //                             ),
            //                             fit: BoxFit.fill,
            //                           ),
            //                         ),
            //                         const SizedBox(
            //                           height: 5,
            //                         ),
            //                         Text(
            //                           "${driverList[index].carName.toString()} ${driverList[index].carMakes.toString()}",
            //                           style: const TextStyle(color: Colors.black, fontSize: 16, letterSpacing: 2, fontWeight: FontWeight.w600),
            //                         ),
            //                         const SizedBox(
            //                           height: 5,
            //                         ),
            //                         Row(
            //                           children: [
            //                             Expanded(
            //                               child: Row(
            //                                 children: [
            //                                   Icon(Icons.people, color: Colors.black.withOpacity(0.50), size: 16),
            //                                   const SizedBox(
            //                                     width: 5,
            //                                   ),
            //                                   Text(
            //                                     "${driverList[index].carInfo!.passenger.toString()} seater",
            //                                     style: TextStyle(color: Colors.black.withOpacity(0.50), letterSpacing: 2, fontWeight: FontWeight.w600),
            //                                   ),
            //                                   const SizedBox(
            //                                     width: 10,
            //                                   ),
            //                                   Icon(Icons.star, color: Colors.orange.withOpacity(0.80), size: 16),
            //                                   const SizedBox(
            //                                     width: 5,
            //                                   ),
            //                                   Text(
            //                                       driverList[index].reviewsCount != 0
            //                                           ? (driverList[index].reviewsSum / driverList[index].reviewsCount).toStringAsFixed(1)
            //                                           : 0.toString(),
            //                                       style: const TextStyle(
            //
            //                                         letterSpacing: 0.5,
            //                                       )),
            //                                 ],
            //                               ),
            //                             ),
            //                             Text(
            //                               symbol + "${driverList[index].carRate}",
            //                               style: TextStyle(color: Color(COLOR_PRIMARY), letterSpacing: 0.5, fontWeight: FontWeight.w900),
            //                             ),
            //                             Text(
            //                               "/day",
            //                               style: TextStyle(color: Colors.black.withOpacity(0.50), letterSpacing: 0.5, fontWeight: FontWeight.w600),
            //                             ),
            //                           ],
            //                         )
            //                       ],
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //             );
            //           },
            //         ),
            // )
          ],
        ),
      ),
    );
  }
}
