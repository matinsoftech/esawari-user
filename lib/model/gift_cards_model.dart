import 'package:cloud_firestore/cloud_firestore.dart';

class GiftCardsModel {
  Timestamp? createdAt;
  String? image;
  String? expiryDay;
  String? id;
  String? message;
  String? title;
  bool? isEnable;

  GiftCardsModel({this.createdAt, this.image, this.expiryDay, this.id, this.message, this.title, this.isEnable});

  GiftCardsModel.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    image = json['image'];
    expiryDay = json['expiryDay'];
    id = json['id'];
    message = json['message'];
    title = json['title'];
    isEnable = json['isEnable'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdAt'] = this.createdAt;
    data['image'] = this.image;
    data['expiryDay'] = this.expiryDay;
    data['id'] = this.id;
    data['message'] = this.message;
    data['title'] = this.title;
    data['isEnable'] = this.isEnable;
    return data;
  }
}
