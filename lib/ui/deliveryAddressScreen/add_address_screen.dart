import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/AddressModel.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:uuid/uuid.dart';

class AddAddressScreen extends StatefulWidget {
  final int? index;
  const AddAddressScreen({super.key, this.index});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  TextEditingController address = TextEditingController();
  TextEditingController landmark = TextEditingController();
  TextEditingController locality = TextEditingController();
  List saveAsList = ['Home', 'Work', 'Hotel', 'other'];
  String selectedSaveAs = "Home";

  UserLocation? userLocation;
  AddressModel addressModel = AddressModel();

  List<AddressModel> shippingAddress = [];

  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  getData() {
    if (MyAppState.currentUser != null) {
      if (MyAppState.currentUser!.shippingAddress != null) {
        shippingAddress = MyAppState.currentUser!.shippingAddress!;
      }
    }
    if (widget.index != null) {
      addressModel = shippingAddress[widget.index!];
      address.text = addressModel.address.toString();
      landmark.text = addressModel.landmark.toString();
      locality.text = addressModel.locality.toString();
      selectedSaveAs = addressModel.addressAs.toString();
      userLocation = addressModel.location;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Add Address'.tr(),
          style: TextStyle(fontFamily: "Poppinsm", color: isDarkMode(context) ? Colors.white : Colors.black),
        ).tr(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Card(
                elevation: 0.5,
                color: isDarkMode(context) ? Color(DARK_BG_COLOR) : Color(0XFFFFFFFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlacePicker(
                                apiKey: GOOGLE_API_KEY,
                                onPlacePicked: (result) {
                                  locality.text = result.formattedAddress!.toString();
                                  userLocation = UserLocation(latitude: result.geometry!.location.lat, longitude: result.geometry!.location.lng);
                                  log(result.toString());

                                  Navigator.of(context).pop();
                                },
                                initialPosition: LatLng(-33.8567844, 151.213108),
                                useCurrentLocation: true,
                                selectInitialPosition: true,
                                usePinPointingSearch: true,
                                usePlaceDetailSearch: true,
                                zoomGesturesEnabled: true,
                                zoomControlsEnabled: true,
                                initialMapType: MapType.terrain,
                                resizeToAvoidBottomInset: false, // only works in page mode, less flickery, remove if wrong offsets
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(Icons.location_searching_sharp, color: Color(COLOR_PRIMARY)),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Choose location *",
                                style: TextStyle(color: Color(COLOR_PRIMARY), fontFamily: "Poppinsm", fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 0.5,
                color: isDarkMode(context) ? Color(DARK_BG_COLOR) : Color(0XFFFFFFFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Save address as *",
                          style: TextStyle(fontFamily: "Poppinsm", fontSize: 14),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 34,
                        child: ListView.builder(
                          itemCount: saveAsList.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedSaveAs = saveAsList[index].toString();
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: selectedSaveAs == saveAsList[index].toString()
                                          ? Color(COLOR_PRIMARY)
                                          : isDarkMode(context)
                                              ? Colors.black
                                              : Colors.grey.withOpacity(0.20),
                                      borderRadius: const BorderRadius.all(Radius.circular(20))),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 30),
                                    child: Center(
                                      child: Text(
                                        saveAsList[index].toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: selectedSaveAs == saveAsList[index].toString()
                                              ? Colors.white
                                              : isDarkMode(context)
                                                  ? Colors.white
                                                  : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        padding: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 10, top: 5),
                        child: TextFormField(
                            controller: address,
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.next,
                            validator: validateEmptyField,
                            // onSaved: (text) => line1 = text,
                            keyboardType: TextInputType.streetAddress,
                            cursorColor: Color(COLOR_PRIMARY),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              labelText: 'Flat / House / Flore / Building *'.tr(),
                              labelStyle: TextStyle(color: Color(0Xff696A75), fontSize: 17),
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                              ),
                            )),
                      ),
                      Container(
                        padding: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 10, top: 5),
                        child: TextFormField(
                            controller: locality,
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.next,
                            validator: validateEmptyField,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            cursorColor: Color(COLOR_PRIMARY),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                              labelText: 'Area / Sector / Locality *'.tr(),
                              labelStyle: TextStyle(color: Color(0Xff696A75), fontSize: 17),
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                              ),
                            )),
                      ),
                      Container(
                        padding: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 10, top: 5),
                        child: TextFormField(
                            controller: landmark,
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.next,
                            validator: validateEmptyField,
                            // onSaved: (text) => line1 = text,
                            keyboardType: TextInputType.streetAddress,
                            cursorColor: Color(COLOR_PRIMARY),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              labelText: 'Nearby Landmark (Optional)'.tr(),
                              labelStyle: TextStyle(color: Color(0Xff696A75), fontSize: 17),
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                          child: SizedBox(
                            width: 160,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(10),
                                backgroundColor: Color(COLOR_PRIMARY),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                if (userLocation == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                      "Please select Location",
                                    ),
                                    backgroundColor: Colors.red.shade400,
                                    duration: Duration(seconds: 1),
                                  ));
                                } else if (address.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                      "Please Enter Flat / House / Flore / Building",
                                    ),
                                    backgroundColor: Colors.red.shade400,
                                    duration: Duration(seconds: 1),
                                  ));
                                } else if (locality.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                      "Please Enter Area / Sector / locality",
                                    ),
                                    backgroundColor: Colors.red.shade400,
                                    duration: Duration(seconds: 1),
                                  ));
                                } else {
                                  if (widget.index != null) {
                                    addressModel.location = userLocation;
                                    addressModel.addressAs = selectedSaveAs;
                                    addressModel.locality = locality.text;
                                    addressModel.address = address.text;
                                    addressModel.landmark = landmark.text;

                                    shippingAddress.removeAt(widget.index!);
                                    shippingAddress.insert(widget.index!, addressModel);
                                  } else {
                                    addressModel.id = Uuid().v4();
                                    addressModel.location = userLocation;
                                    addressModel.addressAs = selectedSaveAs;
                                    addressModel.locality = locality.text;
                                    addressModel.address = address.text;
                                    addressModel.landmark = landmark.text;
                                    addressModel.isDefault = false;
                                    shippingAddress.add(addressModel);
                                  }
                                  setState(() {});

                                  print(MyAppState.currentUser!.userID);
                                  MyAppState.currentUser!.shippingAddress = shippingAddress;
                                  await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
                                  Navigator.pop(context, true);
                                }
                              },
                              child: Text(
                                'Save'.tr(),
                                style: TextStyle(color: isDarkMode(context) ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
