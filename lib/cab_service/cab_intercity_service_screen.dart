import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/cab_service/CabPaymentScreen.dart';
import 'package:emartconsumer/cab_service/cab_order_screen.dart';
import 'package:emartconsumer/cab_service/dashboard_cab_service.dart';
import 'package:emartconsumer/cab_service/intercity_payment_selection_screen.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/CabOrderModel.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/model/VehicleType.dart';
import 'package:emartconsumer/model/popular_destination.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/ui/auth/AuthScreen.dart';
import 'package:emartconsumer/ui/chat_screen/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart' as get_cord_address;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class CabInterCityServiceScreen extends StatefulWidget {
  const CabInterCityServiceScreen({Key? key}) : super(key: key);

  @override
  State<CabInterCityServiceScreen> createState() =>
      _CabInterCityServiceScreenState();
}

class _CabInterCityServiceScreenState extends State<CabInterCityServiceScreen> {
  final CameraPosition _kInitialPosition = const CameraPosition(
      target: LatLng(19.018255973653343, 72.84793849278007),
      zoom: 11.0,
      tilt: 0,
      bearing: 0);

  final TextEditingController departureController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

  GoogleMapController? _controller;
  final Location currentLocation = Location();

  final Map<String, Marker> _markers = {};

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? taxiIcon;

  LatLng? departureLatLong;
  LatLng? destinationLatLong;

  Map<PolylineId, Polyline> polyLines = {};
  PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
    setIcons();
    getVehicleType();
    getCurrentOrder();
    super.initState();
  }

  List<VehicleType> vehicleType = [];
  List<PopularDestination> popularDestination = [];

  bool isPopularDestinationLoading = true;

  getVehicleType() async {
    await FireStoreUtils.getVehicleType().then((value) {
      setState(() {
        vehicleType = value;
      });
    });

    await FireStoreUtils.getPopularDestination().then((value) {
      setState(() {
        popularDestination = value;
        isPopularDestinationLoading = false;
      });
    });

    print("---->${popularDestination.length}");
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
  void dispose() {
    FireStoreUtils().intercityOrdersStreamController.close();
    FireStoreUtils().intercityOrdersStreamSub.cancel();
    FireStoreUtils().driverStreamController.close();
    FireStoreUtils().driverStreamSub.cancel();
    _controller!.dispose();
    super.dispose();
  }

  String statusOfOrder = "";
  late Stream<CabOrderModel> ordersFuture;
  CabOrderModel? _cabOrderModel;

  late Stream<User> driverStream;
  User? _driverModel;

  getCurrentOrder() {
    if (MyAppState.currentUser != null) {
      if (MyAppState.currentUser!.inProgressOrderID != null) {
        ordersFuture = FireStoreUtils().getIntercityOrder(
            MyAppState.currentUser!.inProgressOrderID.toString());
        ordersFuture.listen((event) {
          print("------->${event.status}");
          print("------->${event.paymentMethod}");
          setState(() {
            _cabOrderModel = event;
            statusOfOrder = event.status;
          });
          if (_cabOrderModel!.driverID != null ||
              _cabOrderModel!.driverID!.isNotEmpty) {
            getDriverDetails();
          }
          setState(() {});
        });
      }
      getDirections();
      setState(() {});
    }
  }

  void getCurrentLocation(bool isDepartureSet) async {
    if (isDepartureSet) {
      LocationData location = await currentLocation.getLocation();
      List<get_cord_address.Placemark> placeMarks =
          await get_cord_address.placemarkFromCoordinates(
              location.latitude ?? 0.0, location.longitude ?? 0.0);

      final address = (placeMarks.first.subLocality!.isEmpty
              ? ''
              : "${placeMarks.first.subLocality}, ") +
          (placeMarks.first.street!.isEmpty
              ? ''
              : "${placeMarks.first.street}, ") +
          (placeMarks.first.name!.isEmpty ? '' : "${placeMarks.first.name}, ") +
          (placeMarks.first.subAdministrativeArea!.isEmpty
              ? ''
              : "${placeMarks.first.subAdministrativeArea}, ") +
          (placeMarks.first.administrativeArea!.isEmpty
              ? ''
              : "${placeMarks.first.administrativeArea}, ") +
          (placeMarks.first.country!.isEmpty
              ? ''
              : "${placeMarks.first.country}, ") +
          (placeMarks.first.postalCode!.isEmpty
              ? ''
              : "${placeMarks.first.postalCode}, ");
      departureController.text = address;
      setState(() {
        setDepartureMarker(
            LatLng(location.latitude ?? 0.0, location.longitude ?? 0.0));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Colors.black : null,
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.terrain,
            zoomControlsEnabled: true,
            myLocationButtonEnabled: true,
            padding: const EdgeInsets.only(
              top: 210.0,
            ),
            initialCameraPosition: _kInitialPosition,
            onMapCreated: (GoogleMapController controller) async {
              _controller = controller;
              // LocationData location = await currentLocation.getLocation();
              // _controller!.moveCamera(CameraUpdate.newLatLngZoom(LatLng(location.latitude ?? 0.0, location.longitude ?? 0.0), 14));
            },
            polylines: Set<Polyline>.of(polyLines.values),
            myLocationEnabled: true,
            markers: _markers.values.toSet(),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.04, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_sharp,
                      color: Colors.black,
                    ),
                  ),
                ),
                Visibility(
                  visible: MyAppState.currentUser == null
                      ? true
                      : MyAppState.currentUser!.inProgressOrderID == null ||
                              MyAppState.currentUser!.inProgressOrderID!.isEmpty
                          ? true
                          : false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: isDarkMode(context)
                              ? Colors.black87
                              : Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 10),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/icons/ic_pic_drop_location.png",
                              height: 85,
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PlacePicker(
                                                    apiKey: GOOGLE_API_KEY,
                                                    onPlacePicked: (result) {
                                                      setState(() {
                                                        departureController
                                                                .text =
                                                            result
                                                                .formattedAddress
                                                                .toString();
                                                        setDepartureMarker(
                                                            LatLng(
                                                                result
                                                                    .geometry!
                                                                    .location
                                                                    .lat,
                                                                result
                                                                    .geometry!
                                                                    .location
                                                                    .lng));
                                                      });

                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    initialPosition: LatLng(
                                                        -33.8567844,
                                                        151.213108),
                                                    useCurrentLocation: true,
                                                    initialMapType:
                                                        MapType.terrain,
                                                    selectInitialPosition: true,
                                                    usePinPointingSearch: true,
                                                    usePlaceDetailSearch: true,
                                                    zoomGesturesEnabled: true,
                                                    zoomControlsEnabled: true,
                                                    resizeToAvoidBottomInset:
                                                        false, // only works in page mode, less flickery, remove if wrong offsets
                                                  ),
                                                ),
                                              );
                                            },
                                            child: buildTextField(
                                              title: "Departure".tr(),
                                              textController:
                                                  departureController,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            getCurrentLocation(true);
                                          },
                                          autofocus: false,
                                          icon: Icon(
                                            Icons.my_location_outlined,
                                            size: 18,
                                            color: isDarkMode(context)
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(),
                                    InkWell(
                                      onTap: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PlacePicker(
                                              apiKey: GOOGLE_API_KEY,
                                              onPlacePicked: (result) {
                                                setState(() {
                                                  destinationController.text =
                                                      result.formattedAddress
                                                          .toString();
                                                  setDepartureMarker(LatLng(
                                                      result.geometry!.location
                                                          .lat,
                                                      result.geometry!.location
                                                          .lng));
                                                });

                                                Navigator.of(context).pop();
                                              },
                                              initialPosition: LatLng(
                                                  -33.8567844, 151.213108),
                                              useCurrentLocation: true,
                                              selectInitialPosition: true,
                                              usePinPointingSearch: true,
                                              usePlaceDetailSearch: true,
                                              zoomGesturesEnabled: true,
                                              zoomControlsEnabled: true,
                                              initialMapType: MapType.terrain,
                                              resizeToAvoidBottomInset:
                                                  false, // only works in page mode, less flickery, remove if wrong offsets
                                            ),
                                          ),
                                        );
                                      },
                                      child: buildTextField(
                                        title: "Where do you want to go ?".tr(),
                                        textController: destinationController,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child:
                statusOfOrder == ORDER_STATUS_PLACED ||
                        statusOfOrder == ORDER_STATUS_DRIVER_PENDING ||
                        statusOfOrder == ORDER_STATUS_DRIVER_REJECTED
                    ? waitingDialog()
                    : statusOfOrder == ORDER_STATUS_DRIVER_ACCEPTED ||
                            statusOfOrder == ORDER_STATUS_SHIPPED ||
                            statusOfOrder == ORDER_STATUS_IN_TRANSIT
                        ? driverDialog(_cabOrderModel)
                        : statusOfOrder == ORDER_REACHED_DESTINATION
                            ? completeRide()
                            : statusOfOrder == "conformation"
                                ? conformationButton()
                                : statusOfOrder == "vehicleType"
                                    ? vehicleSelection()
                                    : statusOfOrder == "tripOption"
                                        ? tripOptionSelection()
                                        : destinationLatLong == null
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: SizedBox(
                                                  height: 120,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color:
                                                            isDarkMode(context)
                                                                ? Colors.black87
                                                                : Colors.white),
                                                    child:
                                                        isPopularDestinationLoading
                                                            ? const Center(
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              )
                                                            : Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: ListView
                                                                    .builder(
                                                                  itemCount:
                                                                      popularDestination
                                                                          .length,
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        if (popularDestination[index].latitude !=
                                                                                null ||
                                                                            popularDestination[index].longitude !=
                                                                                null) {
                                                                          List<get_cord_address.Placemark>
                                                                              placeMarks =
                                                                              await get_cord_address.placemarkFromCoordinates(popularDestination[index].latitude ?? 0.0, popularDestination[index].longitude ?? 0.0);

                                                                          final address = (placeMarks.first.subLocality!.isEmpty ? '' : "${placeMarks.first.subLocality}, ") +
                                                                              (placeMarks.first.street!.isEmpty ? '' : "${placeMarks.first.street}, ") +
                                                                              (placeMarks.first.name!.isEmpty ? '' : "${placeMarks.first.name}, ") +
                                                                              (placeMarks.first.subAdministrativeArea!.isEmpty ? '' : "${placeMarks.first.subAdministrativeArea}, ") +
                                                                              (placeMarks.first.administrativeArea!.isEmpty ? '' : "${placeMarks.first.administrativeArea}, ") +
                                                                              (placeMarks.first.country!.isEmpty ? '' : "${placeMarks.first.country}, ") +
                                                                              (placeMarks.first.postalCode!.isEmpty ? '' : "${placeMarks.first.postalCode}, ");
                                                                          destinationController.text =
                                                                              address;

                                                                          setDestinationMarker(LatLng(
                                                                              popularDestination[index].latitude ?? 0.0,
                                                                              popularDestination[index].longitude ?? 0.0));
                                                                        }
                                                                      },
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          CachedNetworkImage(
                                                                            imageUrl:
                                                                                getImageVAlidUrl(popularDestination[index].image.toString()),
                                                                            height:
                                                                                80,
                                                                            width:
                                                                                80,
                                                                            imageBuilder: (context, imageProvider) =>
                                                                                Container(
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
                                                                                  placeholderImage,
                                                                                  fit: BoxFit.cover,
                                                                                  cacheHeight: 80,
                                                                                  cacheWidth: 80,
                                                                                )),
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Text(popularDestination[index]
                                                                              .title
                                                                              .toString()),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                  ),
                                                ),
                                              )
                                            : Container(),
          ),
        ],
      ),
    );
  }

  double distance = 0.0;
  String duration = "";

  VehicleType? selectedVehicleType;
  String selectedVehicleTypeName = "";

  conformationButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
      child: MaterialButton(
        onPressed: () async {
          await getDurationDistance(departureLatLong!, destinationLatLong!)
              .then((durationValue) async {
            print("----->${durationValue.toString()}");
            if (durationValue != null) {
              setState(() {
                distance = durationValue['rows']
                        .first['elements']
                        .first['distance']['value'] /
                    1000.00;
                duration = durationValue['rows']
                    .first['elements']
                    .first['duration']['text'];
                statusOfOrder = "vehicleType";
              });
            }
          });
        },
        height: 50,
        minWidth: MediaQuery.of(context).size.width,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: Color(COLOR_PRIMARY),
        child: Text(
          "Continue".tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ).tr(),
      ),
    );
  }

  vehicleSelection() {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode(context) ? Colors.black : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Select Your Vehicle Type".tr(),
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              itemCount: vehicleType.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedVehicleType = vehicleType[index];
                        selectedVehicleTypeName =
                            vehicleType[index].name.toString();
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: isDarkMode(context)
                                ? selectedVehicleTypeName ==
                                        vehicleType[index].name.toString()
                                    ? Colors.white
                                    : const Color(DarkContainerBorderColor)
                                : selectedVehicleTypeName ==
                                        vehicleType[index].name.toString()
                                    ? Colors.black
                                    : Colors.grey.shade100,
                            width: 1),
                        color: isDarkMode(context)
                            ? const Color(DarkContainerColor)
                            : Colors.white,
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl:
                                    vehicleType[index].vehicleIcon.toString(),
                                height: 60,
                                width: 60,
                                errorWidget: (context, url, error) => ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      placeholderImage,
                                      fit: BoxFit.cover,
                                      height: 60,
                                      width: 60,
                                    )),
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator.adaptive(
                                  valueColor: AlwaysStoppedAnimation(
                                      Color(COLOR_PRIMARY)),
                                )),
                                fit: BoxFit.cover,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vehicleType[index].name.toString() +
                                          " | " +
                                          distance.toStringAsFixed(
                                              currencyData!.decimal) +
                                          "km".tr(),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: Text(
                                        duration,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Text(
                              amountShow(
                                  amount:
                                      getAmount(vehicleType[index]).toString()),
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(
              height: 10,
            ),
            MaterialButton(
              onPressed: () async {
                if (selectedVehicleType!.name!.isNotEmpty) {
                  setState(() {
                    statusOfOrder = "tripOption";
                  });
                }
              },
              height: 50,
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              color: Color(COLOR_PRIMARY),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Book".tr() +
                        " ${selectedVehicleType == null ? "" : selectedVehicleType!.name}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    selectedVehicleType == null
                        ? amountShow(amount: "0.0")
                        : amountShow(
                            amount: getAmount(selectedVehicleType!).toString()),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String selectedTripOption = "One-way";

  final dateController = TextEditingController(
      text: DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()));
  final returnDateController = TextEditingController(
      text: DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()));

  DateTime selectedDateTime = DateTime.now();
  DateTime selectedReturnDateTime = DateTime.now();

  tripOptionSelection() {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode(context) ? Colors.white : Colors.black,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedTripOption = "One-way";
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: selectedTripOption == "One-way"
                            ? Border.all(color: Color(COLOR_PRIMARY))
                            : null,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            Text(
                              "One-way".tr(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text("Get dropped off".tr()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedTripOption = "Round trip";
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: selectedTripOption == "Round trip"
                            ? Border.all(color: Color(COLOR_PRIMARY))
                            : null,
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            Text(
                              "Round trip".tr(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text("Keep the car till return".tr()),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text("Leave on : ".tr()),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePickerDialog(
                        context: context,
                        initialDate: DateTime.now(),
                        minDate: DateTime.now(),
                        maxDate: DateTime(2090, 1, 1),
                      );
                      if (date != null) {
                        setState(() {
                          selectedDateTime = date;
                          dateController.text =
                              DateFormat('dd-MM-yyyy HH:mm').format(date);
                        });
                      }
                    },
                    child: TextFormField(
                      controller: dateController,
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.next,
                      validator: validateEmptyField,
                      keyboardType: TextInputType.streetAddress,
                      cursorColor: Color(COLOR_PRIMARY),
                      enabled: false,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        fillColor: Colors.white,
                        errorStyle: const TextStyle(color: Colors.red),
                        hintText: "Select Data".tr(),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: Color(COLOR_PRIMARY), width: 2.0)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: selectedTripOption == "Round trip" ? true : false,
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text("Return By : ".tr()),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePickerDialog(
                              context: context,
                              initialDate: DateTime.now(),
                              minDate: DateTime.now(),
                              maxDate: DateTime(2090, 1, 1),
                            );
                            if (date != null) {
                              setState(() {
                                selectedReturnDateTime = date;
                                returnDateController.text =
                                    DateFormat('dd-MM-yyyy HH:mm').format(date);
                              });
                            }
                          },
                          child: TextFormField(
                            controller: returnDateController,
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.next,
                            validator: validateEmptyField,
                            keyboardType: TextInputType.streetAddress,
                            cursorColor: Color(COLOR_PRIMARY),
                            enabled: false,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              fillColor: Colors.white,
                              errorStyle: const TextStyle(color: Colors.red),
                              hintText: "Select Data".tr(),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                      color: Color(COLOR_PRIMARY), width: 2.0)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            MaterialButton(
              onPressed: () async {
                if (MyAppState.currentUser == null) {
                  push(context, const AuthScreen());
                } else {
                  final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => InterCityPaymentSelectionScreen(
                              distance: distance.toString(),
                              duration: duration,
                              departureLatLong: departureLatLong,
                              destinationLatLong: destinationLatLong,
                              vehicleId: selectedVehicleType!.id,
                              vehicleType: selectedVehicleType,
                              departureName: departureController.text,
                              destinationName: destinationController.text,
                              roundTrip: selectedTripOption == "Round trip"
                                  ? true
                                  : false,
                              scheduleDateTime:
                                  Timestamp.fromDate(selectedDateTime),
                              scheduleReturnDateTime:
                                  Timestamp.fromDate(selectedReturnDateTime),
                              subTotal: getAmount(selectedVehicleType!)
                                  .toStringAsFixed(currencyData!.decimal))));
                  print("----->${result}");
                  if (result != null) {
                    getCurrentOrder();
                  }
                }
              },
              height: 50,
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              color: Color(COLOR_PRIMARY),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Book".tr() +
                        " ${selectedVehicleType == null ? "" : selectedVehicleType!.name}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    selectedVehicleType == null
                        ? amountShow(amount: "0.0")
                        : amountShow(
                            amount: getAmount(selectedVehicleType!).toString()),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double getAmount(VehicleType vehicleType) {
    double totalAmount = 0.0;
    if (distance <= vehicleType.minimum_delivery_charges_within_km!) {
      totalAmount =
          double.parse(vehicleType.minimum_delivery_charges.toString());
    } else {
      totalAmount = vehicleType.delivery_charges_per_km! * distance;
    }
    return totalAmount;
  }

  getDriverDetails() async {
    if (_cabOrderModel != null) {
      print("------->${_cabOrderModel!.driverID.toString()}");
      if (statusOfOrder == ORDER_STATUS_DRIVER_ACCEPTED) {
        await FireStoreUtils.sendRideBookEmail(orderModel: _cabOrderModel);
      }
      if (statusOfOrder == ORDER_STATUS_DRIVER_ACCEPTED ||
          statusOfOrder == ORDER_STATUS_SHIPPED ||
          statusOfOrder == ORDER_STATUS_IN_TRANSIT) {
        driverStream =
            FireStoreUtils().getDriver(_cabOrderModel!.driverID.toString());
        driverStream.listen((event) {
          setState(() {
            _driverModel = event;
          });
          getDirections();
        });

        await getDurationDistance(
                LatLng(_cabOrderModel!.sourceLocation.latitude,
                    _cabOrderModel!.sourceLocation.longitude),
                LatLng(_cabOrderModel!.destinationLocation.latitude,
                    _cabOrderModel!.destinationLocation.longitude))
            .then((durationValue) async {
          print("----->${durationValue.toString()}");
          if (durationValue != null) {
            setState(() {
              distance = durationValue['rows']
                      .first['elements']
                      .first['distance']['value'] /
                  1000.00;
              duration = durationValue['rows']
                  .first['elements']
                  .first['duration']['text'];
            });
          }
        });
      }
    }
  }

  driverDialog(CabOrderModel? cabOrderModel) {
    return Container(
      decoration: BoxDecoration(
        color: Color(COLOR_PRIMARY),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Image.asset(
                        "assets/images/car_icon.png",
                      )),
                ),
                Text(
                  "You will arrive at you destination in ".tr(),
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
                Text(
                  duration,
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 15),
                ),
              ],
            ),
          ),
          _driverModel == null
              ? const CircularProgressIndicator()
              : Container(
                  decoration: BoxDecoration(
                      color: isDarkMode(context)
                          ? const Color(DarkContainerColor)
                          : Colors.white,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(26),
                          topRight: Radius.circular(26))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 20),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "${cabOrderModel!.driver!.carNumber} \n${cabOrderModel.driver!.carMakes} ${cabOrderModel.driver!.carName}",
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600)),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: Text(
                                      "${cabOrderModel.driver!.firstName} ${cabOrderModel.driver!.lastName}",
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 20,
                                        color: Color(COLOR_PRIMARY),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                          _driverModel!.reviewsCount != 0
                                              ? (_driverModel!.reviewsSum /
                                                      _driverModel!
                                                          .reviewsCount)
                                                  .toStringAsFixed(1)
                                              : 0.toString(),
                                          style: const TextStyle(
                                            letterSpacing: 0.5,
                                            color: Color(0xff000000),
                                          )),
                                      const SizedBox(width: 3),
                                      Text(
                                          '(${cabOrderModel.driver!.reviewsCount.toStringAsFixed(1)})',
                                          style: const TextStyle(
                                            letterSpacing: 0.5,
                                            color: Color(0xff666666),
                                          )),
                                      const SizedBox(width: 5),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        cabOrderModel.driver!.profilePictureURL,
                                    height: 80.0,
                                    width: 80.0,
                                    placeholder: (context, url) => Center(
                                        child:
                                            CircularProgressIndicator.adaptive(
                                      valueColor: AlwaysStoppedAnimation(
                                          Color(COLOR_PRIMARY)),
                                    )),
                                    errorWidget: (context, url, error) =>
                                        ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              height: 80.0,
                                              width: 80.0,
                                              placeholderImage,
                                              fit: BoxFit.cover,
                                            )),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                cabOrderModel.otpCode!.isEmpty
                                    ? Container()
                                    : DottedBorder(
                                        borderType: BorderType.RRect,
                                        radius: const Radius.circular(2),
                                        color: const Color(COUPON_DASH_COLOR),
                                        strokeWidth: 2,
                                        dashPattern: const [5],
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 5),
                                          child: Text(
                                            cabOrderModel.otpCode.toString(),
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                        ))
                              ],
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: MaterialButton(
                                  onPressed: () async {
                                    if (cabOrderModel
                                        .driver!.phoneNumber.isNotEmpty) {
                                      UrlLauncher.launch(
                                          "tel://${cabOrderModel.driver!.phoneNumber}");
                                    } else {
                                      SnackBar snack = SnackBar(
                                        content: Text(
                                          "Driver Phone number is not available"
                                              .tr(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        duration: const Duration(seconds: 2),
                                        backgroundColor: Colors.black,
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snack);
                                    }
                                  },
                                  height: 42,
                                  elevation: 0.5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  color: Color(COLOR_PRIMARY),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.wifi_calling_3,
                                          color: Colors.white),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "Call".tr(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ).tr(),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: MaterialButton(
                                  onPressed: () async {
                                    await showProgress(
                                        context, "Please wait".tr(), false);

                                    User? customer =
                                        await FireStoreUtils.getCurrentUser(
                                            cabOrderModel.authorID);
                                    User? driver =
                                        await FireStoreUtils.getCurrentUser(
                                            cabOrderModel.driverID.toString());

                                    hideProgress();
                                    push(
                                        context,
                                        ChatScreens(
                                          type: "cab_parcel_chat",
                                          customerName: customer!.firstName +
                                              " " +
                                              customer.lastName,
                                          restaurantName: driver!.firstName +
                                              " " +
                                              driver.lastName,
                                          orderId: cabOrderModel.id,
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
                                  height: 42,
                                  elevation: 0.5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  color: Colors.red.withOpacity(0.50),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.message_sharp,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "Message".tr(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        MaterialButton(
                          onPressed: () async {
                            await showProgress(
                                context, "Please wait".tr(), false);

                            LocationData location =
                                await currentLocation.getLocation();

                            await FireStoreUtils()
                                .getSOS(_cabOrderModel!.id)
                                .then((value) async {
                              if (value == false) {
                                await FireStoreUtils()
                                    .setSos(
                                        _cabOrderModel!.id,
                                        UserLocation(
                                            latitude: location.latitude!,
                                            longitude: location.longitude!))
                                    .then((value) {
                                  hideProgress();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Builder(builder: (context) {
                                      return Text(
                                        "Your SOS request has been submitted to admin ",
                                      ).tr();
                                    }),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 3),
                                  ));
                                });
                              } else {
                                hideProgress();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Builder(builder: (context) {
                                    return const Text(
                                      "Your SOS request is already submitted",
                                    ).tr();
                                  }),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 3),
                                ));
                              }
                            });
                          },
                          height: 42,
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          color: Colors.red.withOpacity(0.50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.call,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "SOS".tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ).tr(),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  setDepartureMarker(LatLng departure) {
    setState(() {
      _markers.remove("Departure");
      _markers['Departure'] = Marker(
        markerId: const MarkerId('Departure'),
        infoWindow: const InfoWindow(title: "Departure"),
        position: departure,
        icon: departureIcon!,
      );
      departureLatLong = departure;
      _controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(departure.latitude, departure.longitude), zoom: 14)));

      // _controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(departure.latitude, departure.longitude), zoom: 18)));
      if (departureLatLong != null && destinationLatLong != null) {
        setState(() {
          statusOfOrder = "conformation";
        });
        getDirections();
      }
    });
  }

  waitingDialog() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl:
                    getImageVAlidUrl(_cabOrderModel!.author.profilePictureURL),
                height: 50,
                width: 50,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => Center(
                    child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                )),
                errorWidget: (context, url, error) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      placeholderImage,
                      fit: BoxFit.cover,
                      cacheHeight: 50,
                      cacheWidth: 50,
                    )),
                fit: BoxFit.cover,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  DateFormat('EEE, MMM dd, hh:mm aa')
                      .format(_cabOrderModel!.scheduleDateTime!.toDate()),
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
              ),
              InkWell(
                onTap: () {
                  pushAndRemoveUntil(
                      context,
                      DashBoardCabService(
                        user: MyAppState.currentUser!,
                        currentWidget: const CabOrderScreen(),
                        appBarTitle: 'Rides'.tr(),
                        drawerSelection: DrawerSelection.Orders,
                      ),
                      false);
                },
                child: Row(
                  children: [
                    Text(
                      'View Details'.tr(),
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 20,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  completeRide() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: MaterialButton(
              onPressed: () async {
                final result =
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CabPaymentScreen(
                              cabOrderModel: _cabOrderModel,
                            )));
                print("----------->${result.toString()}");
                if (result != null) {
                  statusOfOrder = "";
                  polyLines.clear();
                  _markers.clear();
                  departureController.clear();
                  destinationController.clear();
                  departureLatLong = null;
                  destinationLatLong = null;
                  setState(() {});
                }
              },
              height: 45,
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              color: Color(COLOR_PRIMARY),
              child: Text(
                "Complete Your Payment".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  setDestinationMarker(LatLng destination) {
    setState(() {
      _markers['Destination'] = Marker(
        markerId: const MarkerId('Destination'),
        infoWindow: const InfoWindow(title: "Destination"),
        position: destination,
        icon: destinationIcon!,
      );
      destinationLatLong = destination;

      if (departureLatLong != null && destinationLatLong != null) {
        setState(() {
          statusOfOrder = "conformation";
        });
        getDirections();
      }
    });
  }

  Widget buildTextField(
      {required title, required TextEditingController textController}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: TextField(
        controller: textController,
        style:
            TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: title,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabled: false,
        ),
      ),
    );
  }

  getDirections() async {
    print(statusOfOrder);
    if (statusOfOrder == ORDER_STATUS_DRIVER_ACCEPTED) {
      List<LatLng> polylineCoordinates = [];

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(_cabOrderModel!.sourceLocation.latitude,
              _cabOrderModel!.sourceLocation.longitude),
          destination: PointLatLng(_cabOrderModel!.destinationLocation.latitude,
              _cabOrderModel!.destinationLocation.longitude),
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
        position: LatLng(_cabOrderModel!.sourceLocation.latitude,
            _cabOrderModel!.sourceLocation.longitude),
        icon: departureIcon!,
      );
      _markers.remove("Destination");
      _markers['Destination'] = Marker(
        markerId: const MarkerId('Destination'),
        infoWindow: const InfoWindow(title: "Destination"),
        position: LatLng(_cabOrderModel!.destinationLocation.latitude,
            _cabOrderModel!.destinationLocation.longitude),
        icon: destinationIcon!,
      );
      addPolyLine(polylineCoordinates);
    } else if (statusOfOrder == ORDER_STATUS_SHIPPED) {
      List<LatLng> polylineCoordinates = [];

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          request: PolylineRequest(
              origin: PointLatLng(_driverModel!.location.latitude,
                  _driverModel!.location.longitude),
              destination: PointLatLng(_cabOrderModel!.sourceLocation.latitude,
                  _cabOrderModel!.sourceLocation.longitude),
              mode: TravelMode.driving));

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      }

      _markers.remove("Driver");
      _markers['Driver'] = Marker(
          markerId: const MarkerId('Driver'),
          infoWindow: const InfoWindow(title: "Driver"),
          position: LatLng(_driverModel!.location.latitude,
              _driverModel!.location.longitude),
          icon: taxiIcon!,
          rotation: double.parse(_driverModel!.rotation.toString()));

      _markers.remove("Departure");
      _markers['Departure'] = Marker(
        markerId: const MarkerId('Departure'),
        infoWindow: const InfoWindow(title: "Departure"),
        position: LatLng(_cabOrderModel!.sourceLocation.latitude,
            _cabOrderModel!.sourceLocation.longitude),
        icon: departureIcon!,
      );

      _markers.remove("Destination");
      _markers['Destination'] = Marker(
        markerId: const MarkerId('Destination'),
        infoWindow: const InfoWindow(title: "Destination"),
        position: LatLng(_cabOrderModel!.destinationLocation.latitude,
            _cabOrderModel!.destinationLocation.longitude),
        icon: destinationIcon!,
      );

      addPolyLine(polylineCoordinates);
    } else if (statusOfOrder == ORDER_STATUS_IN_TRANSIT ||
        statusOfOrder == ORDER_REACHED_DESTINATION) {
      List<LatLng> polylineCoordinates = [];

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(_driverModel!.location.latitude,
              _driverModel!.location.longitude),
          destination: PointLatLng(_cabOrderModel!.destinationLocation.latitude,
              _cabOrderModel!.destinationLocation.longitude),
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
        position: LatLng(_cabOrderModel!.sourceLocation.latitude,
            _cabOrderModel!.sourceLocation.longitude),
        icon: departureIcon!,
      );
      _markers.remove("Destination");
      _markers['Destination'] = Marker(
        markerId: const MarkerId('Destination'),
        infoWindow: const InfoWindow(title: "Destination"),
        position: LatLng(_cabOrderModel!.destinationLocation.latitude,
            _cabOrderModel!.destinationLocation.longitude),
        icon: destinationIcon!,
      );
      addPolyLine(polylineCoordinates);
    } else if (statusOfOrder == "conformation" ||
        statusOfOrder == "vehicleType") {
      List<LatLng> polylineCoordinates = [];
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(

          // travelMode: TravelMode.driving,
          request: PolylineRequest(
        origin: PointLatLng(
            departureLatLong!.latitude, departureLatLong!.longitude),
        destination: PointLatLng(
            destinationLatLong!.latitude, destinationLatLong!.longitude),
        mode: TravelMode.driving,
      ));

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      }
      addPolyLine(polylineCoordinates);
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

  Future<dynamic> getDurationDistance(
      LatLng departureLatLong, LatLng destinationLatLong) async {
    double originLat, originLong, destLat, destLong;
    originLat = departureLatLong.latitude;
    originLong = departureLatLong.longitude;
    destLat = destinationLatLong.latitude;
    destLong = destinationLatLong.longitude;

    String url = 'https://maps.googleapis.com/maps/api/distancematrix/json';
    http.Response restaurantToCustomerTime =
        await http.get(Uri.parse('$url?units=metric&origins=$originLat,'
            '$originLong&destinations=$destLat,$destLong&key=$GOOGLE_API_KEY'));

    var decodedResponse = jsonDecode(restaurantToCustomerTime.body);

    print(decodedResponse);
    if (decodedResponse['status'] == 'OK' &&
        decodedResponse['rows'].first['elements'].first['status'] == 'OK') {
      return decodedResponse;
    }
    return null;
  }
}
