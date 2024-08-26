class FavouriteModel {
  String? store_id;
  String? user_id;
  String? section_id;

  FavouriteModel({this.store_id, this.user_id, this.section_id});

  factory FavouriteModel.fromJson(Map<String, dynamic> parsedJson) {
    return FavouriteModel(store_id: parsedJson["store_id"] ?? "", user_id: parsedJson["user_id"] ?? "", section_id: parsedJson["section_id"] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {"store_id": store_id, "user_id": user_id, "section_id": section_id};
  }
}
