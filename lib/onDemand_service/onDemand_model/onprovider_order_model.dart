import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emartconsumer/model/AddressModel.dart';
import 'package:emartconsumer/model/TaxModel.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/onDemand_service/onDemand_model/provider_serivce_model.dart';

class OnProviderOrderModel {
  String authorID, payment_method;
  User author;
  Timestamp createdAt;
  String? sectionId;
  ProviderServiceModel provider;
  String status;
  AddressModel? address;
  String id;
  List<TaxModel>? taxModel;
  Timestamp? scheduleDateTime;
  Timestamp? newScheduleDateTime;
  Timestamp? startTime;
  Timestamp? endTime;
  String? notes;
  String? discount;
  String? discountType;
  String? discountLabel;
  String? couponCode;
  double quantity;
  String? reason;
  String? otp;
  String? adminCommission;
  String? adminCommissionType;
  String? extraCharges;
  String? extraChargesDescription;
  bool? paymentStatus;
  bool? extraPaymentStatus;
  String? workerId;


  OnProviderOrderModel({
    this.sectionId = '',
    this.authorID = '',
    this.payment_method = '',
    author,
    createdAt,
    provider,
    this.status = '',
    this.address,
    this.id = '',
    this.taxModel,
    scheduleDateTime,
    this.newScheduleDateTime,
    this.startTime,
    this.endTime,
    this.notes = '',
    this.discount ,
    this.discountType ,
    this.discountLabel ,
    this.couponCode,
    this.quantity = 0.0,
    this.reason,
    this.otp,
    this.adminCommission,
    this.adminCommissionType,
    this.extraCharges = '',
    this.extraChargesDescription = '',
    this.paymentStatus,
    this.extraPaymentStatus,
    this.workerId,
  })  : author = author ?? User(),
        createdAt = createdAt ?? Timestamp.now(),
        provider = provider ?? ProviderServiceModel(),
        scheduleDateTime = scheduleDateTime ?? Timestamp.now();

  factory OnProviderOrderModel.fromJson(Map<String, dynamic> parsedJson) {
    List<TaxModel>? taxList;
    if (parsedJson['taxSetting'] != null) {
      taxList = <TaxModel>[];
      parsedJson['taxSetting'].forEach((v) {
        taxList!.add(TaxModel.fromJson(v));
      });
    }
    return OnProviderOrderModel(
      author: parsedJson.containsKey('author') ? User.fromJson(parsedJson['author']) : User(),
      authorID: parsedJson['authorID'] ?? '',
      address: parsedJson.containsKey('address') ? AddressModel.fromJson(parsedJson['address']) : AddressModel(),
      createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
      id: parsedJson['id'] ?? '',
      payment_method: parsedJson['payment_method'] ?? '',
      taxModel: taxList,
      sectionId: parsedJson['sectionId'] ?? '',
      status: parsedJson['status'] ?? '',
      provider: parsedJson.containsKey('provider') ? ProviderServiceModel.fromJson(parsedJson['provider']) : ProviderServiceModel(),
      notes: parsedJson['notes'] ?? "",
      scheduleDateTime: parsedJson['scheduleDateTime'] ?? Timestamp.now(),
      newScheduleDateTime: parsedJson['newScheduleDateTime'],
      startTime: parsedJson['startTime'],
      endTime: parsedJson['endTime'],
      discount: parsedJson['discount'] ?? "0.0",
      discountLabel: parsedJson['discountLabel'] ?? "0.0",
      discountType: parsedJson['discountType'] ?? "",
      couponCode: parsedJson['couponCode'] ?? "",
      quantity: double.parse(parsedJson['quantity'].toString()) ?? 0.0,
      reason: parsedJson['reason'] ?? '',
      otp: parsedJson['otp'] ?? '',
      adminCommission: parsedJson['adminCommission'] ?? "",
      adminCommissionType: parsedJson['adminCommissionType'] ?? "",
      extraCharges: parsedJson["extraCharges"] ?? "0.0",
      paymentStatus: parsedJson['paymentStatus'],
      extraPaymentStatus: parsedJson['extraPaymentStatus'],
      workerId: parsedJson['workerId'] ?? "",
      extraChargesDescription: parsedJson['extraChargesDescription'] ?? "",
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
      'status': status,
      'provider': provider.toJson(),
      'sectionId': sectionId,
      "taxSetting": taxModel != null ? taxModel!.map((v) => v.toJson()).toList() : null,
      "scheduleDateTime": scheduleDateTime,
      "newScheduleDateTime": newScheduleDateTime,
      "startTime": startTime,
      "endTime": endTime,
      "notes": notes,
      'discount': discount,
      "discountLabel": discountLabel,
      "discountType": discountType,
      "couponCode": couponCode,
      'quantity': this.quantity,
      'reason': this.reason,
      'otp': this.otp,
      "adminCommission": adminCommission,
      "adminCommissionType": adminCommissionType,
      'extraCharges': extraCharges,
      'paymentStatus': paymentStatus,
      'extraPaymentStatus': extraPaymentStatus,
      'workerId': workerId,
      'extraChargesDescription': extraChargesDescription,
    };
  }
}
