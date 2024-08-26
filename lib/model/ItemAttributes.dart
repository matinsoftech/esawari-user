class ItemAttributes {
  List<Attributes>? attributes;
  List<Variants>? variants;

  ItemAttributes({this.attributes, this.variants});

  ItemAttributes.fromJson(Map<String, dynamic> json) {
    List<Attributes> attribute = json.containsKey('attributes') ? List<Attributes>.from((json['attributes'] as List<dynamic>).map((e) => Attributes.fromJson(e))).toList() : [].cast<Attributes>();

    List<Variants> variant = json.containsKey('variants') ? List<Variants>.from((json['variants'] as List<dynamic>).map((e) => Variants.fromJson(e))).toList() : [].cast<Variants>();

    attributes = attribute;
    variants = variant;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['attributes'] = attributes!.map((e) => e.toJson()).toList();
    data['variants'] = variants!.map((e) => e.toJson()).toList();
    return data;
  }
}

class Attributes {
  String? attributesId;
  List<dynamic>? attributeOptions;

  Attributes({this.attributesId, this.attributeOptions});

  Attributes.fromJson(Map<String, dynamic> json) {
    attributesId = json['attribute_id'];
    attributeOptions = json['attribute_options'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['attribute_id'] = attributesId;
    data['attribute_options'] = attributeOptions;
    return data;
  }
}

class Variants {
  String? variant_id;
  String? variant_image;
  String? variant_price;
  String? variant_quantity;
  String? variant_sku;

  Variants({this.variant_id, this.variant_image, this.variant_price, this.variant_quantity, this.variant_sku});

  Variants.fromJson(Map<String, dynamic> json) {
    variant_id = json['variant_id'];
    variant_image = json['variant_image'];
    variant_price = json['variant_price'] ?? '0';
    variant_quantity = json['variant_quantity'] ?? '0';
    variant_sku = json['variant_sku'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['variant_id'] = variant_id;
    data['variant_image'] = variant_image;
    data['variant_price'] = variant_price;
    data['variant_quantity'] = variant_quantity;
    data['variant_sku'] = variant_sku;
    return data;
  }
}
