import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/BookTableModel.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/ui/dineInScreen/table_order_details_screen.dart';
import 'package:flutter/material.dart';

class HistoryTableBooking extends StatefulWidget {
  const HistoryTableBooking({Key? key}) : super(key: key);

  @override
  State<HistoryTableBooking> createState() => _HistoryTableBookingState();
}

class _HistoryTableBookingState extends State<HistoryTableBooking> {
  final fireStoreUtils = FireStoreUtils();
  Stream<List<BookTableModel>>? upcomingFuture, bookedFuture;

  @override
  void initState() {
    super.initState();
    bookedFuture = fireStoreUtils.getBookingOrders(MyAppState.currentUser!.userID, false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: StreamBuilder<List<BookTableModel>>(
          stream: bookedFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Container(
                child: Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                  ),
                ),
              );
            if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
              return Center(
                child: showEmptyState('No Previous Booking'.tr(), context),
              );
            } else {
              // ordersList = snapshot.data!;
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  BookTableModel bookTableModel = snapshot.data![index];

                  String bookStatus = '';
                  if (bookTableModel.status == ORDER_STATUS_PLACED) {
                    bookStatus = 'Expired'.tr();
                  } else if (bookTableModel.status == ORDER_STATUS_ACCEPTED) {
                    bookStatus = 'Confirmed'.tr();
                  } else if (bookTableModel.status == ORDER_STATUS_REJECTED) {
                    bookStatus = 'Rejected'.tr();
                  }
                  return InkWell(
                    onTap: () {
                      push(
                          context,
                          TableOrderDetailsScreen(
                            bookTableModel: bookTableModel,
                          ));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 5),
                      decoration: const BoxDecoration(
                        color: Color(0xffFFFFFF),
                        borderRadius: BorderRadius.all(
                          Radius.circular(15.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 0),
                            blurRadius: 1,
                            spreadRadius: 2,
                            color: Colors.black12,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    height: 70,
                                    width: 70,
                                    imageUrl: getImageVAlidUrl(bookTableModel.vendor.photo),
                                    imageBuilder: (context, imageProvider) => Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                      ),
                                    ),
                                    placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator.adaptive(
                                      valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                                    )),
                                    errorWidget: (context, url, error) => ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.network(
                                          placeholderImage,
                                          fit: BoxFit.cover,
                                        )),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        bookTableModel.vendor.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          bookTableModel.vendor.location,
                                          style: const TextStyle(
                                            color: Color(GREY_TEXT_COLOR),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          ListTile(
                            title: Text(
                              'Name'.tr(),
                              style: const TextStyle(color: Colors.black),
                            ),
                            leading: const Icon(Icons.person_outline, color: Colors.black),
                            minLeadingWidth: 10,
                            subtitle: Text(
                              '${bookTableModel.guestFirstName} ${bookTableModel.guestLastName}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Date'.tr(),
                              style: const TextStyle(color: Colors.black),
                            ),
                            leading: const Icon(Icons.date_range, color: Colors.black),
                            minLeadingWidth: 10,
                            subtitle: Text(
                              DateFormat("MMM dd, yyyy 'at' hh:mm a").format(bookTableModel.date.toDate()),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Guest'.tr(),
                              style: const TextStyle(color: Colors.black),
                            ),
                            leading: const Icon(Icons.group, color: Colors.black87),
                            minLeadingWidth: 10,
                            subtitle: Text('${bookTableModel.totalGuest}', style: const TextStyle(color: Colors.grey)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Center(
                                child: Text(
                              bookStatus,
                              style: const TextStyle(letterSpacing: 0.5, color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
                            )),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }),
    );
  }
}
