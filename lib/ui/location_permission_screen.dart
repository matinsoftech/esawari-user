import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/cab_service/dashboard_cab_service.dart';
import 'package:emartconsumer/ui/StoreSelection/StoreSelection.dart';
import 'package:flutter/material.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/AddressModel.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:uuid/uuid.dart';
import 'deliveryAddressScreen/DeliveryAddressScreen.dart';

class LocationPermissionScreen extends StatefulWidget {
  final User? user;
  const LocationPermissionScreen({
    this.user,
    Key? key,
  }) : super(key: key);

  @override
  _LocationPermissionScreenState createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Image.asset("assets/images/location_screen.png"),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 16, top: 32, right: 16, bottom: 8),
            child: Text(
              "Find Your Sawari near you",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold),
            ).tr(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "By allowing location access, you can search for sawari near you and receive more accurate services.",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ).tr(),
          ),
          //user current location
          Padding(
            padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    // side: BorderSide(
                    //   color: Color(COLOR_PRIMARY),
                    // ),
                  ),
                ),
                child: Text(
                  "Use current location",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ).tr(),
                onPressed: () {
                  checkPermission(() async {
                    await showProgress(context, "Please wait...".tr(), false);
                    AddressModel addressModel = AddressModel();
                    try {
                      await Geolocator.requestPermission();
                      Position newLocalData =
                          await Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.high);

                      await placemarkFromCoordinates(
                              newLocalData.latitude, newLocalData.longitude)
                          .then((valuePlaceMaker) {
                        Placemark placeMark = valuePlaceMaker[0];

                        setState(() {
                          addressModel.id = Uuid().v4();
                          addressModel.location = UserLocation(
                            latitude: newLocalData.latitude,
                            longitude: newLocalData.longitude,
                          );
                          String currentLocation =
                              "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.postalCode}, ${placeMark.country}";
                          addressModel.locality = currentLocation;
                        });
                      });
                      setState(() {});

                      MyAppState.selectedPosotion = addressModel;
                      await hideProgress();
                      // pushAndRemoveUntil(context, StoreSelection(), false);
                      if (widget.user != null) {
                        pushAndRemoveUntil(context,
                            DashBoardCabService(user: widget.user), false);
                      } else if (isSkipLogin) {
                        pushAndRemoveUntil(
                            context, DashBoardCabService(user: null), false);
                      }
                    } catch (exception) {
                      await placemarkFromCoordinates(19.228825, 72.854118)
                          .then((valuePlaceMaker) {
                        Placemark placeMark = valuePlaceMaker[0];
                        setState(() {
                          addressModel.id = Uuid().v4();
                          addressModel.location = UserLocation(
                              latitude: 19.228825, longitude: 72.854118);
                          String currentLocation =
                              "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.postalCode}, ${placeMark.country}";
                          addressModel.locality = currentLocation;
                        });
                      });

                      MyAppState.selectedPosotion = addressModel;
                      await hideProgress();
                      print(exception);
                      // pushAndRemoveUntil(context, StoreSelection(), false);
                    }
                  }, context);
                },
              ),
            ),
          ),
          //set from map
          Padding(
            padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    // side: BorderSide(
                    //   color: Color(COLOR_PRIMARY),
                    // ),
                  ),
                ),
                child: Text(
                  "Set from map",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ).tr(),
                onPressed: () async {
                  checkPermission(() async {
                    await showProgress(context, "Please wait...".tr(), false);
                    AddressModel addressModel = AddressModel();
                    try {
                      await Geolocator.requestPermission();
                      await Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.high);
                      await hideProgress();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlacePicker(
                            apiKey: GOOGLE_API_KEY,
                            onPlacePicked: (result) {
                              addressModel.locality =
                                  result.formattedAddress!.toString();
                              addressModel.location = UserLocation(
                                  latitude: result.geometry!.location.lat,
                                  longitude: result.geometry!.location.lng);
                              log(result.toString());
                              MyAppState.selectedPosotion = addressModel;
                              setState(() {});
                              // pushAndRemoveUntil(
                              //     context, StoreSelection(), false);
                              if (!isSkipLogin) {
                                pushAndRemoveUntil(
                                  context,
                                  DashBoardCabService(
                                    user: widget.user,
                                  ),
                                  false,
                                );
                              } else {
                                pushAndRemoveUntil(
                                  context,
                                  DashBoardCabService(
                                    user: null,
                                  ),
                                  false,
                                );
                              }
                            },
                            initialPosition: LatLng(-33.8567844, 151.213108),
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
                    } catch (e) {
                      await placemarkFromCoordinates(19.228825, 72.854118)
                          .then((valuePlaceMaker) {
                        Placemark placeMark = valuePlaceMaker[0];
                        setState(() {
                          addressModel.id = Uuid().v4();
                          addressModel.location = UserLocation(
                              latitude: 19.228825, longitude: 72.854118);
                          String currentLocation =
                              "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.postalCode}, ${placeMark.country}";
                          addressModel.locality = currentLocation;
                        });
                      });

                      MyAppState.selectedPosotion = addressModel;
                      await hideProgress();
                      // pushAndRemoveUntil(context, StoreSelection(), false);
                      if (!isSkipLogin) {
                        pushAndRemoveUntil(
                          context,
                          DashBoardCabService(
                            user: null,
                          ),
                          false,
                        );
                      } else {
                        pushAndRemoveUntil(
                          context,
                          DashBoardCabService(
                            user: MyAppState.currentUser,
                          ),
                          false,
                        );
                      }
                    }
                  }, context);
                },
              ),
            ),
          ),
          MyAppState.currentUser != null
              ? Padding(
                  padding:
                      const EdgeInsets.only(right: 40.0, left: 40.0, top: 10),
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: double.infinity),
                    child: TextButton(
                      child: Text(
                        "Enter Manually location",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ).tr(),
                      onPressed: () async {
                        await Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (context) => DeliveryAddressScreen()))
                            .then((value) {
                          if (value != null) {
                            AddressModel addressModel = value;
                            MyAppState.selectedPosotion = addressModel;
                            pushAndRemoveUntil(
                                context, StoreSelection(), false);
                          }
                        });
                      },
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.only(top: 12, bottom: 12),
                        ),
                        shape: WidgetStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
