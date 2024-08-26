import 'package:emartconsumer/model/ItemAttributes.dart';
import 'package:emartconsumer/model/variant_info.dart';

class ProductModel {
  String categoryID;
  String brandID;
  String description;
  String id;
  String photo;
  List<dynamic> photos;
  String price;
  String name;
  String vendorID;
  String section_id;
  int quantity;
  bool publish;
  int calories;
  int grams;
  int proteins;
  int fats;
  bool veg;
  bool nonveg;
  String? disPrice = "0";
  bool takeaway;
  List<dynamic> addOnsTitle = [];
  List<dynamic> addOnsPrice = [];
  String? addon_name;
  String? addon_price;
  ItemAttributes? itemAttributes;
  Map<String, dynamic>? reviewAttributes;
  Map<String, dynamic> specification = {};
  num reviewsCount;
  num reviewsSum;
  VariantInfo? variant_info;
  bool? isDigitalProduct;
  String? digitalProduct;

  ProductModel({
    this.categoryID = '',
    this.brandID = '',
    this.description = '',
    this.id = '',
    this.photo = '',
    this.photos = const [],
    this.price = '',
    this.name = '',
    this.quantity = 0,
    this.vendorID = '',
    this.section_id = '',
    this.calories = 0,
    this.grams = 0,
    this.proteins = 0,
    this.fats = 0,
    this.publish = true,
    this.veg = false,
    this.nonveg = false,
    this.addon_name,
    this.addon_price,
    this.disPrice,
    this.takeaway = false,
    this.reviewsCount = 0,
    this.reviewsSum = 0,
    this.addOnsPrice = const [],
    this.addOnsTitle = const [],
    this.itemAttributes,
    this.variant_info,
    this.specification = const {},
    this.reviewAttributes,
    this.isDigitalProduct,
    this.digitalProduct,
    /*this.lstSizeCustom = const [],
        this.lstAddOnsCustom = const []*/
  });

  /*: this.geoFireData = geoFireData ??
            GeoFireData(
              geohash: "",
              geoPoint: GeoPoint(0.0, 0.0),
            );*/

  factory ProductModel.fromJson(Map<String, dynamic> parsedJson) {
    /*  List<AddSizeDemo> lstSizeCustom = parsedJson.containsKey('lstSizeCustom')
        ? List<AddSizeDemo>.from((parsedJson['lstSizeCustom'] as List<dynamic>)
        .map((e) => AddSizeDemo.fromJson(e))).toList()
        : [].cast<AddSizeDemo>();

    List<AddAddonsDemo> lstAddOnsCustom = parsedJson.containsKey('lstAddOnsCustom')
        ? List<AddAddonsDemo>.from((parsedJson['lstAddOnsCustom'] as List<dynamic>)
        .map((e) => AddAddonsDemo.fromJson(e))).toList()
        : [].cast<AddAddonsDemo>();*/

    return ProductModel(
      categoryID: parsedJson['categoryID'] ?? '',
      brandID: parsedJson['brandID'] ?? '',
      description: parsedJson['description'] ?? '',
      id: parsedJson['id'] ?? '',
      photo: parsedJson['photo'],
      photos: parsedJson['photos'] ?? [],
      price: parsedJson['price'] ?? '',
      quantity: parsedJson['quantity'] ?? 0,
      name: parsedJson['name'] ?? '',
      vendorID: parsedJson['vendorID'] ?? '',
      section_id: parsedJson['section_id'] ?? '',
      publish: parsedJson['publish'] ?? true,
      calories: parsedJson['calories'] ?? 0,
      grams: parsedJson['grams'] ?? 0,
      proteins: parsedJson['proteins'] ?? 0,
      fats: parsedJson['fats'] ?? 0,
      nonveg: parsedJson['nonveg'] ?? false,
      disPrice: parsedJson['disPrice'] ?? '0',
      specification: parsedJson['product_specification'] ?? {},
      takeaway: parsedJson['takeawayOption'] ?? false,
      addOnsPrice: parsedJson['addOnsPrice'] ?? [],
      addOnsTitle: parsedJson['addOnsTitle'] ?? [],
      reviewsCount: parsedJson['reviewsCount'] ?? 0,
      reviewsSum: parsedJson['reviewsSum'] ?? 0,
      variant_info: (parsedJson.containsKey('variant_info') && parsedJson['variant_info'] != null)
          ? parsedJson['variant_info'].runtimeType.toString() == '_InternalLinkedHashMap<String, dynamic>'
              ? VariantInfo.fromJson(parsedJson['variant_info'])
              : null
          : null,
      reviewAttributes: parsedJson['reviewAttributes'] ?? {},
      addon_name: parsedJson["addon_name"] ?? "",
      addon_price: parsedJson["addon_price"] ?? "",
      //lstSizeCustom: lstSizeCustom,//parse dJson['lstSizeCustom'] != null?parsedJson['lstSizeCustom']:<AddSizeDemo>[] ,
      //lstAddOnsCustom: lstAddOnsCustom,//parsedJson['lstAddOnsCustom']!=null?parsedJson['lstAddOnsCustom']:<AddAddonsDemo>[],
      veg: parsedJson['veg'] ?? false,
      itemAttributes: (parsedJson.containsKey('item_attribute') && parsedJson['item_attribute'] != null) ? ItemAttributes.fromJson(parsedJson['item_attribute']) : null,
      isDigitalProduct: parsedJson['isDigitalProduct'] ?? false,
      digitalProduct: parsedJson['digitalProduct'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    photos.toList().removeWhere((element) => element == null);
    return {
      'categoryID': categoryID,
      'brandID': brandID,
      'description': description,
      'id': id,
      'photo': photo,
      'photos': photos,
      'price': price,
      'name': name,
      'quantity': quantity,
      'vendorID': vendorID,
      'section_id': section_id,
      'publish': publish,
      'calories': calories,
      'grams': grams,
      'proteins': proteins,
      'fats': fats,
      'veg': veg,
      'nonveg': nonveg,
      'takeawayOption': takeaway,
      'disPrice': disPrice,
      "addOnsTitle": addOnsTitle,
      "addOnsPrice": addOnsPrice,
      "addon_name": addon_name,
      "addon_price": addon_price,
      'item_attribute': itemAttributes == null ? null : itemAttributes!.toJson(),
      'product_specification': specification,
      'reviewAttributes': reviewAttributes,
      'reviewsCount': reviewsCount,
      'reviewsSum': reviewsSum,
      'isDigitalProduct': isDigitalProduct,
      'digitalProduct': digitalProduct,
      //"lstAddOnsCustom":this.lstAddOnsCustom.map((e) => e.toJson()).toList(),
      //"lstSizeCustom":this.lstSizeCustom.map((e) => e.toJson()).toList()
    };
  }
}

class ReviewsAttribute {
  num? reviewsCount;
  num? reviewsSum;

  ReviewsAttribute({
    this.reviewsCount,
    this.reviewsSum,
  });

  ReviewsAttribute.fromJson(Map<String, dynamic> json) {
    reviewsCount = json['reviewsCount'] ?? 0;
    reviewsSum = json['reviewsSum'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reviewsCount'] = reviewsCount;
    data['reviewsSum'] = reviewsSum;
    return data;
  }
}
