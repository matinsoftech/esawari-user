import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emartconsumer/model/AddressModel.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/model/VendorModel.dart';
import 'package:emartconsumer/services/localDatabase.dart';

import 'TaxModel.dart';

class OrderModel {
  String authorID, payment_method;

  User author;

  User? driver;

  String? driverID;

  List<CartProduct> products;

  Timestamp createdAt;
  bool payment_shared = false;
  String vendorID;
  String? sectionId;

  VendorModel vendor;

  String status;

  AddressModel? address;

  String id;
  num? discount;
  String? couponCode;
  String? couponId, notes;

  // var extras = [];
  //String? extra_size;
  String? tipValue;
  String? adminCommission;
  String? adminCommissionType;
  final bool? takeAway;

  String? deliveryCharge;
  List<TaxModel>? taxModel;
  Map<String, dynamic>? specialDiscount;

  String courierCompanyName;
  String courierTrackingId;

  String? estimatedTimeToPrepare;
  Timestamp? scheduleTime;

  OrderModel({
    this.address,
    author,
    this.driver,
    this.driverID,
    this.authorID = '',
    this.payment_method = '',
    createdAt,
    this.id = '',
    this.products = const [],
    this.status = '',
    this.discount = 0,
    this.payment_shared = false,
    this.couponCode = '',
    this.couponId = '',
    this.notes = '',
    vendor,
    /*this.extras = const [], this.extra_size,*/ this.tipValue,
    this.adminCommission,
    this.takeAway = false,
    this.adminCommissionType,
    this.deliveryCharge,
    this.vendorID = '',
    this.sectionId = '',
    this.courierCompanyName = '',
    this.courierTrackingId = '',
    this.specialDiscount,
    this.estimatedTimeToPrepare,
    this.taxModel,
    this.scheduleTime,
  })  : author = author ?? User(),
        createdAt = createdAt ?? Timestamp.now(),
        vendor = vendor ?? VendorModel();

  factory OrderModel.fromJson(Map<String, dynamic> parsedJson) {
    List<CartProduct> products = parsedJson.containsKey('products')
        ? List<CartProduct>.from((parsedJson['products'] as List<dynamic>).map((e) => CartProduct.fromJson(e))).toList()
        : [].cast<CartProduct>();

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

    return OrderModel(
      address: parsedJson.containsKey('address') ? AddressModel.fromJson(parsedJson['address']) : AddressModel(),
      author: parsedJson.containsKey('author') ? User.fromJson(parsedJson['author']) : User(),
      authorID: parsedJson['authorID'] ?? '',
      createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
      id: parsedJson['id'] ?? '',
      products: products,
      status: parsedJson['status'] ?? '',
      discount: discountVal,
      couponCode: parsedJson['couponCode'] ?? '',
      couponId: parsedJson['couponId'] ?? '',
      notes: (parsedJson["notes"] != null && parsedJson["notes"].toString().isNotEmpty) ? parsedJson["notes"] : "",
      vendor: parsedJson.containsKey('vendor') ? VendorModel.fromJson(parsedJson['vendor']) : VendorModel(),
      vendorID: parsedJson['vendorID'] ?? '',
      sectionId: parsedJson['section_id'] ?? '',
      driver: parsedJson.containsKey('driver') ? User.fromJson(parsedJson['driver']) : null,
      driverID: parsedJson.containsKey('driverID') ? parsedJson['driverID'] : null,
      adminCommission: parsedJson["adminCommission"] ?? "",
      adminCommissionType: parsedJson["adminCommissionType"] ?? "",
      tipValue: parsedJson["tip_amount"] ?? "",
      takeAway: parsedJson["takeAway"] ?? false,
      payment_method: parsedJson['payment_method'] ?? '',
      payment_shared: parsedJson['payment_shared'] ?? true,
      // taxModel: (parsedJson.containsKey('taxSetting') && parsedJson['taxSetting'] != null) ? TaxModel.fromJson(parsedJson['taxSetting']) : null,
      //extras: parsedJson["extras"]!=null?parsedJson["extras"]:[],
      // extra_size: parsedJson["extras_price"]!=null?parsedJson["extras_price"]:"",
      deliveryCharge: parsedJson["deliveryCharge"],
      courierCompanyName: parsedJson["courierCompanyName"] ?? '',
      courierTrackingId: parsedJson["courierTrackingId"] ?? '',
      specialDiscount: parsedJson["specialDiscount"] ?? {},
      estimatedTimeToPrepare: parsedJson["estimatedTimeToPrepare"] ?? '',
      taxModel: taxList,
      scheduleTime: parsedJson["scheduleTime"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address == null ? null : this.address!.toJson(),
      'author': author.toJson(),
      'authorID': authorID,
      'payment_method': payment_method,
      'createdAt': createdAt,
      'id': id,
      'products': products.map((e) => e.toJson()).toList(),
      'status': status,
      'discount': discount,
      'couponCode': couponCode,
      'couponId': couponId,
      'notes': notes,
      'payment_shared': payment_shared,
      'vendor': vendor.toJson(),
      'vendorID': vendorID,
      'section_id': sectionId,
      'adminCommission': adminCommission,
      'adminCommissionType': adminCommissionType,
      "tip_amount": tipValue,
      "taxSetting": taxModel != null ? taxModel!.map((v) => v.toJson()).toList() : null,
      // "extras":this.extras,
      //"extras_price":this.extra_size,
      "takeAway": takeAway,
      "deliveryCharge": deliveryCharge,
      "specialDiscount": specialDiscount,
      "courierCompanyName": courierCompanyName,
      "courierTrackingId": courierTrackingId,
      "estimatedTimeToPrepare": this.estimatedTimeToPrepare,
      "scheduleTime": this.scheduleTime,
    };
  }
}
