import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emartconsumer/model/TaxModel.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/model/VehicleType.dart';

class CabOrderModel {
  String authorID;
  bool paymentStatus;
  User author;
  User? driver;
  String? driverID;
  String? otpCode;
  Timestamp createdAt;
  Timestamp? trigger_delevery;
  String status;
  String id;
  num? discount;
  String? couponCode;
  String? couponId;
  String? tipValue;
  String? adminCommission;
  String? adminCommissionType;
  String? tax;
  String? taxType;
  String? subTotal;
  String? paymentMethod;
  LocationDatas sourceLocation;
  LocationDatas destinationLocation;
  VehicleType? vehicleType;
  String? vehicleId;
  String? distance;
  String? duration;
  List<dynamic> rejectedByDrivers;
  String? sourceLocationName;
  String? destinationLocationName;

  String? sectionId;
  String? rideType;
  bool? roundTrip;
  Timestamp? scheduleDateTime;
  Timestamp? scheduleReturnDateTime;
  List<TaxModel>? taxModel;


  CabOrderModel(
      {author,
      this.driver,
      this.driverID,
      this.authorID = '',
      this.otpCode = '',
      this.paymentStatus = false,
      createdAt,
      trigger_delevery,
      sourceLocation,
      destinationLocation,
      scheduleDateTime,
      scheduleReturnDateTime,
      this.id = '',
      this.status = '',
      this.discount = 0,
      this.couponCode = '',
      this.couponId = '',
      this.tipValue,
      this.adminCommission,
      this.adminCommissionType,
      this.sourceLocationName,
      this.destinationLocationName,
      this.tax = '',
      this.subTotal = "0.0",
      this.paymentMethod,
      this.vehicleType,
      this.vehicleId,
      this.distance,
      this.duration,
      this.taxType = '',
      this.rideType = '',
      this.roundTrip ,
      this.sectionId ,
      this.taxModel,
      this.rejectedByDrivers = const []})
      : author = author ?? User(),
        sourceLocation = sourceLocation ?? LocationDatas(),
        trigger_delevery = trigger_delevery ?? Timestamp.now(),
        scheduleDateTime = scheduleDateTime ?? Timestamp.now(),
        scheduleReturnDateTime = scheduleReturnDateTime ?? Timestamp.now(),
        destinationLocation = destinationLocation ?? LocationDatas(),
        createdAt = createdAt ?? Timestamp.now();

  factory CabOrderModel.fromJson(Map<String, dynamic> parsedJson) {
    num discountVal = 0;
    if (parsedJson['discount'] == null) {
      discountVal = 0;
    } else if (parsedJson['discount'] is String) {
      discountVal = double.parse(parsedJson['discount']);
    } else {
      discountVal = parsedJson['discount'];
    }
    List<TaxModel>? taxList;
    if (parsedJson['taxSetting'] != null) {
      taxList = <TaxModel>[];
      parsedJson['taxSetting'].forEach((v) {
        taxList!.add(TaxModel.fromJson(v));
      });
    }

    return CabOrderModel(
      author: parsedJson.containsKey('author') ? User.fromJson(parsedJson['author']) : User(),
      authorID: parsedJson['authorID'] ?? '',
      createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
      trigger_delevery: parsedJson['trigger_delevery'] ?? Timestamp.now(),
      id: parsedJson['id'] ?? '',
      paymentStatus: parsedJson['paymentStatus'] ?? false,
      status: parsedJson['status'] ?? '',
      discount: discountVal,
      couponCode: parsedJson['couponCode'] ?? '',
      couponId: parsedJson['couponId'] ?? '',
      driver: parsedJson.containsKey('driver') ? User.fromJson(parsedJson['driver']) : null,
      driverID: parsedJson.containsKey('driverID') ? parsedJson['driverID'] : null,
      adminCommission: parsedJson["adminCommission"] ?? "",
      otpCode: parsedJson["otpCode"] ?? "",
      adminCommissionType: parsedJson["adminCommissionType"] ?? "",
      tipValue: parsedJson["tip_amount"] ?? "",
      tax: parsedJson['tax'] ?? '',
      taxType: parsedJson['taxType'] ?? '',
      subTotal: parsedJson['subTotal'] ?? '0.0',
      paymentMethod: parsedJson['paymentMethod'] ?? '',
      sourceLocationName: parsedJson['sourceLocationName'] ?? '',
      destinationLocationName: parsedJson['destinationLocationName'] ?? '',
      vehicleType: parsedJson.containsKey('vehicleType') ? VehicleType.fromJson(parsedJson['vehicleType']) : null,
      vehicleId: parsedJson['vehicleId'] ?? '',
      distance: parsedJson['distance'] ?? 0,
      duration: parsedJson['duration'] ?? '',
      rejectedByDrivers: parsedJson.containsKey('rejectedByDrivers') ? parsedJson['rejectedByDrivers'] : [].cast<String>(),
      sourceLocation: parsedJson.containsKey('sourceLocation') ? LocationDatas.fromJson(parsedJson['sourceLocation']) : LocationDatas(),
      destinationLocation: parsedJson.containsKey('destinationLocation') ? LocationDatas.fromJson(parsedJson['destinationLocation']) : LocationDatas(),

      sectionId: parsedJson['sectionId'] ??"",
      scheduleDateTime: parsedJson['scheduleDateTime'] ?? Timestamp.now(),
      scheduleReturnDateTime: parsedJson['scheduleReturnDateTime'] ?? Timestamp.now(),
      rideType: parsedJson['rideType'] ?? '',
      roundTrip: parsedJson['roundTrip'] ?? false,
      taxModel: taxList,

    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'author': author.toJson(),
      'authorID': authorID,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt,
      'id': id,
      'status': status,
      'discount': discount,
      'couponCode': couponCode,
      'couponId': couponId,
      'adminCommission': adminCommission,
      'adminCommissionType': adminCommissionType,
      "tip_amount": tipValue,
      "tax": tax,
      "taxType": taxType,
      "sourceLocation": sourceLocation.toJson(),
      "destinationLocation": destinationLocation.toJson(),
      "vehicleType": vehicleType!.toJson(),
      "vehicleId": vehicleId,
      "distance": distance,
      "distance": distance,
      "duration": duration,
      "subTotal": subTotal,
      "paymentMethod": paymentMethod,
      "otpCode": otpCode,
      "rejectedByDrivers": rejectedByDrivers,
      "trigger_delevery": trigger_delevery,
      "sourceLocationName": sourceLocationName,
      "destinationLocationName": destinationLocationName,
      "scheduleReturnDateTime": scheduleReturnDateTime,
      "scheduleDateTime": scheduleDateTime,
      "rideType": rideType,
      "roundTrip": roundTrip,
      "sectionId": sectionId,
      "taxSetting": taxModel != null ? taxModel!.map((v) => v.toJson()).toList() : null,
    };
    if (driver != null) {
      json.addAll({'driverID': driverID, 'driver': driver!.toJson()});
    }
    return json;
  }
}

class LocationDatas {
  double latitude;
  double longitude;

  LocationDatas({this.latitude = 0.01, this.longitude = 0.01});

  factory LocationDatas.fromJson(Map<dynamic, dynamic> parsedJson) {
    return LocationDatas(
      latitude: parsedJson['latitude'] ?? 00.1,
      longitude: parsedJson['longitude'] ?? 00.1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
