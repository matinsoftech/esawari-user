import 'package:cloud_firestore/cloud_firestore.dart';

class OfferModel {
  String? offerId;
  String? offerCode;
  String? descriptionOffer;
  String? discountOffer;
  String? discountTypeOffer;
  Timestamp? expireOfferDate;
  bool? isEnableOffer;
  String? imageOffer = "";
  String? storeId;
  String? parcelCategoryId;

  OfferModel({this.descriptionOffer, this.discountOffer, this.discountTypeOffer, this.expireOfferDate, this.imageOffer = "", this.isEnableOffer, this.offerCode, this.offerId, this.storeId,this.parcelCategoryId});

  factory OfferModel.fromJson(Map<String, dynamic> parsedJson) {
    return OfferModel(
        descriptionOffer: parsedJson["description"],
        discountOffer: parsedJson["discount"],
        discountTypeOffer: parsedJson["discountType"],
        expireOfferDate: parsedJson["expiresAt"],
        imageOffer: parsedJson["image"] ?? ((parsedJson["photo"] ?? "")),
        isEnableOffer: parsedJson["isEnabled"],
        offerCode: parsedJson["code"],
        offerId: parsedJson["id"],
        storeId: parsedJson["vendorID"],
    parcelCategoryId: parsedJson["parcelCategoryId"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "description": descriptionOffer,
      "discount": discountOffer,
      "discountType": discountTypeOffer,
      "expiresAt": expireOfferDate,
      "image": imageOffer,
      "isEnabled": isEnableOffer,
      "code": offerCode,
      "id": offerId,
      "vendorID": storeId,
      "parcelCategoryId": parcelCategoryId
    };
  }
}
