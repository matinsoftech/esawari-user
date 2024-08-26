import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/model/ParcelCategory.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/parcel_delivery/parcel_model/parcel_order_model.dart';
import 'package:emartconsumer/parcel_delivery/parcel_model/parcel_weight_model.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';

import 'cart_parcel_screen.dart';

class BookParcelScreen extends StatefulWidget {
  ParcelCategory? parcelCategory;

  BookParcelScreen({Key? key, this.parcelCategory}) : super(key: key);

  @override
  State<BookParcelScreen> createState() => _BookOrderScreenState();
}

class _BookOrderScreenState extends State<BookParcelScreen> {
  final GlobalKey<FormState> _key = GlobalKey();

  TextEditingController sNameController = TextEditingController();
  TextEditingController sAddressController = TextEditingController();
  TextEditingController sPhoneController = TextEditingController();
  TextEditingController parcelWeightController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  TextEditingController rNameController = TextEditingController();
  TextEditingController rAddressController = TextEditingController();
  TextEditingController rPhoneController = TextEditingController();

  UserLocation? senderLocation;
  UserLocation? receiverLocation;

  int selectedIndex = 0;

  String? senderAddress = "";
  String? receiverAddress = "";

  @override
  void initState() {
    getParcelWidget();
    getCurrentLocation();
    super.initState();
  }

  getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    senderLocation = UserLocation(latitude: position.latitude, longitude: position.longitude);
    receiverLocation = UserLocation(latitude: position.latitude, longitude: position.longitude);
    getAddressFromLatLong(position);
  }

  Future<void> getAddressFromLatLong(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    Placemark place = placemarks[0];
    setState(() {
      senderAddress = '${place.subLocality}, ${place.locality}';
      receiverAddress = '${place.subLocality}, ${place.locality}';
    });
  }

  List<ParcelWeightModel> parcelWeight = [];

  getParcelWidget() async {
    await FireStoreUtils().getParcelWeight().then((value) {
      if (value != null) {
        setState(() {
          parcelWeight = value;
        });
        print(parcelWeight.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back_ios,
                color: isDarkMode(context) ? Colors.white : Colors.black,
              )),
          centerTitle: true,
          title: Text("Book Order".tr())),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            Container(
              width: 330,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildCategory(icon: "assets/images/asSoonAs.png", title: "As soon as possible".tr(), index: 0),
                  buildCategory(icon: "assets/images/schedule.png", title: "Schedule".tr(), index: 1),
                ],
              ),
            ),
            Form(
                key: _key,
                child: Column(
                  children: [
                    buildSenderDetails(context),
                    buildReceiverDetails(),
                  ],
                )),
            parcelImageWidget(),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10),
              child: buildButton(title: "Continue".tr()),
            ),
          ],
        ),
      ),
    );
  }

  buildCategory({required String title, required String icon, required int index}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        //duration: const Duration(milliseconds: 250),
        width: 165,
        decoration: BoxDecoration(
          color: selectedIndex == index ? Color(COLOR_PRIMARY) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ImageIcon(AssetImage(icon), size: 25, color: selectedIndex == index ? Colors.white : Colors.grey.shade500),
              const SizedBox(
                height: 5,
              ),
              Text(
                title,
                style: TextStyle(
                  color: selectedIndex == index ? Colors.white : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildSenderDetails(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Color(COLOR_PRIMARY)),
                  child: const Padding(
                    padding: EdgeInsets.all(7.0),
                    child: Text(
                      "1",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Text(
                  "Sender’s Information".tr(),
                  style: TextStyle(fontSize: 16, color: Color(COLOR_PRIMARY)),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17.0, vertical: 10),
                child: Container(
                  color: isDarkMode(context) ? Colors.white : Colors.black,
                  height: selectedIndex == 0 ? 320 : 400,
                  width: 1,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Your Location'.tr(), style: const TextStyle(fontWeight: FontWeight.w400)),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  senderAddress.toString(),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ),
                          ElevatedButton(
                              child: Text(
                                "Change".tr(),
                              ),
                              style: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all<Color>(Color(COLOR_PRIMARY)),
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(8)), side: BorderSide(color: Color(COLOR_PRIMARY))))),
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlacePicker(
                                      apiKey: GOOGLE_API_KEY,
                                      onPlacePicked: (result) {
                                        senderAddress = result.formattedAddress!;
                                        senderLocation = UserLocation(latitude: result.geometry!.location.lat, longitude: result.geometry!.location.lng);
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
                              })
                        ],
                      ),
                      buildTextFormField(
                        color: Color(COLOR_PRIMARY),
                        title: "Sender's Address".tr(),
                        controller: sAddressController,
                      ),
                      buildTextFormField(
                        color: Color(COLOR_PRIMARY),
                        title: "Name".tr(),
                        controller: sNameController,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                        child: InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) => sPhoneController.text = number.phoneNumber.toString(),
                          ignoreBlank: true,
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          inputDecoration: InputDecoration(
                            hintText: 'Phone Number'.tr(),
                            isDense: true,
                          ),
                          inputBorder: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          selectorConfig: const SelectorConfig(selectorType: PhoneInputSelectorType.DIALOG),
                        ),
                      ),
                      Visibility(
                        visible: selectedIndex == 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "When to Pickup at this address",
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                              ).tr(),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => selectDate(context),
                                    child: Container(
                                      decoration: const BoxDecoration(),
                                      child: Text(
                                        senderData.isEmpty ? 'Select Date'.tr() : senderData.toString(),
                                        style: TextStyle(color: Color(COLOR_PRIMARY)),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => selectTime(context),
                                    child: Container(
                                      decoration: const BoxDecoration(),
                                      child: Text(
                                        senderTime.isEmpty ? 'Select Time'.tr() : senderTime.toString(),
                                        style: TextStyle(color: Color(COLOR_PRIMARY)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                decoration: const BoxDecoration(color: Colors.black38),
                                height: 1,
                              )
                            ],
                          ),
                        ),
                      ),
                      buildParcelDropDown(
                        title: "Select Parcel Weight".tr(),
                        color: Color(COLOR_PRIMARY),
                      ),
                      buildTextFormField(
                        textInputType: TextInputType.multiline,
                        color: Color(COLOR_PRIMARY),
                        title: "Note".tr(),
                        maxLine: 3,
                        controller: noteController,
                      ),
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  buildReceiverDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(COLOR_PRIMARY),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(7.0),
                    child: Text(
                      "2",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Text(
                  "Receiver’s Information".tr(),
                  style: TextStyle(fontSize: 16, color: Color(COLOR_PRIMARY)),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17.0, vertical: 10),
                child: Container(
                  color: isDarkMode(context) ? Colors.white : Colors.black,
                  height: selectedIndex == 0 ? 190 : 250,
                  width: 1,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0, right: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Your Location'.tr(), style: TextStyle(fontWeight: FontWeight.w400)),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  receiverAddress.toString(),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ),
                          ElevatedButton(
                              child: Text(
                                "Change".tr(),
                              ),
                              style: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all<Color>(Color(COLOR_PRIMARY)),
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(8)), side: BorderSide(color: Color(COLOR_PRIMARY))))),
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlacePicker(
                                      apiKey: GOOGLE_API_KEY,
                                      onPlacePicked: (result) {
                                        receiverAddress = result.formattedAddress!;
                                        receiverLocation = UserLocation(latitude: result.geometry!.location.lat, longitude: result.geometry!.location.lng);
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
                              })
                        ],
                      ),
                      buildTextFormField(
                        color: const Color(0xff576FDB),
                        title: "Receiver Location".tr(),
                        controller: rAddressController,
                      ),
                      buildTextFormField(
                        textInputType: TextInputType.name,
                        color: const Color(0xff576FDB),
                        title: "Name".tr(),
                        controller: rNameController,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                        child: InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) => rPhoneController.text = number.phoneNumber.toString(),
                          ignoreBlank: true,
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          inputDecoration: InputDecoration(
                            hintText: 'Phone Number'.tr(),
                            isDense: true,
                          ),
                          inputBorder: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          selectorConfig: const SelectorConfig(selectorType: PhoneInputSelectorType.DIALOG),
                        ),
                      ),
                      Visibility(
                        visible: selectedIndex == 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "When to arrive at this address".tr(),
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => selectDate(context, isPickUp: false),
                                    child: Container(
                                      decoration: const BoxDecoration(),
                                      child: Text(
                                        receiverDate.isEmpty ? 'Select Date'.tr() : receiverDate.toString(),
                                        style: TextStyle(color: Color(COLOR_PRIMARY)),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => selectTime(context, isPickUp: false),
                                    child: Container(
                                      decoration: const BoxDecoration(),
                                      child: Text(
                                        receiverTime.isEmpty ? 'Select Time'.tr() : receiverTime.toString(),
                                        style: TextStyle(color: Color(COLOR_PRIMARY)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Container(
                                  decoration: const BoxDecoration(color: Colors.black38),
                                  height: 1,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  buildTextFormField(
      {required String title,
      int maxLine = 1,
      TextInputType textInputType = TextInputType.text,
      required Color color,
      required TextEditingController controller,
      bool isIcons = false,
      Function()? onClick}) {
    return TextFormField(
      keyboardType: textInputType,
      minLines: 1,
      maxLines: maxLine,
      controller: controller,
      cursorColor: color,
      validator: validateEmptyField,
      decoration: InputDecoration(
          floatingLabelStyle: TextStyle(color: color),
          labelStyle: TextStyle(color: Colors.grey.shade500),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelText: title,
          hintText: title,
          suffixIcon: isIcons
              ? IconButton(
                  onPressed: onClick,
                  icon: const Icon(Icons.location_searching),
                )
              : null,
          hintStyle: TextStyle(color: Colors.grey.shade600),
          alignLabelWithHint: true,
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: color)),
          focusColor: color),
    );
  }

  parcelImageWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Color(COLOR_PRIMARY)),
                  child: const Padding(
                    padding: EdgeInsets.all(7.0),
                    child: Text(
                      "3",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Text(
                  "Upload Parcel Image".tr(),
                  style: TextStyle(fontSize: 16, color: Color(COLOR_PRIMARY)),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17.0, vertical: 10),
                child: Container(
                  color: isDarkMode(context) ? Colors.white : Colors.black,
                  height: selectedIndex == 0 ? 120 : 120,
                  width: 1,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SizedBox(
                    height: 100,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ListView.builder(
                            itemCount: images!.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              print(images![index].name);
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Container(
                                  width: 100,
                                  height: 100.0,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(fit: BoxFit.cover, image: FileImage(File(images![index].path))),
                                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          images!.removeAt(index);
                                        });
                                      },
                                      child: const Icon(
                                        Icons.remove_circle,
                                        size: 30,
                                      )),
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: InkWell(
                              onTap: () {
                                _onCameraClick();
                              },
                              child: Image.asset('assets/images/parcel_add_image.png', height: 100),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  ParcelWeightModel? selectedWeight;

  buildParcelDropDown({
    required String title,
    required Color color,
  }) {
    return DropdownButtonFormField<ParcelWeightModel>(
        decoration: InputDecoration(
          //floatingLabelStyle: TextStyle(color: color),
          labelStyle: TextStyle(color: Colors.grey.shade500),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelText: title,
          hintText: title,
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: color)),
        ),
        value: selectedWeight,
        validator: (value) => value == null ? 'field required'.tr() : null,
        items: parcelWeight.map((ParcelWeightModel item) {
          return DropdownMenuItem<ParcelWeightModel>(
            child: Text(item.title.toString()),
            value: item,
          );
        }).toList(),
        hint: Text("Select Weight".tr()),
        onChanged: (value) {
          setState(() {
            selectedWeight = value;
          });
        });
  }

  DateTime selectedDatePickUp = DateTime.now();
  String senderData = ""; //DateFormat('yyyy-MM-dd').format(DateTime.now());

  DateTime selectedDateDeliver = DateTime.now();
  String receiverDate = ""; //DateFormat('yyyy-MM-dd').format(DateTime.now());

  selectDate(BuildContext context, {bool isPickUp = true}) async {
    final DateTime? picked =
        await showDatePicker(context: context, initialDate: selectedDatePickUp, initialDatePickerMode: DatePickerMode.day, firstDate: selectedDatePickUp, lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        if (isPickUp) {
          selectedDatePickUp = picked;

          senderData = DateFormat('dd-MMMM-yyyy').format(selectedDatePickUp);
          print(senderData);
        } else {
          selectedDateDeliver = picked;

          receiverDate = DateFormat('dd-MMMM-yyyy ').format(selectedDateDeliver);
          print(receiverDate);
        }
      });
    }
  }

  TimeOfDay selectedTimePickUp = TimeOfDay.now();
  String senderTime = "";

  TimeOfDay selectedTimeDeliver = TimeOfDay.now();
  String receiverTime = "";

  selectTime(BuildContext context, {bool isPickUp = true}) async {
    final localizations = MaterialLocalizations.of(context);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTimePickUp,
    );
    if (picked != null) {
      setState(() {
        if (isPickUp) {
          selectedTimePickUp = picked;
          senderTime = localizations.formatTimeOfDay(selectedTimePickUp);
          print(senderTime);
        } else {
          selectedTimeDeliver = picked;
          receiverTime = localizations.formatTimeOfDay(selectedTimeDeliver);
          print(receiverTime);
        }
      });
    }
  }

  double? distance = 0.0;
  double? subTotal = 0.0;

  buildButton({title}) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: MaterialButton(
          height: 45,
          color: Color(COLOR_PRIMARY),
          onPressed: () async {
            print(senderLocation!.toJson());
            print(receiverLocation!.toJson());
            if (_key.currentState!.validate()) {
              if (selectedIndex == 1) {
                if (senderData.isEmpty || senderTime.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text(
                      "Select Sender date and time",
                    ).tr(),
                    backgroundColor: Colors.red.shade400,
                    duration: const Duration(seconds: 6),
                  ));
                } else if (receiverDate.isEmpty || receiverTime.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text(
                      "Select receiver date and time",
                    ).tr(),
                    backgroundColor: Colors.red.shade400,
                    duration: const Duration(seconds: 6),
                  ));
                } else {
                  _key.currentState!.save();
                  await getDurationDistance(LatLng(senderLocation!.latitude, senderLocation!.longitude), LatLng(receiverLocation!.latitude, receiverLocation!.longitude))
                      .then((durationValue) async {
                    print("----->${durationValue.toString()}");
                    if (durationValue != null) {
                      setState(() {
                        distance = durationValue['rows'].first['elements'].first['distance']['value'] / 1000.00;
                        subTotal = (distance! * double.parse(selectedWeight!.deliveryCharge.toString()));
                      });
                    }
                  });
                  bookParcelOrder();
                }
              } else {
                _key.currentState!.save();
                await getDurationDistance(LatLng(senderLocation!.latitude, senderLocation!.longitude), LatLng(receiverLocation!.latitude, receiverLocation!.longitude))
                    .then((durationValue) async {
                  print("----->${durationValue.toString()}");
                  if (durationValue != null) {
                    setState(() {
                      distance = durationValue['rows'].first['elements'].first['distance']['value'] / 1000.00;
                      subTotal = (distance! * double.parse(selectedWeight!.deliveryCharge.toString()));
                    });
                  }
                });
                bookParcelOrder();
              }
            }
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  bookParcelOrder() {
    if (distance! >= 1) {
      ParcelOrderModel createOrderModel = ParcelOrderModel(
          subTotal: subTotal.toString(),
          parcelType: widget.parcelCategory!.title,
          parcelCategoryID: widget.parcelCategory!.id,
          note: noteController.text,
          distance: distance.toString(),
          parcelWeight: selectedWeight!.title,
          parcelWeightCharge: selectedWeight!.deliveryCharge,
          sendToDriver: selectedIndex == 1 ? false : true,
          senderPickupDateTime:
              Timestamp.fromDate(DateTime(selectedDatePickUp.year, selectedDatePickUp.month, selectedDatePickUp.day, selectedTimePickUp.hour, selectedTimePickUp.minute)),
          receiverPickupDateTime:
              Timestamp.fromDate(DateTime(selectedDateDeliver.year, selectedDateDeliver.month, selectedDateDeliver.day, selectedTimeDeliver.hour, selectedTimeDeliver.minute)),
          isSchedule: selectedIndex == 1 ? true : false,
          sender: ParcelUserDetails(
            address: sAddressController.text,
            name: sNameController.text,
            phone: sPhoneController.text,
          ),
          receiver: ParcelUserDetails(
            address: rAddressController.text,
            name: rNameController.text,
            phone: rPhoneController.text,
          ),
          receiverLatLong: receiverLocation,
          senderLatLong: senderLocation,
          sectionId: sectionConstantModel!.id);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CartParcelScreen(
                    parcelOrder: createOrderModel,
                    images: images,
                  )));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
          "Sender's location to Receiver's location should be more than 1km.",
        ).tr(),
        backgroundColor: Colors.red.shade400,
        duration: const Duration(seconds: 6),
      ));
    }
  }

  Future<dynamic> getDurationDistance(LatLng departureLatLong, LatLng destinationLatLong) async {
    showProgress(context, 'Please wait...'.tr(), false);

    String url = 'https://maps.googleapis.com/maps/api/distancematrix/json';
    http.Response restaurantToCustomerTime = await http.get(Uri.parse('$url?units=metric&origins=${departureLatLong.latitude},'
        '${departureLatLong.longitude}&destinations=${destinationLatLong.latitude},${destinationLatLong.longitude}&key=$GOOGLE_API_KEY'));

    var decodedResponse = jsonDecode(restaurantToCustomerTime.body);

    print(decodedResponse);
    if (decodedResponse['status'] == 'OK' && decodedResponse['rows'].first['elements'].first['status'] == 'OK') {
      await hideProgress();
      return decodedResponse;
    }
    await hideProgress();
    return null;
  }

  List<XFile>? images = [];

  _onCameraClick() {
    final action = CupertinoActionSheet(
      message: const Text(
        'Add your parcel image.',
        style: TextStyle(fontSize: 15.0),
      ).tr(),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: const Text('Choose image from gallery').tr(),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            await ImagePicker().pickMultiImage().then((value) {
              value.forEach((element) {
                images!.add(element);
              });
            });
            setState(() {});
          },
        ),
        CupertinoActionSheetAction(
          child: const Text('Take a picture').tr(),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            final XFile? photo = await ImagePicker().pickImage(source: ImageSource.camera);
            if (photo != null) {
              setState(() async {
                images!.add(photo);
              });
            }
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text(
          'Cancel',
        ).tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }
}
