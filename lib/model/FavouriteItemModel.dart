class FavouriteItemModel {
  String? store_id;
  String? user_id;
  String? section_id;
  String? product_id;

  FavouriteItemModel({this.store_id, this.user_id, this.section_id, this.product_id});

  factory FavouriteItemModel.fromJson(Map<String, dynamic> parsedJson) {
    return FavouriteItemModel(store_id: parsedJson["store_id"] ?? "", user_id: parsedJson["user_id"] ?? "", section_id: parsedJson["section_id"] ?? "", product_id: parsedJson["product_id"] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {"store_id": store_id, "user_id": user_id, "section_id": section_id, "product_id": product_id};
  }
}
