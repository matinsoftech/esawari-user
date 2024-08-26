import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emartconsumer/model/User.dart';

class NotificationModel {
  Timestamp createdAt;

  String body;

  String id;

  String type;

  bool seen;

  String title;
  String toUserID;

  User toUser;

  Map<String, dynamic> metadata;

  NotificationModel({createdAt, this.body = '', this.id = '', this.type = '', this.seen = false, this.title = '', this.toUserID = '', toUser, this.metadata = const {}})
      : createdAt = createdAt ?? Timestamp.now(),
        toUser = toUser ?? User();

  factory NotificationModel.fromJson(Map<String, dynamic> parsedJson) {
    return NotificationModel(
        createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
        body: parsedJson['body'] ?? '',
        id: parsedJson['id'] ?? '',
        seen: parsedJson['seen'] ?? false,
        title: parsedJson['title'] ?? '',
        toUserID: parsedJson['toUserID'] ?? '',
        metadata: parsedJson['metadata'] ?? Map(),
        type: parsedJson['type'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'createdAt': createdAt, 'body': body, 'id': id, 'seen': seen, 'title': title, 'toUserID': toUserID, 'metadata': metadata, 'type': type};
  }
}
