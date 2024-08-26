
class SubCategoryModel {
  String? id;
  String? title;
  String? categoryId;
  bool? publish;

  SubCategoryModel({
    this.id,
    this.title,
    this.categoryId,
    this.publish,
  });

  SubCategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    title = json['title'] ?? '';
    categoryId = json['categoryId'] ?? '';
    publish = json['publish'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['categoryId'] = categoryId;
    data['publish'] = publish;
    return data;
  }
}

