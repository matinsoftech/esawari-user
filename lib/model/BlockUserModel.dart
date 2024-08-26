import 'package:cloud_firestore/cloud_firestore.dart';

class BlockUserModel {
  Timestamp createdAt;

  String dest;

  String source;

  String type;

  BlockUserModel({createdAt, this.dest = '', this.source = '', this.type = ''}) : createdAt = createdAt ?? Timestamp.now();

  factory BlockUserModel.fromJson(Map<String, dynamic> parsedJson) {
    return BlockUserModel(createdAt: parsedJson['createdAt'] ?? Timestamp.now(), dest: parsedJson['dest'] ?? '', source: parsedJson['source'] ?? '', type: parsedJson['type'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'createdAt': createdAt, 'dest': dest, 'source': source, 'type': type};
  }
}
