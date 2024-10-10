import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/rental_service/model/rental_order_model.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'vehicle_type_screens.dart';

class RentalServiceHomeScreen extends StatefulWidget {
  final User? user;

  const RentalServiceHomeScreen({Key? key, this.user}) : super(key: key);

  @override
  State<RentalServiceHomeScreen> createState() => _RentalServiceHomeScreenState();
}

class _RentalServiceHomeScreenState extends State<RentalServiceHomeScreen> {
  final _formKey = GlobalKey<FormState>();

  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final pickupLocationController = TextEditingController();
  final dropLocationController = TextEditingController();

  UserLocation? pickUpLocation;
  UserLocation? dropLocation;

  DateTime? startDate = DateTime.now();
  DateTime? endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildBookWithDriver(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                margin: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
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
                child: SfDateRangePicker(
                  selectionMode: DateRangePickerSelectionMode.range,
                  view: DateRangePickerView.month,
                  onSelectionChanged: _onSelectionChanged,
                  minDate: DateTime.now(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Start Time".tr(),
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDarkMode(context) ? Colors.white : Colors.black.withOpacity(0.50)),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (startDate != null) {
                                        selectTime(context, isStart: true);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: const Text(
                                            "Please select Date",
                                          ).tr(),
                                          backgroundColor: Colors.green.shade400,
                                          duration: const Duration(seconds: 6),
                                        ));
                                      }
                                    },
                                    child: TextFormField(
                                      controller: startTimeController,
                                      textAlignVertical: TextAlignVertical.center,
                                      textInputAction: TextInputAction.next,
                                      validator: validateEmptyField,
                                      style: const TextStyle(fontSize: 18.0),
                                      keyboardType: TextInputType.streetAddress,
                                      cursorColor: Color(COLOR_PRIMARY),
                                      enabled: false,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                        fillColor: Colors.white,
                                        errorStyle: const TextStyle(color: Colors.red),
                                        hintText: "Start Time".tr(),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "End Time".tr(),
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDarkMode(context) ? Colors.white : Colors.black.withOpacity(0.50)),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (startDate != null) {
                                        selectTime(context, isStart: false);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text(
                                            "Please select Date".tr(),
                                          ),
                                          backgroundColor: Colors.green.shade400,
                                          duration: const Duration(seconds: 6),
                                        ));
                                      }
                                    },
                                    child: TextFormField(
                                      controller: endTimeController,
                                      textAlignVertical: TextAlignVertical.center,
                                      textInputAction: TextInputAction.next,
                                      validator: validateEmptyField,
                                      style: const TextStyle(fontSize: 18.0),
                                      keyboardType: TextInputType.streetAddress,
                                      cursorColor: Color(COLOR_PRIMARY),
                                      enabled: false,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                        fillColor: Colors.white,
                                        errorStyle: const TextStyle(color: Colors.red),
                                        hintText: "End Time".tr(),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pick up location".tr(),
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDarkMode(context) ? Colors.white : Colors.black.withOpacity(0.50)),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            InkWell(
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlacePicker(
                                      apiKey: GOOGLE_API_KEY,
                                      onPlacePicked: (result) {
                                        pickupLocationController.text = result.formattedAddress!;
                                        pickUpLocation = UserLocation(latitude: result.geometry!.location.lat, longitude: result.geometry!.location.lng);
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
                              child: TextFormField(
                                controller: pickupLocationController,
                                textAlignVertical: TextAlignVertical.center,
                                textInputAction: TextInputAction.next,
                                validator: validateEmptyField,
                                style: const TextStyle(fontSize: 18.0),
                                keyboardType: TextInputType.streetAddress,
                                enabled: false,
                                cursorColor: Color(COLOR_PRIMARY),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  fillColor: Colors.white,
                                  errorStyle: const TextStyle(color: Colors.red),
                                  hintText: "PickUp Location".tr(),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Drop off at same location".tr(),
                                style: const TextStyle(),
                              ),
                            ),
                            Transform.scale(
                              transformHitTests: false,
                              scale: 0.70,
                              child: CupertinoSwitch(
                                value: dropOfAtSameLocation,
                                onChanged: (bool isOn) {
                                  setState(() {
                                    dropOfAtSameLocation = isOn;
                                  });
                                },
                                activeColor: Color(COLOR_PRIMARY),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        dropOfAtSameLocation
                            ? Container()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Drop up location".tr(),
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.50)),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PlacePicker(
                                            apiKey: GOOGLE_API_KEY,
                                            onPlacePicked: (result) {
                                              dropLocationController.text = result.formattedAddress!;
                                              dropLocation = UserLocation(latitude: result.geometry!.location.lat, longitude: result.geometry!.location.lng);
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
                                    child: TextFormField(
                                      controller: dropLocationController,
                                      textAlignVertical: TextAlignVertical.center,
                                      textInputAction: TextInputAction.next,
                                      validator: !dropOfAtSameLocation ? validateEmptyField : null,
                                      style: const TextStyle(fontSize: 18.0),
                                      keyboardType: TextInputType.streetAddress,
                                      enabled: false,
                                      cursorColor: Color(COLOR_PRIMARY),
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                        fillColor: Colors.white,
                                        errorStyle: const TextStyle(color: Colors.red),
                                        hintText: "Drop Location".tr(),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.06,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Color(COLOR_PRIMARY), // foreground
                            ),
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                _formKey.currentState!.save();
                                RentalOrderModel rentalOrderModel = RentalOrderModel(
                                    authorID: MyAppState.currentUser!.userID,
                                    author: MyAppState.currentUser,
                                    pickupDateTime:
                                        Timestamp.fromDate(DateTime(startDate!.year, startDate!.month, startDate!.day, selectedTimeStart.hour, selectedTimeStart.minute)),
                                    dropDateTime: Timestamp.fromDate(DateTime(endDate!.year, endDate!.month, endDate!.day, selectedTimeEnd.hour, selectedTimeEnd.minute)),
                                    bookWithDriver: isDriverWant,
                                    pickupAddress: pickupLocationController.text.toString(),
                                    dropAddress: dropOfAtSameLocation ? pickupLocationController.text.toString() : dropLocationController.text.toString(),
                                    pickupLatLong: pickUpLocation,
                                    dropLatLong: dropOfAtSameLocation ? pickUpLocation : dropLocation,
                                    sectionId: sectionConstantModel!.id);

                                print(pickUpLocation!.toJson());
                                push(
                                    context,
                                    VehicleTypeScreen(
                                      rentalOrderModel: rentalOrderModel,
                                    ));
                              }
                            },
                            child: Text(
                              'Find Car'.tr().toUpperCase(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      startDate = args.value.startDate;
      endDate = args.value.endDate ?? args.value.startDate;
    });
  }

  bool isDriverWant = false;
  bool dropOfAtSameLocation = true;

  Widget buildBookWithDriver() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        margin: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Book With Driver".tr(),
                    style: const TextStyle(),
                  ),
                  Text("Don't have  a driver ? Book car with a Driver".tr(), style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Transform.scale(
              transformHitTests: false,
              scale: 0.70,
              child: CupertinoSwitch(
                value: isDriverWant,
                onChanged: (bool isOn) {
                  setState(() {
                    isDriverWant = isOn;
                  });
                },
                activeColor: Color(COLOR_PRIMARY),
              ),
            ),
          ],
        ));
  }

  TimeOfDay selectedTimeStart = TimeOfDay.now();
  TimeOfDay selectedTimeEnd = TimeOfDay.now();

  selectTime(BuildContext context, {bool isStart = true}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTimeStart,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          selectedTimeStart = picked;
          print(DateTime(startDate!.year, startDate!.month, startDate!.day, selectedTimeStart.hour, selectedTimeStart.minute));
          print(DateTime(endDate!.year, endDate!.month, endDate!.day, selectedTimeEnd.hour, selectedTimeEnd.minute));

          if (DateTime(startDate!.year, startDate!.month, startDate!.day, selectedTimeStart.hour, selectedTimeStart.minute).isAfter(DateTime.now())) {
            startTimeController.text = DateFormat('HH:mm').format(DateTime(startDate!.year, startDate!.month, startDate!.day, selectedTimeStart.hour, selectedTimeStart.minute));
          } else {
            showAlertDialog(context, "Alert".tr(), "Start time should be greater than current time", true);
          }
        } else {
          selectedTimeEnd = picked;
          print(DateTime(startDate!.year, startDate!.month, startDate!.day, selectedTimeStart.hour, selectedTimeStart.minute));
          print(DateTime(endDate!.year, endDate!.month, endDate!.day, selectedTimeEnd.hour, selectedTimeEnd.minute));

          if (DateTime(startDate!.year, startDate!.month, startDate!.day, selectedTimeStart.hour, selectedTimeStart.minute)
              .isBefore(DateTime(endDate!.year, endDate!.month, endDate!.day, selectedTimeEnd.hour, selectedTimeEnd.minute))) {
            endTimeController.text = DateFormat('HH:mm').format(DateTime(endDate!.year, endDate!.month, endDate!.day, selectedTimeEnd.hour, selectedTimeEnd.minute));
          } else {
            showAlertDialog(context, "Alert".tr(), "End time should be greater than start time".tr(), true);
          }
        }
      });
    }
  }
}
