import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  String code;

  String desc;

  // List<dynamic> photos;

  String discount;

  String id;

  bool isEnable;

  Timestamp exipreAt;

  String discountType;

  CouponModel({this.discountType = '', this.id = '', this.code = '', this.desc = '', this.discount = '', this.isEnable = false, exipreAt}) : exipreAt = exipreAt ?? Timestamp.now();

  factory CouponModel.fromJson(Map<String, dynamic> parsedJson) {
    return CouponModel(
      id: parsedJson['id'] ?? '',
      code: parsedJson['code'] ?? '',
      desc: parsedJson['description'] ?? '',
      discount: parsedJson['discount'] ?? '',
      discountType: parsedJson['discountType'] ?? '',
      isEnable: parsedJson['isEnabled'] ?? false,
      exipreAt: parsedJson['expiresAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'description': desc, 'discount': discount, 'Id': id, 'discountType': discountType, 'isEnabled': isEnable, 'expiresAt': exipreAt};
  }
}
