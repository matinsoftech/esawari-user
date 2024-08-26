import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/parcel_delivery/parcel_model/parcel_order_model.dart';
import 'package:emartconsumer/parcel_delivery/parcel_ui/parcel_review_screen.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/ui/chat_screen/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

import '../../constants.dart';
import 'parcel_order_detail_screen.dart';

class ParcelOrderTrackScreen extends StatefulWidget {
  final ParcelOrderModel orderModel;

  const ParcelOrderTrackScreen({Key? key, required this.orderModel})
      : super(key: key);

  @override
  State<ParcelOrderTrackScreen> createState() => _ParcelOrderTrackScreenState();
}

class _ParcelOrderTrackScreenState extends State<ParcelOrderTrackScreen> {
  final CameraPosition _kInitialPosition = const CameraPosition(
      target: LatLng(19.018255973653343, 72.84793849278007),
      zoom: 11.0,
      tilt: 0,
      bearing: 0);
  GoogleMapController? _controller;

  final Location currentLocation = Location();

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? taxiIcon;
  Map<PolylineId, Polyline> polyLines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  final Map<String, Marker> _markers = {};

  @override
  void initState() {
    // TODO: implement initState
    setIcons();
    getDriver();
    super.initState();
  }

  late Stream<ParcelOrderModel> ordersFuture;
  ParcelOrderModel? _cabOrderModel;

  bool isLoading = true;
  late Stream<User> driverStream;
  User? _driverModel;

  getDriver() async {
    setState(() {
      _cabOrderModel = widget.orderModel;
      isLoading = false;
    });
    getCurrentOrder();

    setState(() {});
  }

  getCurrentOrder() async {
    ordersFuture = FireStoreUtils().getParcelOrder(widget.orderModel.id);
    ordersFuture.listen((event) {
      print("------->${event.status}");
      _cabOrderModel = event;
      getDirections();
    });

    if (_cabOrderModel != null) {
      driverStream =
          FireStoreUtils().getDriver(widget.orderModel.driverID.toString());
      driverStream.listen((event) {
        setState(() => _driverModel = event);
        getDirections();
      });
    }
    setState(() {});
  }

  @override
  void dispose() {
    FireStoreUtils().parcelOrdersStreamController.close();
    FireStoreUtils().parcelOrdersStreamSub.cancel();

    FireStoreUtils().driverStreamController.close();
    FireStoreUtils().driverStreamSub.cancel();
    super.dispose();
  }

  setIcons() async {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(
              size: Size(10, 10),
            ),
            "assets/icons/pickup.png")
        .then((value) {
      departureIcon = value;
    });

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(
              size: Size(10, 10),
            ),
            "assets/icons/dropoff.png")
        .then((value) {
      destinationIcon = value;
    });

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(
              size: Size(10, 10),
            ),
            "assets/icons/ic_taxi.png")
        .then((value) {
      taxiIcon = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                GoogleMap(
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: true,
                  padding: const EdgeInsets.only(
                    top: 190.0,
                  ),
                  initialCameraPosition: _kInitialPosition,
                  onMapCreated: (GoogleMapController controller) async {
                    _controller = controller;
                    LocationData location = await currentLocation.getLocation();
                    _controller!.moveCamera(CameraUpdate.newLatLngZoom(
                        LatLng(location.latitude ?? 0.0,
                            location.longitude ?? 0.0),
                        14));
                  },
                  polylines: Set<Polyline>.of(polyLines.values),
                  myLocationEnabled: false,
                  markers: _markers.values.toSet(),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.04),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.black,
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 25),
                                child: Text(
                                  "Track My Order".tr(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: isDarkMode(context)
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _cabOrderModel!.driver == null || _driverModel == null
                          ? Container()
                          : Container(
                              decoration: BoxDecoration(
                                color: Color(COLOR_PRIMARY),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(22),
                                  topLeft: Radius.circular(22),
                                ),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              height: 50,
                                              width: 50,
                                              imageUrl: _driverModel!
                                                  .profilePictureURL,
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                      'assets/images/img_placeholder.png'),
                                              errorWidget: (context, url,
                                                      error) =>
                                                  Image.asset(
                                                      'assets/images/placeholder.png',
                                                      fit: BoxFit.cover),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _driverModel!.firstName +
                                                    " " +
                                                    _driverModel!.lastName,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              Text(
                                                "Your shipper".tr(),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14),
                                              ),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Icon(
                                                    Icons.star,
                                                    size: 20,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                      _driverModel!
                                                                  .reviewsCount !=
                                                              0
                                                          ? (_driverModel!
                                                                      .reviewsSum /
                                                                  _driverModel!
                                                                      .reviewsCount)
                                                              .toStringAsFixed(
                                                                  1)
                                                          : 0.toString(),
                                                      style: const TextStyle(
                                                        letterSpacing: 0.5,
                                                        color: Colors.white,
                                                      )),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                      '(${_driverModel!.reviewsCount.toStringAsFixed(1)})',
                                                      style: const TextStyle(
                                                        letterSpacing: 0.5,
                                                        color: Colors.white,
                                                      )),
                                                  const SizedBox(width: 5),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                        onTap: () {
                                          UrlLauncher.launch(
                                              "tel://${_cabOrderModel!.driver!.phoneNumber}");
                                        },
                                        child:
                                            const Icon(Icons.phone, size: 32)),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        await showProgress(
                                            context, "Please wait".tr(), false);

                                        User? customer =
                                            await FireStoreUtils.getCurrentUser(
                                                widget.orderModel.authorID);
                                        User? driver =
                                            await FireStoreUtils.getCurrentUser(
                                                widget.orderModel.driverID
                                                    .toString());

                                        hideProgress();
                                        push(
                                            context,
                                            ChatScreens(
                                              type: "cab_parcel_chat",
                                              customerName:
                                                  customer!.firstName +
                                                      " " +
                                                      customer.lastName,
                                              restaurantName:
                                                  driver!.firstName +
                                                      " " +
                                                      driver.lastName,
                                              orderId: widget.orderModel.id,
                                              restaurantId: driver.userID,
                                              customerId: customer.userID,
                                              customerProfileImage:
                                                  customer.profilePictureURL,
                                              restaurantProfileImage:
                                                  driver.profilePictureURL,
                                              token: driver.fcmToken,
                                              chatType: 'Driver',
                                            ));
                                      },
                                      child: const ImageIcon(
                                        AssetImage(
                                          "assets/images/chatIcon.png",
                                        ),
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    )
                                  ],
                                ),
                              ),
                            ),
                      Container(
                        color: isDarkMode(context)
                            ? const Color(DarkContainerColor)
                            : Colors.white,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            buildStatusLine(
                                address: widget.orderModel.sender!.address
                                    .toString(),
                                status: _cabOrderModel!.status ==
                                        ORDER_STATUS_REJECTED
                                    ? "Order Canceled"
                                    : "Ready to pickup"),
                            Visibility(
                                visible: _cabOrderModel!.status ==
                                        ORDER_STATUS_REJECTED
                                    ? false
                                    : true,
                                child: buildStatusLine(
                                    isLast: true,
                                    status: "Delivered Parcel".tr(),
                                    address: widget.orderModel.receiver!.address
                                        .toString(),
                                    image: _cabOrderModel!.status ==
                                            ORDER_STATUS_COMPLETED
                                        ? "assets/images/blue_circel_check.png"
                                        : "assets/images/circle.png")),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () async {
                                        push(
                                            context,
                                            ParcelOrderDetailScreen(
                                                orderModel: widget.orderModel));
                                      },
                                      style: ButtonStyle(
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Color(COLOR_PRIMARY)),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  side: BorderSide(
                                                      color: Color(
                                                          COLOR_PRIMARY))))),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          'View Order Info'.tr(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Visibility(
                                    visible: _cabOrderModel!.status ==
                                            ORDER_STATUS_COMPLETED
                                        ? true
                                        : false,
                                    child: Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          push(
                                              context,
                                              ParcelReviewScreen(
                                                  order: widget.orderModel));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(COLOR_PRIMARY),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          elevation: 15.0,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(
                                            'Add Review'.tr(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  buildStatusLine({
    String status = "Ready to pickup",
    String address = "Palace Estate Ave, South Vegas",
    image = "assets/images/blue_circel_check.png",
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: Image.asset(image),
                ),
              ),
              Text(
                status.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 2),
              child: Opacity(
                opacity: isLast ? 0 : 1,
                child: SizedBox(
                  width: 1.3,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          child: Container(
                            color: Colors.black38,
                            height: 2.5,
                          ),
                        );
                      }),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 5,
                ),
                Text(
                  address,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  getDirections() async {
    if (_cabOrderModel != null) {
      if (_cabOrderModel!.status != ORDER_STATUS_COMPLETED) {
        if (_cabOrderModel!.status == ORDER_STATUS_SHIPPED) {
          List<LatLng> polylineCoordinates = [];

          PolylineResult result =
              await polylinePoints.getRouteBetweenCoordinates(
            request: PolylineRequest(
              origin: PointLatLng(_driverModel!.location.latitude,
                  _driverModel!.location.longitude),
              destination: PointLatLng(_cabOrderModel!.senderLatLong!.latitude,
                  _cabOrderModel!.senderLatLong!.longitude),
              mode: TravelMode.driving,
            ),
          );

          print("----?${result.points}");
          if (result.points.isNotEmpty) {
            for (var point in result.points) {
              polylineCoordinates.add(LatLng(point.latitude, point.longitude));
            }
          }
          setState(() {
            _markers.remove("Driver");
            _markers['Driver'] = Marker(
                markerId: const MarkerId('Driver'),
                infoWindow: const InfoWindow(title: "Driver"),
                position: LatLng(_driverModel!.location.latitude,
                    _driverModel!.location.longitude),
                icon: taxiIcon!,
                rotation: double.parse(_driverModel!.rotation.toString()));
          });

          _markers.remove("Departure");
          _markers['Departure'] = Marker(
            markerId: const MarkerId('Departure'),
            infoWindow: const InfoWindow(title: "Departure"),
            position: LatLng(_cabOrderModel!.senderLatLong!.latitude,
                _cabOrderModel!.senderLatLong!.longitude),
            icon: departureIcon!,
          );

          _markers.remove("Destination");
          _markers['Destination'] = Marker(
            markerId: const MarkerId('Destination'),
            infoWindow: const InfoWindow(title: "Destination"),
            position: LatLng(_cabOrderModel!.receiverLatLong!.latitude,
                _cabOrderModel!.receiverLatLong!.longitude),
            icon: destinationIcon!,
          );
          addPolyLine(polylineCoordinates);
        } else if (_cabOrderModel!.status == ORDER_STATUS_IN_TRANSIT) {
          List<LatLng> polylineCoordinates = [];

          PolylineResult result =
              await polylinePoints.getRouteBetweenCoordinates(
            request: PolylineRequest(
              origin: PointLatLng(_driverModel!.location.latitude,
                  _driverModel!.location.longitude),
              destination: PointLatLng(
                  _cabOrderModel!.receiverLatLong!.latitude,
                  _cabOrderModel!.receiverLatLong!.longitude),
              mode: TravelMode.driving,
            ),
          );

          print("----?${result.points}");
          if (result.points.isNotEmpty) {
            for (var point in result.points) {
              polylineCoordinates.add(LatLng(point.latitude, point.longitude));
            }
          }
          setState(() {
            _markers.remove("Driver");
            _markers['Driver'] = Marker(
                markerId: const MarkerId('Driver'),
                infoWindow: const InfoWindow(title: "Driver"),
                position: LatLng(_driverModel!.location.latitude,
                    _driverModel!.location.longitude),
                icon: taxiIcon!,
                rotation: double.parse(_driverModel!.rotation.toString()));
          });
          _markers.remove("Departure");
          _markers['Departure'] = Marker(
            markerId: const MarkerId('Departure'),
            infoWindow: const InfoWindow(title: "Departure"),
            position: LatLng(_cabOrderModel!.senderLatLong!.latitude,
                _cabOrderModel!.senderLatLong!.longitude),
            icon: departureIcon!,
          );
          _markers.remove("Destination");
          _markers['Destination'] = Marker(
            markerId: const MarkerId('Destination'),
            infoWindow: const InfoWindow(title: "Destination"),
            position: LatLng(_cabOrderModel!.receiverLatLong!.latitude,
                _cabOrderModel!.receiverLatLong!.longitude),
            icon: destinationIcon!,
          );
          addPolyLine(polylineCoordinates);
        } else {
          List<LatLng> polylineCoordinates = [];

          PolylineResult result =
              await polylinePoints.getRouteBetweenCoordinates(
            request: PolylineRequest(
              origin: PointLatLng(_cabOrderModel!.senderLatLong!.latitude,
                  _cabOrderModel!.senderLatLong!.longitude),
              destination: PointLatLng(
                  _cabOrderModel!.receiverLatLong!.latitude,
                  _cabOrderModel!.receiverLatLong!.longitude),
              mode: TravelMode.driving,
            ),
          );

          if (result.points.isNotEmpty) {
            for (var point in result.points) {
              polylineCoordinates.add(LatLng(point.latitude, point.longitude));
            }
          }
          _markers.remove("Departure");
          _markers['Departure'] = Marker(
            markerId: const MarkerId('Departure'),
            infoWindow: const InfoWindow(title: "Departure"),
            position: LatLng(_cabOrderModel!.senderLatLong!.latitude,
                _cabOrderModel!.senderLatLong!.longitude),
            icon: departureIcon!,
          );
          _markers.remove("Destination");
          _markers['Destination'] = Marker(
            markerId: const MarkerId('Destination'),
            infoWindow: const InfoWindow(title: "Destination"),
            position: LatLng(_cabOrderModel!.receiverLatLong!.latitude,
                _cabOrderModel!.receiverLatLong!.longitude),
            icon: destinationIcon!,
          );
          addPolyLine(polylineCoordinates);
        }
      }
    }
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Color(COLOR_PRIMARY),
      points: polylineCoordinates,
      width: 4,
      geodesic: true,
    );
    polyLines[id] = polyline;
    updateCameraLocation(
        polylineCoordinates.first, polylineCoordinates.last, _controller);
    setState(() {});
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController? mapController,
  ) async {
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude &&
        source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(source.latitude, destination.longitude),
          northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destination.latitude, source.longitude),
          northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 100);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(
      CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }
}
