import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderServiceModel {
  String? author;
  String? authorName;

  String? authorProfilePic;
  String? sectionId;
  String? subCategoryId;
  String? categoryId;
  Timestamp? createdAt;
  String? description;
  String? id;
  double? latitude;
  double? longitude;
  List<dynamic> photos;
  String? address;
  num? reviewsCount;
  num? reviewsSum;
  String? title;
  GeoFireData geoFireData;
  String? price;
  String? disPrice = "0";
  bool? publish;
  String? startTime;
  String? endTime;
  String? priceUnit;
  List<dynamic> days;
  String? phoneNumber;

  ProviderServiceModel({
    this.author = '',
    this.authorName = '',
    this.authorProfilePic = '',
    this.sectionId = '',
    this.subCategoryId = '',
    this.categoryId = '',
    this.createdAt,
    this.description = '',
    this.id = '',
    this.latitude = 0.1,
    this.longitude = 0.1,
    this.address = '',
    this.reviewsCount = 0,
    this.reviewsSum = 0,
    this.title = '',
    this.price = '',
    this.disPrice,
    geoFireData,
    DeliveryCharge,
    this.photos = const [],
    this.publish = true,
    this.startTime,
    this.endTime,
    this.priceUnit,
    this.days = const [],
    this.phoneNumber,
    //  this.fcmToken
  }) : this.geoFireData = geoFireData ??
            GeoFireData(
              geohash: "",
              geoPoint: GeoPoint(0.0, 0.0),
            );

  factory ProviderServiceModel.fromJson(Map<String, dynamic> parsedJson) {
    return ProviderServiceModel(
      author: parsedJson['author'] ?? '',
      authorName: parsedJson['authorName'] ?? '',

      authorProfilePic: parsedJson['authorProfilePic'] ?? '',
      sectionId: parsedJson['sectionId'] ?? '',
      categoryId: parsedJson['categoryId'] ?? '',
      subCategoryId: parsedJson['subCategoryId'] ?? '',
      price: parsedJson['price'] ?? '',
      disPrice: parsedJson['disPrice'] ?? '0',
      createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
      geoFireData: parsedJson.containsKey('g')
          ? GeoFireData.fromJson(parsedJson['g'])
          : GeoFireData(
              geohash: "",
              geoPoint: GeoPoint(0.0, 0.0),
            ),
      description: parsedJson['description'] ?? '',
      id: parsedJson['id'] ?? '',
      latitude: parsedJson['latitude'] ?? 0.1,
      longitude: parsedJson['longitude'] ?? 0.1,
      photos: parsedJson['photos'] ?? [],
      address: parsedJson['address'] ?? '',
      reviewsCount: parsedJson['reviewsCount'] ?? 0,
      reviewsSum: parsedJson['reviewsSum'] ?? 0,
      title: parsedJson['title'] ?? '',
      publish: parsedJson['publish'] ?? true,
      startTime: parsedJson['startTime'],
      endTime: parsedJson['endTime'],
      priceUnit: parsedJson['priceUnit'],
      days: parsedJson['days'] ?? [],
      phoneNumber: parsedJson['phoneNumber'],
      //  fcmToken: parsedJson['fcmToken'],
    );
  }

  Map<String, dynamic> toJson() {
    photos.toList().removeWhere((element) => element == null);
    Map<String, dynamic> json = {
      'author': author,
      'authorName': authorName,

      'sectionId': sectionId,
      'price': price,
      'disPrice': disPrice,
      'authorProfilePic': authorProfilePic,
      'subCategoryId': subCategoryId,
      'categoryId': categoryId,
      'createdAt': createdAt,
      "g": geoFireData.toJson(),
      'description': description,
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'photos': photos,
      'address': address,
      'reviewsCount': reviewsCount,
      'reviewsSum': reviewsSum,
      'title': title,
      'publish': publish,
      'startTime': startTime,
      'endTime': endTime,
      'priceUnit': priceUnit,
      'days': days,
      'phoneNumber': phoneNumber,
      //'fcmToken': fcmToken,
    };
    return json;
  }
}

class GeoFireData {
  String? geohash;
  GeoPoint? geoPoint;

  GeoFireData({this.geohash, this.geoPoint});

  factory GeoFireData.fromJson(Map<dynamic, dynamic> parsedJson) {
    return GeoFireData(
      geohash: parsedJson['geohash'] ?? '',
      geoPoint: parsedJson['geopoint'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'geohash': this.geohash,
      'geopoint': this.geoPoint,
    };
  }
}

class GeoPointClass {
  double latitude;

  double longitude;

  GeoPointClass({this.latitude = 0.01, this.longitude = 0.0});

  factory GeoPointClass.fromJson(Map<dynamic, dynamic> parsedJson) {
    return GeoPointClass(
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
